

module bsg_chip
 import bsg_chip_pkg::*;
  (
   input [1:0] async_token_reset_i
   , input [1:0] downlink_reset_i
   , input [1:0][width_gp-1:0] uplink_data_i
   , input [1:0] uplink_v_i
   , output [1:0] uplink_ready_o

   , input [1:0] downstream_clk_i
   , input [1:0] downstream_reset_i
   , output logic [1:0][width_gp-1:0] downstream_data_o
   , output logic [1:0] downstream_v_o
   , input [1:0] downstream_ready_i
   );

  logic link_clk_li, link_clk_lo;
  logic [width_gp-1:0] link_data_li, link_data_lo;
  logic link_v_lo, link_v_li;
  logic link_token_li, link_token_lo;

  bsg_sdr_one_side
   sdr_0
   (.async_token_reset_i(async_token_reset_i[0])
   ,.downlink_reset_i(downlink_reset_i[0])

   ,.uplink_data_i(uplink_data_i[0])
   ,.uplink_v_i(uplink_v_i[0])
   ,.uplink_ready_o(uplink_ready_o[0])

   ,.downstream_reset_i(downstream_reset_i[0])
   ,.downstream_data_o(downstream_data_o[0])
   ,.downstream_v_o(downstream_v_o[0])
   ,.downstream_ready_i(downstream_ready_i[0])

   ,.link_clk_o(link_clk_lo)
   ,.link_data_o(link_data_lo)
   ,.link_v_o(link_v_lo)
   ,.link_token_i(link_token_li)

   ,.link_clk_i(link_clk_li)
   ,.link_data_i(link_data_li)
   ,.link_v_i(link_v_li)
   ,.link_token_o(link_token_lo)
   );

  bsg_sdr_one_side
   sdr_1
   (.async_token_reset_i(async_token_reset_i[1])
   ,.downlink_reset_i(downlink_reset_i[1])

   ,.uplink_data_i(uplink_data_i[1])
   ,.uplink_v_i(uplink_v_i[1])
   ,.uplink_ready_o(uplink_ready_o[1])

   ,.downstream_reset_i(downstream_reset_i[1])
   ,.downstream_data_o(downstream_data_o[1])
   ,.downstream_v_o(downstream_v_o[1])
   ,.downstream_ready_i(downstream_ready_i[1])

   ,.link_clk_o(link_clk_li)
   ,.link_data_o(link_data_li)
   ,.link_v_o(link_v_li)
   ,.link_token_i(link_token_lo)

   ,.link_clk_i(link_clk_lo)
   ,.link_data_i(link_data_lo)
   ,.link_v_i(link_v_lo)
   ,.link_token_o(link_token_li)
   );

endmodule

