
`include "bsg_padmapping.v"
`include "bsg_iopad_macros.v"

//==============================================================================
//
// BSG CHIP
//
// This is the toplevel for the ASIC. This chip uses the HB BGA package found
// inside bsg_packaging/basejump_fcbga_785.
//

module bsg_chip

`include "bsg_pinout.v"
`include "bsg_iopads.v"

  bsg_chip_block block (.*);

endmodule
