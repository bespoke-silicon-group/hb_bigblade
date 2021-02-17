

module bsg_chip
 import bsg_chip_pkg::*;
  (
   input a_async_token_reset_i
   , input  a_downlink_reset_i
   , input [width_gp-1:0] a_uplink_data_i
   , input  a_uplink_v_i
   , output  a_uplink_ready_o

   , input  a_downstream_clk_i
   , input  a_downstream_reset_i
   , output logic [width_gp-1:0] a_downstream_data_o
   , output logic  a_downstream_v_o
   , input  a_downstream_ready_i

   , input b_async_token_reset_i
   , input  b_downlink_reset_i
   , input [width_gp-1:0] b_uplink_data_i
   , input  b_uplink_v_i
   , output  b_uplink_ready_o

   , input  b_downstream_clk_i
   , input  b_downstream_reset_i
   , output logic [width_gp-1:0] b_downstream_data_o
   , output logic  b_downstream_v_o
   , input  b_downstream_ready_i
   );

  logic link_clk_li, link_clk_lo;
  logic [width_gp-1:0] link_data_li, link_data_lo;
  logic link_v_lo, link_v_li;
  logic link_token_li, link_token_lo;

  bsg_sdr_one_side
   a_sdr
   (.async_token_reset_i(a_async_token_reset_i)
    ,.downlink_reset_i(a_downlink_reset_i)

    ,.uplink_data_i(a_uplink_data_i)
    ,.uplink_v_i(a_uplink_v_i)
    ,.uplink_ready_o(a_uplink_ready_o)

    ,.downstream_reset_i(a_downstream_reset_i)
    ,.downstream_data_o(a_downstream_data_o)
    ,.downstream_v_o(a_downstream_v_o)
    ,.downstream_ready_i(a_downstream_ready_i)

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
   b_sdr
   (.async_token_reset_i(b_async_token_reset_i)
    ,.downlink_reset_i(b_downlink_reset_i)

    ,.uplink_data_i(b_uplink_data_i)
    ,.uplink_v_i(b_uplink_v_i)
    ,.uplink_ready_o(b_uplink_ready_o)

    ,.downstream_reset_i(b_downstream_reset_i)
    ,.downstream_data_o(b_downstream_data_o)
    ,.downstream_v_o(b_downstream_v_o)
    ,.downstream_ready_i(b_downstream_ready_i)

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

