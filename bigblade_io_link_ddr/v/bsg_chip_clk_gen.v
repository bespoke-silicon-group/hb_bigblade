
module bsg_chip_clk_gen

 import bsg_tag_pkg::bsg_tag_s;

 #(parameter ds_width_p = 8
  ,parameter num_adgs_p = 1
  )

  (// bsg_tag signals
   input bsg_tag_s async_reset_tag_lines_i
  ,input bsg_tag_s osc_tag_lines_i
  ,input bsg_tag_s osc_trigger_tag_lines_i
  ,input bsg_tag_s ds_tag_lines_i
  ,input bsg_tag_s sel_tag_lines_i

  // output constant zero for all clocks
  , input async_output_disable_i

  // external clock input
  , input ext_clk_i

  // output clocks
  , output logic clk_o
  );

  logic async_reset_lo;
  logic [1:0] clk_select;

  bsg_tag_client_unsync #( .width_p(1) )
    btc_async_reset
      (.bsg_tag_i(async_reset_tag_lines_i)
      ,.data_async_r_o(async_reset_lo)
      );

  bsg_tag_client_unsync #( .width_p(2) )
    btc_clk_select
      (.bsg_tag_i(sel_tag_lines_i)
      ,.data_async_r_o(clk_select)
      );

  bsg_clk_gen #(.downsample_width_p(ds_width_p)
               ,.num_adgs_p(num_adgs_p)
               ,.version_p(2)
               )
    clk_gen_inst
      (.async_osc_reset_i     (async_reset_lo)
      ,.bsg_osc_tag_i         (osc_tag_lines_i)
      ,.bsg_osc_trigger_tag_i (osc_trigger_tag_lines_i)
      ,.bsg_ds_tag_i          (ds_tag_lines_i)
      ,.ext_clk_i             (ext_clk_i)
      ,.select_i              (async_output_disable_i? 2'b11 : clk_select)
      ,.clk_o                 (clk_o)
      );

endmodule