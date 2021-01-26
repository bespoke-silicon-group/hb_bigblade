
module bsg_gateway_chip_core_complex

 import bsg_chip_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_manycore_pkg::*;

  (input                      hb_clk_i
  ,input bsg_chip_tag_lines_s tag_lines_i
  ,input                      tag_trace_done_i

  ,input  tag_clk_i
  ,input  tag_data_i
  ,input  tag_en_i

  ,input  bsg_chip_io_link_sif_s [io_link_num_gp-1:0][io_ct_num_in_gp-1:0] io_links_i
  ,output bsg_chip_io_link_sif_s [io_link_num_gp-1:0][io_ct_num_in_gp-1:0] io_links_o

  ,input  bsg_chip_mem_link_sif_s [mem_link_num_gp-1:0] mem_links_i
  ,output bsg_chip_mem_link_sif_s [mem_link_num_gp-1:0] mem_links_o
  );

  //////////////////////////////////////////////////
  //
  // BSG Tag Client Instance
  //

  // Tag payload for hb control signals
  typedef struct packed { 
      logic padding;
      logic reset;
  } hb_tag_payload_s;

  hb_tag_payload_s hb_tag_data_lo;
  logic            hb_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(hb_tag_data_lo) ), .default_p( 0 ))
    btc_hb
      (.bsg_tag_i     ( tag_lines_i.hb_reset )
      ,.recv_clk_i    ( hb_clk_i )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( hb_tag_new_data_lo )
      ,.recv_data_r_o ( hb_tag_data_lo )
      );


  //////////////////////////////////////////////////
  //
  // Manycore Adapter
  //
  `declare_bsg_manycore_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  bsg_manycore_link_sif_s [io_link_num_gp-1:0] manycore_links_li;
  bsg_manycore_link_sif_s [io_link_num_gp-1:0] manycore_links_lo;
  
  for (genvar i = 0; i < io_link_num_gp; i++)
  begin: mc_io
    bsg_manycore_link_async_to_bsg_link
   #(.addr_width_p    (hb_addr_width_gp  )
    ,.data_width_p    (hb_data_width_gp  )
    ,.x_cord_width_p  (hb_x_cord_width_gp)
    ,.y_cord_width_p  (hb_y_cord_width_gp)
    ,.bsg_link_width_p(io_ct_width_gp    )
    ) mc_adapter
    (.mc_clk_i        (hb_clk_i)
    ,.mc_reset_i      (hb_tag_data_lo.reset)
    ,.mc_links_sif_i  (manycore_links_lo[i])
    ,.mc_links_sif_o  (manycore_links_li[i])
  
    ,.bsg_link_clk_i  (hb_clk_i)
    ,.bsg_link_reset_i(hb_tag_data_lo.reset)
    ,.bsg_link_i      (io_links_i[i])
    ,.bsg_link_o      (io_links_o[i])
    );
  end


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
    ,.io_x_cord_p(7'b0010000)
    ,.io_y_cord_p(7'b0000000)
  ) host (
    .clk_i(hb_clk_i)
    ,.reset_i(hb_tag_data_lo.reset | ~tag_trace_done_i)
    ,.io_link_sif_i(manycore_links_li[0])
    ,.io_link_sif_o(manycore_links_lo[0])
    ,.loader_done_o()
    ,.print_stat_v_o()
    ,.print_stat_tag_o()
  );

  // manycore links tieoff
  for (genvar i = 1; i < io_link_num_gp; i++)
    assign manycore_links_lo[i] = '0;


  // Attach wormhole links to mem links
  bsg_chip_mem_link_sif_s [mem_link_conc_num_gp-1:0] mem_links_conc_li;
  bsg_chip_mem_link_sif_s [mem_link_conc_num_gp-1:0] mem_links_conc_lo;

  // mem link round robin arbiters
  for (genvar i = 0; i < mem_link_conc_num_gp; i++) begin: mem_link_arb
    bsg_ready_and_link_round_robin_static 
   #(.width_p      (mem_link_width_gp   )
    ,.num_in_p     (mem_link_rr_ratio_gp)
    ) rr
    (.clk_i        (hb_clk_i            )
    ,.reset_i      (hb_tag_data_lo.reset | ~tag_trace_done_i)
    ,.single_link_i(mem_links_conc_lo[i])
    ,.single_link_o(mem_links_conc_li[i])
    ,.links_i      (mem_links_i[i*mem_link_rr_ratio_gp+:mem_link_rr_ratio_gp])
    ,.links_o      (mem_links_o[i*mem_link_rr_ratio_gp+:mem_link_rr_ratio_gp])
    );
  end


  // wormhole test mem
  // in bytes
  // north + south row of vcache
  localparam longint unsigned mem_size_lp = 2*(2**30)*`BSG_CDIV(hb_num_pods_x_gp, 2);
  localparam num_vcaches_lp = 2*hb_num_tiles_x_gp*`BSG_CDIV(hb_num_pods_x_gp, 2);

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
      .clk_i(hb_clk_i)
      ,.reset_i(hb_tag_data_lo.reset | ~tag_trace_done_i)

      ,.wh_link_sif_i(mem_links_conc_li[i])
      ,.wh_link_sif_o(mem_links_conc_lo[i])
    );
  end

endmodule