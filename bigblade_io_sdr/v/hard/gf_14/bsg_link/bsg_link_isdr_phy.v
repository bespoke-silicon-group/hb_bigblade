
module bsg_link_isdr_phy

 #(parameter width_p = "inv")

  (input                clk_i
  ,input  [width_p-1:0] data_i
  ,output [width_p-1:0] data_o
  );

  wire clk_li;
  SC7P5T_CKBUFX2_SSC16R BSG_CKBUF_DONT_TOUCH (.CLK(clk_i),.Z(clk_li));

  for (genvar i = 0; i < width_p; i++)
  begin: data
    SC7P5T_DFFQX1_SSC16R BSG_DFFQ_DONT_TOUCH
    (.D(data_i[i]),.CLK(clk_li),.Q(data_o[i]));
  end

endmodule