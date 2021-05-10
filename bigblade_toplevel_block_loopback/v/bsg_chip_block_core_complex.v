
module bsg_chip_block_core_complex

 import bsg_chip_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_manycore_pkg::*;

 #(parameter mc_fwd_width_lp =
    `bsg_manycore_packet_width(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp)
  ,parameter mc_rev_width_lp =
    `bsg_manycore_return_packet_width(hb_x_cord_width_gp,hb_y_cord_width_gp,hb_data_width_gp)
  ,parameter total_num_tiles_x_lp = (hb_num_pods_x_gp*hb_num_tiles_x_gp)
  )

  (input  [hb_num_pods_y_gp-1:0]   mc_clk_i
  ,input                           tag_clk_i
  ,input                           tag_data_i

  ,output                          mc_fwd_link_clk_o
  ,output [mc_fwd_width_lp-1:0]    mc_fwd_link_data_o
  ,output                          mc_fwd_link_v_o
  ,input                           mc_fwd_link_token_i

  ,input                           mc_fwd_link_clk_i
  ,input  [mc_fwd_width_lp-1:0]    mc_fwd_link_data_i
  ,input                           mc_fwd_link_v_i
  ,output                          mc_fwd_link_token_o

  ,output                          mc_rev_link_clk_o
  ,output [mc_rev_width_lp-1:0]    mc_rev_link_data_o
  ,output                          mc_rev_link_v_o
  ,input                           mc_rev_link_token_i

  ,input                           mc_rev_link_clk_i
  ,input  [mc_rev_width_lp-1:0]    mc_rev_link_data_i
  ,input                           mc_rev_link_v_i
  ,output                          mc_rev_link_token_o

  ,output [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_clk_o
  ,output [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0] wh_link_data_o
  ,output [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_v_o
  ,input  [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_token_i

  ,input  [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_clk_i
  ,input  [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0] wh_link_data_i
  ,input  [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_v_i
  ,output [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_token_o
  );

  assign mc_fwd_link_clk_o   = mc_fwd_link_clk_i;
  assign mc_fwd_link_data_o  = mc_fwd_link_data_i;
  assign mc_fwd_link_v_o     = mc_fwd_link_v_i;
  assign mc_fwd_link_token_o = mc_fwd_link_token_i;

  assign mc_rev_link_clk_o   = mc_rev_link_clk_i;
  assign mc_rev_link_data_o  = mc_rev_link_data_i;
  assign mc_rev_link_v_o     = mc_rev_link_v_i;
  assign mc_rev_link_token_o = mc_rev_link_token_i;

  assign wh_link_clk_o   = wh_link_clk_i;
  assign wh_link_data_o  = wh_link_data_i;
  assign wh_link_v_o     = wh_link_v_i;
  assign wh_link_token_o = wh_link_token_i;

endmodule
