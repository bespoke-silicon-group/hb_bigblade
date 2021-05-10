module bsg_gateway_chip_dpi_manycore
  import bsg_chip_pkg::*;  
  import bsg_manycore_pkg::*;
  import bsg_bladerunner_pkg::*;
  #(localparam link_sif_width_lp =
    `bsg_manycore_link_sif_width(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp)
  )
  
  (input clk_i
    ,input reset_i

    // manycore link
    ,input [link_sif_width_lp-1:0] link_sif_i
    ,output [link_sif_width_lp-1:0] link_sif_o

    ,input reset_done_i

    ,input [hb_x_cord_width_gp-1:0] global_x_i
    ,input [hb_y_cord_width_gp-1:0] global_y_i

    ,output bit debug_o
  );
  
  localparam ep_fifo_els_lp = 4;
  bsg_nonsynth_dpi_manycore #(
     .x_cord_width_p(hb_x_cord_width_gp)
    ,.y_cord_width_p(hb_y_cord_width_gp)
    ,.addr_width_p(hb_addr_width_gp)
    ,.data_width_p(hb_data_width_gp)
    ,.ep_fifo_els_p(ep_fifo_els_lp)
    ,.dpi_fifo_els_p(bsg_machine_dpi_fifo_els_gp)
    ,.fifo_width_p(128)
    ,.rom_els_p(bsg_machine_rom_els_gp)
    ,.rom_width_p(bsg_machine_rom_width_gp)
    ,.rom_arr_p(bsg_machine_rom_arr_gp)
    ,.credit_counter_width_p(`BSG_WIDTH(200))
  ) mc_dpi (
    .clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.link_sif_i(link_sif_i)
    ,.link_sif_o(link_sif_o)
    ,.reset_done_i(reset_done_i)
    ,.global_x_i(global_x_i)
    ,.global_y_i(global_y_i)
    );
  
  
endmodule
