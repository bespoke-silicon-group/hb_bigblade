
`include "bp_common_defines.svh"
`include "bp_me_defines.svh"

module bsg_blackparrot_halfpod
 import bsg_chip_pkg::*;
 import bsg_mesh_router_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_manycore_pkg::*;
 import bp_common_pkg::*;
 import bp_me_pkg::*;
 #(localparam fwd_width_lp =
       `bsg_manycore_packet_width(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp)
   , localparam rev_width_lp =
       `bsg_manycore_return_packet_width(mc_x_cord_width_gp, mc_y_cord_width_gp, mc_data_width_gp)
   )
  (
   input                                          tag_clk_i
   , input                                        tag_data_i
   , input  [tag_lg_els_gp-1:0]                   tag_node_id_offset_i

   , input [mc_y_cord_width_gp-1:0]               global_y_cord_i

   , output logic [2:0]                           io_fwd_link_clk_o
   , output logic [2:0][fwd_width_lp-1:0]         io_fwd_link_data_o
   , output logic [2:0]                           io_fwd_link_v_o
   , input [2:0]                                  io_fwd_link_token_i

   , input [2:0]                                  io_fwd_link_clk_i
   , input [2:0][fwd_width_lp-1:0]                io_fwd_link_data_i
   , input [2:0]                                  io_fwd_link_v_i
   , output logic [2:0]                           io_fwd_link_token_o

   , output logic [2:0]                           io_rev_link_clk_o
   , output logic [2:0][rev_width_lp-1:0]         io_rev_link_data_o
   , output logic [2:0]                           io_rev_link_v_o
   , input [2:0]                                  io_rev_link_token_i

   , input [2:0]                                  io_rev_link_clk_i
   , input [2:0][rev_width_lp-1:0]                io_rev_link_data_i
   , input [2:0]                                  io_rev_link_v_i
   , output logic [2:0]                           io_rev_link_token_o
   );

  // tag master instance
  bsg_chip_noc_tag_lines_s tag_lines_lo;
  bsg_tag_master_decentralized
 #(.els_p      (tag_els_gp)
  ,.local_els_p(tag_noc_local_els_gp)
  ,.lg_width_p (tag_lg_width_gp)
  ) btm
  (.clk_i           (tag_clk_i)
  ,.data_i          (tag_data_i)
  ,.node_id_offset_i(tag_node_id_offset_i)
  ,.clients_o       (tag_lines_lo)
  );

  logic sdr_uplink_reset, sdr_downlink_reset, sdr_downstream_reset, sdr_token_reset;

  bsg_tag_client_unsync #(.width_p(1)) btc0
  (.bsg_tag_i     (tag_lines_lo.sdr.token_reset)
  ,.data_async_r_o(sdr_token_reset));
  bsg_tag_client_unsync #(.width_p(1)) btc1
  (.bsg_tag_i     (tag_lines_lo.sdr.downstream_reset)
  ,.data_async_r_o(sdr_downstream_reset));
  bsg_tag_client_unsync #(.width_p(1)) btc2
  (.bsg_tag_i     (tag_lines_lo.sdr.downlink_reset)
  ,.data_async_r_o(sdr_downlink_reset));
  bsg_tag_client_unsync #(.width_p(1)) btc3
  (.bsg_tag_i     (tag_lines_lo.sdr.uplink_reset)
  ,.data_async_r_o(sdr_uplink_reset));

  bsg_blackparrot_unicore_tile_sdr
   DUT
    (.clk_i(clk)
     ,.reset_i(reset)

     ,.async_uplink_reset_i(async_uplink_reset)
     ,.async_downlink_reset_i(async_downlink_reset)
     ,.async_downstream_reset_i(async_downstream_reset)
     ,.async_token_reset_i(async_token_reset)

     ,.*
     );

endmodule

