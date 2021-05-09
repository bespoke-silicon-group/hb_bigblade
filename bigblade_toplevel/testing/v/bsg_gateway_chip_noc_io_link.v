
`include "bsg_defines.v"
`include "bsg_noc_links.vh"

module bsg_gateway_chip_noc_io_link

 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_manycore_pkg::*;
 import bsg_chip_pkg::*;

 #(localparam bsg_manycore_link_sif_width_lp =
    `bsg_manycore_link_sif_width(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp)
  ,localparam mc_fwd_width_lp =
    `bsg_manycore_packet_width(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp)
  ,localparam mc_rev_width_lp =
    `bsg_manycore_return_packet_width(hb_x_cord_width_gp,hb_y_cord_width_gp,hb_data_width_gp)
  )

  (input                              core_clk_i
  ,input                              io_clk_i

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

  ,input  [bsg_manycore_link_sif_width_lp-1:0]  mc_links_sif_i
  ,output [bsg_manycore_link_sif_width_lp-1:0]  mc_links_sif_o
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

  `declare_bsg_then_ready_link_sif_s(bsg_link_width_gp, core_link_sif_s);
  core_link_sif_s [1:0] core_links_li, core_links_lo;
  logic [1:0] core_links_ready_and_lo;

  for (genvar i = 0; i < 2; i++)
  begin: ddr_link
    assign core_links_lo[i].then_ready_rev = core_links_li[i].v & core_links_ready_and_lo[i];
    bsg_gateway_chip_io_link_ddr link
    (.core_clk_i                     (core_clk_i            )
    ,.io_clk_i                       (io_clk_i              )

    ,.tag_clk_i                      (tag_clk_i          )
    ,.tag_lines_i                    (tag_lines_lo.ddr[i].main)

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
  (.bsg_tag_i     (tag_lines_lo.noc_reset)
  ,.recv_clk_i    (core_clk_i)
  ,.recv_reset_i  (1'b0)
  ,.recv_new_r_o  (noc_reset_new_lo)
  ,.recv_data_r_o (noc_reset_lo)
  );

  // mem link round robin arbiters
  core_link_sif_s core_links_conc_li, core_links_conc_lo;

  bsg_then_ready_link_round_robin_static 
 #(.width_p      (bsg_link_width_gp)
  ,.num_in_p     (2)
  ) rr
  (.clk_i        (core_clk_i)
  ,.reset_i      (noc_reset_lo)
  ,.single_link_i(core_links_conc_li)
  ,.single_link_o(core_links_conc_lo)
  ,.links_i      (core_links_lo)
  ,.links_o      (core_links_li)
  );

  `declare_bsg_then_ready_link_sif_s(ct_width_gp, ct_link_sif_s);
  ct_link_sif_s ct_links_fwd_li, ct_links_fwd_lo;
  ct_link_sif_s ct_links_rev_li, ct_links_rev_lo;

  bsg_channel_tunnel
 #(.width_p                (ct_width_gp)
  ,.num_in_p               (ct_num_in_gp)
  ,.remote_credits_p       (ct_remote_credits_gp)
  ,.use_pseudo_large_fifo_p(ct_use_pseudo_large_fifo_gp)
  ,.lg_credit_decimation_p (ct_lg_credit_decimation_gp)
  ) tunnel
  (.clk_i       (core_clk_i)
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

  `declare_bsg_manycore_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  bsg_manycore_link_sif_s mc_links_sif_li, mc_links_sif_lo;

  assign mc_links_sif_li = mc_links_sif_i;
  assign mc_links_sif_o  = mc_links_sif_lo;

  bsg_wide_link_to_then_ready_link
 #(.wide_link_width_p (mc_fwd_width_lp)
  ,.bsg_link_width_p  (ct_width_gp)
  ) fwd_adapter
  (.clk_i             (core_clk_i)
  ,.reset_i           (noc_reset_lo)
  ,.wide_link_i       (mc_links_sif_li.fwd)
  ,.wide_link_o       (mc_links_sif_lo.fwd)
  ,.bsg_link_i        (ct_links_fwd_lo)
  ,.bsg_link_o        (ct_links_fwd_li)
  );
  bsg_wide_link_to_then_ready_link
 #(.wide_link_width_p (mc_rev_width_lp)
  ,.bsg_link_width_p  (ct_width_gp)
  ) rev_adapter
  (.clk_i             (core_clk_i)
  ,.reset_i           (noc_reset_lo)
  ,.wide_link_i       (mc_links_sif_li.rev)
  ,.wide_link_o       (mc_links_sif_lo.rev)
  ,.bsg_link_i        (ct_links_rev_lo)
  ,.bsg_link_o        (ct_links_rev_li)
  );

endmodule
