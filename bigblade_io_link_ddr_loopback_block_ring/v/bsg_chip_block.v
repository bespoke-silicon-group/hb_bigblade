
//==============================================================================
//
// BSG CHIP
//
// This is the toplevel for the ASIC. This chip uses the HB BGA package found
// inside bsg_packaging/basejump_fcbga_785.
//

module bsg_chip_block

 import bsg_chip_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;

  (input  tag_clk_i, tag_data_i, tag_en_i
  ,input  ext_io_clk_i, ext_noc_clk_i, async_output_disable_i

  ,input  [mem_link_conc_num_gp-1:0][1:0]                                io_link_clk_i
  ,input  [mem_link_conc_num_gp-1:0][1:0]                                io_link_v_i
  ,input  [mem_link_conc_num_gp-1:0][1:0][mem_link_channel_width_gp-1:0] io_link_data_i
  ,output [mem_link_conc_num_gp-1:0][1:0]                                io_link_token_o

  ,output [mem_link_conc_num_gp-1:0][1:0]                                io_link_clk_o
  ,output [mem_link_conc_num_gp-1:0][1:0]                                io_link_v_o
  ,output [mem_link_conc_num_gp-1:0][1:0][mem_link_channel_width_gp-1:0] io_link_data_o
  ,input  [mem_link_conc_num_gp-1:0][1:0]                                io_link_token_i
  );

  //////////////////////////////////////////////////
  //
  // Control Wires Hub
  //

  //wire bsg_tag_clk_i_int        = pad_ML0_0_i_int;
  //wire bsg_tag_en_i_int         = pad_ML0_1_i_int;
  //wire bsg_tag_data_i_int       = pad_ML0_2_i_int;
  //
  //wire async_output_disable_int = pad_CT0_v_i_int;
  //wire ext_io_clk_i_int         = pad_CT0_0_i_int;
  //wire ext_noc_clk_i_int        = pad_CT0_1_i_int;

  //wire sel_0_i_int            = pad_CT0_6_i_int;
  //wire sel_1_i_int            = pad_CT0_7_i_int;
  //wire clk_o_reset_int        = pad_CT0_clk_i_int;

  //wire clk_o_int, clk_div_pos_o_int, clk_div_neg_o_int;
  //assign pad_CT0_0_o_int  = clk_o_int;
  //assign pad_CT0_1_o_int  = clk_div_pos_o_int;
  //assign pad_CT0_2_o_int  = clk_div_neg_o_int;


  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance
  //

  wire tag_clk_lo  = tag_clk_i;
  wire tag_data_lo = tag_en_i & tag_data_i;

  //wire [mem_link_conc_num_gp-1:0] tag_data_r;
  //localparam tag_stages_lp = 20;
  //
  //for (genvar i = 0; i < mem_link_conc_num_gp; i++)
  //begin: tag_data_reg
  //  bsg_dff_chain #(.width_p(1),.num_stages_p(tag_stages_lp)) chain
  //  (.clk_i(tag_clk_lo),.data_i(tag_data_lo),.data_o(tag_data_r[i]));
  //end

  //// All tag lines from the btm
  //wire bsg_chip_tag_lines_s tag_lines_lo;
  //
  //// BSG tag master instance
  //bsg_tag_master #(.els_p( tag_num_clients_gp )
  //                ,.lg_width_p( tag_lg_max_payload_width_gp )
  //                )
  //  btm
  //    (.clk_i      ( bsg_tag_clk_i_int )
  //    ,.data_i     ( bsg_tag_en_i_int ? bsg_tag_data_i_int : 1'b0 )
  //    ,.en_i       ( 1'b1 )
  //    ,.clients_r_o( tag_lines_lo )
  //    );

  //////////////////////////////////////////////////
  //
  // BSG Clock Generator Power Domain
  //

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
  
