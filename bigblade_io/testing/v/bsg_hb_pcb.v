// bsg_hb_pcb.v
//
// simulates connectivity of the asic cloud PCB
//
// this is intended as the canonical simulation file
// but currently it may only implement a subset of
// all of the wires and functionality -- please
// extend rather than cloning the file and modifying it
//

`timescale 1ps/1ps

module bsg_hb_pcb
(
    // this is the FMC connector
    inout [33:00] LAxx_N
    , inout [33:00] LAxx_P      //  e.g. LA14_N
    , inout CLK0_C2M_N
    , inout CLK0_C2M_P
    , inout CLK0_M2C_N
    , inout CLK0_M2C_P

    // SMA connectors (for simulation)
    , input ASIC_SMA_IN_N
    , input ASIC_SMA_IN_P       // terminated on ASIC side
    , inout ASIC_SMA_OUT_N
    , inout ASIC_SMA_OUT_P      // unterminated

    , inout FPGA_SMA_IN_N
    , inout FPGA_SMA_IN_P       // unterminated
    , inout FPGA_SMA_OUT_N
    , inout FPGA_SMA_OUT_P      // unterminated

    // LEDs (for simulation)
    , output [3:0] FPGA_LED     // from GW   FPGA
    , output [1:0] ASIC_LED     // from ASIC FPGA

    , input  UART_RX
    , output UART_TX

    // low-true reset signal for GW FPGA (normal driven by reset controller)
    , input PWR_RSTN
  );


  //
  // bsg link wires (Between GW and IC)
  //

  wire [19:0] IC_GW_LINK_CLK, IC_GW_LINK_V, IC_GW_LINK_TKN;
  wire [19:0][8:0] IC_GW_LINK_DATA;

  wire [19:0] GW_IC_LINK_CLK, GW_IC_LINK_V, GW_IC_LINK_TKN;
  wire [19:0][8:0] GW_IC_LINK_DATA;
  //
  // Misc wires (GW)
  //
  wire GW_TAG_CLKO;
  wire GW_TAG_DATAO;
  wire GW_TAG_EN;

  wire GW_CLKA;
  wire GW_CLKB;
  wire GW_CLKC;

  wire GW_SEL0;
  wire GW_SEL1;
  wire GW_SEL2;

  wire GW_CLK_RESET;
  wire GW_CORE_RESET;


  //
  // Misc wires (IC)
  //
  wire IC_CLKO;  // Clock out (for scoping clock generators)

  //
  // GATEWAY SOCKET
  //

  bsg_gateway_socket GW
  (.LINK_OUT_CLK_I        (IC_GW_LINK_CLK)
  ,.LINK_OUT_V_I          (IC_GW_LINK_V)
  ,.LINK_OUT_TKN_O        (IC_GW_LINK_TKN)
  ,.LINK_OUT_DATA_I       (IC_GW_LINK_DATA)

  ,.LINK_IN_CLK_O         (GW_IC_LINK_CLK)
  ,.LINK_IN_V_O           (GW_IC_LINK_V)
  ,.LINK_IN_TKN_I         (GW_IC_LINK_TKN)
  ,.LINK_IN_DATA_O        (GW_IC_LINK_DATA)

  ,.TAG_CLK_O             (GW_TAG_CLKO)
  ,.TAG_EN_O              (GW_TAG_EN)
  ,.TAG_DATA_O            (GW_TAG_DATAO)

  ,.CLKA_O                (GW_CLKA)
  ,.CLKB_O                (GW_CLKB)
  ,.CLKC_O                (GW_CLKC)

  ,.CLK0_I                (IC_CLKO)

  ,.SEL0_O                (GW_SEL0)
  ,.SEL1_O                (GW_SEL1)
  ,.SEL2_O                (GW_SEL2)

  ,.CLK_RESET_O           (GW_CLK_RESET)
  ,.CORE_RESET_O          (GW_CORE_RESET)
  );

  //
  // ASIC SOCKET
  //

  bsg_asic_socket IC
  (.LINK_IN_CLK_I         (GW_IC_LINK_CLK)
  ,.LINK_IN_V_I           (GW_IC_LINK_V)
  ,.LINK_IN_TKN_O         (GW_IC_LINK_TKN)
  ,.LINK_IN_DATA_I        (GW_IC_LINK_DATA)

  ,.LINK_OUT_CLK_O        (IC_GW_LINK_CLK)
  ,.LINK_OUT_V_O          (IC_GW_LINK_V)
  ,.LINK_OUT_TKN_I        (IC_GW_LINK_TKN)
  ,.LINK_OUT_DATA_O       (IC_GW_LINK_DATA)

  ,.TAG_CLK_I             (GW_TAG_CLKO)
  ,.TAG_EN_I              (GW_TAG_EN)
  ,.TAG_DATA_I            (GW_TAG_DATAO)
  ,.TAG_CLK_O             ()
  ,.TAG_DATA_O            ()
                          
  ,.CLKA_I                (GW_CLKA)
  ,.CLKB_I                (GW_CLKB)
  ,.CLKC_I                (GW_CLKC)
                          
  ,.CLK_O                 (IC_CLKO)
                          
  ,.SEL0_I                (GW_SEL0)
  ,.SEL1_I                (GW_SEL1)
  ,.SEL2_I                (GW_SEL2)
                          
  ,.CLK_RESET_I           (GW_CLK_RESET)
  ,.CORE_RESET_I          (GW_CORE_RESET)
                          
  ,.MISC_O                ()
  );

endmodule
