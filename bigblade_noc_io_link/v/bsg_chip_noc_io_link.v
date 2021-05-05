
`include "bsg_defines.v"
`include "bsg_noc_links.vh"

module bsg_chip_noc_io_link

 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_manycore_pkg::*;

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
  ,parameter ct_num_in_p                         = "inv"
  ,parameter ct_remote_credits_p                 = "inv"
  ,parameter ct_use_pseudo_large_fifo_p          = "inv"
  ,parameter mc_addr_width_p                     = "inv"
  ,parameter mc_data_width_p                     = "inv"
  ,parameter mc_x_cord_width_p                   = "inv"
  ,parameter mc_y_cord_width_p                   = "inv"
  ,parameter lg_tag_num_clients_lp               = `BSG_SAFE_CLOG2(tag_num_clients_p)
  ,parameter ct_tag_width_lp                     = `BSG_SAFE_CLOG2(ct_num_in_p + 1)
  ,parameter ct_width_lp                         = width_p - ct_tag_width_lp
  ,parameter ct_credit_decimation_lp             = ct_remote_credits_p/4
  ,parameter ct_lg_credit_decimation_lp          = `BSG_SAFE_CLOG2(ct_credit_decimation_lp/2+1)
  ,parameter mc_fwd_width_lp =
    `bsg_manycore_packet_width(mc_addr_width_p,mc_data_width_p,mc_x_cord_width_p,mc_y_cord_width_p)
  ,parameter mc_rev_width_lp =
    `bsg_manycore_return_packet_width(mc_x_cord_width_p,mc_y_cord_width_p,mc_data_width_p)
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

  ,output                             mc_fwd_link_clk_o
  ,output [mc_fwd_width_lp-1:0]       mc_fwd_link_data_o
  ,output                             mc_fwd_link_v_o
  ,input                              mc_fwd_link_token_i

  ,input                              mc_fwd_link_clk_i
  ,input  [mc_fwd_width_lp-1:0]       mc_fwd_link_data_i
  ,input                              mc_fwd_link_v_i
  ,output                             mc_fwd_link_token_o

  ,output                             mc_rev_link_clk_o
  ,output [mc_rev_width_lp-1:0]       mc_rev_link_data_o
  ,output                             mc_rev_link_v_o
  ,input                              mc_rev_link_token_i

  ,input                              mc_rev_link_clk_i
  ,input  [mc_rev_width_lp-1:0]       mc_rev_link_data_i
  ,input                              mc_rev_link_v_i
  ,output                             mc_rev_link_token_o
  );

  // ddr_tag_lines + noc_tag_lines + sdr_tag_lines
  localparam tag_num_local_clients_lp = 12*2 + 1 + 4;

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

  `declare_bsg_then_ready_link_sif_s(width_p, core_link_sif_s);
  core_link_sif_s [1:0] core_links_li, core_links_lo;
  logic [1:0] core_links_ready_and_lo;

  for (genvar i = 0; i < 2; i++)
  begin: ddr_link
    assign core_links_lo[i].then_ready_rev = core_links_li[i].v & core_links_ready_and_lo[i];
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

    ,.core_v_i                       (core_links_li[i].v             )
    ,.core_data_i                    (core_links_li[i].data          )
    ,.core_ready_and_o               (core_links_ready_and_lo[i]     )

    ,.core_v_o                       (core_links_lo[i].v             )
    ,.core_data_o                    (core_links_lo[i].data          )
    ,.core_yumi_i                    (core_links_li[i].then_ready_rev)

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

  for (genvar i = 0; i < $bits(sdr_tag_payload_s); i++)
  begin: btc_sdr
    bsg_tag_client_unsync #(.width_p(1)) btc
    (.bsg_tag_i     (tag_lines_lo[25+i])
    ,.data_async_r_o(async_sdr_tag_data_lo[i])
    );
  end

  // mem link round robin arbiters
  core_link_sif_s core_links_conc_li, core_links_conc_lo;

  bsg_then_ready_link_round_robin_static 
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

  `declare_bsg_then_ready_link_sif_s(ct_width_lp, ct_link_sif_s);
  ct_link_sif_s ct_links_fwd_li, ct_links_fwd_lo;
  ct_link_sif_s ct_links_rev_li, ct_links_rev_lo;

  bsg_channel_tunnel
 #(.width_p                (ct_width_lp)
  ,.num_in_p               (ct_num_in_p)
  ,.remote_credits_p       (ct_remote_credits_p)
  ,.use_pseudo_large_fifo_p(ct_use_pseudo_large_fifo_p)
  ,.lg_credit_decimation_p (ct_lg_credit_decimation_lp)
  ) tunnel
  (.clk_i       (noc_clk_lo)
  ,.reset_i     (noc_reset_lo)

  ,.multi_v_i   (core_links_conc_lo.v)
  ,.multi_data_i(core_links_conc_lo.data)
  ,.multi_yumi_o(core_links_conc_li.then_ready_rev)

  ,.multi_v_o   (core_links_conc_li.v)
  ,.multi_data_o(core_links_conc_li.data)
  ,.multi_yumi_i(core_links_conc_lo.then_ready_rev)

  ,.data_i      ({ct_links_fwd_li.data,           ct_links_rev_li.data          })
  ,.v_i         ({ct_links_fwd_li.v,              ct_links_rev_li.v             })
  ,.yumi_o      ({ct_links_fwd_lo.then_ready_rev, ct_links_rev_lo.then_ready_rev})

  ,.data_o      ({ct_links_fwd_lo.data,           ct_links_rev_lo.data          })
  ,.v_o         ({ct_links_fwd_lo.v,              ct_links_rev_lo.v             })
  ,.yumi_i      ({ct_links_fwd_li.then_ready_rev, ct_links_rev_li.then_ready_rev})
  );

  `declare_bsg_then_ready_link_sif_s(mc_fwd_width_lp, mc_fwd_link_sif_s);
  mc_fwd_link_sif_s mc_links_fwd_li, mc_links_fwd_lo;
  `declare_bsg_then_ready_link_sif_s(mc_rev_width_lp, mc_rev_link_sif_s);
  mc_rev_link_sif_s mc_links_rev_li, mc_links_rev_lo;

  bsg_then_ready_link_to_bsg_link
 #(.wide_link_width_p (mc_fwd_width_lp)
  ,.bsg_link_width_p  (ct_width_lp)
  ) fwd_adapter
  (.clk_i             (noc_clk_lo)
  ,.reset_i           (noc_reset_lo)
  ,.wide_link_i       (mc_links_fwd_lo)
  ,.wide_link_o       (mc_links_fwd_li)
  ,.bsg_link_i        (ct_links_fwd_lo)
  ,.bsg_link_o        (ct_links_fwd_li)
  );
  bsg_then_ready_link_to_bsg_link
 #(.wide_link_width_p (mc_rev_width_lp)
  ,.bsg_link_width_p  (ct_width_lp)
  ) rev_adapter
  (.clk_i             (noc_clk_lo)
  ,.reset_i           (noc_reset_lo)
  ,.wide_link_i       (mc_links_rev_lo)
  ,.wide_link_o       (mc_links_rev_li)
  ,.bsg_link_i        (ct_links_rev_lo)
  ,.bsg_link_o        (ct_links_rev_li)
  );


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

  logic mc_links_fwd_ready_and_lo;
  assign mc_links_fwd_lo.then_ready_rev = mc_links_fwd_li.v & mc_links_fwd_ready_and_lo;

  bsg_link_sdr
 #(.width_p                        (mc_fwd_width_lp)
  ,.lg_fifo_depth_p                (sdr_lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_p)
  ,.bypass_upstream_twofer_fifo_p  (0)
  ,.bypass_downstream_twofer_fifo_p(0)
  ) fwd_sdr
  (.core_clk_i             (noc_clk_lo)
  ,.core_uplink_reset_i    (uplink_reset_sync)
  ,.core_downstream_reset_i(downstream_reset_sync)
  ,.async_downlink_reset_i (async_sdr_tag_data_lo.downlink_reset)
  ,.async_token_reset_i    (async_sdr_tag_data_lo.token_reset)

  ,.core_data_i (mc_links_fwd_li.data)
  ,.core_v_i    (mc_links_fwd_li.v)
  ,.core_ready_o(mc_links_fwd_ready_and_lo)

  ,.core_data_o (mc_links_fwd_lo.data)
  ,.core_v_o    (mc_links_fwd_lo.v)
  ,.core_yumi_i (mc_links_fwd_li.then_ready_rev)

  ,.link_clk_o  (mc_fwd_link_clk_o  )
  ,.link_data_o (mc_fwd_link_data_o )
  ,.link_v_o    (mc_fwd_link_v_o    )
  ,.link_token_i(mc_fwd_link_token_i)

  ,.link_clk_i  (mc_fwd_link_clk_i  )
  ,.link_data_i (mc_fwd_link_data_i )
  ,.link_v_i    (mc_fwd_link_v_i    )
  ,.link_token_o(mc_fwd_link_token_o)
  );

  logic mc_links_rev_ready_and_lo;
  assign mc_links_rev_lo.then_ready_rev = mc_links_rev_li.v & mc_links_rev_ready_and_lo;

  bsg_link_sdr
 #(.width_p                        (mc_rev_width_lp)
  ,.lg_fifo_depth_p                (sdr_lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_p)
  ,.bypass_upstream_twofer_fifo_p  (0)
  ,.bypass_downstream_twofer_fifo_p(0)
  ) rev_sdr
  (.core_clk_i             (noc_clk_lo)
  ,.core_uplink_reset_i    (uplink_reset_sync)
  ,.core_downstream_reset_i(downstream_reset_sync)
  ,.async_downlink_reset_i (async_sdr_tag_data_lo.downlink_reset)
  ,.async_token_reset_i    (async_sdr_tag_data_lo.token_reset)

  ,.core_data_i (mc_links_rev_li.data)
  ,.core_v_i    (mc_links_rev_li.v)
  ,.core_ready_o(mc_links_rev_ready_and_lo)

  ,.core_data_o (mc_links_rev_lo.data)
  ,.core_v_o    (mc_links_rev_lo.v)
  ,.core_yumi_i (mc_links_rev_li.then_ready_rev)

  ,.link_clk_o  (mc_rev_link_clk_o  )
  ,.link_data_o (mc_rev_link_data_o )
  ,.link_v_o    (mc_rev_link_v_o    )
  ,.link_token_i(mc_rev_link_token_i)

  ,.link_clk_i  (mc_rev_link_clk_i  )
  ,.link_data_i (mc_rev_link_data_i )
  ,.link_v_i    (mc_rev_link_v_i    )
  ,.link_token_o(mc_rev_link_token_o)
  );

endmodule
