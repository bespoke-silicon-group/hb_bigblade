`include "bsg_defines.v"
`include "bsg_noc_links.vh"

module bsg_router_tile
  import bsg_noc_pkg::*; // {P=0, W, E, N, S}

#(parameter width_p          = 128
, parameter dims_p           = 2
, parameter x_cord_width_p   = 5
, parameter y_cord_width_p   = 5
, parameter ruche_factor_X_p = 0
, parameter ruche_factor_Y_p = 0
, parameter stub_p           = 5'b00001  // SNEWP

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

  assign link_li[P] = '0;

  assign link_li[W] = link_w_i;
  assign link_li[E] = link_e_i;
  assign link_li[N] = link_n_i;
  assign link_li[S] = link_s_i;

  assign link_w_o = link_lo[W];
  assign link_e_o = link_lo[E];
  assign link_n_o = link_lo[N];
  assign link_s_o = link_lo[S];

endmodule // bsg_router_tile
