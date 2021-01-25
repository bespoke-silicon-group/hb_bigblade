
`include "bsg_padmapping.v"
`include "bsg_iopad_macros.v"

//==============================================================================
//
// BSG CHIP
//
// This is the toplevel for the ASIC. This chip uses the HB BGA package found
// inside bsg_packaging/basejump_fcbga_785.
//

module bsg_chip

 import bsg_chip_pkg::*;

`include "bsg_pinout.v"
`include "bsg_iopads.v"


  //////////////////////////////////////////////////
  //
  // Control Wires Hub
  //

  wire bsg_tag_clk_i_int      = pad_CT0_0_i_int;
  wire bsg_tag_en_i_int       = pad_CT0_1_i_int;
  wire bsg_tag_data_i_int     = pad_CT0_2_i_int;
  
  wire clk_A_i_int            = pad_CT0_3_i_int;
  wire clk_B_i_int            = pad_CT0_4_i_int;
  wire clk_C_i_int            = pad_CT0_5_i_int;

  wire sel_0_i_int            = pad_CT0_6_i_int;
  wire sel_1_i_int            = pad_CT0_7_i_int;
  wire clk_output_disable_int = pad_CT0_v_i_int;

  wire clk_o_int, clk_div_pos_o_int, clk_div_neg_o_int;
  assign pad_CT0_0_o_int  = clk_o_int;
  assign pad_CT0_1_o_int  = clk_div_pos_o_int;
  assign pad_CT0_2_o_int  = clk_div_neg_o_int;


  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance
  //

  // All tag lines from the btm
  bsg_chip_tag_lines_s tag_lines_lo;

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
  logic bp_clk_lo; // not used
  logic router_clk_lo; // not used

  bsg_clk_gen_power_domain #(.num_clk_endpoint_p( clk_gen_num_endpoints_gp )
                            ,.ds_width_p( clk_gen_ds_width_gp )
                            ,.num_adgs_p( clk_gen_num_adgs_gp )
                            )
    clk_gen_pd
      (.async_reset_tag_lines_i ( tag_lines_lo.async_reset )
      ,.osc_tag_lines_i         ( tag_lines_lo.clk_gen_osc )
      ,.osc_trigger_tag_lines_i ( tag_lines_lo.clk_gen_osc_trigger )
      ,.ds_tag_lines_i          ( tag_lines_lo.clk_gen_ds )
      ,.sel_tag_lines_i         ( tag_lines_lo.clk_gen_sel )
      ,.async_output_disable_i  ( clk_output_disable_int )
      ,.ext_clk_i({ clk_C_i_int, clk_B_i_int, clk_A_i_int })

      ,.clk_o({ router_clk_lo, bp_clk_lo, hb_clk_lo })
      );
      
  // Route the clock signals off chip
  logic [1:0]  clk_out_sel;
  logic        clk_out;
  logic [1:0]  clk_out_div_pos, clk_out_div_neg;

  assign clk_out_sel[0] = sel_0_i_int;
  assign clk_out_sel[1] = sel_1_i_int;
  assign clk_o_int      = clk_out;
  assign clk_div_pos_o_int = clk_out_div_pos[1];
  assign clk_div_neg_o_int = clk_out_div_neg[1];

  bsg_mux #(.width_p   ( 1 )
           ,.els_p     ( 4 )
           ,.balanced_p( 1 )
           ,.harden_p  ( 1 )
           ) 
    clk_out_mux
      (.data_i( {1'b0, hb_clk_lo, bp_clk_lo, router_clk_lo} )
      ,.sel_i ( clk_out_sel )
      ,.data_o( clk_out )
      );

  bsg_dff #(.width_p(2)) dff_clk_o_pos
  (.clk_i  ( clk_out )
  ,.data_i ( clk_out_div_pos + 2'b01 )
  ,.data_o ( clk_out_div_pos )
  );

  bsg_dff #(.width_p(2)) dff_clk_o_neg
  (.clk_i  ( ~clk_out )
  ,.data_i ( clk_out_div_neg + 2'b01 )
  ,.data_o ( clk_out_div_neg )
  );

  // FIXME: Change to appropriate external clock
  wire bsg_link_clk_gen_ext_clk_lo = clk_C_i_int;


  //////////////////////////////////////////////////
  //
  // BSG Link Hub
  //
  
  // Mapping physical links to logical links
  logic [io_link_num_gp-1:0] io_link_clk_li, io_link_v_li, io_link_tkn_lo;
  logic [io_link_num_gp-1:0][io_link_channel_width_gp-1:0] io_link_data_li;
  logic [io_link_num_gp-1:0] io_link_clk_lo, io_link_v_lo, io_link_tkn_li;
  logic [io_link_num_gp-1:0][io_link_channel_width_gp-1:0] io_link_data_lo;

  logic [mem_link_num_gp-1:0] mem_link_clk_li, mem_link_v_li, mem_link_tkn_lo;
  logic [mem_link_num_gp-1:0][mem_link_channel_width_gp-1:0] mem_link_data_li;
  logic [mem_link_num_gp-1:0] mem_link_clk_lo, mem_link_v_lo, mem_link_tkn_li;
  logic [mem_link_num_gp-1:0][mem_link_channel_width_gp-1:0] mem_link_data_lo;

`define BSG_CHIP_LINK_HUB_DATA(pad, typ, i, j)                   \
    assign ``typ``_link_data_li[i][j] = pad_``pad``_``j``_i_int; \
    assign pad_``pad``_``j``_o_int = ``typ``_link_data_lo[i][j];

`define BSG_CHIP_LINK_HUB(pad, typ, i)                           \
    assign ``typ``_link_clk_li[i] = pad_``pad``_clk_i_int;       \
    assign ``typ``_link_v_li  [i] = pad_``pad``_v_i_int;         \
    assign pad_``pad``_tkn_o_int  = ``typ``_link_tkn_lo[i];      \
    assign pad_``pad``_clk_o_int  = ``typ``_link_clk_lo[i];      \
    assign pad_``pad``_v_o_int    = ``typ``_link_v_lo  [i];      \
    assign ``typ``_link_tkn_li[i] = pad_``pad``_tkn_i_int;       \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  0)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  1)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  2)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  3)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  4)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  5)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  6)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  7)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  8)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  9)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 10)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 11)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 12)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 13)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 14)                     \
    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 15)

  `BSG_CHIP_LINK_HUB(IT0, io,   0)
  `BSG_CHIP_LINK_HUB(IT1, io,   1)
  `BSG_CHIP_LINK_HUB(DL0, mem,  0)
  `BSG_CHIP_LINK_HUB(DL1, mem,  1)
  `BSG_CHIP_LINK_HUB(DL2, mem,  2)
  `BSG_CHIP_LINK_HUB(DL3, mem,  3)
  `BSG_CHIP_LINK_HUB(DL4, mem,  4)
  `BSG_CHIP_LINK_HUB(DL5, mem,  5)
  `BSG_CHIP_LINK_HUB(DL6, mem,  6)
  `BSG_CHIP_LINK_HUB(DL7, mem,  7)
  `BSG_CHIP_LINK_HUB(DR0, mem,  8)
  `BSG_CHIP_LINK_HUB(DR1, mem,  9)
  `BSG_CHIP_LINK_HUB(DR2, mem, 10)
  `BSG_CHIP_LINK_HUB(DR3, mem, 11)
  `BSG_CHIP_LINK_HUB(DR4, mem, 12)
  `BSG_CHIP_LINK_HUB(DR5, mem, 13)
  `BSG_CHIP_LINK_HUB(DR6, mem, 14)
  `BSG_CHIP_LINK_HUB(DR7, mem, 15)


  //////////////////////////////////////////////////
  //
  // BSG Chip IO
  //

  bsg_chip_io_link_sif_s [io_link_num_gp-1:0][io_ct_num_in_gp-1:0] io_links_li, io_links_lo;
  bsg_chip_mem_link_sif_s [mem_link_num_gp-1:0] mem_links_li, mem_links_lo;
  logic [io_link_num_gp-1:0] io_link_io_clk_lo;
  logic [mem_link_num_gp-1:0] mem_link_io_clk_lo;

  for (genvar i = 0; i < io_link_num_gp; i++)
  begin: io_link
    bsg_clk_gen_power_domain 
   #(.num_clk_endpoint_p      ( 1 )
    ,.ds_width_p              ( clk_gen_ds_width_gp )
    ,.num_adgs_p              ( clk_gen_num_adgs_gp )
    ) clk_gen
    (.async_reset_tag_lines_i ( tag_lines_lo.async_reset )
    ,.osc_tag_lines_i         ( tag_lines_lo.io_link_osc        [i] )
    ,.osc_trigger_tag_lines_i ( tag_lines_lo.io_link_osc_trigger[i] )
    ,.ds_tag_lines_i          ( tag_lines_lo.io_link_ds         [i] )
    ,.sel_tag_lines_i         ( tag_lines_lo.io_link_sel        [i] )
    ,.async_output_disable_i  ( clk_output_disable_int )
    ,.ext_clk_i               ( bsg_link_clk_gen_ext_clk_lo )
    ,.clk_o                   ( io_link_io_clk_lo               [i] )
    );

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
    ,.io_clk_i   ( io_link_io_clk_lo[i] )
   
    ,.link_io_tag_lines_i   ( tag_lines_lo.io_link_io[i] )
    ,.link_core_tag_lines_i ( tag_lines_lo.io_link_core[i] )
   
    ,.link_clk_i ( io_link_clk_li [i] )
    ,.link_v_i   ( io_link_v_li   [i] )
    ,.link_tkn_o ( io_link_tkn_lo [i] )
    ,.link_data_i( io_link_data_li[i] )
   
    ,.link_clk_o ( io_link_clk_lo [i] )
    ,.link_v_o   ( io_link_v_lo   [i] )
    ,.link_tkn_i ( io_link_tkn_li [i] )
    ,.link_data_o( io_link_data_lo[i] )
   
    ,.links_i    ( io_links_li[i] ) 
    ,.links_o    ( io_links_lo[i] )
    );
  end

  for (genvar i = 0; i < mem_link_num_gp; i++)
  begin: mem_link
    bsg_clk_gen_power_domain 
   #(.num_clk_endpoint_p      ( 1 )
    ,.ds_width_p              ( clk_gen_ds_width_gp )
    ,.num_adgs_p              ( clk_gen_num_adgs_gp )
    ) clk_gen
    (.async_reset_tag_lines_i ( tag_lines_lo.async_reset )
    ,.osc_tag_lines_i         ( tag_lines_lo.mem_link_osc        [i] )
    ,.osc_trigger_tag_lines_i ( tag_lines_lo.mem_link_osc_trigger[i] )
    ,.ds_tag_lines_i          ( tag_lines_lo.mem_link_ds         [i] )
    ,.sel_tag_lines_i         ( tag_lines_lo.mem_link_sel        [i] )
    ,.async_output_disable_i  ( clk_output_disable_int )
    ,.ext_clk_i               ( bsg_link_clk_gen_ext_clk_lo )
    ,.clk_o                   ( mem_link_io_clk_lo               [i] )
    );

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
    ,.io_clk_i   ( mem_link_io_clk_lo[i] )
   
    ,.link_io_tag_lines_i   ( tag_lines_lo.mem_link_io[i] )
    ,.link_core_tag_lines_i ( tag_lines_lo.mem_link_core[i] )
   
    ,.link_clk_i ( mem_link_clk_li [i] )
    ,.link_v_i   ( mem_link_v_li   [i] )
    ,.link_tkn_o ( mem_link_tkn_lo [i] )
    ,.link_data_i( mem_link_data_li[i] )

    ,.link_clk_o ( mem_link_clk_lo [i] )
    ,.link_v_o   ( mem_link_v_lo   [i] )
    ,.link_tkn_i ( mem_link_tkn_li [i] )
    ,.link_data_o( mem_link_data_lo[i] )

    ,.links_i    ( mem_links_li[i] ) 
    ,.links_o    ( mem_links_lo[i] )
    );
  end

  //////////////////////////////////////////////////
  //
  // HB Complex
  //

  bsg_chip_core_complex core_complex
  (.hb_clk_i   ( hb_clk_lo          )
  ,.tag_lines_i( tag_lines_lo       )

  ,.tag_clk_i  ( bsg_tag_clk_i_int  )
  ,.tag_data_i ( bsg_tag_data_i_int )
  ,.tag_en_i   ( bsg_tag_en_i_int   )

  ,.io_links_i ( io_links_lo        )
  ,.io_links_o ( io_links_li        )
  ,.mem_links_i( mem_links_lo       )
  ,.mem_links_o( mem_links_li       )
  );

endmodule
