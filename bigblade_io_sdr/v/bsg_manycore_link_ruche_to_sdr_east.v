
module bsg_manycore_link_ruche_to_sdr_east

 import bsg_noc_pkg::*;
 import bsg_manycore_pkg::*;

 #(parameter lg_fifo_depth_p                 = "inv"
  ,parameter lg_credit_to_token_decimation_p = "inv"

  ,parameter addr_width_p     = "inv"
  ,parameter data_width_p     = "inv"
  ,parameter x_cord_width_p   = "inv"
  ,parameter y_cord_width_p   = "inv"
  ,parameter ruche_factor_X_p = "inv"

  ,parameter link_sif_width_lp =
    `bsg_manycore_link_sif_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p)
  ,parameter ruche_x_link_sif_width_lp =
    `bsg_manycore_ruche_x_link_sif_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p)
  ,parameter fwd_width_lp =
    `bsg_manycore_packet_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p)
  ,parameter rev_width_lp =
    `bsg_manycore_return_packet_width(x_cord_width_p,y_cord_width_p,data_width_p)
  )

  (input  core_clk_i
  ,input  core_reset_i

  ,input  [S:N][link_sif_width_lp-1:0] core_ver_link_sif_i
  ,output [S:N][link_sif_width_lp-1:0] core_ver_link_sif_o

  ,input  [link_sif_width_lp-1:0] core_hor_link_sif_i
  ,output [link_sif_width_lp-1:0] core_hor_link_sif_o

  ,input  [ruche_x_link_sif_width_lp-1:0] core_ruche_link_i
  ,output [ruche_x_link_sif_width_lp-1:0] core_ruche_link_o

  ,input  [x_cord_width_p-1:0] core_global_x_i
  ,input  [y_cord_width_p-1:0] core_global_y_i

  ,input  async_uplink_reset_i
  ,input  async_downlink_reset_i
  ,input  async_downstream_reset_i
  ,input  async_token_reset_i

  ,output async_uplink_reset_o
  ,output async_downlink_reset_o
  ,output async_downstream_reset_o
  ,output async_token_reset_o

  ,output                    io_fwd_link_clk_o
  ,output [fwd_width_lp-1:0] io_fwd_link_data_o
  ,output                    io_fwd_link_v_o
  ,input                     io_fwd_link_token_i

  ,input                     io_fwd_link_clk_i
  ,input  [fwd_width_lp-1:0] io_fwd_link_data_i
  ,input                     io_fwd_link_v_i
  ,output                    io_fwd_link_token_o

  ,output                    io_rev_link_clk_o
  ,output [rev_width_lp-1:0] io_rev_link_data_o
  ,output                    io_rev_link_v_o
  ,input                     io_rev_link_token_i

  ,input                     io_rev_link_clk_i
  ,input  [rev_width_lp-1:0] io_rev_link_data_i
  ,input                     io_rev_link_v_i
  ,output                    io_rev_link_token_o
  );

  bsg_manycore_link_ruche_to_sdr
 #(.lg_fifo_depth_p                (lg_fifo_depth_p                )
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
  ,.addr_width_p                   (addr_width_p                   )
  ,.data_width_p                   (data_width_p                   )
  ,.x_cord_width_p                 (x_cord_width_p                 )
  ,.y_cord_width_p                 (y_cord_width_p                 )
  ,.ruche_factor_X_p               (ruche_factor_X_p               )
  ,.tieoff_west_not_east_p         (1'b0                           )
  ) sdr_link
  (.*);

endmodule
