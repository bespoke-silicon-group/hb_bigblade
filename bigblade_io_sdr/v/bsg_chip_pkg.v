`ifndef BSG_CHIP_PKG_V
`define BSG_CHIP_PKG_V

package bsg_chip_pkg;

  `include "bsg_defines.v"

  // sdr link parameters
  localparam lg_fifo_depth_gp = 3;
  localparam lg_credit_to_token_decimation_gp = 0;

  // manycore parameters
  parameter x_cord_width_gp = 7; // (global X)
  parameter y_cord_width_gp = 7; // (global Y)
  parameter addr_width_gp   = 28; // word addr
  parameter data_width_gp   = 32;
  parameter ruche_factor_X_gp = 3;
  parameter tieoff_west_not_east_gp = 0;

endpackage // bsg_chip_pkg

`endif // BSG_CHIP_PKG_V
