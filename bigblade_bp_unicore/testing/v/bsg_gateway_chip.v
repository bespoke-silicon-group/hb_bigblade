`timescale 1ps/1ps

`ifndef BLACKPARROT_CLK_PERIOD
  `define BLACKPARROT_CLK_PERIOD 2100.0
  `define BLACKPARROT_IO_DELAY 400.0
`endif

module bsg_gateway_chip

import bsg_chip_pkg::*;

import bp_common_pkg::*;
import bp_common_aviary_pkg::*;
import bp_be_pkg::*;
import bp_me_pkg::*;
import bsg_noc_pkg::*;
import bsg_wormhole_router_pkg::*;
import bsg_manycore_pkg::*;

#(localparam bp_params_e bp_params_p = e_bp_unicore_cfg `declare_bp_proc_params(bp_params_p)
  `declare_bp_bedrock_mem_if_widths(paddr_width_p, cce_block_width_p, lce_id_width_p, lce_assoc_p, cce))
  ();


  //////////////////////////////////////////////////
  //
  // Nonsynth Clock Generator(s)
  //

  logic blackparrot_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`BLACKPARROT_CLK_PERIOD)) blackparrot_clk_gen (.o(blackparrot_clk));

  //////////////////////////////////////////////////
  //
  // Nonsynth Reset Generator(s)
  //

  logic blackparrot_reset;
  bsg_nonsynth_reset_gen #(.num_clocks_p(1),.reset_cycles_lo_p(10),.reset_cycles_hi_p(5))
    blackparrot_reset_gen
      (.clk_i(blackparrot_clk)
      ,.async_reset_o(blackparrot_reset)
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
      @(posedge blackparrot_clk);
      @(negedge blackparrot_reset);
      $asserton();
    end

  logic trigger_saif;
  initial
    begin
      $set_gate_level_monitoring("rtl_on");
      $set_toggle_region(DUT);
      @(posedge blackparrot_clk);
      @(negedge blackparrot_reset);
      @(posedge trigger_saif);
      $toggle_start();
    end

  final
    begin
      $toggle_stop();
      $toggle_report("run.saif", 1.0e-12, DUT);
    end


  //////////////////////////////////////////////////
  //
  // DUT
  //
  `declare_bp_bedrock_mem_if(paddr_width_p, cce_block_width_p, lce_id_width_p, lce_assoc_p, cce);
  bp_bedrock_cce_mem_msg_s _proc_io_resp_li;
  `declare_bsg_manycore_link_sif_s(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp);
  `declare_bsg_manycore_ruche_x_link_sif_s(mc_addr_width_gp,mc_data_width_gp,mc_x_cord_width_gp,mc_y_cord_width_gp);
  bsg_manycore_ruche_x_link_sif_s [1:0][E:E] mc_ruche_links_li, mc_ruche_links_lo;
  bsg_manycore_link_sif_s [1:0][3:0][E:E] mc_hor_links_li, mc_hor_links_lo;
  bsg_manycore_link_sif_s [S:N] mc_ver_links_li, mc_ver_links_lo;

  bsg_blackparrot_unicore_pod
   DUT
    (.bp_clk_i(blackparrot_clk)
     ,.bp_reset_i(blackparrot_reset)

     ,.mc_clk_i(blackparrot_clk)
     ,.mc_reset_i(blackparrot_reset)

     ,.my_y_pod_i('0)

     ,.mc_ruche_links_i(mc_ruche_links_li)
     ,.mc_ruche_links_o(mc_ruche_links_lo)

     ,.mc_hor_links_i(mc_hor_links_li)
     ,.mc_hor_links_o(mc_hor_links_lo)

     ,.mc_ver_links_i(mc_ver_links_lo)
     ,.mc_ver_links_o(mc_ver_links_lo)
     );

  assign trigger_saif = '0;

endmodule

