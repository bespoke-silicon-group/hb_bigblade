
`include "bsg_defines.v"
`include "bsg_noc_links.vh"

module bsg_chip_noc_mem_link

 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_chip_pkg::*;

  (input                              ext_io_clk_i
  ,input                              ext_noc_clk_i
  ,input                              async_output_disable_i

  ,input                              tag_clk_i
  ,input                              tag_data_i
  ,input  [tag_lg_els_gp-1:0]         tag_node_id_offset_i

  ,input  [1:0]                                 io_link_clk_i
  ,input  [1:0]                                 io_link_v_i
  ,input  [1:0][bsg_link_channel_width_gp-1:0]  io_link_data_i
  ,output [1:0]                                 io_link_token_o

  ,output [1:0]                                 io_link_clk_o
  ,output [1:0]                                 io_link_v_o
  ,output [1:0][bsg_link_channel_width_gp-1:0]  io_link_data_o
  ,input  [1:0]                                 io_link_token_i

  ,output [1:0][wh_ruche_factor_gp-1:0]                      io_wh_link_clk_o
  ,output [1:0][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0] io_wh_link_data_o
  ,output [1:0][wh_ruche_factor_gp-1:0]                      io_wh_link_v_o
  ,input  [1:0][wh_ruche_factor_gp-1:0]                      io_wh_link_token_i

  ,input  [1:0][wh_ruche_factor_gp-1:0]                      io_wh_link_clk_i
  ,input  [1:0][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0] io_wh_link_data_i
  ,input  [1:0][wh_ruche_factor_gp-1:0]                      io_wh_link_v_i
  ,output [1:0][wh_ruche_factor_gp-1:0]                      io_wh_link_token_o
  );

  // tag master instance
  bsg_chip_noc_tag_lines_s tag_lines_lo;
  bsg_tag_master_decentralized
 #(.els_p      (tag_els_gp)
  ,.local_els_p(tag_noc_local_els_gp)
  ,.lg_width_p (tag_lg_width_gp)
  ) btm
  (.clk_i           (tag_clk_i)
  ,.data_i          (tag_data_i)
  ,.node_id_offset_i(tag_node_id_offset_i)
  ,.clients_o       (tag_lines_lo)
  );

  // noc clock, only one in use
  wire [1:0] noc_clk_raw_lo;
  wire noc_clk_lo = noc_clk_raw_lo[0];

  `declare_bsg_ready_and_link_sif_s(bsg_link_width_gp, core_link_sif_s);
  core_link_sif_s [1:0] core_links_li, core_links_lo;

  wire [1:0] io_link_clk_li, io_link_v_li, io_link_clk_lo, io_link_v_lo;
  wire [1:0][bsg_link_channel_width_gp-1:0] io_link_data_li, io_link_data_lo;

  for (genvar i = 0; i < 2; i++)
  begin: ddr_link
    bsg_link_delay_line idelay
    (.tag_clk_i(tag_clk_i)
    ,.tag_lines_i(tag_lines_lo.ddr[i].idelay)
    ,.i({io_link_clk_i [i], io_link_v_i [i], io_link_data_i [i]})
    ,.o({io_link_clk_li[i], io_link_v_li[i], io_link_data_li[i]}));

    bsg_link_delay_line odelay
    (.tag_clk_i(tag_clk_i)
    ,.tag_lines_i(tag_lines_lo.ddr[i].odelay)
    ,.i({io_link_clk_lo[i], io_link_v_lo[i], io_link_data_lo[i]})
    ,.o({io_link_clk_o [i], io_link_v_o [i], io_link_data_o [i]}));

    bsg_chip_io_link_ddr link
    (.core_clk_i                     (noc_clk_lo            )
    ,.ext_io_clk_i                   (ext_io_clk_i          )
    ,.ext_noc_clk_i                  (ext_noc_clk_i         )
    ,.async_output_disable_i         (async_output_disable_i)
    ,.noc_clk_o                      (noc_clk_raw_lo[i]     )

    ,.tag_clk_i                      (tag_clk_i          )
    ,.tag_lines_i                    (tag_lines_lo.ddr[i].main)

    ,.core_v_i                       (core_links_li[i].v                                 )
    ,.core_data_i                    (core_links_li[i].data                              )
    ,.core_ready_and_o               (core_links_lo[i].ready_and_rev                     )

    ,.core_v_o                       (core_links_lo[i].v                                 )
    ,.core_data_o                    (core_links_lo[i].data                              )
    ,.core_yumi_i                    (core_links_lo[i].v & core_links_li[i].ready_and_rev)

    ,.io_link_clk_o                  (io_link_clk_lo [i])
    ,.io_link_data_o                 (io_link_data_lo[i])
    ,.io_link_v_o                    (io_link_v_lo   [i])
    ,.io_link_token_i                (io_link_token_i[i])

    ,.io_link_clk_i                  (io_link_clk_li [i])
    ,.io_link_data_i                 (io_link_data_li[i])
    ,.io_link_v_i                    (io_link_v_li   [i])
    ,.io_link_token_o                (io_link_token_o[i])
    );
  end

  // bsg_tag clients
  logic noc_reset_lo, noc_reset_new_lo;

  bsg_tag_client
 #(.width_p       (1)
  ,.default_p     (0)
  ) btc_noc
  (.bsg_tag_i     (tag_lines_lo.noc_reset)
  ,.recv_clk_i    (noc_clk_lo)
  ,.recv_reset_i  (1'b0)
  ,.recv_new_r_o  (noc_reset_new_lo)
  ,.recv_data_r_o (noc_reset_lo)
  );

  logic sdr_uplink_reset, sdr_downlink_reset, sdr_downstream_reset, sdr_token_reset;

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

  // mem link round robin arbiters
  core_link_sif_s core_links_conc_li, core_links_conc_lo;

  bsg_ready_and_link_round_robin_static 
 #(.width_p      (bsg_link_width_gp)
  ,.num_in_p     (2)
  ) rr
  (.clk_i        (noc_clk_lo)
  ,.reset_i      (noc_reset_lo)
  ,.single_link_i(core_links_conc_li)
  ,.single_link_o(core_links_conc_lo)
  ,.links_i      (core_links_lo)
  ,.links_o      (core_links_li)
  );

  `declare_bsg_ready_and_link_sif_s(wh_flit_width_gp, wh_link_sif_s);
  wh_link_sif_s wh_link_sif_li, wh_link_sif_lo;

  assign wh_link_sif_li.v             = core_links_conc_lo.v;
  assign wh_link_sif_li.data          = core_links_conc_lo.data;
  assign wh_link_sif_li.ready_and_rev = core_links_conc_lo.ready_and_rev;
  assign core_links_conc_li.v             = wh_link_sif_lo.v;
  assign core_links_conc_li.data          = wh_link_sif_lo.data;
  assign core_links_conc_li.ready_and_rev = wh_link_sif_lo.ready_and_rev;

  wh_link_sif_s [1:0][wh_ruche_factor_gp-1:0] wh_unconc_link_sif_li, wh_unconc_link_sif_lo;
  bsg_wormhole_concentrator
 #(.flit_width_p(wh_flit_width_gp)
  ,.len_width_p (wh_len_width_gp)
  ,.cid_width_p (wh_cid_width_gp)
  ,.cord_width_p(wh_cord_width_gp)
  ,.num_in_p    (2*wh_ruche_factor_gp)
  ) conc0
  (.clk_i  (noc_clk_lo)
  ,.reset_i(noc_reset_lo)
  
  ,.links_i(wh_unconc_link_sif_lo)
  ,.links_o(wh_unconc_link_sif_li)

  ,.concentrated_link_i(wh_link_sif_li)
  ,.concentrated_link_o(wh_link_sif_lo)
  );

  for (genvar i = 0; i < 2; i++)
  begin: sdr
    logic uplink_reset_sync, downstream_reset_sync;
    bsg_sync_sync #(.width_p(1)) up_bss
    (.oclk_i     (noc_clk_lo                        )
    ,.iclk_data_i(sdr_uplink_reset)
    ,.oclk_data_o(uplink_reset_sync                 )
    );
    bsg_sync_sync #(.width_p(1)) down_bss
    (.oclk_i     (noc_clk_lo                            )
    ,.iclk_data_i(sdr_downstream_reset)
    ,.oclk_data_o(downstream_reset_sync                 )
    );
    for (genvar j = 0; j < wh_ruche_factor_gp; j++)
      begin: wh_sdr
        bsg_link_sdr
       #(.width_p                        (wh_flit_width_gp)
        ,.lg_fifo_depth_p                (sdr_lg_fifo_depth_gp)
        ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_gp)
        ,.bypass_upstream_twofer_fifo_p  (0)
        ,.bypass_downstream_twofer_fifo_p(0)
        ) sdr
        (.core_clk_i             (noc_clk_lo)
        ,.core_uplink_reset_i    (uplink_reset_sync)
        ,.core_downstream_reset_i(downstream_reset_sync)
        ,.async_downlink_reset_i (sdr_downlink_reset)
        ,.async_token_reset_i    (sdr_token_reset)

        ,.core_data_i (wh_unconc_link_sif_li[i][j].data)
        ,.core_v_i    (wh_unconc_link_sif_li[i][j].v)
        ,.core_ready_o(wh_unconc_link_sif_lo[i][j].ready_and_rev)

        ,.core_data_o (wh_unconc_link_sif_lo[i][j].data)
        ,.core_v_o    (wh_unconc_link_sif_lo[i][j].v)
        ,.core_yumi_i (wh_unconc_link_sif_lo[i][j].v & wh_unconc_link_sif_li[i][j].ready_and_rev)

        ,.link_clk_o  (io_wh_link_clk_o  [i][j])
        ,.link_data_o (io_wh_link_data_o [i][j])
        ,.link_v_o    (io_wh_link_v_o    [i][j])
        ,.link_token_i(io_wh_link_token_i[i][j])

        ,.link_clk_i  (io_wh_link_clk_i  [i][j])
        ,.link_data_i (io_wh_link_data_i [i][j])
        ,.link_v_i    (io_wh_link_v_i    [i][j])
        ,.link_token_o(io_wh_link_token_o[i][j])
        );
      end
  end

endmodule
