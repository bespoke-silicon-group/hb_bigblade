
module bsg_gateway_chip_io_links_ct_fifo

import bsg_tag_pkg::*;

#(parameter link_width_p = -1
, parameter link_channel_width_p = -1
, parameter link_num_channels_p = -1
, parameter link_lg_fifo_depth_p = -1
, parameter link_lg_credit_to_token_decimation_p = -1
, parameter link_use_extra_data_bit_p = 0

, parameter ct_bypass_p                = -1
, parameter ct_width_p                 = (ct_bypass_p == 1)? link_width_p : -1
, parameter ct_num_in_p                = (ct_bypass_p == 1)? 1            : -1
, parameter ct_remote_credits_p        = (ct_bypass_p == 1)? 0            : -1
, parameter ct_use_pseudo_large_fifo_p = (ct_bypass_p == 1)? 0            : -1
, parameter ct_lg_credit_decimation_p  = (ct_bypass_p == 1)? 0            : -1

, parameter bsg_ready_and_link_sif_width_lp = `bsg_ready_and_link_sif_width(ct_width_p)

// Inserts twofer fifos between the links_i/o and the channel tunnels. Used to
// pipeline long distances on the chip.
, parameter num_hops_p = 0
)

( input  core_clk_i
, input  io_clk_i

, input bsg_tag_s  link_io_tag_lines_i
, input bsg_tag_s  link_core_tag_lines_i
, input bsg_tag_s  ct_core_tag_lines_i

, input  [link_num_channels_p-1:0][1:0]                      link_clk_i
, input  [link_num_channels_p-1:0]                           link_v_i
, input  [link_num_channels_p-1:0][link_channel_width_p-1:0] link_data_i
, output [link_num_channels_p-1:0]                           link_tkn_o

, output [link_num_channels_p-1:0]                           link_clk_o
, output [link_num_channels_p-1:0]                           link_v_o
, output [link_num_channels_p-1:0][link_channel_width_p-1:0] link_data_o
, input  [link_num_channels_p-1:0]                           link_tkn_i

, input  [ct_num_in_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] links_i
, output [ct_num_in_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] links_o
);

  genvar i, h;

  typedef struct packed { 
      logic up_link_reset;
      logic down_link_reset;
      logic async_token_reset;
  } link_io_tag_payload_s;

  typedef struct packed { 
      logic up_link_reset;
      logic down_link_reset;
  } link_core_tag_payload_s;

  typedef struct packed { 
      logic ct_reset;
      logic fifo_reset;
  } ct_core_tag_payload_s;

  link_io_tag_payload_s   link_io_tag_data_lo;
  link_core_tag_payload_s link_core_tag_data_lo;
  ct_core_tag_payload_s   ct_core_tag_data_lo;

  logic                    link_v_lo;
  logic [link_width_p-1:0] link_data_lo;
  logic                    link_ready_lo;

  logic                    ct_multi_v_lo;
  logic [link_width_p-1:0] ct_multi_data_lo;
  logic                    ct_multi_yumi_lo;

  logic [ct_num_in_p-1:0]                 ct_fifo_valid_lo;
  logic [ct_num_in_p-1:0][ct_width_p-1:0] ct_fifo_data_lo;
  logic [ct_num_in_p-1:0]                 ct_fifo_yumi_li;

  logic [ct_num_in_p-1:0]                 ct_valid_lo;
  logic [ct_num_in_p-1:0][ct_width_p-1:0] ct_data_lo;
  logic [ct_num_in_p-1:0]                 ct_yumi_li;

  // declare the bsg_ready_and_link_sif_s struct
  `declare_bsg_ready_and_link_sif_s(ct_width_p, bsg_ready_and_link_sif_s);

  bsg_ready_and_link_sif_s [num_hops_p:0][ct_num_in_p-1:0] links_cast_li;
  assign links_cast_li[num_hops_p] = links_i;

  bsg_ready_and_link_sif_s [num_hops_p:0][ct_num_in_p-1:0] links_cast_lo;
  assign links_o = links_cast_lo[num_hops_p];

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

  bsg_tag_client #(.width_p( $bits(ct_core_tag_data_lo) ), .default_p( 0 ))
    btc_ct_core
      (.bsg_tag_i     ( ct_core_tag_lines_i )
      ,.recv_clk_i    ( core_clk_i )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ()
      ,.recv_data_r_o ( ct_core_tag_data_lo )
      );

  // UPSTREAM LINK
  bsg_link_ddr_upstream #(.width_p( link_width_p )
                         ,.channel_width_p( link_channel_width_p )
                         ,.num_channels_p( link_num_channels_p )
                         ,.lg_fifo_depth_p( link_lg_fifo_depth_p )
                         ,.lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_p )
                         ,.use_extra_data_bit_p( link_use_extra_data_bit_p )
                         ,.use_encode_p(0)
                         )
    uplink
      (.core_clk_i        ( core_clk_i )
      ,.core_link_reset_i ( link_core_tag_data_lo.up_link_reset )

      ,.core_data_i  ( ct_multi_data_lo )
      ,.core_valid_i ( ct_multi_v_lo )
      ,.core_ready_o ( link_ready_lo )

      ,.io_clk_i            ( io_clk_i )
      ,.io_link_reset_i     ( link_io_tag_data_lo.up_link_reset )
      ,.async_token_reset_i ( link_io_tag_data_lo.async_token_reset )

      ,.io_clk_r_o   ( link_clk_o )
      ,.io_data_r_o  ( link_data_o )
      ,.io_valid_r_o ( link_v_o )
      ,.token_clk_i  ( link_tkn_i )
      );

  // DOWNSTREAM
  logic [link_num_channels_p-1:0][1:0] downlink_reset_lo;
  for (i = 0; i < link_num_channels_p; i++)
  begin: down_bss
    for (h = 0; h < 2; h++)
      begin: dual
        bsg_sync_sync #(.width_p( 1 ))
          downlink_io_reset_sync_sync
            (.oclk_i      ( link_clk_i[i][h] )
            ,.iclk_data_i ( link_io_tag_data_lo.down_link_reset )
            ,.oclk_data_o ( downlink_reset_lo[i][h] )
            );
      end
  end

  bsg_link_ddr_downstream_encode #(.width_p( link_width_p )
                           ,.channel_width_p( link_channel_width_p )
                           ,.num_channels_p( link_num_channels_p )
                           ,.lg_fifo_depth_p( link_lg_fifo_depth_p )
                           ,.lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_p )
                           ,.use_extra_data_bit_p( link_use_extra_data_bit_p )
                           )
    downlink
      (.core_clk_i        ( core_clk_i )
      ,.core_link_reset_i ( link_core_tag_data_lo.down_link_reset )

      ,.io_link_reset_i ( downlink_reset_lo )

      ,.core_data_o  ( link_data_lo )
      ,.core_valid_o ( link_v_lo )
      ,.core_yumi_i  ( ct_multi_yumi_lo )

      ,.io_clk_i       ( link_clk_i )
      ,.io_data_i      ( link_data_i )
      ,.io_valid_i     ( link_v_i )
      ,.core_token_r_o ( link_tkn_o )
      );

  // CHANNEL TUNNEL
  if (ct_bypass_p == 1)
  begin
    assign ct_multi_v_lo = links_cast_li[0][0].v;
    assign ct_multi_data_lo = links_cast_li[0][0].data;
    assign links_cast_lo[0][0].ready_and_rev = link_ready_lo;

    assign links_cast_lo[0][0].v = link_v_lo;
    assign links_cast_lo[0][0].data = link_data_lo;
    assign ct_multi_yumi_lo = link_v_lo & links_cast_li[0][0].ready_and_rev;
  end
  else
  begin
    bsg_channel_tunnel #(.width_p( ct_width_p )
                        ,.num_in_p( ct_num_in_p )
                        ,.remote_credits_p( ct_remote_credits_p )
                        ,.use_pseudo_large_fifo_p( ct_use_pseudo_large_fifo_p )
                        ,.lg_credit_decimation_p( ct_lg_credit_decimation_p )
                        )
      tunnel
        (.clk_i   ( core_clk_i )
        ,.reset_i ( ct_core_tag_data_lo.ct_reset )
    
        ,.multi_v_i     ( link_v_lo )
        ,.multi_data_i  ( link_data_lo )
        ,.multi_yumi_o  ( ct_multi_yumi_lo )
    
        ,.multi_v_o    ( ct_multi_v_lo )
        ,.multi_data_o ( ct_multi_data_lo )
        ,.multi_yumi_i ( ct_multi_v_lo & link_ready_lo )
    
        ,.data_i ( ct_fifo_data_lo )
        ,.v_i    ( ct_fifo_valid_lo )
        ,.yumi_o ( ct_fifo_yumi_li )
    
        ,.data_o ( ct_data_lo )
        ,.v_o    ( ct_valid_lo )
        ,.yumi_i ( ct_yumi_li )
        );
    
    for (i = 0; i < ct_num_in_p; i++)
      begin: ct
    
        bsg_two_fifo #(.width_p( ct_width_p ))
          tunnel_fifo
            (.clk_i( core_clk_i )
            ,.reset_i ( ct_core_tag_data_lo.ct_reset )
    
            ,.v_o    ( ct_fifo_valid_lo[i] )
            ,.data_o ( ct_fifo_data_lo[i] )
            ,.yumi_i ( ct_fifo_yumi_li[i] )
    
            ,.ready_o ( links_cast_lo[0][i].ready_and_rev )
            ,.data_i  ( links_cast_li[0][i].data )
            ,.v_i     ( links_cast_li[0][i].v )
            );
    
        assign links_cast_lo[0][i].v = ct_valid_lo[i];
        assign links_cast_lo[0][i].data = ct_data_lo[i];
        assign ct_yumi_li[i] = ct_valid_lo[i] & links_cast_li[0][i].ready_and_rev;
    
      end: ct
  end

  for (i = 0; i < ct_num_in_p; i++)
    begin: r
      for (h = 0; h < num_hops_p; h++)
        begin: hop

          bsg_two_fifo #(.width_p( ct_width_p ))
            fifo_to_ct
              (.clk_i( core_clk_i )
              ,.reset_i ( ct_core_tag_data_lo.fifo_reset )

              ,.v_o     ( links_cast_li[h][i].v )
              ,.data_o  ( links_cast_li[h][i].data )
              ,.yumi_i  ( links_cast_lo[h][i].ready_and_rev & links_cast_li[h][i].v )

              ,.v_i     ( links_cast_li[h+1][i].v )
              ,.data_i  ( links_cast_li[h+1][i].data )
              ,.ready_o ( links_cast_lo[h+1][i].ready_and_rev )
              );

          bsg_two_fifo #(.width_p( ct_width_p ))
            fifo_to_rtr
              (.clk_i( core_clk_i )
              ,.reset_i ( ct_core_tag_data_lo.fifo_reset )

              ,.ready_o (links_cast_li[h][i].ready_and_rev)
              ,.data_i  (links_cast_lo[h][i].data)
              ,.v_i     (links_cast_lo[h][i].v)

              ,.v_o    (links_cast_lo[h+1][i].v)
              ,.data_o (links_cast_lo[h+1][i].data)
              ,.yumi_i (links_cast_li[h+1][i].ready_and_rev & links_cast_lo[h+1][i].v)
              );
          
        end: hop
    end: r

endmodule
