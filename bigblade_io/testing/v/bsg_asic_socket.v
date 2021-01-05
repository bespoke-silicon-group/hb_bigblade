// this is the ASIC FPGA "socket"

module bsg_asic_socket

  (
  // reset
   input  CLK_RESET_I, CORE_RESET_I

  // clk
  ,input  CLKA_I, CLKB_I, CLKC_I
  ,input  SEL0_I, SEL1_I, SEL2_I
  ,output CLK_O, MISC_O

  // tag
  ,input  TAG_CLK_I, TAG_EN_I, TAG_DATA_I
  ,output TAG_CLK_O, TAG_DATA_O

  // bsg_link
  ,input  [19:0] LINK_IN_CLK_I, LINK_IN_V_I
  ,output [19:0] LINK_IN_TKN_O
  ,input  [19:0][8:0] LINK_IN_DATA_I
  
  ,output [19:0] LINK_OUT_CLK_O, LINK_OUT_V_O
  ,input  [19:0] LINK_OUT_TKN_I
  ,output [19:0][8:0] LINK_OUT_DATA_O
  );

`define BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS(i)      \
     .p_bsg_link_in``i``_clk_i (LINK_IN_CLK_I  [i]   ) \
    ,.p_bsg_link_in``i``_v_i   (LINK_IN_V_I    [i]   ) \
    ,.p_bsg_link_in``i``_tkn_o (LINK_IN_TKN_O  [i]   ) \
    ,.p_bsg_link_in``i``_d0_i  (LINK_IN_DATA_I [i][0]) \
    ,.p_bsg_link_in``i``_d1_i  (LINK_IN_DATA_I [i][1]) \
    ,.p_bsg_link_in``i``_d2_i  (LINK_IN_DATA_I [i][2]) \
    ,.p_bsg_link_in``i``_d3_i  (LINK_IN_DATA_I [i][3]) \
    ,.p_bsg_link_in``i``_d4_i  (LINK_IN_DATA_I [i][4]) \
    ,.p_bsg_link_in``i``_d5_i  (LINK_IN_DATA_I [i][5]) \
    ,.p_bsg_link_in``i``_d6_i  (LINK_IN_DATA_I [i][6]) \
    ,.p_bsg_link_in``i``_d7_i  (LINK_IN_DATA_I [i][7]) \
    ,.p_bsg_link_in``i``_d8_i  (LINK_IN_DATA_I [i][8]) \
                                                       \
    ,.p_bsg_link_out``i``_clk_o(LINK_OUT_CLK_O [i]   ) \
    ,.p_bsg_link_out``i``_v_o  (LINK_OUT_V_O   [i]   ) \
    ,.p_bsg_link_out``i``_tkn_i(LINK_OUT_TKN_I [i]   ) \
    ,.p_bsg_link_out``i``_d0_o (LINK_OUT_DATA_O[i][0]) \
    ,.p_bsg_link_out``i``_d1_o (LINK_OUT_DATA_O[i][1]) \
    ,.p_bsg_link_out``i``_d2_o (LINK_OUT_DATA_O[i][2]) \
    ,.p_bsg_link_out``i``_d3_o (LINK_OUT_DATA_O[i][3]) \
    ,.p_bsg_link_out``i``_d4_o (LINK_OUT_DATA_O[i][4]) \
    ,.p_bsg_link_out``i``_d5_o (LINK_OUT_DATA_O[i][5]) \
    ,.p_bsg_link_out``i``_d6_o (LINK_OUT_DATA_O[i][6]) \
    ,.p_bsg_link_out``i``_d7_o (LINK_OUT_DATA_O[i][7]) \
    ,.p_bsg_link_out``i``_d8_o (LINK_OUT_DATA_O[i][8])

  bsg_chip ASIC
  (
  // 20 full-duplex bsg_link interfaces, 480 pins
   `BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS( 0)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS( 1)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS( 2)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS( 3)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS( 4)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS( 5)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS( 6)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS( 7)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS( 8)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS( 9)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS(10)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS(11)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS(12)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS(13)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS(14)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS(15)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS(16)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS(17)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS(18)
  ,`BSG_ASIC_SOCKET_FULL_DUPLEX_LINK_PORTS(19)

  // bsg tag interface, 5 pins
  ,.p_bsg_tag_clk_i  (TAG_CLK_I)
  ,.p_bsg_tag_en_i   (TAG_EN_I)
  ,.p_bsg_tag_data_i (TAG_DATA_I)
  ,.p_bsg_tag_clk_o  (TAG_CLK_O)
  ,.p_bsg_tag_data_o (TAG_DATA_O)

  // clock and reset interface, 9 pins
  // clock input signals
  ,.p_clk_A_i(CLKA_I)
  ,.p_clk_B_i(CLKB_I)
  ,.p_clk_C_i(CLKC_I)

  // clock output signal
  ,.p_clk_o  (CLK_O)

  // 3-bit clock selection signals
  ,.p_sel_0_i(SEL0_I)
  ,.p_sel_1_i(SEL1_I)
  ,.p_sel_2_i(SEL2_I)

  // asynchronous reset signals
  ,.p_clk_async_reset_i  (CLK_RESET_I)
  ,.p_core_async_reset_i (CORE_RESET_I)

  // miscellaneous signal, 1 pin
  ,.p_misc_o (MISC_O)
  );


endmodule
