
`include "bsg_padmapping.v"
`include "bsg_iopad_macros.v"

//==============================================================================
//
// BSG CHIP
//
// This is the toplevel for the ASIC. This chip uses the HB BGA package found
// inside bsg_packaging/hb_bga.
//

module bsg_chip

 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_chip_pkg::*;

`include "bsg_pinout.v"
`include "bsg_iopads.v"

  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance
  //

  // All tag lines from the btm
  bsg_tag_s [tag_num_clients_gp-1:0] tag_lines_lo;

  // Tag lines for clock generators
  bsg_tag_s       async_reset_tag_lines_lo;
  bsg_tag_s [2:0] osc_tag_lines_lo;
  bsg_tag_s [2:0] osc_trigger_tag_lines_lo;
  bsg_tag_s [2:0] ds_tag_lines_lo;
  bsg_tag_s [2:0] sel_tag_lines_lo;

  assign async_reset_tag_lines_lo                 = tag_lines_lo[0];
  assign osc_tag_lines_lo        [2:0]            = tag_lines_lo[3:1];
  assign osc_trigger_tag_lines_lo[2:0]            = tag_lines_lo[6:4];
  assign ds_tag_lines_lo         [2:0]            = tag_lines_lo[9:7];
  assign sel_tag_lines_lo        [2:0]            = tag_lines_lo[12:10];

  // Tag lines for io
  wire bsg_tag_s [3:0]  io_link_io_tag_lines_lo    = tag_lines_lo[16:13];
  wire bsg_tag_s [3:0]  io_link_core_tag_lines_lo  = tag_lines_lo[20:17];
  wire bsg_tag_s [15:0] mem_link_io_tag_lines_lo   = tag_lines_lo[36:21];
  wire bsg_tag_s [15:0] mem_link_core_tag_lines_lo = tag_lines_lo[52:37];

  // Tag lines for HB
  wire bsg_tag_s hb_tag_lines_lo                  = tag_lines_lo[53];

  // BSG tag master instance
  bsg_tag_master #(.els_p( tag_num_clients_gp )
                  ,.lg_width_p( tag_lg_max_payload_width_gp )
                  )
    btm
      (.clk_i      ( bsg_tag_clk_i_int )
      ,.data_i     ( bsg_tag_en_i_int ? bsg_tag_data_i_int : 1'b0 )
      ,.en_i       ( 1'b1 )
      ,.clients_r_o( tag_lines_lo )
      );

  //////////////////////////////////////////////////
  //
  // BSG Clock Generator Power Domain
  //

  logic hb_clk_lo;
  logic io_link_master_clk_lo;
  logic mem_link_master_clk_lo;

  bsg_clk_gen_power_domain #(.num_clk_endpoint_p( clk_gen_num_endpoints_gp )
                            ,.ds_width_p( clk_gen_ds_width_gp )
                            ,.num_adgs_p( clk_gen_num_adgs_gp )
                            )
    clk_gen_pd
      (.async_reset_tag_lines_i ( async_reset_tag_lines_lo )
      ,.osc_tag_lines_i         ( osc_tag_lines_lo )
      ,.osc_trigger_tag_lines_i ( osc_trigger_tag_lines_lo )
      ,.ds_tag_lines_i          ( ds_tag_lines_lo )
      ,.sel_tag_lines_i         ( sel_tag_lines_lo )

      ,.ext_clk_i({ clk_C_i_int, clk_B_i_int, clk_A_i_int })

      ,.clk_o({ mem_link_master_clk_lo, io_link_master_clk_lo, hb_clk_lo })
      );
      
  // Route the clock signals off chip
  logic [1:0]  clk_out_sel;
  logic        clk_out;

  assign clk_out_sel[0] = sel_0_i_int;
  assign clk_out_sel[1] = sel_1_i_int;
  assign clk_o_int      = clk_out;

  bsg_mux #(.width_p   ( 1 )
           ,.els_p     ( 4 )
           ,.balanced_p( 1 )
           ,.harden_p  ( 1 )
           ) 
    clk_out_mux
      (.data_i( {1'b0, hb_clk_lo, io_link_master_clk_lo, mem_link_master_clk_lo} )
      ,.sel_i ( clk_out_sel )
      ,.data_o( clk_out )
      );

  //////////////////////////////////////////////////
  //
  // BSG Tag Client Instance
  //

  // Tag payload for hb control signals
  typedef struct packed { 
      logic reset;
      logic [io_wh_cord_width_gp-1:0] cord;
  } hb_tag_payload_s;

  // Tag payload for manycore control signals
  hb_tag_payload_s hb_tag_data_lo;
  logic            hb_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(hb_tag_data_lo) ), .default_p( 0 ))
    btc_hb
      (.bsg_tag_i     ( hb_tag_lines_lo )
      ,.recv_clk_i    ( hb_clk_lo )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( hb_tag_new_data_lo )
      ,.recv_data_r_o ( hb_tag_data_lo )
      );
      

  //////////////////////////////////////////////////
  //
  // BSG Link Hub
  //

  logic [19:0] bsg_link_clk_li, bsg_link_v_li, bsg_link_tkn_lo;
  logic [19:0][8:0] bsg_link_data_li;

  logic [19:0] bsg_link_clk_lo, bsg_link_v_lo, bsg_link_tkn_li;
  logic [19:0][8:0] bsg_link_data_lo;

