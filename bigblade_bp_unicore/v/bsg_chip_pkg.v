`ifndef BSG_CHIP_PKG_V
`define BSG_CHIP_PKG_V

package bsg_chip_pkg;

  `include "bsg_defines.v"

  import bp_common_aviary_pkg::*;

  //////////////////////////////////////////////////
  //
  // BSG BLACKPARROT PARAMETERS
  //
  
  localparam bp_params_e bp_cfg_gp = e_bp_unicore_no_l2_cfg;

  localparam mc_num_tiles_x_gp = 16;
  localparam mc_num_tiles_y_gp = 8;

  localparam mc_x_cord_width_gp = 7;
  localparam mc_y_cord_width_gp = 7;
  localparam mc_x_subcord_width_gp = `BSG_SAFE_CLOG2(mc_num_tiles_x_gp);
  localparam mc_y_subcord_width_gp = `BSG_SAFE_CLOG2(mc_num_tiles_y_gp);
  localparam pod_x_cord_width_gp = 3;
  localparam pod_y_cord_width_gp = 4;
  localparam bp_x_cord_width_gp = 0;
  localparam bp_y_cord_width_gp = 1;
  
  localparam mc_addr_width_gp = 28;
  localparam mc_data_width_gp = 32;

  localparam mc_num_pods_x_gp = 4;
  localparam mc_num_pods_y_gp = 4;

  localparam ruche_factor_X_gp = 3;

  localparam mc_vcache_ways_gp = 4;
  localparam mc_vcache_sets_gp = 64;
  localparam mc_vcache_block_size_in_words_gp = 8;
  localparam mc_vcache_size_gp = mc_vcache_ways_gp*mc_vcache_sets_gp*mc_vcache_block_size_in_words_gp;
  localparam mc_vcache_dma_data_width_gp = mc_data_width_gp;

endpackage // bsg_chip_pkg

`endif // BSG_CHIP_PKG_V

