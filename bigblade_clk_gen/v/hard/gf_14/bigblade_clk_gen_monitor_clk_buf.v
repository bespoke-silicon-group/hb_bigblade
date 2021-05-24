module bigblade_clk_gen_monitor_clk_buf
( input        i
, output logic o
);

  SC7P5T_CKBUFX4_SSC14R buf_BSG_DONT_TOUCH (.CLK(i), .Z(o));

endmodule // bigblade_clk_gen_monitor_clk_buf
