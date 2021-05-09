
module bsg_link_delay_line

 import bsg_chip_pkg::*;

 #(localparam width_lp = 2+bsg_link_channel_width_gp)

  (input  bsg_chip_delay_tag_lines_s tag_lines_i
  ,input  [width_lp-1:0] i
  ,output [width_lp-1:0] o
  );

  wire [width_lp-1:0][1:0] sel;

  for (genvar k = 0; k < width_lp; k++)
    assign #(sel[k]*50) o[k] = i[k];

  // hardcoded for bsg_link_channel_width_gp = 16
  bsg_tag_client_unsync #(.width_p(12)) btc0
  (.bsg_tag_i     (tag_lines_i.data[0])
  ,.data_async_r_o(sel[0+:6]));
  bsg_tag_client_unsync #(.width_p(12)) btc1
  (.bsg_tag_i     (tag_lines_i.data[1])
  ,.data_async_r_o(sel[6+:6]));
  bsg_tag_client_unsync #(.width_p(10)) btc2
  (.bsg_tag_i     (tag_lines_i.data[2])
  ,.data_async_r_o(sel[12+:5]));
  bsg_tag_client_unsync #(.width_p(2)) btc3
  (.bsg_tag_i     (tag_lines_i.clk)
  ,.data_async_r_o(sel[17]));

endmodule
