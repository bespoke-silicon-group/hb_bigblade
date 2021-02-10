

module bsg_chip
 import bsg_chip_pkg::*;
  (// Upstream link
   input uplink_clk_i
   , input uplink_reset_i
   , input async_token_reset_i
   , input [width_gp-1:0] uplink_data_i
   , input uplink_v_i
   , output uplink_ready_o
   , input downlink_reset_i

   , output logic link_clk_o
   , output logic [width_gp-1:0] link_data_o
   , output logic link_v_o
   , input link_token_i

   // Downstream link
   , input downstream_clk_i
   , input downstream_reset_i
   , output logic [width_gp-1:0] downstream_data_o
   , output logic downstream_v_o
   , input downstream_ready_i

   , input link_clk_i
   , input [width_gp-1:0] link_data_i
   , input link_v_i
   , output logic link_token_o
   );

  bsg_link_sdr_upstream
 #(.width_p                        (width_gp)
  ,.lg_fifo_depth_p                (lg_fifo_depth_gp)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_gp)
  ) uplink
  (// Core side
   .io_clk_i           (uplink_clk_i)
  ,.io_link_reset_i    (uplink_reset_i)
  ,.async_token_reset_i(async_token_reset_i)
  ,.io_data_i          (uplink_data_i)
  ,.io_v_i             (uplink_v_i)
  ,.io_ready_and_o     (uplink_ready_o)
  // IO side
  ,.io_clk_o           (link_clk_o)
  ,.io_data_o          (link_data_o)
  ,.io_v_o             (link_v_o)
  ,.token_clk_i        (link_token_i)
  );

  logic downlink_reset_sync;

  bsg_sync_sync #(.width_p(1)) bss
  (.oclk_i     (link_clk_i         )
  ,.iclk_data_i(downlink_reset_i   )
  ,.oclk_data_o(downlink_reset_sync)
  );

  bsg_link_sdr_downstream
 #(.width_p                        (width_gp)
  ,.lg_fifo_depth_p                (lg_fifo_depth_gp)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_gp)
  ) downlink
  (// Core side
   .core_clk_i        (downstream_clk_i)
  ,.core_link_reset_i (downstream_reset_i)
  ,.core_data_o       (downstream_data_o)
  ,.core_v_o          (downstream_v_o)
  ,.core_yumi_i       (downstream_v_o & downstream_ready_i)
  // IO side
  ,.io_link_reset_i   (downlink_reset_sync)
  ,.io_clk_i          (link_clk_i)
  ,.io_data_i         (link_data_i)
  ,.io_v_i            (link_v_i)
  ,.core_token_r_o    (link_token_o)
  );

endmodule

