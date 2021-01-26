
module bsg_chip_core_complex

 import bsg_chip_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_manycore_pkg::*;

  (input                      hb_clk_i
  ,input                      router_clk_i
  ,input bsg_chip_tag_lines_s tag_lines_i

  ,input  tag_clk_i
  ,input  tag_data_i
  ,input  tag_en_i

  ,input  bsg_chip_io_link_sif_s [io_link_num_gp-1:0][io_ct_num_in_gp-1:0] io_links_i
  ,output bsg_chip_io_link_sif_s [io_link_num_gp-1:0][io_ct_num_in_gp-1:0] io_links_o

  ,input  bsg_chip_mem_link_sif_s [mem_link_num_gp-1:0] mem_links_i
  ,output bsg_chip_mem_link_sif_s [mem_link_num_gp-1:0] mem_links_o
  );

  //////////////////////////////////////////////////
  //
  // BSG Tag Client Instance
  //

  // Tag payload for hb control signals
  typedef struct packed { 
      logic padding;
      logic reset;
  } hb_tag_payload_s;

  hb_tag_payload_s hb_tag_data_lo;
  logic            hb_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(hb_tag_data_lo) ), .default_p( 0 ))
    btc_hb
      (.bsg_tag_i     ( tag_lines_i.hb_reset )
      ,.recv_clk_i    ( hb_clk_i )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( hb_tag_new_data_lo )
      ,.recv_data_r_o ( hb_tag_data_lo )
      );

  // Tag payload for router control signals
  typedef struct packed { 
      logic padding;
      logic reset;
  } router_tag_payload_s;

  router_tag_payload_s router_tag_data_lo;
  logic                router_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(router_tag_data_lo) ), .default_p( 0 ))
    btc_router
      (.bsg_tag_i     ( tag_lines_i.router_reset )
      ,.recv_clk_i    ( router_clk_i )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( router_tag_new_data_lo )
      ,.recv_data_r_o ( router_tag_data_lo )
      );


  //////////////////////////////////////////////////
  //
  // Loopback
  //

  assign io_links_o  = io_links_i;
  assign mem_links_o = mem_links_i;

endmodule