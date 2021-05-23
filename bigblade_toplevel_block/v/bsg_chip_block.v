
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

  wire async_output_disable_i = pad_CT0_v_i_int;
  wire tag_clk_i              = pad_CT0_0_i_int;
  wire tag_data_i             = pad_CT0_1_i_int;
  wire tag_en_i               = pad_CT0_2_i_int;

  wire ext_io_clk_i           = pad_CT0_clk_i_int;
  wire ext_noc_clk_i          = pad_CT0_tkn_i_int;
  wire [hb_num_pods_y_gp-1:0] mc_ext_clk_i = {pad_ML0_3_i_int, pad_ML0_2_i_int, pad_ML0_1_i_int, pad_ML0_0_i_int};
  //wire ext_bp_clk_i           = pad_CT0_6_i_int;
  //wire ext_cgra_clk_i         = pad_CT0_7_i_int;

  wire [1:0] mc_clk_monitor_sel_i      = {pad_CT0_4_i_int, pad_CT0_3_i_int};
  wire [2:0] noc_mem_clk_monitor_sel_i = {pad_CT0_7_i_int, pad_CT0_6_i_int, pad_CT0_5_i_int};

  wire [hb_num_pods_y_gp-1:0] mc_clk_monitor_o;
  wire [mem_link_conc_num_gp-1:0] noc_mem_clk_monitor_o;
  wire noc_io_clk_monitor_o;

  wire [3:0] mc_mux_data_li = {'0, mc_clk_monitor_o};
  bsg_mux #(.width_p(1),.els_p(4),.balanced_p(1),.harden_p(1)) mc_mux
  (.data_i(mc_mux_data_li),.sel_i(mc_clk_monitor_sel_i),.data_o(pad_CT0_0_o_int));

  assign pad_CT0_1_o_int = noc_io_clk_monitor_o;

  wire [1:0] noc_mem_clk_monitor_mid;
  bsg_mux #(.width_p(1),.els_p(4),.balanced_p(1),.harden_p(1)) noc_mem_mux0
  (.data_i(noc_mem_clk_monitor_o[3:0]),.sel_i(noc_mem_clk_monitor_sel_i[1:0]),.data_o(noc_mem_clk_monitor_mid[0]));
  bsg_mux #(.width_p(1),.els_p(4),.balanced_p(1),.harden_p(1)) noc_mem_mux1
  (.data_i(noc_mem_clk_monitor_o[7:4]),.sel_i(noc_mem_clk_monitor_sel_i[1:0]),.data_o(noc_mem_clk_monitor_mid[1]));
  bsg_mux #(.width_p(1),.els_p(4),.balanced_p(1),.harden_p(1)) noc_mem_mux2
  (.data_i({2'b00, noc_mem_clk_monitor_mid}),.sel_i({1'b0, noc_mem_clk_monitor_sel_i[2]}),.data_o(pad_CT0_2_o_int));


  //////////////////////////////////////////////////
  //
  // BSG Tag
  //

  wire tag_clk_lo  = tag_clk_i;
  wire tag_data_lo = tag_en_i & tag_data_i;


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
  ,.noc_clk_monitor_o              (noc_io_clk_monitor_o  )
 
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
    ,.noc_clk_monitor_o              (noc_mem_clk_monitor_o[i])
   
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

  ,.mc_ext_clk_i           (mc_ext_clk_i        )

  ,.mc_clk_monitor_o       (mc_clk_monitor_o    )
                           
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