//  // Mapping physical links to logical links
//  logic [io_link_num_gp-1:0] io_link_clk_li, io_link_v_li, io_link_tkn_lo;
//  logic [io_link_num_gp-1:0][io_link_channel_width_gp-1:0] io_link_data_li;
//  logic [io_link_num_gp-1:0] io_link_clk_lo, io_link_v_lo, io_link_tkn_li;
//  logic [io_link_num_gp-1:0][io_link_channel_width_gp-1:0] io_link_data_lo;
//
//  logic [mem_link_num_gp-1:0] mem_link_clk_li, mem_link_v_li, mem_link_tkn_lo;
//  logic [mem_link_num_gp-1:0][mem_link_channel_width_gp-1:0] mem_link_data_li;
//  logic [mem_link_num_gp-1:0] mem_link_clk_lo, mem_link_v_lo, mem_link_tkn_li;
//  logic [mem_link_num_gp-1:0][mem_link_channel_width_gp-1:0] mem_link_data_lo;
//
//`define BSG_CHIP_LINK_HUB_DATA(pad, typ, i, j)                   \
//    assign ``typ``_link_data_li[i][j] = pad_``pad``_``j``_i_int; \
//    assign pad_``pad``_``j``_o_int = ``typ``_link_data_lo[i][j];
//
//`define BSG_CHIP_LINK_HUB(pad, typ, i)                           \
//    assign ``typ``_link_clk_li[i] = pad_``pad``_clk_i_int;       \
//    assign ``typ``_link_v_li  [i] = pad_``pad``_v_i_int;         \
//    assign pad_``pad``_tkn_o_int  = ``typ``_link_tkn_lo[i];      \
//    assign pad_``pad``_clk_o_int  = ``typ``_link_clk_lo[i];      \
//    assign pad_``pad``_v_o_int    = ``typ``_link_v_lo  [i];      \
//    assign ``typ``_link_tkn_li[i] = pad_``pad``_tkn_i_int;       \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  0)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  1)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  2)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  3)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  4)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  5)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  6)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  7)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  8)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i,  9)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 10)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 11)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 12)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 13)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 14)                     \
//    `BSG_CHIP_LINK_HUB_DATA(pad, typ, i, 15)
//
//  `BSG_CHIP_LINK_HUB(IT0, io,   0)
//  `BSG_CHIP_LINK_HUB(IT1, io,   1)
//  `BSG_CHIP_LINK_HUB(DL0, mem,  0)
//  `BSG_CHIP_LINK_HUB(DL1, mem,  1)
//  `BSG_CHIP_LINK_HUB(DL2, mem,  2)
//  `BSG_CHIP_LINK_HUB(DL3, mem,  3)
//  `BSG_CHIP_LINK_HUB(DL4, mem,  4)
//  `BSG_CHIP_LINK_HUB(DL5, mem,  5)
//  `BSG_CHIP_LINK_HUB(DL6, mem,  6)
//  `BSG_CHIP_LINK_HUB(DL7, mem,  7)
//  `BSG_CHIP_LINK_HUB(DR0, mem,  8)
//  `BSG_CHIP_LINK_HUB(DR1, mem,  9)
//  `BSG_CHIP_LINK_HUB(DR2, mem, 10)
//  `BSG_CHIP_LINK_HUB(DR3, mem, 11)
//  `BSG_CHIP_LINK_HUB(DR4, mem, 12)
//  `BSG_CHIP_LINK_HUB(DR5, mem, 13)
//  `BSG_CHIP_LINK_HUB(DR6, mem, 14)
//  `BSG_CHIP_LINK_HUB(DR7, mem, 15)


  //////////////////////////////////////////////////
  //
  // BSG Chip IO
  //

  //bsg_chip_io_link_sif_s [io_link_num_gp-1:0] io_links_li, io_links_lo;
  //bsg_chip_mem_link_sif_s [mem_link_num_gp-1:0] mem_links_li, mem_links_lo;
  //wire [io_link_num_gp-1:0] io_noc_clk_lo;
  //wire [mem_link_num_gp-1:0] mem_noc_clk_lo;

  //for (genvar i = 0; i < io_link_num_gp; i++)
  //begin: io_link
  //
  //  bsg_chip_io_link_ddr
  // #(.ds_width_p                     (clk_gen_ds_width_gp                     )
  //  ,.num_adgs_p                     (clk_gen_num_adgs_gp                     )
  //  ,.width_p                        (io_link_width_gp                        )
  //  ,.channel_width_p                (io_link_channel_width_gp                )
  //  ,.num_channels_p                 (io_link_num_channels_gp                 )
  //  ,.lg_fifo_depth_p                (io_link_lg_fifo_depth_gp                )
  //  ,.lg_credit_to_token_decimation_p(io_link_lg_credit_to_token_decimation_gp)
  //  ,.use_extra_data_bit_p           (io_link_use_extra_data_bit_gp           )
  //  ) link
  //  (.core_clk_i                     (io_noc_clk_lo[i]        ) // TODO: two links share one noc_clk
  //  ,.ext_io_clk_i                   (ext_io_clk_i_int        )
  //  ,.ext_noc_clk_i                  (ext_noc_clk_i_int       )
  //  ,.async_output_disable_i         (async_output_disable_int)
  //  ,.noc_clk_o                      (io_noc_clk_lo[i]        )
  //
  //  ,.tag_clk_i                      (bsg_tag_clk_i_int                      )
  //  ,.tag_io_tag_lines_i             (tag_lines_lo.io_link_io             [i])
  //  ,.tag_core_tag_lines_i           (tag_lines_lo.io_link_core           [i])
  //  ,.tag_io_async_reset_tag_lines_i (tag_lines_lo.io_link_io_async_reset [i])
  //  ,.tag_io_osc_tag_lines_i         (tag_lines_lo.io_link_io_osc         [i])
  //  ,.tag_io_osc_trigger_tag_lines_i (tag_lines_lo.io_link_io_osc_trigger [i])
  //  ,.tag_io_ds_tag_lines_i          (tag_lines_lo.io_link_io_ds          [i])
  //  ,.tag_io_sel_tag_lines_i         (tag_lines_lo.io_link_io_sel         [i])
  //  ,.tag_noc_async_reset_tag_lines_i(tag_lines_lo.io_link_noc_async_reset[i])
  //  ,.tag_noc_osc_tag_lines_i        (tag_lines_lo.io_link_noc_osc        [i])
  //  ,.tag_noc_osc_trigger_tag_lines_i(tag_lines_lo.io_link_noc_osc_trigger[i])
  //  ,.tag_noc_ds_tag_lines_i         (tag_lines_lo.io_link_noc_ds         [i])
  //  ,.tag_noc_sel_tag_lines_i        (tag_lines_lo.io_link_noc_sel        [i])
  //
  //  ,.core_v_i                       (io_links_lo[i].v                               )
  //  ,.core_data_i                    (io_links_lo[i].data                            )
  //  ,.core_ready_and_o               (io_links_li[i].ready_and_rev                   )
  //
  //  ,.core_v_o                       (io_links_li[i].v                               )
  //  ,.core_data_o                    (io_links_li[i].data                            )
  //  ,.core_yumi_i                    (io_links_li[i].v & io_links_lo[i].ready_and_rev)
  //
  //  ,.io_link_clk_o                  (io_link_clk_lo [i])
  //  ,.io_link_data_o                 (io_link_data_lo[i])
  //  ,.io_link_v_o                    (io_link_v_lo   [i])
  //  ,.io_link_token_i                (io_link_tkn_li [i])
  //
  //  ,.io_link_clk_i                  (io_link_clk_li [i])
  //  ,.io_link_data_i                 (io_link_data_li[i])
  //  ,.io_link_v_i                    (io_link_v_li   [i])
  //  ,.io_link_token_o                (io_link_tkn_lo [i])
  //  );
  //
  //end

  logic [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0] wh_link_clk_li, wh_link_v_li, wh_link_tkn_lo;
  logic [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0] wh_link_data_li;
  logic [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0] wh_link_clk_lo, wh_link_v_lo, wh_link_tkn_li;
  logic [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0] wh_link_data_lo;

  for (genvar i = 0; i < mem_link_conc_num_gp; i++)
  begin: mem_link

    bsg_chip_noc_mem_link
   #(.ds_width_p                         (clk_gen_ds_width_gp                      )
    ,.num_adgs_p                         (clk_gen_num_adgs_gp                      )
    ,.width_p                            (mem_link_width_gp                        )
    ,.channel_width_p                    (mem_link_channel_width_gp                )
    ,.num_channels_p                     (mem_link_num_channels_gp                 )
    ,.lg_fifo_depth_p                    (mem_link_lg_fifo_depth_gp                )
    ,.lg_credit_to_token_decimation_p    (mem_link_lg_credit_to_token_decimation_gp)
    ,.use_extra_data_bit_p               (mem_link_use_extra_data_bit_gp           )
    ,.tag_num_clients_p                  (tag_num_clients_gp                       )
    ,.tag_lg_max_payload_width_p         (tag_lg_max_payload_width_gp              )
    ,.sdr_lg_fifo_depth_p                (sdr_lg_fifo_depth_gp                     )
    ,.sdr_lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_gp     )
    ,.wh_ruche_factor_p                  (wh_ruche_factor_gp                       )
    ,.wh_flit_width_p                    (wh_flit_width_gp                         )
    ,.wh_len_width_p                     (wh_len_width_gp                          )
    ,.wh_cid_width_p                     (wh_cid_width_gp                          )
    ,.wh_cord_width_p                    (wh_cord_width_gp                         )
    ) link
    (.ext_io_clk_i                   (ext_io_clk_i          )
    ,.ext_noc_clk_i                  (ext_noc_clk_i         )
    ,.async_output_disable_i         (async_output_disable_i)

    ,.tag_clk_i                      (tag_clk_lo            )
    ,.tag_data_i                     (tag_data_lo           )
    ,.tag_node_id_offset_i           ((`BSG_SAFE_CLOG2(tag_num_clients_gp))'(i*26))

    ,.io_link_clk_o                  (io_link_clk_o  [i])
    ,.io_link_data_o                 (io_link_data_o [i])
    ,.io_link_v_o                    (io_link_v_o    [i])
    ,.io_link_token_i                (io_link_token_i[i])

    ,.io_link_clk_i                  (io_link_clk_i  [i])
    ,.io_link_data_i                 (io_link_data_i [i])
    ,.io_link_v_i                    (io_link_v_i    [i])
    ,.io_link_token_o                (io_link_token_o[i])

    ,.io_wh_link_clk_o               (wh_link_clk_lo [i])
    ,.io_wh_link_data_o              (wh_link_data_lo[i])
    ,.io_wh_link_v_o                 (wh_link_v_lo   [i])
    ,.io_wh_link_token_i             (wh_link_tkn_li [i])

    ,.io_wh_link_clk_i               (wh_link_clk_li [i])
    ,.io_wh_link_data_i              (wh_link_data_li[i])
    ,.io_wh_link_v_i                 (wh_link_v_li   [i])
    ,.io_wh_link_token_o             (wh_link_tkn_lo [i])
    );

  end

  //////////////////////////////////////////////////
  //
  // HB Complex
  //

  // Loopback
  assign wh_link_clk_li  = wh_link_clk_lo;
  assign wh_link_v_li    = wh_link_v_lo;
  assign wh_link_tkn_li  = wh_link_tkn_lo;
  assign wh_link_data_li = wh_link_data_lo;

  //bsg_chip_core_complex core_complex
  //(.io_links_i    ( io_links_li        )
  //,.io_links_o    ( io_links_lo        )
  //,.mem_links_i   ( mem_links_li       )
  //,.mem_links_o   ( mem_links_lo       )
  //);

endmodule
