
module bsg_link_osdr_phy

 #(parameter width_p = "inv")

  (input                clk_i
  ,input                reset_i
  ,input  [width_p-1:0] data_i
  ,output               clk_o
  ,output [width_p-1:0] data_o
  );

  wire clk_r_p, clk_r_n;

  SC7P5T_CKXOR2X2_SSC16R BSG_CKXOR2_DONT_TOUCH
  (.Z(clk_o),.CLK(clk_r_p),.EN(clk_r_n));

  SC7P5T_DFFRQX2_SSC16R BSG_DFFRQ_DONT_TOUCH
  (.D(~clk_r_p),.CLK(clk_i),.RESET(~reset_i),.Q(clk_r_p));
  SC7P5T_DFFNRQX2_SSC16R BSG_DFFNRQ_DONT_TOUCH
  (.D(~clk_r_n),.CLK(clk_i),.RESET(~reset_i),.Q(clk_r_n));

  for (genvar i = 0; i < width_p; i++)
  begin: data
    SC7P5T_DFFQX1_SSC16R BSG_DFFQ_DONT_TOUCH
    (.D(data_i[i]),.CLK(clk_i),.Q(data_o[i]));
  end

endmodule