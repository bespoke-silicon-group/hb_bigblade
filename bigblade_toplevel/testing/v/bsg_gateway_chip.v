`timescale 1ps/1ps

`define IO_CLK_PERIOD  10000
`define NOC_CLK_PERIOD 10000
`define MC_CLK_PERIOD  10000
`define BP_CLK_PERIOD  10000
`define CGRA_CLK_PERIOD 10000
`define TAG_CLK_PERIOD 20000

// Slow down core clocks when tag is programming, divide clock speed by the given ratio
//
// We cannot slow down the clock too much, since we'll need time for reset signals to
// go through the synchronizers. Shortest tag packet can be 16-bits long, which takes
// 16 cycles to be sent out. Since the synchronizer we use takes 2 cycles to sync, the
// maximum possible slowdown ratio is (16*TAG_CLK_PERIOD)/(2*CLK_PERIOD).
//
// Note that we use DDR clock for off-chip links, so the maximum ratio for IO is
// (16*TAG_CLK_PERIOD)/(2*2*IO_CLK_PERIOD).
//
// The downsampler in this testbench supports slowdown ratio up to 1024
//
`define IO_SLOWDOWN_RATIO  8
`define NOC_SLOWDOWN_RATIO 16
`define MC_SLOWDOWN_RATIO  16
`define BP_SLOWDOWN_RATIO  16
`define CGRA_SLOWDOWN_RATIO 16

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

  wire p_async_output_disable_lo;
  wire p_tag_clk_lo, p_tag_data_lo, p_tag_en_lo;
  assign p_pad_CT0_v_o = p_async_output_disable_lo;
  assign p_pad_CT0_0_o = p_tag_clk_lo;
  assign p_pad_CT0_1_o = p_tag_data_lo;
  assign p_pad_CT0_2_o = p_tag_en_lo;

  wire p_io_clk_lo, p_noc_clk_lo, p_mc_clk_lo, p_bp_clk_lo, p_cgra_clk_lo;
  assign p_pad_CT0_clk_o = p_io_clk_lo;
  assign p_pad_CT0_tkn_o = p_noc_clk_lo;
  assign {p_pad_ML0_3_o, p_pad_ML0_2_o, p_pad_ML0_1_o, p_pad_ML0_0_o} = {(hb_num_pods_y_gp){p_mc_clk_lo}};
  assign p_pad_ML0_4_o = p_bp_clk_lo;
  assign p_pad_MR0_0_o = p_cgra_clk_lo;

  wire p_mc_clk_monitor_li = p_pad_CT0_0_i;
  wire p_noc_io_clk_monitor_li = p_pad_CT0_1_i;
  wire p_noc_mem_clk_monitor_li = p_pad_CT0_2_i;
  wire p_bp_clk_monitor_li = p_pad_CB0_0_i;
  wire p_cgra_clk_monitor_li = p_pad_CB0_1_i;

  assign {p_pad_CT0_4_o, p_pad_CT0_3_o} = 2'b00; // mc clk monitor sel
  assign {p_pad_CT0_7_o, p_pad_CT0_6_o, p_pad_CT0_5_o} = 3'b000; // noc mem clk monitor sel
  assign {p_pad_CB0_2_o, p_pad_CB0_1_o, p_pad_CB0_0_o} = 3'b000; // bp clk monitor sel
  assign {p_pad_CB0_5_o, p_pad_CB0_4_o, p_pad_CB0_3_o} = 3'b000; // cgra mem clk monitor sel

  //////////////////////////////////////////////////
  //
  // Nonsynth Clock Generator(s)
  //
  // 2x clocks generated for downsamplers
  //
  
  logic io_clk, io_clk_2x;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`IO_CLK_PERIOD/2)) io_clk_gen (.o(io_clk_2x));
  
  logic noc_clk, noc_clk_2x;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`NOC_CLK_PERIOD/2)) noc_clk_gen (.o(noc_clk_2x));

  logic mc_clk, mc_clk_2x;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`MC_CLK_PERIOD/2)) mc_clk_gen (.o(mc_clk_2x));

  logic bp_clk, bp_clk_2x;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`BP_CLK_PERIOD/2)) bp_clk_gen (.o(bp_clk_2x));

  logic cgra_clk, cgra_clk_2x;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`CGRA_CLK_PERIOD/2)) cgra_clk_gen (.o(cgra_clk_2x));

  logic tag_clk, tag_clk_raw;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`TAG_CLK_PERIOD)) tag_clk_gen (.o(tag_clk_raw));

  assign p_io_clk_lo  = io_clk;
  assign p_noc_clk_lo = noc_clk;
  assign p_mc_clk_lo  = mc_clk;
  assign p_bp_clk_lo  = bp_clk;
  assign p_cgra_clk_lo = cgra_clk;
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

  // Shutdown tag clk after programming to speedup simulation
  assign tag_clk = (tag_trace_done_lo === 1'b1)? 1'b1 : tag_clk_raw;

  // When tag is programming, slow down other clocks to speed up simulation
  // With dynamic downsampler, there will be no glitch and no double-edges
  // problem in simulation
  //
  // output_freq = input_freq/((ds_val+1)*2)
  //
  wire [9:0] io_ds_val, noc_ds_val, mc_ds_val, bp_ds_val, cgra_ds_val;
  assign io_ds_val  = (tag_trace_done_lo)? 0 : `IO_SLOWDOWN_RATIO-1;
  assign noc_ds_val = (tag_trace_done_lo)? 0 : `NOC_SLOWDOWN_RATIO-1;
  assign mc_ds_val  = (tag_trace_done_lo)? 0 : `MC_SLOWDOWN_RATIO-1;
  assign bp_ds_val  = (tag_trace_done_lo)? 0 : `BP_SLOWDOWN_RATIO-1;
  assign cgra_ds_val = (tag_trace_done_lo)? 0 : `CGRA_SLOWDOWN_RATIO-1;

  bsg_counter_clock_downsample #(.width_p(10)) io_ds
  (.clk_i(io_clk_2x),.reset_i(tag_reset),.val_i(io_ds_val),.clk_r_o(io_clk));
  bsg_counter_clock_downsample #(.width_p(10)) noc_ds
  (.clk_i(noc_clk_2x),.reset_i(tag_reset),.val_i(noc_ds_val),.clk_r_o(noc_clk));
  bsg_counter_clock_downsample #(.width_p(10)) mc_ds
  (.clk_i(mc_clk_2x),.reset_i(tag_reset),.val_i(mc_ds_val),.clk_r_o(mc_clk));
  bsg_counter_clock_downsample #(.width_p(10)) bp_ds
  (.clk_i(bp_clk_2x),.reset_i(tag_reset),.val_i(bp_ds_val),.clk_r_o(bp_clk));
  bsg_counter_clock_downsample #(.width_p(10)) cgra_ds
  (.clk_i(cgra_clk_2x),.reset_i(tag_reset),.val_i(cgra_ds_val),.clk_r_o(cgra_clk));


  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance
  //

  bsg_tag_s tag_lines_lo;
  bsg_tag_master_decentralized
 #(.els_p      (tag_els_gp)
  ,.local_els_p(1)
  ,.lg_width_p (tag_lg_width_gp)
  ) btm
  (.clk_i           (tag_clk)
  ,.data_i          (tag_trace_en_r_lo[0] & tag_trace_valid_lo ? p_tag_data_lo : 1'b0)
  ,.node_id_offset_i((tag_lg_els_gp)'(2))
  ,.clients_o       (tag_lines_lo)
  );

  bsg_tag_client_unsync #(.width_p(1)) btc
  (.bsg_tag_i     (tag_lines_lo)
  ,.data_async_r_o(p_async_output_disable_lo));


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


`define clock_printer(clk)                                     \
  always @(posedge clk) begin                                  \
    int fd;                                                    \
    reg [63:0] t;                                              \
    t = 0;                                                     \
    $system("date +%s%3N > date.txt");                         \
    fd=$fopen("date.txt","r");                                 \
    $fscanf(fd, "%d", t);                                      \
    $fclose(fd);                                               \
    $display("%-10s: tick: time (ms) = %d, ps = %t", `BSG_STRINGIFY(`clk), t, $time); \
  end

  `ifdef PRINT_MC_CLK
  `clock_printer(mc_clk);
  `endif
  `ifdef PRINT_IO_CLK
  `clock_printer(io_clk);
  `endif
  `ifdef PRINT_NOC_CLK
  `clock_printer(noc_clk);
  `endif
  `ifdef PRINT_TAG_CLK
  `clock_printer(tag_clk);
  `endif
  
endmodule
