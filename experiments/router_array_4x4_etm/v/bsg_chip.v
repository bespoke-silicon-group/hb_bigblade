`include "bsg_defines.v"
`include "bsg_noc_links.vh"

module bsg_chip
  import bsg_noc_pkg::*; // {P=0, W, E, N, S}

#(parameter num_tiles_x_p    = 4
, parameter num_tiles_y_p    = 4

, parameter width_p          = 32
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

, input  [num_tiles_y_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] link_w_i
, output [num_tiles_y_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] link_w_o

, input  [num_tiles_y_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] link_e_i
, output [num_tiles_y_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] link_e_o

, input  [num_tiles_x_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] link_n_i
, output [num_tiles_x_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] link_n_o

, input  [num_tiles_x_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] link_s_i
, output [num_tiles_x_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] link_s_o
);

  logic [num_tiles_y_p-1:0][num_tiles_x_p-1:0][S:W][bsg_ready_and_link_sif_width_lp-1:0] link_li, link_lo;

  logic [E:W][num_tiles_y_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] hor_link_li, hor_link_lo;
  logic [S:N][num_tiles_y_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] ver_link_li, ver_link_lo;

  for (genvar r = 0; r < num_tiles_y_p; r++)
  begin: y
    for (genvar c = 0; c < num_tiles_x_p; c++)
    begin: x
      bsg_router_tile #
        (.width_p(width_p)
        ,.dims_p(dims_p)
        ,.x_cord_width_p(x_cord_width_p)
        ,.y_cord_width_p(y_cord_width_p)
        ,.ruche_factor_X_p(ruche_factor_X_p)
        ,.ruche_factor_Y_p(ruche_factor_Y_p)
        ,.stub_p(stub_p))
      tile
        (.clk_i(clk_i)
        ,.reset_i(reset_i)

        ,.link_w_i(link_li[r][c][W])
        ,.link_w_o(link_lo[r][c][W])

        ,.link_e_i(link_li[r][c][E])
        ,.link_e_o(link_lo[r][c][E])

        ,.link_n_i(link_li[r][c][N])
        ,.link_n_o(link_lo[r][c][N])

        ,.link_s_i(link_li[r][c][S])
        ,.link_s_o(link_lo[r][c][S])

        ,.my_x_i(x_cord_width_p'(c))
        ,.my_y_i(y_cord_width_p'(r))
        );
    end: x
  end: y

  bsg_mesh_stitch #
    (.width_p(bsg_ready_and_link_sif_width_lp)
    ,.x_max_p(num_tiles_x_p)
    ,.y_max_p(num_tiles_y_p))
  stitch
    (.outs_i(link_lo)
    ,.ins_o(link_li)
    ,.hor_i(hor_link_li)
    ,.hor_o(hor_link_lo)
    ,.ver_i(ver_link_li)
    ,.ver_o(ver_link_lo)
    );

  assign hor_link_li[W] = link_w_i;
  assign hor_link_li[E] = link_e_i;
  assign ver_link_li[N] = link_n_i;
  assign ver_link_li[S] = link_s_i;

  assign link_w_o = hor_link_lo[W];
  assign link_e_o = hor_link_lo[E];
  assign link_n_o = ver_link_lo[N];
  assign link_s_o = ver_link_lo[S];

endmodule // bsg_chip
