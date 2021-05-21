`timescale 1ps/1ps

`define IO_CLK_PERIOD  10000
`define NOC_CLK_PERIOD 10000
`define MC_CLK_PERIOD  10000
`define TAG_CLK_PERIOD 20000

module bsg_gateway_chip

 import bsg_chip_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_manycore_pkg::*;

`include "bsg_pinout_inverted.v"


  //////////////////////////////////////////////////
  //
  // Control Wires Hub
  //

  wire p_tag_clk_lo, p_tag_data_lo, p_tag_en_lo;
  assign p_pad_ML0_0_o = p_tag_clk_lo;
  assign p_pad_ML0_1_o = p_tag_data_lo;
  assign p_pad_ML0_2_o = p_tag_en_lo;

  wire p_async_output_disable_lo;
  wire p_io_clk_lo, p_noc_clk_lo, p_mc_clk_lo;
  assign p_pad_CT0_v_o = p_async_output_disable_lo;
  assign p_pad_CT0_0_o = p_io_clk_lo;
  assign p_pad_CT0_1_o = p_noc_clk_lo;
  assign p_pad_CT0_2_o = p_mc_clk_lo;

  //wire p_sel_0_o, p_sel_1_o, p_clk_o_reset_o;
  //assign p_pad_CT0_6_o = p_sel_0_o;
  //assign p_pad_CT0_7_o = p_sel_1_o;
  //assign p_pad_CT0_clk_o = p_clk_o_reset_o;
  //
  //wire p_clk_i = p_pad_CT0_0_i;


  //////////////////////////////////////////////////
  //
  // Nonsynth Clock Generator(s)
  //
  
  logic io_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`IO_CLK_PERIOD)) io_clk_gen (.o(io_clk));
  
  logic noc_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`NOC_CLK_PERIOD)) noc_clk_gen (.o(noc_clk));

  logic mc_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`MC_CLK_PERIOD)) mc_clk_gen (.o(mc_clk));

  logic tag_clk, tag_clk_raw;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`TAG_CLK_PERIOD)) tag_clk_gen (.o(tag_clk_raw));

  assign p_io_clk_lo  = io_clk;
  assign p_noc_clk_lo = noc_clk;
  assign p_mc_clk_lo  = mc_clk;
  assign p_tag_clk_lo = ~tag_clk; // center-aligned output clock
  
  //assign p_sel_0_o = 1'b0;
  //assign p_sel_1_o = 1'b0;

  //////////////////////////////////////////////////
  //
  // Nonsynth Reset Generator(s)
  //

  logic tag_reset;
  bsg_nonsynth_reset_gen #(.num_clocks_p(1),.reset_cycles_lo_p(10),.reset_cycles_hi_p(5))
    tag_reset_gen
      (.clk_i(tag_clk)
      ,.async_reset_o(tag_reset)
      );

  //bsg_nonsynth_reset_gen #(.num_clocks_p(1),.reset_cycles_lo_p(10),.reset_cycles_hi_p(5))
  //  clk_o_reset_gen
  //    (.clk_i(p_clk_i)
  //    ,.async_reset_o(p_clk_o_reset_o)
  //    );

  assign p_async_output_disable_lo = 1'b0;

  //////////////////////////////////////////////////
  //
  // BSG Tag Track Replay
  //

  localparam tag_trace_rom_addr_width_lp = 32;
  localparam tag_trace_rom_data_width_lp = 4+tag_num_masters_gp+tag_lg_els_gp+1+tag_lg_width_gp+tag_max_payload_width_gp;

  logic [tag_trace_rom_addr_width_lp-1:0] rom_addr_li;
  logic [tag_trace_rom_data_width_lp-1:0] rom_data_lo;

  logic                          tag_trace_valid_lo;
  logic [tag_num_masters_gp-1:0] tag_trace_en_r_lo;
  logic                          tag_trace_done_lo;

  // TAG TRACE ROM
  bsg_tag_boot_rom #(.width_p( tag_trace_rom_data_width_lp )
                    ,.addr_width_p( tag_trace_rom_addr_width_lp )
                    )
    tag_trace_rom
      (.addr_i( rom_addr_li )
      ,.data_o( rom_data_lo )
      );

  // TAG TRACE REPLAY
  bsg_tag_trace_replay #(.rom_addr_width_p   ( tag_trace_rom_addr_width_lp )
                        ,.rom_data_width_p   ( tag_trace_rom_data_width_lp )
                        ,.num_masters_p      ( tag_num_masters_gp )
                        ,.num_clients_p      ( tag_els_gp )
                        ,.max_payload_width_p( tag_max_payload_width_gp )
                        )
    tag_trace_replay
      (.clk_i   ( tag_clk )
      ,.reset_i ( tag_reset    )
      ,.en_i    ( 1'b1            )

      ,.rom_addr_o( rom_addr_li )
      ,.rom_data_i( rom_data_lo )

      ,.valid_i ( 1'b0 )
      ,.data_i  ( '0 )
      ,.ready_o ()

      ,.valid_o    ( tag_trace_valid_lo )
      ,.en_r_o     ( tag_trace_en_r_lo )
      ,.tag_data_o ( p_tag_data_lo )
      ,.yumi_i     ( tag_trace_valid_lo )

      ,.done_o  ( tag_trace_done_lo )
      ,.error_o ()
      ) ;

  assign p_tag_en_lo = tag_trace_en_r_lo[1] & tag_trace_valid_lo;

  assign tag_clk = (tag_trace_done_lo === 1'b1)? 1'b1 : tag_clk_raw;


  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance
  //

  //// All tag lines from the btm
  //bsg_tag_s [tag_els_gp-1:0] tag_lines_raw_lo;
  //wire bsg_chip_tag_lines_s tag_lines_lo = tag_lines_raw_lo;
  //
  //// BSG tag master instance
  //bsg_tag_master #(.els_p( tag_els_gp )
  //                ,.lg_width_p( tag_lg_width_gp )
  //                )
  //  btm
  //    (.clk_i      ( tag_clk )
  //    ,.data_i     ( tag_trace_en_r_lo[0] & tag_trace_valid_lo ? p_bsg_tag_data_o : 1'b0 )
  //    ,.en_i       ( 1'b1 )
  //    ,.clients_r_o( tag_lines_raw_lo )
  //    );


  //////////////////////////////////////////////////
  //
  // BSG Link Hub
  //

  // Mapping physical links to logical links
  logic [io_link_num_gp-1:0] io_link_clk_li, io_link_v_li, io_link_extra_li, io_link_tkn_lo;
  logic [io_link_num_gp-1:0][bsg_link_channel_width_gp-1:0] io_link_data_li;
  logic [io_link_num_gp-1:0] io_link_clk_lo, io_link_v_lo, io_link_extra_lo, io_link_tkn_li;
  logic [io_link_num_gp-1:0][bsg_link_channel_width_gp-1:0] io_link_data_lo;

  logic [mem_link_num_gp-1:0] mem_link_clk_li, mem_link_v_li, mem_link_extra_li, mem_link_tkn_lo;
  logic [mem_link_num_gp-1:0][bsg_link_channel_width_gp-1:0] mem_link_data_li;
  logic [mem_link_num_gp-1:0] mem_link_clk_lo, mem_link_v_lo, mem_link_extra_lo, mem_link_tkn_li;
  logic [mem_link_num_gp-1:0][bsg_link_channel_width_gp-1:0] mem_link_data_lo;

`define BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i, j)         \
    assign ``typ``_link_data_li[i][j] = p_pad_``pad``_``j``_i; \
    assign p_pad_``pad``_``j``_o = ``typ``_link_data_lo[i][j];

`define BSG_GATEWAY_CHIP_LINK_HUB(pad, typ, i)                 \
    assign ``typ``_link_clk_li  [i] = p_pad_``pad``_clk_i;     \
    assign ``typ``_link_v_li    [i] = p_pad_``pad``_v_i;       \
    assign ``typ``_link_extra_li[i] = p_pad_``pad``_extra_i;   \
    assign p_pad_``pad``_tkn_o   = ``typ``_link_tkn_lo  [i];   \
    assign p_pad_``pad``_clk_o   = ``typ``_link_clk_lo  [i];   \
    assign p_pad_``pad``_v_o     = ``typ``_link_v_lo    [i];   \
    assign p_pad_``pad``_extra_o = ``typ``_link_extra_lo[i];   \
    assign ``typ``_link_tkn_li  [i] = p_pad_``pad``_tkn_i;     \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i,  0)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i,  1)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i,  2)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i,  3)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i,  4)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i,  5)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i,  6)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i,  7)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i,  8)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i,  9)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i, 10)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i, 11)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i, 12)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i, 13)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i, 14)           \
    `BSG_GATEWAY_CHIP_LINK_HUB_DATA(pad, typ, i, 15)

  `BSG_GATEWAY_CHIP_LINK_HUB(IT0, io,   0)
  `BSG_GATEWAY_CHIP_LINK_HUB(IT1, io,   1)
  `BSG_GATEWAY_CHIP_LINK_HUB(DL0, mem,  0)
  `BSG_GATEWAY_CHIP_LINK_HUB(DL1, mem,  1)
  `BSG_GATEWAY_CHIP_LINK_HUB(DL2, mem,  2)
  `BSG_GATEWAY_CHIP_LINK_HUB(DL3, mem,  3)
  `BSG_GATEWAY_CHIP_LINK_HUB(DL4, mem,  4)
  `BSG_GATEWAY_CHIP_LINK_HUB(DL5, mem,  5)
  `BSG_GATEWAY_CHIP_LINK_HUB(DL6, mem,  6)
  `BSG_GATEWAY_CHIP_LINK_HUB(DL7, mem,  7)
  `BSG_GATEWAY_CHIP_LINK_HUB(DR0, mem,  8)
  `BSG_GATEWAY_CHIP_LINK_HUB(DR1, mem,  9)
  `BSG_GATEWAY_CHIP_LINK_HUB(DR2, mem, 10)
  `BSG_GATEWAY_CHIP_LINK_HUB(DR3, mem, 11)
  `BSG_GATEWAY_CHIP_LINK_HUB(DR4, mem, 12)
  `BSG_GATEWAY_CHIP_LINK_HUB(DR5, mem, 13)
  `BSG_GATEWAY_CHIP_LINK_HUB(DR6, mem, 14)
  `BSG_GATEWAY_CHIP_LINK_HUB(DR7, mem, 15)


  //////////////////////////////////////////////////
  //
  // BSG Chip IO
  //

  
  `declare_bsg_manycore_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  bsg_manycore_link_sif_s mc_links_sif_li, mc_links_sif_lo;

  bsg_gateway_chip_noc_io_link io_link
  (.core_clk_i                     (mc_clk)
  ,.io_clk_i                       (io_clk)
 
  ,.tag_clk_i                      (tag_clk            )
  ,.tag_data_i                     (tag_trace_en_r_lo[0] & tag_trace_valid_lo ? p_tag_data_lo : 1'b0)
  ,.tag_node_id_offset_i           ((tag_lg_els_gp)'(tag_io_link_offset_gp))
 
  ,.io_link_clk_o                  ({io_link_clk_lo [1], io_link_clk_lo [0]})
  ,.io_link_data_o                 ({io_link_data_lo[1], io_link_data_lo[0]})
  ,.io_link_v_o                    ({io_link_v_lo   [1], io_link_v_lo   [0]})
  ,.io_link_token_i                ({io_link_tkn_li [1], io_link_tkn_li [0]})
 
  ,.io_link_clk_i                  ({io_link_clk_li [1], io_link_clk_li [0]})
  ,.io_link_data_i                 ({io_link_data_li[1], io_link_data_li[0]})
  ,.io_link_v_i                    ({io_link_v_li   [1], io_link_v_li   [0]})
  ,.io_link_token_o                ({io_link_tkn_lo [1], io_link_tkn_lo [0]})
 
  ,.mc_links_sif_i                 (mc_links_sif_li)
  ,.mc_links_sif_o                 (mc_links_sif_lo)
  );

  `declare_bsg_ready_and_link_sif_s(wh_flit_width_gp, wh_link_sif_s);
  wh_link_sif_s [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0] wh_links_li, wh_links_lo;

  // Support variable number of pods when debugging for faster iteration
  for (genvar i = 0; i < hb_num_pods_y_gp*2; i++)
  begin: mem_link

    localparam idx1 = i*mem_link_rr_ratio_gp+1;
    localparam idx0 = i*mem_link_rr_ratio_gp+0;

    bsg_gateway_chip_noc_mem_link link
    (.core_clk_i                     (mc_clk)
    ,.io_clk_i                       (io_clk)
   
    ,.tag_clk_i                      (tag_clk            )
    ,.tag_data_i                     (tag_trace_en_r_lo[0] & tag_trace_valid_lo ? p_tag_data_lo : 1'b0)
    ,.tag_node_id_offset_i           ((tag_lg_els_gp)'(tag_mem_link_offset_gp+i*tag_noc_local_els_gp))
   
    ,.io_link_clk_o                  ({mem_link_clk_lo [idx1], mem_link_clk_lo [idx0]})
    ,.io_link_data_o                 ({mem_link_data_lo[idx1], mem_link_data_lo[idx0]})
    ,.io_link_v_o                    ({mem_link_v_lo   [idx1], mem_link_v_lo   [idx0]})
    ,.io_link_token_i                ({mem_link_tkn_li [idx1], mem_link_tkn_li [idx0]})
   
    ,.io_link_clk_i                  ({mem_link_clk_li [idx1], mem_link_clk_li [idx0]})
    ,.io_link_data_i                 ({mem_link_data_li[idx1], mem_link_data_li[idx0]})
    ,.io_link_v_i                    ({mem_link_v_li   [idx1], mem_link_v_li   [idx0]})
    ,.io_link_token_o                ({mem_link_tkn_lo [idx1], mem_link_tkn_lo [idx0]})
   
    ,.wh_links_i                     (wh_links_li[i])
    ,.wh_links_o                     (wh_links_lo[i])
    );

  end


  //////////////////////////////////////////////////
  //
  // HB Complex
  //

  bsg_gateway_chip_core_complex core_complex
  (.mc_clk_i        ( mc_clk            )
  ,.tag_trace_done_i( tag_trace_done_lo )
  ,.mc_links_sif_i  ( mc_links_sif_lo   )
  ,.mc_links_sif_o  ( mc_links_sif_li   )
  ,.wh_links_i      ( wh_links_lo       )
  ,.wh_links_o      ( wh_links_li       )
  );

endmodule
