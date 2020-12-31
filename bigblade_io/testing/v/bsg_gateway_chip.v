`timescale 1ps/1ps

`ifdef CORNER_SS
  `define HB_SLOWDOWN_RATIO 256
  `define HB_SPMD_RATIO 16
  `define HB_CLK_PERIOD 1020
  `define IO_MASTER_CLK_PERIOD 1724
  `define ROUTER_CLK_PERIOD 1724
  `define TAG_CLK_PERIOD 6896
`else
  `define HB_SLOWDOWN_RATIO 16
  `define HB_SPMD_RATIO 1
  `define HB_CLK_PERIOD 15000
  `define IO_MASTER_CLK_PERIOD 1724
  `define ROUTER_CLK_PERIOD 1724
  `define TAG_CLK_PERIOD 6896
`endif

module bsg_gateway_chip

import bsg_tag_pkg::*;
import bsg_chip_pkg::*;
import bsg_noc_pkg::*;

`include "bsg_pinout_inverted.v"


  //////////////////////////////////////////////////
  //
  // Nonsynth Clock Generator(s)
  //
  
  // To speed up simulation, slow down manycore clock when programming tag_clients
  logic manycore_clk_fast, manycore_clk_slow, manycore_clk_spmd, manycore_clk;
  logic init_done_lo, loader_done_lo;
  
  assign manycore_clk = (init_done_lo)? ((loader_done_lo)? manycore_clk_fast : manycore_clk_spmd) : manycore_clk_slow;
  
  bsg_nonsynth_clock_gen #(.cycle_time_p(`MANYCORE_CLK_PERIOD)) manycore_clk_fast_gen (.o(manycore_clk_fast));
  bsg_nonsynth_clock_gen #(.cycle_time_p(`MANYCORE_CLK_PERIOD*`MANYCORE_SLOWDOWN_RATIO)) manycore_clk_slow_gen (.o(manycore_clk_slow));
  bsg_nonsynth_clock_gen #(.cycle_time_p(`MANYCORE_CLK_PERIOD*`MANYCORE_SPMD_RATIO)) manycore_clk_spmd_gen (.o(manycore_clk_spmd));
  
  logic io_master_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`IO_MASTER_CLK_PERIOD)) io_master_clk_gen (.o(io_master_clk));

  logic router_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`ROUTER_CLK_PERIOD)) router_clk_gen (.o(router_clk));

  logic tag_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`TAG_CLK_PERIOD)) tag_clk_gen (.o(tag_clk));
  
  
  //////////////////////////////////////////////////
  //
  // Gateway Core
  //

  logic [`NUM_ASIC-1:0] mc_reset_lo;
  bsg_manycore_link_sif_s [`NUM_ASIC-1:0] links_sif_li, links_sif_lo;
  
  bsg_gateway_chip_core 
   #(.num_asic_p(`NUM_ASIC)
    ) gw_core
    (.mc_clk_i       ( manycore_clk )
    ,.mc_reset_o     ( mc_reset_lo )
    ,.init_done_o    ( init_done_lo )
    
    ,.io_master_clk_i( io_master_clk )
    ,.router_clk_i   ( router_clk )
    ,.tag_clk_i      ( tag_clk )
  
    ,.mc_links_sif_i ( links_sif_lo )
    ,.mc_links_sif_o ( links_sif_li )
    
    ,.ci_clk_i  ( p_ci_clk_i )
    ,.ci_v_i    ( p_ci_v_i )
    ,.ci_data_i ( {p_ci_8_i, p_ci_7_i, p_ci_6_i, p_ci_5_i, p_ci_4_i, p_ci_3_i, p_ci_2_i, p_ci_1_i, p_ci_0_i} )
    ,.ci_tkn_o  ( p_ci_tkn_o )
  
    ,.ci2_clk_o ( p_ci2_clk_o )
    ,.ci2_v_o   ( p_ci2_v_o )
    ,.ci2_data_o( {p_ci2_8_o, p_ci2_7_o, p_ci2_6_o, p_ci2_5_o, p_ci2_4_o, p_ci2_3_o, p_ci2_2_o, p_ci2_1_o, p_ci2_0_o} )
    ,.ci2_tkn_i ( p_ci2_tkn_i )
  
    ,.co_clk_i  ( p_co_clk_i )
    ,.co_v_i    ( p_co_v_i )
    ,.co_data_i ( {p_co_8_i, p_co_7_i, p_co_6_i, p_co_5_i, p_co_4_i, p_co_3_i, p_co_2_i, p_co_1_i, p_co_0_i} )
    ,.co_tkn_o  ( p_co_tkn_o )
  
    ,.co2_clk_o ( p_co2_clk_o )
    ,.co2_v_o   ( p_co2_v_o )
    ,.co2_data_o( {p_co2_8_o, p_co2_7_o, p_co2_6_o, p_co2_5_o, p_co2_4_o, p_co2_3_o, p_co2_2_o, p_co2_1_o, p_co2_0_o} )
    ,.co2_tkn_i ( p_co2_tkn_i )
    
    ,.tag_clk_o ( p_bsg_tag_clk_o )
    ,.tag_en_o  ( {p_sel_2_o, p_bsg_tag_en_o} )
    ,.tag_data_o( p_bsg_tag_data_o )
  
    ,.clk_a_o   ( p_clk_A_o )
    ,.clk_b_o   ( p_clk_B_o )
    ,.clk_c_o   ( p_clk_C_o )
    );
    
    assign p_sel_0_o = 1'b0;
    assign p_sel_1_o = 1'b0;


  //////////////////////////////////////////////////
  //
  // Manycore SPMD Loader
  //
  
  genvar i;
  
  for (i = 0; i < `NUM_ASIC; i++)
  begin: multi_asic

  bsg_nonsynth_manycore_io_complex #(
    .addr_width_p( manycore_addr_width_gp )
    ,.data_width_p( manycore_data_width_gp )
    ,.load_id_width_p( manycore_load_id_width_gp )
    ,.x_cord_width_p( manycore_x_cord_width_gp )
    ,.y_cord_width_p( manycore_y_cord_width_gp )

    ,.num_tiles_x_p(manycore_num_tiles_x_gp)
    ,.num_tiles_y_p(manycore_num_tiles_y_gp)

  ) manycore_io (
    .clk_i(manycore_clk)
    ,.reset_i(mc_reset_lo[i] | ~init_done_lo)
    ,.loader_done_o(loader_done_lo)
    ,.io_link_sif_i(links_sif_li[i])
    ,.io_link_sif_o(links_sif_lo[i])
  );

  end

endmodule
