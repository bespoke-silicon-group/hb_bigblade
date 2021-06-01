module bigblade_clk_gen_monitor_clk_buf
( input        i
, output logic o
);

  wire n0;
  SC7P5T_CKBUFX1_SSC14R bufx1_BSG_DONT_TOUCH (.CLK(i),  .Z(n0));
  SC7P5T_CKBUFX4_SSC14R bufx4_BSG_DONT_TOUCH (.CLK(n0), .Z(o));

endmodule // bigblade_clk_gen_monitor_clk_buf
