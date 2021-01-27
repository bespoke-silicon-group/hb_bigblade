
module bsg_chip_io_links

import bsg_tag_pkg::*;

#(parameter link_width_p = -1
, parameter link_channel_width_p = -1
, parameter link_num_channels_p = -1
, parameter link_lg_fifo_depth_p = -1
, parameter link_lg_credit_to_token_decimation_p = -1
, parameter link_use_extra_data_bit_p = 0
)

( input  core_clk_i
, input  io_clk_i

, input bsg_tag_s  link_io_tag_lines_i
, input bsg_tag_s  link_core_tag_lines_i

, input  [link_num_channels_p-1:0]                           link_clk_i
, input  [link_num_channels_p-1:0]                           link_v_i
, input  [link_num_channels_p-1:0][link_channel_width_p-1:0] link_data_i
, output [link_num_channels_p-1:0]                           link_tkn_o

, output [link_num_channels_p-1:0]                           link_clk_o
, output [link_num_channels_p-1:0]                           link_v_o
, output [link_num_channels_p-1:0][link_channel_width_p-1:0] link_data_o
, input  [link_num_channels_p-1:0]                           link_tkn_i

, input  [link_width_p-1:0] core_data_i
, input                     core_valid_i
, output                    core_ready_o

, output [link_width_p-1:0] core_data_o
, output                    core_valid_o
, input                     core_yumi_i
);

  genvar i;

  typedef struct packed { 
      logic up_link_reset;
      logic down_link_reset;
      logic async_token_reset;
  } link_io_tag_payload_s;

  typedef struct packed { 
      logic up_link_reset;
      logic down_link_reset;
  } link_core_tag_payload_s;

  link_io_tag_payload_s   link_io_tag_data_lo;
  link_core_tag_payload_s link_core_tag_data_lo;

  bsg_tag_client #(.width_p( $bits(link_io_tag_data_lo) ), .default_p( 0 ))
    btc_link_io
      (.bsg_tag_i     ( link_io_tag_lines_i )
      ,.recv_clk_i    ( io_clk_i )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ()
      ,.recv_data_r_o ( link_io_tag_data_lo )
      );

  bsg_tag_client #(.width_p( $bits(link_core_tag_data_lo) ), .default_p( 0 ))
    btc_link_core
      (.bsg_tag_i     ( link_core_tag_lines_i )
      ,.recv_clk_i    ( core_clk_i )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ()
      ,.recv_data_r_o ( link_core_tag_data_lo )
      );

  // UPSTREAM LINK
  bsg_link_ddr_upstream #(.width_p( link_width_p )
                         ,.channel_width_p( link_channel_width_p )
                         ,.num_channels_p( link_num_channels_p )
                         ,.lg_fifo_depth_p( link_lg_fifo_depth_p )
                         ,.lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_p )
                         ,.use_extra_data_bit_p( link_use_extra_data_bit_p )
                         ,.use_encode_p(1)
                         )
    uplink
      (.core_clk_i        ( core_clk_i )
      ,.core_link_reset_i ( link_core_tag_data_lo.up_link_reset )

      ,.core_data_i  ( core_data_i )
      ,.core_valid_i ( core_valid_i )
      ,.core_ready_o ( core_ready_o )

      ,.io_clk_i            ( io_clk_i )
      ,.io_link_reset_i     ( link_io_tag_data_lo.up_link_reset )
      ,.async_token_reset_i ( link_io_tag_data_lo.async_token_reset )

      ,.io_clk_r_o   ( link_clk_o )
      ,.io_data_r_o  ( link_data_o )
      ,.io_valid_r_o ( link_v_o )
      ,.token_clk_i  ( link_tkn_i )
      );

  // DOWNSTREAM
  logic [link_num_channels_p-1:0] downlink_reset_lo;
  for (i = 0; i < link_num_channels_p; i++)
  begin: down_bss
    bsg_sync_sync #(.width_p( 1 ))
      downlink_io_reset_sync_sync
        (.oclk_i      ( link_clk_i[i] )
        ,.iclk_data_i ( link_io_tag_data_lo.down_link_reset )
        ,.oclk_data_o ( downlink_reset_lo[i] )
        );
  end

  bsg_link_ddr_downstream #(.width_p( link_width_p )
                           ,.channel_width_p( link_channel_width_p )
                           ,.num_channels_p( link_num_channels_p )
                           ,.lg_fifo_depth_p( link_lg_fifo_depth_p )
                           ,.lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_p )
                           ,.use_extra_data_bit_p( link_use_extra_data_bit_p )
                           ,.use_encode_p(0)
                           )
    downlink
      (.core_clk_i        ( core_clk_i )
      ,.core_link_reset_i ( link_core_tag_data_lo.down_link_reset )

      ,.io_link_reset_i ( downlink_reset_lo )

      ,.core_data_o  ( core_data_o )
      ,.core_valid_o ( core_valid_o )
      ,.core_yumi_i  ( core_yumi_i )

      ,.io_clk_i       ( link_clk_i )
      ,.io_data_i      ( link_data_i )
      ,.io_valid_i     ( link_v_i )
      ,.core_token_r_o ( link_tkn_o )
      );

endmodule