`timescale 1ps/1ps

`include "bsg_defines.v"

module bsg_gateway_chip_clk_switch

 #(parameter  num_in_p       = "inv"
  ,parameter  fast_clk_idx_p = 0
  ,localparam lg_num_in_lp   = `BSG_SAFE_CLOG2(num_in_p)
  )

  (input [num_in_p-1:0]     clk_i
  ,input [lg_num_in_lp-1:0] sel_i
  ,output                   clk_o
  );

  logic [lg_num_in_lp-1:0] sel_r;
  assign clk_o = clk_i[sel_r];

  logic clk_dly;
  assign #1 clk_dly = clk_i[fast_clk_idx];

  always_ff @(posedge clk_dly)
    if (sel_r === (lg_num_in_lp)'('X))
        sel_r <= '0;
    else if (clk_i[sel_i] == clk_i[sel_r])
        sel_r <= sel_i;

endmodule
