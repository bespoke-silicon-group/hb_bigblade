

module bsg_chip
 import bsg_chip_pkg::*;
  (
     input  a_core_clk_i
   , input  a_core_uplink_reset_i
   , input  a_core_downlink_reset_i
   , input  a_core_downstream_reset_i
   , input  a_async_token_reset_i

   , input  [width_gp-1:0] a_core_data_i
   , input                 a_core_v_i
   , output                a_core_ready_o

   , output [width_gp-1:0] a_core_data_o
   , output                a_core_v_o
   , input                 a_core_yumi_i

   , input  b_core_clk_i
   , input  b_core_uplink_reset_i
   , input  b_core_downlink_reset_i
   , input  b_core_downstream_reset_i
   , input  b_async_token_reset_i

   , input  [width_gp-1:0] b_core_data_i
   , input                 b_core_v_i
   , output                b_core_ready_o

   , output [width_gp-1:0] b_core_data_o
   , output                b_core_v_o
   , input                 b_core_yumi_i
   );

  logic a_link_clk_lo, b_link_clk_lo;
  logic [width_gp-1:0] a_link_data_lo, b_link_data_lo;
  logic a_link_v_lo, b_link_v_lo;
  logic a_link_token_li, b_link_token_li;

  bsg_sdr_one_side
   a_sdr
   ( .core_clk_i              (a_core_clk_i)
    ,.core_uplink_reset_i     (a_core_uplink_reset_i)
    ,.core_downlink_reset_i   (a_core_downlink_reset_i)
    ,.core_downstream_reset_i (a_core_downstream_reset_i)
    ,.async_token_reset_i     (a_async_token_reset_i)

    ,.core_data_i (a_core_data_i)
    ,.core_v_i    (a_core_v_i)
    ,.core_ready_o(a_core_ready_o)

    ,.core_data_o (a_core_data_o)
    ,.core_v_o    (a_core_v_o)
    ,.core_yumi_i (a_core_yumi_i)

    ,.link_clk_o  (a_link_clk_lo)
    ,.link_data_o (a_link_data_lo)
    ,.link_v_o    (a_link_v_lo)
    ,.link_token_i(a_link_token_li)

    ,.link_clk_i  (b_link_clk_lo)
    ,.link_data_i (b_link_data_lo)
    ,.link_v_i    (b_link_v_lo)
    ,.link_token_o(b_link_token_li)
    );

  bsg_sdr_one_side
   b_sdr
   ( .core_clk_i              (b_core_clk_i)
    ,.core_uplink_reset_i     (b_core_uplink_reset_i)
    ,.core_downlink_reset_i   (b_core_downlink_reset_i)
    ,.core_downstream_reset_i (b_core_downstream_reset_i)
    ,.async_token_reset_i     (b_async_token_reset_i)

    ,.core_data_i (b_core_data_i)
    ,.core_v_i    (b_core_v_i)
    ,.core_ready_o(b_core_ready_o)

    ,.core_data_o (b_core_data_o)
    ,.core_v_o    (b_core_v_o)
    ,.core_yumi_i (b_core_yumi_i)

    ,.link_clk_o  (b_link_clk_lo)
    ,.link_data_o (b_link_data_lo)
    ,.link_v_o    (b_link_v_lo)
    ,.link_token_i(b_link_token_li)

    ,.link_clk_i  (a_link_clk_lo)
    ,.link_data_i (a_link_data_lo)
    ,.link_v_i    (a_link_v_lo)
    ,.link_token_o(a_link_token_li)
    );

endmodule

