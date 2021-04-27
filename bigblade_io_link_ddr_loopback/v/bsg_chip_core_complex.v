
module bsg_chip_core_complex

 import bsg_chip_pkg::*;
 import bsg_noc_pkg::*;

  (input  bsg_chip_io_link_sif_s [io_link_num_gp-1:0] io_links_i
  ,output bsg_chip_io_link_sif_s [io_link_num_gp-1:0] io_links_o
  ,input  bsg_chip_mem_link_sif_s [mem_link_num_gp-1:0] mem_links_i
  ,output bsg_chip_mem_link_sif_s [mem_link_num_gp-1:0] mem_links_o
  );


  //////////////////////////////////////////////////
  //
  // Loopback
  //

  assign io_links_o  = io_links_i;
  assign mem_links_o = mem_links_i;

endmodule