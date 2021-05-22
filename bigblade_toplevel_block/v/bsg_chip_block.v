
//==============================================================================
//
// BSG CHIP
//
// This is the toplevel for the ASIC. This chip uses the HB BGA package found
// inside bsg_packaging/basejump_fcbga_785.
//

`include "bsg_padmapping.v"
`include "bsg_iopad_macros.v"

module bsg_chip_block

 import bsg_chip_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_manycore_pkg::*;

`include "bsg_chip_block_pinout.v"
`include "bsg_iopads_tie_cells.v"

  //////////////////////////////////////////////////
  //
  // Control Wires Hub
  //

  wire tag_clk_i              = pad_ML0_0_i_int;
  wire tag_data_i             = pad_ML0_1_i_int;
  wire tag_en_i               = pad_ML0_2_i_int;
  
  wire async_output_disable_i = pad_CT0_v_i_int;
  wire ext_io_clk_i           = pad_CT0_0_i_int;
  wire ext_noc_clk_i          = pad_CT0_1_i_int;
  wire ext_mc_clk_i           = pad_CT0_2_i_int;
  //wire ext_bp_clk_i           = pad_CT0_3_i_int;
  //wire ext_cgra_clk_i         = pad_CT0_4_i_int;

  //wire sel_0_i_int            = pad_CT0_6_i_int;
  //wire sel_1_i_int            = pad_CT0_7_i_int;
  //wire clk_o_reset_int        = pad_CT0_clk_i_int;

  //wire clk_o_int, clk_div_pos_o_int, clk_div_neg_o_int;
  //assign pad_CT0_0_o_int  = clk_o_int;
  //assign pad_CT0_1_o_int  = clk_div_pos_o_int;
  //assign pad_CT0_2_o_int  = clk_div_neg_o_int;


  //////////////////////////////////////////////////
  //
  // BSG Tag
  //

  wire tag_clk_lo  = tag_clk_i;
  wire tag_data_lo = tag_en_i & tag_data_i;


  //////////////////////////////////////////////////
  //
  // BSG Clock Generator
  //

  logic [hb_num_pods_y_gp-1:0] mc_clk_lo;
  for (genvar i = 0; i < hb_num_pods_y_gp; i++)
    assign mc_clk_lo[i] = ext_mc_clk_i;

  //logic hb_clk_lo;
  //logic bp_clk_lo; // not used
  //logic router_clk_lo;
  //
  //logic [clk_gen_num_endpoints_gp-1:0] main_ext_clk_li, main_clk_lo;
  //assign main_ext_clk_li = { clk_C_i_int, clk_B_i_int, clk_A_i_int };
  //assign { router_clk_lo, bp_clk_lo, hb_clk_lo } = main_clk_lo;
  //
  //for (genvar i = 0; i < clk_gen_num_endpoints_gp; i++)
  //begin: top_clk_gen
  //  bsg_chip_clk_gen 
  // #(.ds_width_p              ( clk_gen_ds_width_gp )
  //  ,.num_adgs_p              ( clk_gen_num_adgs_gp )
  //  ) clk_gen
  //  (.async_reset_tag_lines_i ( tag_lines_lo.clk_gen_async_reset[i] )
  //  ,.osc_tag_lines_i         ( tag_lines_lo.clk_gen_osc        [i] )
  //  ,.osc_trigger_tag_lines_i ( tag_lines_lo.clk_gen_osc_trigger[i] )
  //  ,.ds_tag_lines_i          ( tag_lines_lo.clk_gen_ds         [i] )
  //  ,.sel_tag_lines_i         ( tag_lines_lo.clk_gen_sel        [i] )
  //  ,.async_output_disable_i  ( clk_output_disable_int              )
  //  ,.ext_clk_i               ( main_ext_clk_li                 [i] )
  //  ,.clk_o                   ( main_clk_lo                     [i] )
  //  );
  //end

  // Route the clock signals off chip
  //logic [1:0]  clk_out_sel;
  //logic        clk_out;
  //logic [1:0]  clk_out_div_pos, clk_out_div_neg;
  //
  //assign clk_out_sel[0] = sel_0_i_int;
  //assign clk_out_sel[1] = sel_1_i_int;
  //assign clk_o_int      = clk_out;
  //assign clk_div_pos_o_int = clk_out_div_pos[1];
  //assign clk_div_neg_o_int = clk_out_div_neg[1];
  //
  //bsg_mux #(.width_p   ( 1 )
  //         ,.els_p     ( 4 )
  //         ,.balanced_p( 1 )
  //         ,.harden_p  ( 1 )
  //         ) 
  //  clk_out_mux
  //    (.data_i( {1'b0, hb_clk_lo, bp_clk_lo, router_clk_lo} )
  //    ,.sel_i ( clk_out_sel )
  //    ,.data_o( clk_out )
  //    );

  // clk_o signal is connected directly to the outside world. This will prevent user 
  // from visualizing the clock when clock frequency is high (the upper limit will be
  // around 1GHz). Dividing the frequency by 4 can resolve this.
  //
  // In order to preserve information about duty cycle, both posedge and negedge 
  // waveforms are transmitted off-chip. Refer to Github issue #6 for more info.
  //
  //bsg_dff_reset #(.width_p(2)) dff_clk_o_pos
  //(.clk_i  ( clk_out )
  //,.reset_i( clk_o_reset_int )
  //,.data_i ( clk_out_div_pos + 2'b01 )
  //,.data_o ( clk_out_div_pos )
  //);
  //
  //bsg_dff_reset #(.width_p(2)) dff_clk_o_neg
  //(.clk_i  ( ~clk_out )
  //,.reset_i( clk_o_reset_int )
  //,.data_i ( clk_out_div_neg + 2'b01 )
  //,.data_o ( clk_out_div_neg )
  //);
  //
  //// FIXME: Change to appropriate external clock
  //wire bsg_link_clk_gen_ext_clk_lo = clk_C_i_int;


  //////////////////////////////////////////////////
  //
  // BSG Link Hub
  //
  
  // Mapping physical links to logical links
  logic [io_link_num_gp-1:0] io_link_clk_li, io_link_v_li, io_link_tkn_lo;
  logic [io_link_num_gp-1:0][bsg_link_channel_width_gp-1:0] io_link_data_li;
  logic [io_link_num_gp-1:0] io_link_clk_lo, io_link_v_lo, io_link_tkn_li;
  logic [io_link_num_gp-1:0][bsg_link_channel_width_gp-1:0] io_link_data_lo;

  logic [mem_link_num_gp-1:0] mem_link_clk_li, mem_link_v_li, mem_link_tkn_lo;
  logic [mem_link_num_gp-1:0][bsg_link_channel_width_gp-1:0] mem_link_data_li;
  logic [mem_link_num_gp-1:0] mem_link_clk_lo, mem_link_v_lo, mem_link_tkn_li;
  logic [mem_link_num_gp-1:0][bsg_link_channel_width_gp-1:0] mem_link_data_lo;

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
  // BSG Chip IO Links
  //

  localparam mc_fwd_width_lp =
    `bsg_manycore_packet_width(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  localparam mc_rev_width_lp =
    `bsg_manycore_return_packet_width(hb_x_cord_width_gp,hb_y_cord_width_gp,hb_data_width_gp);

  logic mc_fwd_link_clk_li, mc_fwd_link_v_li, mc_fwd_link_token_lo;
  logic [mc_fwd_width_lp-1:0] mc_fwd_link_data_li;
  logic mc_fwd_link_clk_lo, mc_fwd_link_v_lo, mc_fwd_link_token_li;
  logic [mc_fwd_width_lp-1:0] mc_fwd_link_data_lo;

  logic mc_rev_link_clk_li, mc_rev_link_v_li, mc_rev_link_token_lo;
  logic [mc_rev_width_lp-1:0] mc_rev_link_data_li;
  logic mc_rev_link_clk_lo, mc_rev_link_v_lo, mc_rev_link_token_li;
  logic [mc_rev_width_lp-1:0] mc_rev_link_data_lo;

  bsg_chip_noc_io_link io_link
  (.ext_io_clk_i                   (ext_io_clk_i          )
  ,.ext_noc_clk_i                  (ext_noc_clk_i         )
  ,.async_output_disable_i         (async_output_disable_i)
  ,.noc_clk_monitor_o              (                      )
 
  ,.tag_clk_i                      (tag_clk_lo            )
  ,.tag_data_i                     (tag_data_lo           )
  ,.tag_node_id_offset_i           ((tag_lg_els_gp)'(tag_io_link_offset_gp))
 
  ,.io_link_clk_o                  ({io_link_clk_lo [1], io_link_clk_lo [0]})
  ,.io_link_data_o                 ({io_link_data_lo[1], io_link_data_lo[0]})
  ,.io_link_v_o                    ({io_link_v_lo   [1], io_link_v_lo   [0]})
  ,.io_link_token_i                ({io_link_tkn_li [1], io_link_tkn_li [0]})
 
  ,.io_link_clk_i                  ({io_link_clk_li [1], io_link_clk_li [0]})
  ,.io_link_data_i                 ({io_link_data_li[1], io_link_data_li[0]})
  ,.io_link_v_i                    ({io_link_v_li   [1], io_link_v_li   [0]})
  ,.io_link_token_o                ({io_link_tkn_lo [1], io_link_tkn_lo [0]})
 
  ,.mc_fwd_link_clk_o              (mc_fwd_link_clk_lo  )
  ,.mc_fwd_link_data_o             (mc_fwd_link_data_lo )
  ,.mc_fwd_link_v_o                (mc_fwd_link_v_lo    )
  ,.mc_fwd_link_token_i            (mc_fwd_link_token_li)
 
  ,.mc_fwd_link_clk_i              (mc_fwd_link_clk_li  )
  ,.mc_fwd_link_data_i             (mc_fwd_link_data_li )
  ,.mc_fwd_link_v_i                (mc_fwd_link_v_li    )
  ,.mc_fwd_link_token_o            (mc_fwd_link_token_lo)
 
  ,.mc_rev_link_clk_o              (mc_rev_link_clk_lo  )
  ,.mc_rev_link_data_o             (mc_rev_link_data_lo )
  ,.mc_rev_link_v_o                (mc_rev_link_v_lo    )
  ,.mc_rev_link_token_i            (mc_rev_link_token_li)
 
  ,.mc_rev_link_clk_i              (mc_rev_link_clk_li  )
  ,.mc_rev_link_data_i             (mc_rev_link_data_li )
  ,.mc_rev_link_v_i                (mc_rev_link_v_li    )
  ,.mc_rev_link_token_o            (mc_rev_link_token_lo)
  );


  //////////////////////////////////////////////////
  //
  // BSG Chip MEM Links
  //

  logic [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0] wh_link_clk_li, wh_link_v_li, wh_link_token_lo;
  logic [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0] wh_link_data_li;
  logic [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0] wh_link_clk_lo, wh_link_v_lo, wh_link_token_li;
  logic [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0] wh_link_data_lo;

  for (genvar i = 0; i < mem_link_conc_num_gp; i++)
  begin: mem_link

    localparam idx1 = i*mem_link_rr_ratio_gp+1;
    localparam idx0 = i*mem_link_rr_ratio_gp+0;

    bsg_chip_noc_mem_link link
    (.ext_io_clk_i                   (ext_io_clk_i          )
    ,.ext_noc_clk_i                  (ext_noc_clk_i         )
    ,.async_output_disable_i         (async_output_disable_i)
    ,.noc_clk_monitor_o              (                      )
   
    ,.tag_clk_i                      (tag_clk_lo            )
    ,.tag_data_i                     (tag_data_lo           )
    ,.tag_node_id_offset_i           ((tag_lg_els_gp)'(tag_mem_link_offset_gp+i*tag_noc_local_els_gp))
   
    ,.io_link_clk_o                  ({mem_link_clk_lo [idx1], mem_link_clk_lo [idx0]})
    ,.io_link_data_o                 ({mem_link_data_lo[idx1], mem_link_data_lo[idx0]})
    ,.io_link_v_o                    ({mem_link_v_lo   [idx1], mem_link_v_lo   [idx0]})
    ,.io_link_token_i                ({mem_link_tkn_li [idx1], mem_link_tkn_li [idx0]})
   
    ,.io_link_clk_i                  ({mem_link_clk_li [idx1], mem_link_clk_li [idx0]})
    ,.io_link_data_i                 ({mem_link_data_li[idx1], mem_link_data_li[idx0]})
    ,.io_link_v_i                    ({mem_link_v_li   [idx1], mem_link_v_li   [idx0]})
    ,.io_link_token_o                ({mem_link_tkn_lo [idx1], mem_link_tkn_lo [idx0]})
   
    ,.io_wh_link_clk_o               (wh_link_clk_lo  [i])
    ,.io_wh_link_data_o              (wh_link_data_lo [i])
    ,.io_wh_link_v_o                 (wh_link_v_lo    [i])
    ,.io_wh_link_token_i             (wh_link_token_li[i])
   
    ,.io_wh_link_clk_i               (wh_link_clk_li  [i])
    ,.io_wh_link_data_i              (wh_link_data_li [i])
    ,.io_wh_link_v_i                 (wh_link_v_li    [i])
    ,.io_wh_link_token_o             (wh_link_token_lo[i])
    );

  end

  //////////////////////////////////////////////////
  //
  // HB Core Complex
  //

  bsg_chip_block_core_complex core_complex
  (.tag_clk_i              (tag_clk_lo            )
  ,.tag_data_i             (tag_data_lo           )
  ,.async_output_disable_i (async_output_disable_i)

  ,.mc_ext_clk_i           (mc_clk_lo           )

  ,.mc_monitor_clk_o       (                    )
                           
  ,.mc_fwd_link_clk_o      (mc_fwd_link_clk_li  )
  ,.mc_fwd_link_data_o     (mc_fwd_link_data_li )
  ,.mc_fwd_link_v_o        (mc_fwd_link_v_li    )
  ,.mc_fwd_link_token_i    (mc_fwd_link_token_lo)
                           
  ,.mc_fwd_link_clk_i      (mc_fwd_link_clk_lo  )
  ,.mc_fwd_link_data_i     (mc_fwd_link_data_lo )
  ,.mc_fwd_link_v_i        (mc_fwd_link_v_lo    )
  ,.mc_fwd_link_token_o    (mc_fwd_link_token_li)
                           
  ,.mc_rev_link_clk_o      (mc_rev_link_clk_li  )
  ,.mc_rev_link_data_o     (mc_rev_link_data_li )
  ,.mc_rev_link_v_o        (mc_rev_link_v_li    )
  ,.mc_rev_link_token_i    (mc_rev_link_token_lo)
                           
  ,.mc_rev_link_clk_i      (mc_rev_link_clk_lo  )
  ,.mc_rev_link_data_i     (mc_rev_link_data_lo )
  ,.mc_rev_link_v_i        (mc_rev_link_v_lo    )
  ,.mc_rev_link_token_o    (mc_rev_link_token_li)
                           
  ,.wh_link_clk_o          (wh_link_clk_li      )
  ,.wh_link_data_o         (wh_link_data_li     )
  ,.wh_link_v_o            (wh_link_v_li        )
  ,.wh_link_token_i        (wh_link_token_lo    )
 
  ,.wh_link_clk_i          (wh_link_clk_lo      )
  ,.wh_link_data_i         (wh_link_data_lo     )
  ,.wh_link_v_i            (wh_link_v_lo        )
  ,.wh_link_token_o        (wh_link_token_li    )
  );

endmodule
