module bigblade_clk_gen_monitor
  import bsg_tag_pkg::bsg_tag_s;

( input  bsg_tag_s  monitor_reset_tag_line_i
, input             clk_i
, output logic      clk_monitor_o
);

  logic monitor_clk_buf_lo;

  bigblade_clk_gen_monitor_clk_buf
    monitor_clk_buf
      (.i(clk_i)
      ,.o(monitor_clk_buf_lo)
      );

  logic monitor_reset_lo;

  bsg_tag_client_unsync #(.width_p(1))
    btc_monitor_reset
      (.bsg_tag_i(monitor_reset_tag_line_i)
      ,.data_async_r_o(monitor_reset_lo)
      );

  logic monitor_reset_sync_lo;

  bsg_sync_sync #(.width_p(1))
    monitor_reset_sync
      (.oclk_i(monitor_clk_buf_lo)
      ,.iclk_data_i(monitor_reset_lo)
      ,.oclk_data_o(monitor_reset_sync_lo)
      );

  bsg_lfsr_div30
    monitor_ds
      (.clk_i(monitor_clk_buf_lo)
      ,.reset_i(monitor_reset_sync_lo)
      ,.clk_div_o(clk_monitor_o)
      );

endmodule // bigblade_clk_gen_monitor

