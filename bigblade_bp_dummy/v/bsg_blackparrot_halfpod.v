
// WARNING: THIS IS A DUMMY MODULE FOR RTL SIMULATION ONLY

module bsg_blackparrot_halfpod
  import bsg_chip_pkg::*;
  import bsg_manycore_pkg::*;
  import bsg_noc_pkg::*; // {P=0, W, E, N, S}
  import bsg_tag_pkg::*;
  #(localparam fwd_width_lp =
      `bsg_manycore_packet_width(hb_addr_width_gp, hb_data_width_gp, hb_x_cord_width_gp, hb_y_cord_width_gp)
    , localparam rev_width_lp =
      `bsg_manycore_return_packet_width(hb_x_cord_width_gp, hb_y_cord_width_gp, hb_data_width_gp)
  )
  (
    input clk_i

    , input                      tag_clk_i
    , input                      tag_data_i
    , input  [tag_lg_els_gp-1:0] tag_node_id_offset_i
 
    , output logic [2:0]                   io_fwd_link_clk_o
    , output logic [2:0][fwd_width_lp-1:0] io_fwd_link_data_o
    , output logic [2:0]                   io_fwd_link_v_o
    , input [2:0]                          io_fwd_link_token_i
    , output logic [2:0]                   async_fwd_link_o_disable_o
 
    , input [2:0]                          io_fwd_link_clk_i
    , input [2:0][fwd_width_lp-1:0]        io_fwd_link_data_i
    , input [2:0]                          io_fwd_link_v_i
    , output logic [2:0]                   io_fwd_link_token_o
    , output logic [2:0]                   async_fwd_link_i_disable_o
 
    , output logic [2:0]                   io_rev_link_clk_o
    , output logic [2:0][rev_width_lp-1:0] io_rev_link_data_o
    , output logic [2:0]                   io_rev_link_v_o
    , input [2:0]                          io_rev_link_token_i
    , output logic [2:0]                   async_rev_link_o_disable_o
 
    , input [2:0]                          io_rev_link_clk_i
    , input [2:0][rev_width_lp-1:0]        io_rev_link_data_i
    , input [2:0]                          io_rev_link_v_i
    , output logic [2:0]                   io_rev_link_token_o
    , output logic [2:0]                   async_rev_link_i_disable_o
  );

  //=========================================================================
  // Tag master and clients
  //=========================================================================

  // tag master instance
  bsg_chip_halfpod_tag_lines_s tag_lines_lo;
  bsg_tag_master_decentralized
 #(.els_p      (tag_els_gp)
  ,.local_els_p(tag_halfpod_local_els_gp)
  ,.lg_width_p (tag_lg_width_gp)
  ) btm
  (.clk_i           (tag_clk_i)
  ,.data_i          (tag_data_i)
  ,.node_id_offset_i(tag_node_id_offset_i)
  ,.clients_o       (tag_lines_lo)
  );

  logic sdr_uplink_reset, sdr_downlink_reset, sdr_downstream_reset, sdr_token_reset;
  logic [hb_y_cord_width_gp-1:0] async_global_y_cord;
  logic async_core_reset, sdr_disable_lo;

  bsg_tag_client_unsync #(.width_p(1)) btc0
  (.bsg_tag_i     (tag_lines_lo.sdr.token_reset)
  ,.data_async_r_o(sdr_token_reset));

  bsg_tag_client_unsync #(.width_p(1)) btc1
  (.bsg_tag_i     (tag_lines_lo.sdr.downstream_reset)
  ,.data_async_r_o(sdr_downstream_reset));

  bsg_tag_client_unsync #(.width_p(1)) btc2
  (.bsg_tag_i     (tag_lines_lo.sdr.downlink_reset)
  ,.data_async_r_o(sdr_downlink_reset));

  bsg_tag_client_unsync #(.width_p(1)) btc3
  (.bsg_tag_i     (tag_lines_lo.sdr.uplink_reset)
  ,.data_async_r_o(sdr_uplink_reset));

  bsg_tag_client_unsync #(.width_p(1)) btc4
  (.bsg_tag_i     (tag_lines_lo.sdr_disable)
  ,.data_async_r_o(sdr_disable_lo));
  assign async_fwd_link_i_disable_o = {3{sdr_disable_lo}};
  assign async_fwd_link_o_disable_o = {3{sdr_disable_lo}};
  assign async_rev_link_i_disable_o = {3{sdr_disable_lo}};
  assign async_rev_link_o_disable_o = {3{sdr_disable_lo}};

  bsg_tag_client_unsync #(.width_p(hb_y_cord_width_gp)) btc5
  (.bsg_tag_i     (tag_lines_lo.global_y_cord)
  ,.data_async_r_o(async_global_y_cord));

  bsg_tag_client_unsync #(.width_p(1)) btc6
  (.bsg_tag_i     (tag_lines_lo.core_reset)
  ,.data_async_r_o(async_core_reset));

  // End of tag master and clients

  `declare_bsg_manycore_link_sif_s(hb_addr_width_gp, hb_data_width_gp, hb_x_cord_width_gp, hb_y_cord_width_gp);

  bsg_manycore_link_sif_s [2:0] proc_link_sif_li, proc_link_sif_lo;

  //=========================================================================
  // Reset
  //=========================================================================

  logic sync_reset;
  bsg_sync_sync #(
    .width_p(1)
  ) reset_bss (
    .oclk_i(clk_i)
    ,.iclk_data_i(async_core_reset)
    ,.oclk_data_o(sync_reset)
  );

  logic uplink_reset_sync;
  bsg_sync_sync #(
    .width_p(1)
  ) up_bss (
    .oclk_i(clk_i)
    ,.iclk_data_i(sdr_uplink_reset)
    ,.oclk_data_o(uplink_reset_sync)
  );

  logic downstream_reset_sync;
  bsg_sync_sync #(
    .width_p(1)
  ) down_bss (
    .oclk_i(clk_i)
    ,.iclk_data_i(sdr_downstream_reset)
    ,.oclk_data_o(downstream_reset_sync)
  );

  //=========================================================================
  // SDR
  //=========================================================================

  for (genvar i = 0; i < 3; i++) begin : links
    bsg_link_sdr #(
      .width_p(fwd_width_lp)
      ,.lg_fifo_depth_p(sdr_lg_fifo_depth_gp)
      ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_gp)
    ) fwd_sdr (
      .core_clk_i(clk_i)
      ,.core_uplink_reset_i(uplink_reset_sync)
      ,.core_downstream_reset_i(downstream_reset_sync)
      ,.async_downlink_reset_i(sdr_downlink_reset)
      ,.async_token_reset_i(sdr_token_reset)

      ,.core_data_i(proc_link_sif_lo[i].fwd.data)
      ,.core_v_i(proc_link_sif_lo[i].fwd.v)
      ,.core_ready_o(proc_link_sif_li[i].fwd.ready_and_rev)

      ,.core_data_o(proc_link_sif_li[i].fwd.data)
      ,.core_v_o(proc_link_sif_li[i].fwd.v)
      ,.core_yumi_i(proc_link_sif_li[i].fwd.v & proc_link_sif_lo[i].fwd.ready_and_rev)

      ,.link_clk_o(io_fwd_link_clk_o[i])
      ,.link_data_o(io_fwd_link_data_o[i])
      ,.link_v_o(io_fwd_link_v_o[i])
      ,.link_token_i(io_fwd_link_token_i[i])

      ,.link_clk_i(io_fwd_link_clk_i[i])
      ,.link_data_i(io_fwd_link_data_i[i])
      ,.link_v_i(io_fwd_link_v_i[i])
      ,.link_token_o(io_fwd_link_token_o[i])
    );

    bsg_link_sdr #(
      .width_p(rev_width_lp)
      ,.lg_fifo_depth_p(sdr_lg_fifo_depth_gp)
      ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_gp)
    ) rev_sdr (
      .core_clk_i(clk_i)
      ,.core_uplink_reset_i(uplink_reset_sync)
      ,.core_downstream_reset_i(downstream_reset_sync)
      ,.async_downlink_reset_i(sdr_downlink_reset)
      ,.async_token_reset_i(sdr_token_reset)

      ,.core_data_i(proc_link_sif_lo[i].rev.data)
      ,.core_v_i(proc_link_sif_lo[i].rev.v)
      ,.core_ready_o(proc_link_sif_li[i].rev.ready_and_rev)

      ,.core_data_o(proc_link_sif_li[i].rev.data)
      ,.core_v_o(proc_link_sif_li[i].rev.v)
      ,.core_yumi_i(proc_link_sif_li[i].rev.v & proc_link_sif_lo[i].rev.ready_and_rev)

      ,.link_clk_o(io_rev_link_clk_o[i])
      ,.link_data_o(io_rev_link_data_o[i])
      ,.link_v_o(io_rev_link_v_o[i])
      ,.link_token_i(io_rev_link_token_i[i])

      ,.link_clk_i(io_rev_link_clk_i[i])
      ,.link_data_i(io_rev_link_data_i[i])
      ,.link_v_i(io_rev_link_v_i[i])
      ,.link_token_o(io_rev_link_token_o[i])
    );
  end

  // Loopback manycore links
  assign proc_link_sif_lo = proc_link_sif_li;

endmodule 
