`timescale 1ps/1ps

`ifndef BLACKPARROT_CLK_PERIOD
  `define BLACKPARROT_CLK_PERIOD 2100.0
`endif


  //////////////////////////////////////////////////
  // This testbench is structured like this, with the overlying network being
  //   a giant crossbar and infinite memories instead of vcaches
  // [ IO ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ]
  // [ BP ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  // [ BP ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  // [ BP ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ] 
  // [ BP ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  // [ 00 ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ]

module bsg_gateway_chip
 import bsg_chip_pkg::*;

 import bp_common_pkg::*;
 import bp_common_aviary_pkg::*;
 import bp_be_pkg::*;
 import bp_me_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_wormhole_router_pkg::*;
 import bsg_manycore_pkg::*;
 import bsg_tag_pkg::*;

 #(localparam bp_params_e bp_params_p = e_bp_unicore_cfg `declare_bp_proc_params(bp_params_p)
  `declare_bp_bedrock_mem_if_widths(paddr_width_p, cce_block_width_p, lce_id_width_p, lce_assoc_p, cce))
  ();

  //////////////////////////////////////////////////
  //
  // Nonsynth Clock Generator(s)
  //

  logic clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`BLACKPARROT_CLK_PERIOD)) clk_gen (.o(clk));

  //////////////////////////////////////////////////
  //
  // Nonsynth Reset Generator(s)
  //

  logic reset;
  bsg_nonsynth_reset_gen #(.num_clocks_p(1),.reset_cycles_lo_p(10),.reset_cycles_hi_p(5))
    reset_gen
      (.clk_i(clk)
      ,.async_reset_o(reset)
      );

  //////////////////////////////////////////////////
  //
  // Waveform Dump
  //

  initial
    begin
      $vcdpluson;
      $vcdplusmemon;
      $vcdplusautoflushon;
    end

  initial
    begin
      $assertoff();
      @(posedge clk);
      @(negedge reset);
      $asserton();
    end

  logic trigger_saif;
  initial
    begin
      $set_gate_level_monitoring("rtl_on");
      $set_toggle_region(DUT);
      @(posedge clk);
      @(negedge reset);
      @(posedge trigger_saif);
      $toggle_start();
    end

  final
    begin
      $toggle_stop();
      $toggle_report("run.saif", 1.0e-12, DUT);
    end
  assign trigger_saif = '0;

  //////////////////////////////////////////////////
  //
  // bsg_tag
  localparam num_clients_lp = 4;
  localparam payload_width_lp = 7;
  localparam max_payload_width_lp = 10;
  localparam lg_payload_width_lp = `BSG_WIDTH(max_payload_width_lp);
  localparam rom_data_width_lp = 4+1+`BSG_SAFE_CLOG2(num_clients_lp)+1+lg_payload_width_lp+max_payload_width_lp;
  localparam rom_addr_width_lp = 12;
  
  logic tr_valid_lo, tr_data_lo, tr_done_lo;
  logic [rom_data_width_lp-1:0] rom_data;
  logic [rom_addr_width_lp-1:0] rom_addr;
  bsg_tag_trace_replay
   #(.rom_addr_width_p(rom_addr_width_lp)
     ,.rom_data_width_p(rom_data_width_lp)
     ,.num_clients_p(num_clients_lp)
     ,.max_payload_width_p(max_payload_width_lp)
     )
   tr
    (.clk_i(clk)
     ,.reset_i(reset)
     ,.en_i(1'b1)

     ,.rom_addr_o(rom_addr)
     ,.rom_data_i(rom_data)

     ,.valid_i(1'b0)
     ,.data_i('0)
     ,.ready_o()

     ,.valid_o(tr_valid_lo)
     ,.en_r_o()
     ,.tag_data_o(tr_data_lo)
     ,.yumi_i(tr_valid_lo)
     
     ,.done_o(tr_done_lo)
     ,.error_o()
     );  

  bsg_nonsynth_test_rom
   #(.filename_p("trace.tr")
     ,.data_width_p(rom_data_width_lp)
     ,.addr_width_p(rom_addr_width_lp)
     )
   rom
    (.addr_i(rom_addr)
     ,.data_o(rom_data)
     );

  bsg_tag_s [3:0] bsg_tag_li;
  bsg_tag_master
   #(.els_p(num_clients_lp), .lg_width_p(lg_payload_width_lp))
   btm
    (.clk_i(clk)
     ,.data_i(tr_valid_lo & tr_data_lo)
     ,.en_i(1'b1)
     ,.clients_r_o(bsg_tag_li)
     );

  //////////////////////////////////////////////////
  //
  // DUT
  //
  // TODO: Connect to test node
  bsg_chip
   DUT
   (.uplink_clk_i
   ,.uplink_reset_i
   ,.async_token_reset_i
   ,.uplink_data_i
   ,.uplink_v_i
   ,.uplink_ready_o

   ,.link_clk_o
   ,.link_data_o
   ,.link_v_o
   ,.link_token_i

   ,.downstream_clk_i
   ,.downstream_reset_i
   ,.downstream_data_o
   ,.downstream_v_o
   ,.downstream_ready_i

   ,.link_clk_i
   ,.link_data_i
   ,.link_v_i
   ,.link_token_o
   );

endmodule

