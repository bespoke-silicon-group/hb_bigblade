
`include "bsg_defines.v"
`include "bsg_noc_links.vh"

module bsg_chip_noc_mem_link

 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;

 #(parameter ds_width_p                          = "inv"
  ,parameter num_adgs_p                          = "inv"
  ,parameter width_p                             = "inv"
  ,parameter channel_width_p                     = "inv"
  ,parameter num_channels_p                      = "inv"
  ,parameter lg_fifo_depth_p                     = "inv"
  ,parameter lg_credit_to_token_decimation_p     = "inv"
  ,parameter use_extra_data_bit_p                = "inv"
  ,parameter tag_num_clients_p                   = "inv"
  ,parameter tag_lg_max_payload_width_p          = "inv"
  ,parameter sdr_lg_fifo_depth_p                 = "inv"
  ,parameter sdr_lg_credit_to_token_decimation_p = "inv"
  ,parameter wh_ruche_factor_p                   = "inv"
  ,parameter wh_flit_width_p                     = "inv"
  ,parameter wh_len_width_p                      = "inv"
  ,parameter wh_cid_width_p                      = "inv"
  ,parameter wh_cord_width_p                     = "inv"
  ,parameter lg_tag_num_clients_lp               = `BSG_SAFE_CLOG2(tag_num_clients_p)
  ,parameter wh_link_sif_width_lp =
    `bsg_ready_and_link_sif_width(wh_flit_width_p)
  )

  (input                              ext_io_clk_i
  ,input                              ext_noc_clk_i
  ,input                              async_output_disable_i

  ,input                              tag_clk_i
  ,input                              tag_data_i
  ,input  [lg_tag_num_clients_lp-1:0] tag_node_id_offset_i

  ,input  [1:0]                       io_link_clk_i
  ,input  [1:0]                       io_link_v_i
  ,input  [1:0][channel_width_p-1:0]  io_link_data_i
  ,output [1:0]                       io_link_token_o

  ,output [1:0]                       io_link_clk_o
  ,output [1:0]                       io_link_v_o
  ,output [1:0][channel_width_p-1:0]  io_link_data_o
  ,input  [1:0]                       io_link_token_i

  ,output [1:0][wh_ruche_factor_p-1:0]                      io_wh_link_clk_o
  ,output [1:0][wh_ruche_factor_p-1:0][wh_flit_width_p-1:0] io_wh_link_data_o
  ,output [1:0][wh_ruche_factor_p-1:0]                      io_wh_link_v_o
  ,input  [1:0][wh_ruche_factor_p-1:0]                      io_wh_link_token_i

  ,input  [1:0][wh_ruche_factor_p-1:0]                      io_wh_link_clk_i
  ,input  [1:0][wh_ruche_factor_p-1:0][wh_flit_width_p-1:0] io_wh_link_data_i
  ,input  [1:0][wh_ruche_factor_p-1:0]                      io_wh_link_v_i
  ,output [1:0][wh_ruche_factor_p-1:0]                      io_wh_link_token_o
  );

  // ddr_tag_lines + sdr_tag_lines + noc_tag_lines
  localparam tag_num_local_clients_lp = 12*2 + 1 + 1;

  // tag master instance
  bsg_tag_s [tag_num_local_clients_lp-1:0] tag_lines_lo;
  bsg_tag_master_decentralized
 #(.els_p      (tag_num_clients_p)
  ,.local_els_p(tag_num_local_clients_lp)
  ,.lg_width_p (tag_lg_max_payload_width_p)
  ) btm
  (.clk_i           (tag_clk_i)
  ,.data_i          (tag_data_i)
  ,.node_id_offset_i(tag_node_id_offset_i)
  ,.clients_o       (tag_lines_lo)
  );

  // noc clock, only one in use
  wire [1:0] noc_clk_raw_lo;
  wire noc_clk_lo = noc_clk_raw_lo[0];

  `declare_bsg_ready_and_link_sif_s(width_p, core_link_sif_s);
  core_link_sif_s [1:0] core_links_li, core_links_lo;

  for (genvar i = 0; i < 2; i++)
  begin: ddr_link
    bsg_chip_io_link_ddr
   #(.ds_width_p                     (ds_width_p                     )
    ,.num_adgs_p                     (num_adgs_p                     )
    ,.width_p                        (width_p                        )
    ,.channel_width_p                (channel_width_p                )
    ,.num_channels_p                 (num_channels_p                 )
    ,.lg_fifo_depth_p                (lg_fifo_depth_p                )
    ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
    ,.use_extra_data_bit_p           (use_extra_data_bit_p           )
    ) link
    (.core_clk_i                     (noc_clk_lo            )
    ,.ext_io_clk_i                   (ext_io_clk_i          )
    ,.ext_noc_clk_i                  (ext_noc_clk_i         )
    ,.async_output_disable_i         (async_output_disable_i)
    ,.noc_clk_o                      (noc_clk_raw_lo[i]     )

    ,.tag_clk_i                      (tag_clk_i       )
    ,.tag_io_tag_lines_i             (tag_lines_lo[i*12+0 ])
    ,.tag_core_tag_lines_i           (tag_lines_lo[i*12+1 ])
    ,.tag_io_async_reset_tag_lines_i (tag_lines_lo[i*12+2 ])
    ,.tag_io_osc_tag_lines_i         (tag_lines_lo[i*12+3 ])
    ,.tag_io_osc_trigger_tag_lines_i (tag_lines_lo[i*12+4 ])
    ,.tag_io_ds_tag_lines_i          (tag_lines_lo[i*12+5 ])
    ,.tag_io_sel_tag_lines_i         (tag_lines_lo[i*12+6 ])
    ,.tag_noc_async_reset_tag_lines_i(tag_lines_lo[i*12+7 ])
    ,.tag_noc_osc_tag_lines_i        (tag_lines_lo[i*12+8 ])
    ,.tag_noc_osc_trigger_tag_lines_i(tag_lines_lo[i*12+9 ])
    ,.tag_noc_ds_tag_lines_i         (tag_lines_lo[i*12+10])
    ,.tag_noc_sel_tag_lines_i        (tag_lines_lo[i*12+11])

    ,.core_v_i                       (core_links_li[i].v                                 )
    ,.core_data_i                    (core_links_li[i].data                              )
    ,.core_ready_and_o               (core_links_lo[i].ready_and_rev                     )

    ,.core_v_o                       (core_links_lo[i].v                                 )
    ,.core_data_o                    (core_links_lo[i].data                              )
    ,.core_yumi_i                    (core_links_lo[i].v & core_links_li[i].ready_and_rev)

    ,.io_link_clk_o                  (io_link_clk_o  [i])
    ,.io_link_data_o                 (io_link_data_o [i])
    ,.io_link_v_o                    (io_link_v_o    [i])
    ,.io_link_token_i                (io_link_token_i[i])

    ,.io_link_clk_i                  (io_link_clk_i  [i])
    ,.io_link_data_i                 (io_link_data_i [i])
    ,.io_link_v_i                    (io_link_v_i    [i])
    ,.io_link_token_o                (io_link_token_o[i])
    );
  end

  // bsg_tag clients
  logic noc_reset_lo, noc_reset_new_lo;

  bsg_tag_client
 #(.width_p       (1)
  ,.default_p     (0)
  ) btc_noc
  (.bsg_tag_i     (tag_lines_lo[24])
  ,.recv_clk_i    (noc_clk_lo)
  ,.recv_reset_i  (1'b0)
  ,.recv_new_r_o  (noc_reset_new_lo)
  ,.recv_data_r_o (noc_reset_lo)
  );

  typedef struct packed { 
    logic uplink_reset;
    logic downlink_reset;
    logic downstream_reset;
    logic token_reset;
  } sdr_tag_payload_s;
  sdr_tag_payload_s async_sdr_tag_data_lo;

  bsg_tag_client_unsync
 #(.width_p       ($bits(sdr_tag_payload_s))
  ) btc_sdr
  (.bsg_tag_i     (tag_lines_lo[25])
  ,.data_async_r_o(async_sdr_tag_data_lo)
  );

  // mem link round robin arbiters
  core_link_sif_s core_links_conc_li, core_links_conc_lo;

  bsg_ready_and_link_round_robin_static 
 #(.width_p      (width_p)
  ,.num_in_p     (2)
  ) rr
  (.clk_i        (noc_clk_lo)
  ,.reset_i      (noc_reset_lo)
  ,.single_link_i(core_links_conc_li)
  ,.single_link_o(core_links_conc_lo)
  ,.links_i      (core_links_lo)
  ,.links_o      (core_links_li)
  );

  `declare_bsg_ready_and_link_sif_s(wh_flit_width_p, wh_link_sif_s);
  wh_link_sif_s wh_link_sif_li, wh_link_sif_lo;

  assign wh_link_sif_li.v             = core_links_conc_lo.v;
  assign wh_link_sif_li.data          = core_links_conc_lo.data;
  assign wh_link_sif_li.ready_and_rev = core_links_conc_lo.ready_and_rev;
  assign core_links_conc_li.v             = wh_link_sif_lo.v;
  assign core_links_conc_li.data          = wh_link_sif_lo.data;
  assign core_links_conc_li.ready_and_rev = wh_link_sif_lo.ready_and_rev;

  wh_link_sif_s [1:0][wh_ruche_factor_p-1:0] wh_unconc_link_sif_li, wh_unconc_link_sif_lo;
  bsg_wormhole_concentrator
 #(.flit_width_p(wh_flit_width_p)
  ,.len_width_p (wh_len_width_p)
  ,.cid_width_p (wh_cid_width_p)
  ,.cord_width_p(wh_cord_width_p)
  ,.num_in_p    (2*wh_ruche_factor_p)
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
    ,.iclk_data_i(async_sdr_tag_data_lo.uplink_reset)
    ,.oclk_data_o(uplink_reset_sync                 )
    );
    bsg_sync_sync #(.width_p(1)) down_bss
    (.oclk_i     (noc_clk_lo                            )
    ,.iclk_data_i(async_sdr_tag_data_lo.downstream_reset)
    ,.oclk_data_o(downstream_reset_sync                 )
    );
    for (genvar j = 0; j < wh_ruche_factor_p; j++)
      begin: wh_sdr
        bsg_link_sdr
       #(.width_p                        (wh_flit_width_p)
        ,.lg_fifo_depth_p                (sdr_lg_fifo_depth_p)
        ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_p)
        ,.bypass_upstream_twofer_fifo_p  (0)
        ,.bypass_downstream_twofer_fifo_p(0)
        ) sdr
        (.core_clk_i             (noc_clk_lo)
        ,.core_uplink_reset_i    (uplink_reset_sync)
        ,.core_downstream_reset_i(downstream_reset_sync)
        ,.async_downlink_reset_i (async_sdr_tag_data_lo.downlink_reset)
        ,.async_token_reset_i    (async_sdr_tag_data_lo.token_reset)

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
