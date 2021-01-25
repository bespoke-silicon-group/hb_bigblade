`timescale 1ps/1ps

`define HB_CLK_PERIOD 10000
`define BP_CLK_PERIOD 10000
`define ROUTER_CLK_PERIOD 10000
`define TAG_CLK_PERIOD 20000

module bsg_gateway_chip

 import bsg_chip_pkg::*;
 import bsg_tag_pkg::*;

`include "bsg_pinout_inverted.v"


  //////////////////////////////////////////////////
  //
  // Control Wires Hub
  //

  wire p_bsg_tag_clk_o, p_bsg_tag_en_o, p_bsg_tag_data_o;
  assign p_pad_CT0_0_o = p_bsg_tag_clk_o;
  assign p_pad_CT0_1_o = p_bsg_tag_en_o;
  assign p_pad_CT0_2_o = p_bsg_tag_data_o;

  wire p_clk_A_o, p_clk_B_o, p_clk_C_o;
  assign p_pad_CT0_3_o = p_clk_A_o;
  assign p_pad_CT0_4_o = p_clk_B_o;
  assign p_pad_CT0_5_o = p_clk_C_o;

  wire p_sel_0_o, p_sel_1_o, p_clk_output_disable_o;
  assign p_pad_CT0_6_o = p_sel_0_o;
  assign p_pad_CT0_7_o = p_sel_1_o;
  assign p_pad_CT0_v_o = p_clk_output_disable_o;


  //////////////////////////////////////////////////
  //
  // Nonsynth Clock Generator(s)
  //
  
  logic hb_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`HB_CLK_PERIOD)) hb_clk_gen (.o(hb_clk));
  
  logic bp_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`BP_CLK_PERIOD)) bp_clk_gen (.o(bp_clk));

  logic router_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`ROUTER_CLK_PERIOD)) router_clk_gen (.o(router_clk));

  logic tag_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`TAG_CLK_PERIOD)) tag_clk_gen (.o(tag_clk));

  assign p_clk_A_o = hb_clk;
  assign p_clk_B_o = bp_clk;
  assign p_clk_C_o = router_clk;
  assign p_bsg_tag_clk_o = ~tag_clk;
  
  assign p_sel_0_o = 1'b0;
  assign p_sel_1_o = 1'b0;
  
  // FIXME: Change to proper clock
  wire bsg_link_io_clk_lo = router_clk;

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

  assign p_clk_output_disable_o = 1'b0;

  //////////////////////////////////////////////////
  //
  // BSG Tag Track Replay
  //

  localparam tag_trace_rom_addr_width_lp = 32;
  localparam tag_trace_rom_data_width_lp = 4+tag_num_masters_gp+`BSG_SAFE_CLOG2(tag_num_clients_gp)+1+tag_lg_max_payload_width_gp+tag_max_payload_width_gp;

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
                        ,.num_clients_p      ( tag_num_clients_gp )
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
      ,.tag_data_o ( p_bsg_tag_data_o )
      ,.yumi_i     ( tag_trace_valid_lo )

      ,.done_o  ( tag_trace_done_lo )
      ,.error_o ()
      ) ;

  assign p_bsg_tag_en_o = tag_trace_en_r_lo[1] & tag_trace_valid_lo;
  
  logic init_done_lo;
  bsg_launch_sync_sync #(.width_p(1)) done_blss
   (.iclk_i       ( tag_clk )
    ,.iclk_reset_i( 1'b0 )
    ,.oclk_i      ( hb_clk )
    ,.iclk_data_i ( tag_trace_done_lo )
    ,.iclk_data_o (  )
    ,.oclk_data_o ( init_done_lo )
    );

  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance (Copied from ASIC)
  //

  // All tag lines from the btm
  bsg_tag_s [tag_num_clients_gp-1:0] tag_lines_raw_lo;
  wire bsg_chip_tag_lines_s tag_lines_lo = tag_lines_raw_lo;

  // BSG tag master instance
  bsg_tag_master #(.els_p( tag_num_clients_gp )
                  ,.lg_width_p( tag_lg_max_payload_width_gp )
                  )
    btm
      (.clk_i      ( tag_clk )
      ,.data_i     ( tag_trace_en_r_lo[0] & tag_trace_valid_lo ? p_bsg_tag_data_o : 1'b0 )
      ,.en_i       ( 1'b1 )
      ,.clients_r_o( tag_lines_raw_lo )
      );


  //////////////////////////////////////////////////
  //
  // BSG Link Hub
  //

  // Mapping physical links to logical links
  logic [io_link_num_gp-1:0] io_link_clk_li, io_link_v_li, io_link_extra_li, io_link_tkn_lo;
  logic [io_link_num_gp-1:0][io_link_channel_width_gp-1:0] io_link_data_li;
  logic [io_link_num_gp-1:0] io_link_clk_lo, io_link_v_lo, io_link_extra_lo, io_link_tkn_li;
  logic [io_link_num_gp-1:0][io_link_channel_width_gp-1:0] io_link_data_lo;

  logic [mem_link_num_gp-1:0] mem_link_clk_li, mem_link_v_li, mem_link_extra_li, mem_link_tkn_lo;
  logic [mem_link_num_gp-1:0][mem_link_channel_width_gp-1:0] mem_link_data_li;
  logic [mem_link_num_gp-1:0] mem_link_clk_lo, mem_link_v_lo, mem_link_extra_lo, mem_link_tkn_li;
  logic [mem_link_num_gp-1:0][mem_link_channel_width_gp-1:0] mem_link_data_lo;

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

  bsg_chip_io_link_sif_s [io_link_num_gp-1:0][io_ct_num_in_gp-1:0] io_links_li, io_links_lo;
  bsg_chip_mem_link_sif_s [mem_link_num_gp-1:0] mem_links_li, mem_links_lo;

  for (genvar i = 0; i < io_link_num_gp; i++)
  begin: io_link
    bsg_gateway_chip_io_links_ct_fifo 
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
    (.core_clk_i ( hb_clk )
    ,.io_clk_i   ( bsg_link_io_clk_lo )
   
    ,.link_io_tag_lines_i   ( tag_lines_lo.io_link_io[i] )
    ,.link_core_tag_lines_i ( tag_lines_lo.io_link_core[i] )
   
    ,.link_clk_i ( {io_link_clk_li[i], io_link_extra_li[i]} )
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
    bsg_gateway_chip_io_links_ct_fifo 
   #(.link_width_p                        ( mem_link_width_gp         )
    ,.link_channel_width_p                ( mem_link_channel_width_gp )
    ,.link_num_channels_p                 ( mem_link_num_channels_gp  )
    ,.link_lg_fifo_depth_p                ( mem_link_lg_fifo_depth_gp )
    ,.link_lg_credit_to_token_decimation_p( mem_link_lg_credit_to_token_decimation_gp )
    ,.link_use_extra_data_bit_p           ( mem_link_use_extra_data_bit_gp )
    ,.ct_bypass_p                         ( 1 )
    ,.num_hops_p                          ( 1 )
    ) link
    (.core_clk_i ( hb_clk )
    ,.io_clk_i   ( bsg_link_io_clk_lo )
   
    ,.link_io_tag_lines_i   ( tag_lines_lo.mem_link_io[i] )
    ,.link_core_tag_lines_i ( tag_lines_lo.mem_link_core[i] )
   
    ,.link_clk_i ( {mem_link_clk_li[i], mem_link_extra_li[i]} )
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

  bsg_gateway_chip_core_complex core_complex
  (.hb_clk_i        ( hb_clk            )
  ,.tag_lines_i     ( tag_lines_lo      )
  ,.tag_trace_done_i( tag_trace_done_lo )

  ,.tag_clk_i       ( tag_clk           )
  ,.tag_data_i      ( p_bsg_tag_data_o  )
  ,.tag_en_i        ( tag_trace_en_r_lo[0] & tag_trace_valid_lo )

  ,.io_links_i      ( io_links_lo       )
  ,.io_links_o      ( io_links_li       )
  ,.mem_links_i     ( mem_links_lo      )
  ,.mem_links_o     ( mem_links_li      )
  );

endmodule
