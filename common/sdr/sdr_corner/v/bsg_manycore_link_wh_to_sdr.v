
 import bsg_noc_pkg::*;
 import bsg_manycore_pkg::*;

 #(parameter lg_fifo_depth_p                 = "inv"
  ,parameter lg_credit_to_token_decimation_p = "inv"

  ,parameter addr_width_p      = "inv"
  ,parameter data_width_p      = "inv"
  ,parameter x_cord_width_p    = "inv"
  ,parameter y_cord_width_p    = "inv"

  ,parameter wh_ruche_factor_p = "inv"
  ,parameter wh_flit_width_p   = "inv"

  ,parameter link_sif_width_lp =
    `bsg_manycore_link_sif_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p)
  ,parameter fwd_width_lp =
    `bsg_manycore_packet_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p)
  ,parameter rev_width_lp =
    `bsg_manycore_return_packet_width(x_cord_width_p,y_cord_width_p,data_width_p)
  ,parameter wh_link_sif_width_lp =
    `bsg_ready_and_link_sif_width(wh_flit_width_p)
  )

  (input  core_clk_i
  ,input  core_reset_i

  ,input  [link_sif_width_lp-1:0] core_ver_link_sif_i
  ,output [link_sif_width_lp-1:0] core_ver_link_sif_o

  ,input  [wh_ruche_factor_p-1:0][wh_link_sif_width_lp-1:0] core_wh_link_sif_i
  ,output [wh_ruche_factor_p-1:0][wh_link_sif_width_lp-1:0] core_wh_link_sif_o

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

  ,output [wh_ruche_factor_p-1:0]                      io_wh_link_clk_o
  ,output [wh_ruche_factor_p-1:0][wh_flit_width_p-1:0] io_wh_link_data_o
  ,output [wh_ruche_factor_p-1:0]                      io_wh_link_v_o
  ,input  [wh_ruche_factor_p-1:0]                      io_wh_link_token_i

  ,input  [wh_ruche_factor_p-1:0]                      io_wh_link_clk_i
  ,input  [wh_ruche_factor_p-1:0][wh_flit_width_p-1:0] io_wh_link_data_i
  ,input  [wh_ruche_factor_p-1:0]                      io_wh_link_v_i
  ,output [wh_ruche_factor_p-1:0]                      io_wh_link_token_o
  );

  //-------------------------------------------
  //As the manycore will distribute across large area, it will take long
  //time for the reset signal to propgate. We should register the reset
  //signal in each tile
  logic core_reset_r;
  bsg_dff #(.width_p(1)) dff_core_reset
  (.clk_i(core_clk_i),.data_i(core_reset_i),.data_o(core_reset_r));

  `declare_bsg_manycore_link_sif_s(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p);
  `declare_bsg_ready_and_link_sif_s(wh_flit_width_p, wh_link_sif_s);

  bsg_manycore_link_sif_s ver_link_sif_li, ver_link_sif_lo;
  bsg_manycore_link_sif_s ver_int_link_sif_li, ver_int_link_sif_lo;
  wh_link_sif_s [wh_ruche_factor_p-1:0] wh_link_sif_li, wh_link_sif_lo;
  wh_link_sif_s [wh_ruche_factor_p-1:0] wh_link_int_sif_li, wh_link_int_sif_lo;

  assign ver_link_sif_li = core_ver_link_sif_i;
  assign core_ver_link_sif_o = ver_link_sif_lo;
  assign wh_link_sif_li = core_wh_link_sif_i;
  assign core_wh_link_sif_o = wh_link_sif_lo;

  bsg_noc_repeater_node
 #(.width_p       (fwd_width_lp)
  ) fwd_node
  (.clk_i         (core_clk_i)
  ,.reset_i       (core_reset_r)
  ,.side_A_links_i(ver_link_sif_li.fwd)
  ,.side_A_links_o(ver_link_sif_lo.fwd)
  ,.side_B_links_i(ver_int_link_sif_li.fwd)
  ,.side_B_links_o(ver_int_link_sif_lo.fwd)
  );

  bsg_noc_repeater_node
 #(.width_p       (rev_width_lp)
  ) rev_node
  (.clk_i         (core_clk_i)
  ,.reset_i       (core_reset_r)
  ,.side_A_links_i(ver_link_sif_li.rev)
  ,.side_A_links_o(ver_link_sif_lo.rev)
  ,.side_B_links_i(ver_int_link_sif_li.rev)
  ,.side_B_links_o(ver_int_link_sif_lo.rev)
  );

  for (genvar i = 0; i < wh_ruche_factor_p; i++)
  begin: wh_node
    bsg_noc_repeater_node
   #(.width_p       (wh_flit_width_p)
    ) node
    (.clk_i         (core_clk_i)
    ,.reset_i       (core_reset_r)
    ,.side_A_links_i(wh_link_sif_li    [i])
    ,.side_A_links_o(wh_link_sif_lo    [i])
    ,.side_B_links_i(wh_link_int_sif_li[i])
    ,.side_B_links_o(wh_link_int_sif_lo[i])
    );
  end

  assign async_uplink_reset_o     = async_uplink_reset_i;
  assign async_downlink_reset_o   = async_downlink_reset_i;
  assign async_downstream_reset_o = async_downstream_reset_i;
  assign async_token_reset_o      = async_token_reset_i;

  logic core_uplink_reset_sync, core_downstream_reset_sync;
  bsg_sync_sync #(.width_p(1)) up_bss
  (.oclk_i     (core_clk_i            )
  ,.iclk_data_i(async_uplink_reset_i  )
  ,.oclk_data_o(core_uplink_reset_sync)
  );
  bsg_sync_sync #(.width_p(1)) down_bss
  (.oclk_i     (core_clk_i                )
  ,.iclk_data_i(async_downstream_reset_i  )
  ,.oclk_data_o(core_downstream_reset_sync)
  );

  bsg_link_sdr
 #(.width_p                        (fwd_width_lp)
  ,.lg_fifo_depth_p                (lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
  ) fwd_sdr
  (.core_clk_i             (core_clk_i)
  ,.core_uplink_reset_i    (core_uplink_reset_sync)
  ,.core_downstream_reset_i(core_downstream_reset_sync)
  ,.async_downlink_reset_i (async_downlink_reset_i)
  ,.async_token_reset_i    (async_token_reset_i)

  ,.core_data_i (ver_int_link_sif_lo.fwd.data)
  ,.core_v_i    (ver_int_link_sif_lo.fwd.v)
  ,.core_ready_o(ver_int_link_sif_li.fwd.ready_and_rev)

  ,.core_data_o (ver_int_link_sif_li.fwd.data)
  ,.core_v_o    (ver_int_link_sif_li.fwd.v)
  ,.core_yumi_i (ver_int_link_sif_li.fwd.v & ver_int_link_sif_lo.fwd.ready_and_rev)

  ,.link_clk_o  (io_fwd_link_clk_o)
  ,.link_data_o (io_fwd_link_data_o)
  ,.link_v_o    (io_fwd_link_v_o)
  ,.link_token_i(io_fwd_link_token_i)

  ,.link_clk_i  (io_fwd_link_clk_i)
  ,.link_data_i (io_fwd_link_data_i)
  ,.link_v_i    (io_fwd_link_v_i)
  ,.link_token_o(io_fwd_link_token_o)
  );

  bsg_link_sdr
 #(.width_p                        (rev_width_lp)
  ,.lg_fifo_depth_p                (lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
  ) rev_sdr
  (.core_clk_i             (core_clk_i)
  ,.core_uplink_reset_i    (core_uplink_reset_sync)
  ,.core_downstream_reset_i(core_downstream_reset_sync)
  ,.async_downlink_reset_i (async_downlink_reset_i)
  ,.async_token_reset_i    (async_token_reset_i)

  ,.core_data_i (ver_int_link_sif_lo.rev.data)
  ,.core_v_i    (ver_int_link_sif_lo.rev.v)
  ,.core_ready_o(ver_int_link_sif_li.rev.ready_and_rev)

  ,.core_data_o (ver_int_link_sif_li.rev.data)
  ,.core_v_o    (ver_int_link_sif_li.rev.v)
  ,.core_yumi_i (ver_int_link_sif_li.rev.v & ver_int_link_sif_lo.rev.ready_and_rev)

  ,.link_clk_o  (io_rev_link_clk_o)
  ,.link_data_o (io_rev_link_data_o)
  ,.link_v_o    (io_rev_link_v_o)
  ,.link_token_i(io_rev_link_token_i)

  ,.link_clk_i  (io_rev_link_clk_i)
  ,.link_data_i (io_rev_link_data_i)
  ,.link_v_i    (io_rev_link_v_i)
  ,.link_token_o(io_rev_link_token_o)
  );

  for (genvar i = 0; i < wh_ruche_factor_p; i++)
  begin: wh_sdr
    bsg_link_sdr
   #(.width_p                        (wh_flit_width_p)
    ,.lg_fifo_depth_p                (lg_fifo_depth_p)
    ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
    ) sdr
    (.core_clk_i             (core_clk_i)
    ,.core_uplink_reset_i    (core_uplink_reset_sync)
    ,.core_downstream_reset_i(core_downstream_reset_sync)
    ,.async_downlink_reset_i (async_downlink_reset_i)
    ,.async_token_reset_i    (async_token_reset_i)

    ,.core_data_i (wh_link_int_sif_lo[i].data)
    ,.core_v_i    (wh_link_int_sif_lo[i].v)
    ,.core_ready_o(wh_link_int_sif_li[i].ready_and_rev)

    ,.core_data_o (wh_link_int_sif_li[i].data)
    ,.core_v_o    (wh_link_int_sif_li[i].v)
    ,.core_yumi_i (wh_link_int_sif_li[i].v & wh_link_int_sif_lo[i].ready_and_rev)

    ,.link_clk_o  (io_wh_link_clk_o  [i])
    ,.link_data_o (io_wh_link_data_o [i])
    ,.link_v_o    (io_wh_link_v_o    [i])
    ,.link_token_i(io_wh_link_token_i[i])

    ,.link_clk_i  (io_wh_link_clk_i  [i])
    ,.link_data_i (io_wh_link_data_i [i])
    ,.link_v_i    (io_wh_link_v_i    [i])
    ,.link_token_o(io_wh_link_token_o[i])
    );
  end
