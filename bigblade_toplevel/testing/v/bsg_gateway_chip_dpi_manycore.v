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

  localparam reset_depth_lp = 3;
  logic reset_done_r;
  bsg_dff_chain
     #(
       .width_p(1)
       ,.num_stages_p(reset_depth_lp)
       )
   reset_dff
     (
      .clk_i(clk_i)
      ,.data_i(reset_done_i)
      ,.data_o(reset_done_r)
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
    ,.reset_done_i(reset_done_r)
    ,.global_x_i(global_x_i)
    ,.global_y_i(global_y_i)
    );

  `define COSIM_MAIN
  `ifdef COSIM_MAIN
  // In VCS, the C/C++ testbench is controlled by the
  // simulator. Therefore, we need to "call into" the C/C++ program
  // using the cosim_main function, during the initial block.
  //
  // DPI Calls in cosim_main will cause simulator time to progress.
  //
  // This mirrors the DPI functions in aws simulation
  import "DPI-C" context task cosim_main(output int unsigned exit_code, input string args, input string path);
   initial begin
      int exit_code;
      string args;
      string path;
      longint t;
      $value$plusargs("c_path=%s", path);
      $value$plusargs("c_args=%s", args);
      bsg_bigblade_pcb.GW.bgc.core_complex.mc_dpi.cosim_main(exit_code, args, path);
      if(exit_code < 0) begin
        $display("BSG COSIM FAIL: Test failed with exit code: %d", exit_code);
        $fatal;
      end else begin
        $display("BSG COSIM PASS: Test passed!");
        $finish;
      end
   end
  `endif //  `ifndef COSIM_MAIN
  
   // Global Counter for Profilers, Tracing, Debugging
   localparam global_counter_width_lp = 64;
   logic [global_counter_width_lp-1:0] global_ctr;

  
   bsg_nonsynth_dpi_cycle_counter
     #(.width_p(global_counter_width_lp))
   ctr
     (
      .clk_i(clk_i)
      ,.reset_i(reset_i)
      ,.ctr_r_o(global_ctr)
      );

  
endmodule
