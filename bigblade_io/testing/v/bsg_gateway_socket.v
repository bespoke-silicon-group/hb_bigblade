/**
 *  bsg_gateway_socket.v
 */

module bsg_gateway_socket

  (
   input  [19:0] LINK_OUT_CLK_I, LINK_OUT_V_I
  ,output [19:0] LINK_OUT_TKN_O
  ,input  [19:0][8:0] LINK_OUT_DATA_I
  
  ,output [19:0] LINK_IN_CLK_O, LINK_IN_V_O
  ,input  [19:0] LINK_IN_TKN_I
  ,output [19:0][8:0] LINK_IN_DATA_O

  ,output TAG_CLK_O
  ,output TAG_EN_O
  ,output TAG_DATA_O

  ,output CLKA_O
  ,output CLKB_O
  ,output CLKC_O

  ,input  CLK0_I
  
  ,output SEL0_O
  ,output SEL1_O
  ,output SEL2_O

  ,output CLK_RESET_O
  ,output CORE_RESET_O
  );

`define BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS(i)   \
     .p_bsg_link_out``i``_clk_i(LINK_OUT_CLK_I [i]   ) \
    ,.p_bsg_link_out``i``_v_i  (LINK_OUT_V_I   [i]   ) \
    ,.p_bsg_link_out``i``_tkn_o(LINK_OUT_TKN_O [i]   ) \
    ,.p_bsg_link_out``i``_d0_i (LINK_OUT_DATA_I[i][0]) \
    ,.p_bsg_link_out``i``_d1_i (LINK_OUT_DATA_I[i][1]) \
    ,.p_bsg_link_out``i``_d2_i (LINK_OUT_DATA_I[i][2]) \
    ,.p_bsg_link_out``i``_d3_i (LINK_OUT_DATA_I[i][3]) \
    ,.p_bsg_link_out``i``_d4_i (LINK_OUT_DATA_I[i][4]) \
    ,.p_bsg_link_out``i``_d5_i (LINK_OUT_DATA_I[i][5]) \
    ,.p_bsg_link_out``i``_d6_i (LINK_OUT_DATA_I[i][6]) \
    ,.p_bsg_link_out``i``_d7_i (LINK_OUT_DATA_I[i][7]) \
    ,.p_bsg_link_out``i``_d8_i (LINK_OUT_DATA_I[i][8]) \
                                                       \
    ,.p_bsg_link_in``i``_clk_o (LINK_IN_CLK_O  [i]   ) \
    ,.p_bsg_link_in``i``_v_o   (LINK_IN_V_O    [i]   ) \
    ,.p_bsg_link_in``i``_tkn_i (LINK_IN_TKN_I  [i]   ) \
    ,.p_bsg_link_in``i``_d0_o  (LINK_IN_DATA_O [i][0]) \
    ,.p_bsg_link_in``i``_d1_o  (LINK_IN_DATA_O [i][1]) \
    ,.p_bsg_link_in``i``_d2_o  (LINK_IN_DATA_O [i][2]) \
    ,.p_bsg_link_in``i``_d3_o  (LINK_IN_DATA_O [i][3]) \
    ,.p_bsg_link_in``i``_d4_o  (LINK_IN_DATA_O [i][4]) \
    ,.p_bsg_link_in``i``_d5_o  (LINK_IN_DATA_O [i][5]) \
    ,.p_bsg_link_in``i``_d6_o  (LINK_IN_DATA_O [i][6]) \
    ,.p_bsg_link_in``i``_d7_o  (LINK_IN_DATA_O [i][7]) \
    ,.p_bsg_link_in``i``_d8_o  (LINK_IN_DATA_O [i][8])

bsg_gateway_chip bgc
(
   `BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS( 0)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS( 1)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS( 2)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS( 3)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS( 4)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS( 5)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS( 6)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS( 7)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS( 8)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS( 9)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS(10)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS(11)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS(12)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS(13)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS(14)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS(15)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS(16)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS(17)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS(18)
  ,`BSG_GATEWAY_SOCKET_FULL_DUPLEX_LINK_PORTS(19)

  ,.p_bsg_tag_clk_o   (TAG_CLK_O)
  ,.p_bsg_tag_en_o    (TAG_EN_O)
  ,.p_bsg_tag_data_o  (TAG_DATA_O)
  ,.p_bsg_tag_clk_i   (1'b0)
  ,.p_bsg_tag_data_i  (1'b0)

  ,.p_clk_A_o     (CLKA_O)
  ,.p_clk_B_o     (CLKB_O)
  ,.p_clk_C_o     (CLKC_O)

  ,.p_clk_i       (CLK0_I)

  ,.p_sel_0_o     (SEL0_O)
  ,.p_sel_1_o     (SEL1_O)
  ,.p_sel_2_o     (SEL2_O)

  ,.p_clk_async_reset_o   (CLK_RESET_O)
  ,.p_core_async_reset_o  (CORE_RESET_O)

  ,.p_misc_i      (1'b0)
);

endmodule
