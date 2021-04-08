
module bsg_chip_hold_time_test

 #(parameter width_p = "inv"
  )

  (input                core_clk_i
  ,input  [width_p-1:0] core_data_i
  ,output [width_p-1:0] core_data_o
  );

  logic [width_p-1:0] isdr_r, mem_r;

  for (genvar i = 0; i < width_p; i++)
    SC7P5T_DFFQX1_SSC14R isdr_DFFQ
    (.D(core_data_i[i]),.CLK(core_clk_i),.Q(isdr_r[i]));

  bsg_mem_1r1w_sync
 #(.width_p(34)
  ,.els_p  (64)
  ) mem
  (.clk_i   (core_clk_i)
  ,.reset_i (1'b0)
  ,.w_v_i   (isdr_r[0])
  ,.w_addr_i(isdr_r[1+:6])
  ,.w_data_i(isdr_r)
  ,.r_v_i   (isdr_r[7])
  ,.r_addr_i(isdr_r[8+:6])
  ,.r_data_o(mem_r)
  );

  for (genvar i = 0; i < width_p; i++)
    SC7P5T_DFFQX1_SSC14R osdr_DFFQ
    (.D(mem_r[i]),.CLK(core_clk_i),.Q(core_data_o[i]));

endmodule
