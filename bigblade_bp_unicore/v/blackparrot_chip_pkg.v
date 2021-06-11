`ifndef BLACKPARROT_CHIP_PKG_V
`define BLACKPARROT_CHIP_PKG_V

package blackparrot_chip_pkg;

  `include "bp_common_defines.svh"

  import bp_common_pkg::*;
  import bsg_tag_pkg::*;

  //////////////////////////////////////////////////
  //
  // BSG BLACKPARROT PARAMETERS
  //
  
  localparam bp_params_e bp_cfg_gp = e_bp_bigblade_unicore_cfg;

  // Number of outstanding MMIO requests to manycore
  localparam mc_max_outstanding_host_gp = 4;
  localparam mc_max_outstanding_dram_gp = 8;

endpackage // blackparrot_chip_pkg

`endif // BLACKPARROT_CHIP_PKG_V

