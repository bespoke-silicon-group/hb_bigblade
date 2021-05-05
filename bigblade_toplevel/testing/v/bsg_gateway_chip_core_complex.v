
module bsg_gateway_chip_core_complex

 import bsg_chip_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_manycore_pkg::*;

  (input  mc_clk_i
  ,input  tag_trace_done_i

  ,input  bsg_chip_bsg_link_sif_s [io_link_num_gp-1:0] io_links_i
  ,output bsg_chip_bsg_link_sif_s [io_link_num_gp-1:0] io_links_o

  ,input  bsg_chip_bsg_link_sif_s [mem_link_num_gp-1:0] mem_links_i
  ,output bsg_chip_bsg_link_sif_s [mem_link_num_gp-1:0] mem_links_o
  );

  // mem link round robin arbiters
  bsg_chip_bsg_link_sif_s io_links_conc_li, io_links_conc_lo;
  bsg_ready_and_link_round_robin_static 
 #(.width_p      (bsg_link_width_gp   )
  ,.num_in_p     (io_link_num_gp)
  ) io_rr
  (.clk_i        (mc_clk_i            )
  ,.reset_i      (~tag_trace_done_i)
  ,.single_link_i(io_links_conc_li)
  ,.single_link_o(io_links_conc_lo)
  ,.links_i      (io_links_i)
  ,.links_o      (io_links_o)
  );

  `declare_bsg_ready_and_link_sif_s(ct_width_gp, ct_link_sif_s);
  ct_link_sif_s [ct_num_in_gp-1:0] ct_links_li, ct_links_lo;

  bsg_channel_tunnel
 #(.width_p                (ct_width_gp)
  ,.num_in_p               (ct_num_in_gp)
  ,.remote_credits_p       (ct_remote_credits_gp)
  ,.use_pseudo_large_fifo_p(ct_use_pseudo_large_fifo_gp)
  ,.lg_credit_decimation_p (ct_lg_credit_decimation_gp)
  ) tunnel
  (.clk_i       (mc_clk_i)
  ,.reset_i     (~tag_trace_done_i)

  ,.multi_v_i   (io_links_conc_lo.v)
  ,.multi_data_i(io_links_conc_lo.data)
  ,.multi_yumi_o(io_links_conc_li.ready_and_rev)

  ,.multi_v_o   (io_links_conc_li.v)
  ,.multi_data_o(io_links_conc_li.data)
  ,.multi_yumi_i(io_links_conc_li.v&io_links_conc_lo.ready_and_rev)

  ,.data_i      ({ct_links_li[1].data,          ct_links_li[0].data         })
  ,.v_i         ({ct_links_li[1].v,             ct_links_li[0].v            })
  ,.yumi_o      ({ct_links_lo[1].ready_and_rev, ct_links_lo[0].ready_and_rev})

  ,.data_o      ({ct_links_lo[1].data,          ct_links_lo[0].data         })
  ,.v_o         ({ct_links_lo[1].v,             ct_links_lo[0].v            })
  ,.yumi_i      ({ct_links_lo[1].v&ct_links_li[1].ready_and_rev, ct_links_lo[0].v&ct_links_li[0].ready_and_rev})
  );


  //////////////////////////////////////////////////
  //
  // Manycore Adapter
  //
  `declare_bsg_manycore_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  bsg_manycore_link_sif_s manycore_links_li, manycore_links_lo;

  bsg_manycore_link_async_to_bsg_link
 #(.addr_width_p    (hb_addr_width_gp  )
  ,.data_width_p    (hb_data_width_gp  )
  ,.x_cord_width_p  (hb_x_cord_width_gp)
  ,.y_cord_width_p  (hb_y_cord_width_gp)
  ,.bsg_link_width_p(ct_width_gp    )
  ) mc_adapter
  (.mc_clk_i        (mc_clk_i)
  ,.mc_reset_i      (~tag_trace_done_i)
  ,.mc_links_sif_i  (manycore_links_lo)
  ,.mc_links_sif_o  (manycore_links_li)
 
  ,.bsg_link_clk_i  (mc_clk_i)
  ,.bsg_link_reset_i(~tag_trace_done_i)
  ,.bsg_link_i      (ct_links_lo)
  ,.bsg_link_o      (ct_links_li)
  );
  
  
  //////////////////////////////////////////////////
  //
  // Manycore Testbench
  //
  
  // HOST CONNECTION
  bsg_nonsynth_manycore_io_complex #(
    .addr_width_p(hb_addr_width_gp)
    ,.data_width_p(hb_data_width_gp)
    ,.x_cord_width_p(hb_x_cord_width_gp)
    ,.y_cord_width_p(hb_y_cord_width_gp)
    ,.io_x_cord_p(7'b0001111)
    ,.io_y_cord_p(7'b0001000)
  ) host (
    .clk_i(mc_clk_i)
    ,.reset_i(~tag_trace_done_i)
    ,.io_link_sif_i(manycore_links_li)
    ,.io_link_sif_o(manycore_links_lo)
    ,.loader_done_o()
    ,.print_stat_v_o()
    ,.print_stat_tag_o()
  );
  
  
  // mem link round robin arbiters
  bsg_chip_bsg_link_sif_s [mem_link_conc_num_gp-1:0] mem_links_conc_li;
  bsg_chip_bsg_link_sif_s [mem_link_conc_num_gp-1:0] mem_links_conc_lo;
  
  for (genvar i = 0; i < mem_link_conc_num_gp; i++) begin: mem_link_arb
    bsg_ready_and_link_round_robin_static 
   #(.width_p      (bsg_link_width_gp   )
    ,.num_in_p     (mem_link_rr_ratio_gp)
    ) rr
    (.clk_i        (mc_clk_i            )
    ,.reset_i      (~tag_trace_done_i)
    ,.single_link_i(mem_links_conc_lo[i])
    ,.single_link_o(mem_links_conc_li[i])
    ,.links_i      (mem_links_i[i*mem_link_rr_ratio_gp+:mem_link_rr_ratio_gp])
    ,.links_o      (mem_links_o[i*mem_link_rr_ratio_gp+:mem_link_rr_ratio_gp])
    );
  end
  
  // Attach wormhole links to mem links
  `declare_bsg_ready_and_link_sif_s(wh_flit_width_gp, wh_link_sif_s);
  wh_link_sif_s [mem_link_conc_num_gp-1:0] wh_link_sif_li;
  wh_link_sif_s [mem_link_conc_num_gp-1:0] wh_link_sif_lo;
  
  for (genvar i = 0; i < mem_link_conc_num_gp; i++) begin
    assign wh_link_sif_li[i].v                = mem_links_conc_li[i].v;
    assign wh_link_sif_li[i].data             = mem_links_conc_li[i].data;
    assign wh_link_sif_li[i].ready_and_rev    = mem_links_conc_li[i].ready_and_rev;
    assign mem_links_conc_lo[i].v             = wh_link_sif_lo[i].v;
    assign mem_links_conc_lo[i].data          = wh_link_sif_lo[i].data;
    assign mem_links_conc_lo[i].ready_and_rev = wh_link_sif_lo[i].ready_and_rev;
  end
  
  
  // wormhole test mem
  // in bytes
  // north + south row of vcache (*2)
  // mem traffic routed to both left and right sides (/2)
  localparam longint unsigned mem_size_lp = (2**30)*hb_num_pods_x_gp*2/2;
  localparam num_vcaches_lp = hb_num_tiles_x_gp*hb_num_pods_x_gp*2/2;
  
  for (genvar i = 0; i < mem_link_conc_num_gp; i++) begin
    bsg_nonsynth_wormhole_test_mem #(
      .vcache_data_width_p(vcache_data_width_gp)
      ,.vcache_dma_data_width_p(vcache_dma_data_width_gp)
      ,.vcache_block_size_in_words_p(vcache_block_size_in_words_gp)
      ,.num_vcaches_p(num_vcaches_lp)
      ,.wh_cid_width_p(wh_cid_width_gp)
      ,.wh_flit_width_p(wh_flit_width_gp)
      ,.wh_cord_width_p(wh_cord_width_gp)
      ,.wh_len_width_p(wh_len_width_gp)
      ,.wh_ruche_factor_p(wh_ruche_factor_gp)
      ,.mem_size_p(mem_size_lp)
  
    ) test_mem (
      .clk_i(mc_clk_i)
      ,.reset_i(~tag_trace_done_i)
  
      ,.wh_link_sif_i(wh_link_sif_li[i])
      ,.wh_link_sif_o(wh_link_sif_lo[i])
    );
  end

endmodule