`define BSG_CHIP_LINK_HUB_DATA(i, j)                               \
    assign bsg_link_data_li[i][j] = bsg_link_in``i``_d``j``_i_int; \
    assign bsg_link_out``i``_d``j``_o_int = bsg_link_data_lo[i][j];

`define BSG_CHIP_LINK_HUB(i)                                          \
    assign bsg_link_clk_li         [i] = bsg_link_in``i``_clk_i_int;  \
    assign bsg_link_v_li           [i] = bsg_link_in``i``_v_i_int;    \
    assign bsg_link_in``i``_tkn_o_int  = bsg_link_tkn_lo[i];          \
    assign bsg_link_out``i``_clk_o_int = bsg_link_clk_lo[i];          \
    assign bsg_link_out``i``_v_o_int   = bsg_link_v_lo  [i];          \
    assign bsg_link_tkn_li         [i] = bsg_link_out``i``_tkn_i_int; \
    `BSG_CHIP_LINK_HUB_DATA(i, 0)                                     \
    `BSG_CHIP_LINK_HUB_DATA(i, 1)                                     \
    `BSG_CHIP_LINK_HUB_DATA(i, 2)                                     \
    `BSG_CHIP_LINK_HUB_DATA(i, 3)                                     \
    `BSG_CHIP_LINK_HUB_DATA(i, 4)                                     \
    `BSG_CHIP_LINK_HUB_DATA(i, 5)                                     \
    `BSG_CHIP_LINK_HUB_DATA(i, 6)                                     \
    `BSG_CHIP_LINK_HUB_DATA(i, 7)                                     \
    `BSG_CHIP_LINK_HUB_DATA(i, 8)

  `BSG_CHIP_LINK_HUB( 0)
  `BSG_CHIP_LINK_HUB( 1)
  `BSG_CHIP_LINK_HUB( 2)
  `BSG_CHIP_LINK_HUB( 3)
  `BSG_CHIP_LINK_HUB( 4)
  `BSG_CHIP_LINK_HUB( 5)
  `BSG_CHIP_LINK_HUB( 6)
  `BSG_CHIP_LINK_HUB( 7)
  `BSG_CHIP_LINK_HUB( 8)
  `BSG_CHIP_LINK_HUB( 9)
  `BSG_CHIP_LINK_HUB(10)
  `BSG_CHIP_LINK_HUB(11)
  `BSG_CHIP_LINK_HUB(12)
  `BSG_CHIP_LINK_HUB(13)
  `BSG_CHIP_LINK_HUB(14)
  `BSG_CHIP_LINK_HUB(15)
  `BSG_CHIP_LINK_HUB(16)
  `BSG_CHIP_LINK_HUB(17)
  `BSG_CHIP_LINK_HUB(18)
  `BSG_CHIP_LINK_HUB(19)

  // Mapping physical links to logical links
  logic [3:0] io_link_clk_li, io_link_v_li, io_link_tkn_lo;
  logic [3:0][8:0] io_link_data_li;
  logic [3:0] io_link_clk_lo, io_link_v_lo, io_link_tkn_li;
  logic [3:0][8:0] io_link_data_lo;

  logic [15:0] mem_link_clk_li, mem_link_v_li, mem_link_tkn_lo;
  logic [15:0][8:0] mem_link_data_li;
  logic [15:0] mem_link_clk_lo, mem_link_v_lo, mem_link_tkn_li;
  logic [15:0][8:0] mem_link_data_lo;

`define BSG_CHIP_LINK_TYPE_HUB(typ, num)                                          \
  for (genvar i = 0; i < ``num``; i++)                                            \
  begin                                                                           \
    assign ``typ``_link_clk_li [i] = bsg_link_clk_li [``typ``_link_mapping_gp[i]]; \
    assign ``typ``_link_v_li   [i] = bsg_link_v_li   [``typ``_link_mapping_gp[i]]; \
    assign ``typ``_link_data_li[i] = bsg_link_data_li[``typ``_link_mapping_gp[i]]; \
    assign bsg_link_tkn_lo[``typ``_link_mapping_gp[i]] = ``typ``_link_tkn_lo[i];   \
                                                                                  \
    assign bsg_link_clk_lo [``typ``_link_mapping_gp[i]] = ``typ``_link_clk_lo [i]; \
    assign bsg_link_v_lo   [``typ``_link_mapping_gp[i]] = ``typ``_link_v_lo   [i]; \
    assign bsg_link_data_lo[``typ``_link_mapping_gp[i]] = ``typ``_link_data_lo[i]; \
    assign ``typ``_link_tkn_li[i] = bsg_link_tkn_li[``typ``_link_mapping_gp[i]];   \
  end

  `BSG_CHIP_LINK_TYPE_HUB(io, 4)
  `BSG_CHIP_LINK_TYPE_HUB(mem, 16)

  //////////////////////////////////////////////////
  //
  // BSG Chip IO
  //

  `declare_bsg_ready_and_link_sif_s(io_ct_width_gp, io_link_sif_s);
  `declare_bsg_ready_and_link_sif_s(mem_link_width_gp, mem_link_sif_s);

  io_link_sif_s [3:0][io_ct_num_in_gp-1:0] io_links_li, io_links_lo;
  mem_link_sif_s [15:0] mem_links_li, mem_links_lo;

  for (genvar i = 0; i < 4; i++)
  begin: io_link
    bsg_chip_io_links_ct_fifo 
   #(.link_width_p                        ( io_link_width_gp         )
    ,.link_channel_width_p                ( io_link_channel_width_gp )
    ,.link_num_channels_p                 ( io_link_num_channels_gp  )
    ,.link_lg_fifo_depth_p                ( io_link_lg_fifo_depth_gp )
    ,.link_lg_credit_to_token_decimation_p( io_link_lg_credit_to_token_decimation_gp )
    ,.link_use_extra_data_bit_p           ( io_link_use_extra_data_bit_gp )
    ,.ct_bypass_p                         ( 0 )
    ,.ct_width_p                          ( io_ct_width_gp )
    ,.ct_num_in_p                         ( io_ct_num_in_gp )
    ,.ct_remote_credits_p                 ( io_ct_remote_credits_gp )
    ,.ct_use_pseudo_large_fifo_p          ( io_ct_use_pseudo_large_fifo_gp )
    ,.ct_lg_credit_decimation_p           ( io_ct_lg_credit_decimation_gp )
    ,.num_hops_p                          ( 2 )
    ) link
    (.core_clk_i ( hb_clk_lo )
    ,.io_clk_i   ( io_link_master_clk_lo )
   
    ,.link_io_tag_lines_i   ( io_link_io_tag_lines_lo[i] )
    ,.link_core_tag_lines_i ( io_link_core_tag_lines_lo[i] )
   
    ,.link_clk_i ( io_link_clk_li [i] )
    ,.link_v_i   ( io_link_v_li   [i] )
    ,.link_tkn_o ( io_link_tkn_lo [i] )
    ,.link_data_i( io_link_data_li[i][io_link_channel_width_gp-1:0] )
   
    ,.link_clk_o ( io_link_clk_lo [i] )
    ,.link_v_o   ( io_link_v_lo   [i] )
    ,.link_tkn_i ( io_link_tkn_li [i] )
    ,.link_data_o( io_link_data_lo[i][io_link_channel_width_gp-1:0] )
   
    ,.links_i    ( io_links_li[i] ) 
    ,.links_o    ( io_links_lo[i] )
    );
  end

  for (genvar i = 0; i < 16; i++)
  begin: mem_link
    bsg_chip_io_links_ct_fifo 
   #(.link_width_p                        ( mem_link_width_gp         )
    ,.link_channel_width_p                ( mem_link_channel_width_gp )
    ,.link_num_channels_p                 ( mem_link_num_channels_gp  )
    ,.link_lg_fifo_depth_p                ( mem_link_lg_fifo_depth_gp )
    ,.link_lg_credit_to_token_decimation_p( mem_link_lg_credit_to_token_decimation_gp )
    ,.link_use_extra_data_bit_p           ( mem_link_use_extra_data_bit_gp )
    ,.ct_bypass_p                         ( 1 )
    ,.num_hops_p                          ( 1 )
    ) link
    (.core_clk_i ( hb_clk_lo )
    ,.io_clk_i   ( mem_link_master_clk_lo )
   
    ,.link_io_tag_lines_i   ( mem_link_io_tag_lines_lo[i] )
    ,.link_core_tag_lines_i ( mem_link_core_tag_lines_lo[i] )
   
    ,.link_clk_i ( mem_link_clk_li [i] )
    ,.link_v_i   ( mem_link_v_li   [i] )
    ,.link_tkn_o ( mem_link_tkn_lo [i] )
    ,.link_data_i( mem_link_data_li[i][mem_link_channel_width_gp-1:0] )

    ,.link_clk_o ( mem_link_clk_lo [i] )
    ,.link_v_o   ( mem_link_v_lo   [i] )
    ,.link_tkn_i ( mem_link_tkn_li [i] )
    ,.link_data_o( mem_link_data_lo[i][mem_link_channel_width_gp-1:0] )

    ,.links_i    ( mem_links_li[i] ) 
    ,.links_o    ( mem_links_lo[i] )
    );
  end

  //////////////////////////////////////////////////
  //
  // Loopback
  //
  
  assign io_links_li = io_links_lo;
  assign mem_links_li = mem_links_lo;

endmodule
