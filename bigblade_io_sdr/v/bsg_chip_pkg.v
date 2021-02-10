`ifndef BSG_CHIP_PKG_V
`define BSG_CHIP_PKG_V

package bsg_chip_pkg;

  `include "bsg_defines.v"

  localparam width_gp = 96;
  localparam lg_fifo_depth_gp = 3;
  localparam lg_credit_to_token_decimation_gp = 0;

endpackage // bsg_chip_pkg

`endif // BSG_CHIP_PKG_V

