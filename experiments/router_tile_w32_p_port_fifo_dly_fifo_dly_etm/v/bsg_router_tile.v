`include "bsg_defines.v"
`include "bsg_noc_links.vh"

module bsg_router_tile
  import bsg_noc_pkg::*; // {P=0, W, E, N, S}

#(parameter width_p          = 32
, parameter dims_p           = 2
, parameter x_cord_width_p   = 10
, parameter y_cord_width_p   = 10
, parameter ruche_factor_X_p = 0
, parameter ruche_factor_Y_p = 0
, parameter stub_p           = 5'b00000  // SNEWP

, localparam dirs_lp = 2*dims_p + 1
, localparam bsg_ready_and_link_sif_width_lp=`bsg_ready_and_link_sif_width(width_p)
)

( input clk_i
, input reset_i

, input  [bsg_ready_and_link_sif_width_lp-1:0] link_w_i
, output [bsg_ready_and_link_sif_width_lp-1:0] link_w_o

, input  [bsg_ready_and_link_sif_width_lp-1:0] link_e_i
, output [bsg_ready_and_link_sif_width_lp-1:0] link_e_o

, input  [bsg_ready_and_link_sif_width_lp-1:0] link_n_i
, output [bsg_ready_and_link_sif_width_lp-1:0] link_n_o

, input  [bsg_ready_and_link_sif_width_lp-1:0] link_s_i
, output [bsg_ready_and_link_sif_width_lp-1:0] link_s_o

, input [x_cord_width_p-1:0] my_x_i
, input [y_cord_width_p-1:0] my_y_i
);

  logic [dirs_lp-1:0][bsg_ready_and_link_sif_width_lp-1:0] link_li, link_lo;

  bsg_mesh_router_buffered #
    (.width_p(width_p)
    ,.dims_p(dims_p)
    ,.x_cord_width_p(x_cord_width_p)
    ,.y_cord_width_p(y_cord_width_p)
    ,.ruche_factor_X_p(ruche_factor_X_p)
    ,.ruche_factor_Y_p(ruche_factor_Y_p)
    ,.stub_p(stub_p))
  rtr
    (.clk_i(clk_i)
    ,.reset_i(reset_i)

    ,.link_i(link_li)
    ,.link_o(link_lo)

    ,.my_x_i(my_x_i)
    ,.my_y_i(my_y_i)
   );

  assign link_li[W] = link_w_i;
  assign link_li[E] = link_e_i;
  assign link_li[N] = link_n_i;
  assign link_li[S] = link_s_i;

  assign link_w_o = link_lo[W];
  assign link_e_o = link_lo[E];
  assign link_n_o = link_lo[N];
  assign link_s_o = link_lo[S];

  logic [width_p-1:0] dly_pre_lo, dly_post_li, fifo_data_lo;
  logic fifo_v_n, fifo_ready_n;

  bsg_two_fifo #(.width_p(width_p))
  p_out_fifo
    (.clk_i(clk_i)
    ,.reset_i(reset_i)

    ,.data_i(link_lo[P][width_p-1:0])
    ,.v_i(link_lo[P][width_p+1])
    ,.ready_o(link_li[P][width_p])

    ,.data_o(fifo_data_lo)
    ,.v_o(fifo_v_n)
    ,.yumi_i(fifo_v_n & fifo_ready_n)
    );

  bsg_dly_chain #(.width_p(width_p),.depth_p(3))
  dly_pre
    (.i(fifo_data_lo)
    ,.o(dly_pre_lo)
    );

  bsg_two_fifo #(.width_p(width_p))
  inter_dly_fifo
    (.clk_i(clk_i)
    ,.reset_i(reset_i)

    ,.data_i(dly_pre_lo)
    ,.v_i(fifo_v_n)
    ,.ready_o(fifo_ready_n)

    ,.data_o(dly_post_li)
    ,.v_o(link_li[P][width_p+1])
    ,.yumi_i(link_lo[P][width_p] & link_li[P][width_p+1])
    );

  bsg_dly_chain #(.width_p(width_p),.depth_p(1))
  dly_post
    (.i(dly_post_li)
    ,.o(link_li[P][width_p-1:0])
    );

endmodule // bsg_router_tile

