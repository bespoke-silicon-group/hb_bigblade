
module bsg_chip

 import bsg_chip_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_manycore_pkg::*;

 #(parameter lg_fifo_depth_p                 = lg_fifo_depth_gp
  ,parameter lg_credit_to_token_decimation_p = lg_credit_to_token_decimation_gp

  ,parameter addr_width_p     = addr_width_gp
  ,parameter data_width_p     = data_width_gp
  ,parameter x_cord_width_p   = x_cord_width_gp
  ,parameter y_cord_width_p   = y_cord_width_gp
  ,parameter ruche_factor_X_p = ruche_factor_X_gp
  ,parameter tieoff_west_p    = tieoff_west_gp
  ,parameter tieoff_east_p    = tieoff_east_gp

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

  ,input  [S:W][link_sif_width_lp-1:0] core_link_sif_i
  ,output [S:W][link_sif_width_lp-1:0] core_link_sif_o

  ,input  [E:W][ruche_x_link_sif_width_lp-1:0] core_ruche_link_i
  ,output [E:W][ruche_x_link_sif_width_lp-1:0] core_ruche_link_o

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

  bsg_manycore_io_router_sdr_link
 #(.lg_fifo_depth_p                (lg_fifo_depth_p                )
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
  ,.addr_width_p                   (addr_width_p                   )
  ,.data_width_p                   (data_width_p                   )
  ,.x_cord_width_p                 (x_cord_width_p                 )
  ,.y_cord_width_p                 (y_cord_width_p                 )
  ,.ruche_factor_X_p               (ruche_factor_X_p               )
  ,.tieoff_west_p                  (tieoff_west_p                  )
  ,.tieoff_east_p                  (tieoff_east_p                  )
  ) sdr_link
  (.*);

endmodule
