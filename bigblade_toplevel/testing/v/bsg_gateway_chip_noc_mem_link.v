
`include "bsg_defines.v"
`include "bsg_noc_links.vh"

module bsg_gateway_chip_noc_mem_link

 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_chip_pkg::*;

 #(localparam wh_link_sif_width_lp = `bsg_ready_and_link_sif_width(wh_flit_width_gp)
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

  ,input  [S:N][wh_ruche_factor_gp-1:0][wh_link_sif_width_lp-1:0] wh_links_i
  ,output [S:N][wh_ruche_factor_gp-1:0][wh_link_sif_width_lp-1:0] wh_links_o
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

  `declare_bsg_ready_and_link_sif_s(bsg_link_width_gp, core_link_sif_s);
  core_link_sif_s [1:0] core_links_li, core_links_lo;

  for (genvar i = 0; i < 2; i++)
  begin: ddr_link
    bsg_gateway_chip_io_link_ddr link
    (.core_clk_i                     (core_clk_i            )
    ,.io_clk_i                       (io_clk_i              )

    ,.tag_clk_i                      (tag_clk_i          )
    ,.tag_lines_i                    (tag_lines_lo.ddr[i])

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
  (.bsg_tag_i     (tag_lines_lo.noc_reset)
  ,.recv_clk_i    (core_clk_i)
  ,.recv_reset_i  (1'b0)
  ,.recv_new_r_o  (noc_reset_new_lo)
  ,.recv_data_r_o (noc_reset_lo)
  );

  // mem link round robin arbiters
  core_link_sif_s core_links_conc_li, core_links_conc_lo;

  bsg_ready_and_link_round_robin_static 
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

  `declare_bsg_ready_and_link_sif_s(wh_flit_width_gp, wh_link_sif_s);
  wh_link_sif_s wh_link_sif_li, wh_link_sif_lo;

  assign wh_link_sif_li.v             = core_links_conc_lo.v;
  assign wh_link_sif_li.data          = core_links_conc_lo.data;
  assign wh_link_sif_li.ready_and_rev = core_links_conc_lo.ready_and_rev;
  assign core_links_conc_li.v             = wh_link_sif_lo.v;
  assign core_links_conc_li.data          = wh_link_sif_lo.data;
  assign core_links_conc_li.ready_and_rev = wh_link_sif_lo.ready_and_rev;

  bsg_wormhole_concentrator
 #(.flit_width_p(wh_flit_width_gp)
  ,.len_width_p (wh_len_width_gp)
  ,.cid_width_p (wh_cid_width_gp)
  ,.cord_width_p(wh_cord_width_gp)
  ,.num_in_p    (2*wh_ruche_factor_gp)
  ) conc0
  (.clk_i  (core_clk_i)
  ,.reset_i(noc_reset_lo)
  
  ,.links_i(wh_links_i)
  ,.links_o(wh_links_o)

  ,.concentrated_link_i(wh_link_sif_li)
  ,.concentrated_link_o(wh_link_sif_lo)
  );

endmodule
