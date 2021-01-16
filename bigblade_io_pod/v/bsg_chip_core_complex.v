
module bsg_chip_core_complex

 import bsg_chip_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_manycore_pkg::*;

  (input                      hb_clk_i
  ,input bsg_chip_tag_lines_s tag_lines_i

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


  // Tag payload for hb dest cords
  typedef struct packed { 
      logic [wh_cord_width_gp-1:0] cord;
  } hb_dest_cord_tag_payload_s;

  hb_dest_cord_tag_payload_s [1:0] hb_dest_cord_tag_data_lo;
  logic                      [1:0] hb_dest_cord_tag_new_data_lo;

  for (genvar i = 0; i < 2; i++)
  begin: hb_cord_loop
    bsg_tag_client #(.width_p( $bits(hb_dest_cord_tag_data_lo[i]) ), .default_p( 0 ))
      btc_hb_dest_cord
        (.bsg_tag_i     ( tag_lines_i.hb_dest_cord[i] )
        ,.recv_clk_i    ( hb_clk_i )
        ,.recv_reset_i  ( 1'b0 )
        ,.recv_new_r_o  ( hb_dest_cord_tag_new_data_lo[i] )
        ,.recv_data_r_o ( hb_dest_cord_tag_data_lo[i] )
        );
  end


  //////////////////////////////////////////////////
  //
  // Manycore Adapter
  //
  `declare_bsg_manycore_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  bsg_manycore_link_sif_s [io_link_num_gp-1:0] manycore_links_li;
  bsg_manycore_link_sif_s [io_link_num_gp-1:0] manycore_links_lo;
  
  for (genvar i = 0; i < io_link_num_gp; i++)
  begin: mc_io
    bsg_manycore_link_async_to_wormhole
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
  // Manycore Array
  //
  localparam reset_depth_gp=3;

  `declare_bsg_manycore_ruche_x_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  `declare_bsg_ready_and_link_sif_s(wh_flit_width_gp, wh_link_sif_s);

  bsg_manycore_link_sif_s [S:N][(hb_num_pods_x_gp*hb_num_tiles_x_gp)-1:0] io_link_sif_li;
  bsg_manycore_link_sif_s [S:N][(hb_num_pods_x_gp*hb_num_tiles_x_gp)-1:0] io_link_sif_lo;
  wh_link_sif_s [E:W][2*hb_num_pods_y_gp-1:0] wh_link_sif_li;
  wh_link_sif_s [E:W][2*hb_num_pods_y_gp-1:0] wh_link_sif_lo;
  bsg_manycore_link_sif_s [E:W][hb_num_pods_y_gp-1:0][hb_num_tiles_y_gp-1:0] hor_link_sif_li;
  bsg_manycore_link_sif_s [E:W][hb_num_pods_y_gp-1:0][hb_num_tiles_y_gp-1:0] hor_link_sif_lo;
  bsg_manycore_ruche_x_link_sif_s [E:W][hb_num_pods_y_gp-1:0][hb_num_tiles_y_gp-1:0][hb_ruche_factor_X_gp-1:0] ruche_link_li;
  bsg_manycore_ruche_x_link_sif_s [E:W][hb_num_pods_y_gp-1:0][hb_num_tiles_y_gp-1:0][hb_ruche_factor_X_gp-1:0] ruche_link_lo;
  logic [E:W][wh_cord_width_gp-1:0] dest_wh_cord_li;

  // Attach dest cords to bsg_tag
  assign dest_wh_cord_li[W] = hb_dest_cord_tag_data_lo[0].cord;
  assign dest_wh_cord_li[E] = hb_dest_cord_tag_data_lo[1].cord;
  
  // Attach manycore io to manycore links
  assign io_link_sif_li[N][0] = manycore_links_li[0];
  assign manycore_links_lo = {'0, io_link_sif_lo[N][0]};

  // Attach wormhole links to mem links
  assign wh_link_sif_li[W] = mem_links_i[0+:2*hb_num_pods_y_gp];
  assign wh_link_sif_li[E] = mem_links_i[mem_link_num_gp/2+:2*hb_num_pods_y_gp];
  assign mem_links_o[0+:mem_link_num_gp/2]                 = {'0, wh_link_sif_lo[W]};
  assign mem_links_o[mem_link_num_gp/2+:mem_link_num_gp/2] = {'0, wh_link_sif_lo[E]};

  bsg_manycore_pod_ruche_array #(
    .num_tiles_x_p(hb_num_tiles_x_gp)
    ,.num_tiles_y_p(hb_num_tiles_y_gp)
    ,.pod_x_cord_width_p(hb_pod_x_cord_width_gp)
    ,.pod_y_cord_width_p(hb_pod_y_cord_width_gp)
    ,.x_cord_width_p(hb_x_cord_width_gp)
    ,.y_cord_width_p(hb_y_cord_width_gp)
    ,.addr_width_p(hb_addr_width_gp)
    ,.data_width_p(hb_data_width_gp)
    ,.ruche_factor_X_p(hb_ruche_factor_X_gp)
    
    ,.dmem_size_p(hb_dmem_size_gp)
    ,.icache_entries_p(hb_icache_entries_gp)
    ,.icache_tag_width_p(hb_icache_tag_width_gp)

    ,.vcache_addr_width_p(vcache_addr_width_gp)
    ,.vcache_data_width_p(vcache_data_width_gp)
    ,.vcache_ways_p(vcache_ways_gp)
    ,.vcache_sets_p(vcache_sets_gp)
    ,.vcache_block_size_in_words_p(vcache_block_size_in_words_gp)
    ,.vcache_size_p(vcache_size_gp)
    ,.vcache_dma_data_width_p(vcache_dma_data_width_gp)

    ,.wh_ruche_factor_p(wh_ruche_factor_gp)
    ,.wh_cid_width_p(wh_cid_width_gp)
    ,.wh_flit_width_p(wh_flit_width_gp)
    ,.wh_cord_width_p(wh_cord_width_gp)
    ,.wh_len_width_p(wh_len_width_gp)

    ,.num_pods_y_p(hb_num_pods_y_gp)
    ,.num_pods_x_p(hb_num_pods_x_gp)

    ,.reset_depth_p(reset_depth_gp)
  ) DUT (
    .clk_i(hb_clk_i)
    ,.reset_i(hb_tag_data_lo.reset)

    ,.io_link_sif_i(io_link_sif_li)
    ,.io_link_sif_o(io_link_sif_lo)

    ,.wh_link_sif_i(wh_link_sif_li)
    ,.wh_link_sif_o(wh_link_sif_lo)

    ,.hor_link_sif_i(hor_link_sif_li)
    ,.hor_link_sif_o(hor_link_sif_lo)

    ,.ruche_link_i(ruche_link_li)
    ,.ruche_link_o(ruche_link_lo)

    ,.dest_wh_cord_i(dest_wh_cord_li)
  );

  // hor tieoff
  for (genvar i = W; i <= E; i++) begin
    for (genvar j = 0; j < hb_num_pods_y_gp; j++) begin
      for (genvar k = 0; k < hb_num_tiles_y_gp; k++) begin
        bsg_manycore_link_sif_tieoff #(
          .addr_width_p(hb_addr_width_gp)
          ,.data_width_p(hb_data_width_gp)
          ,.x_cord_width_p(hb_x_cord_width_gp)
          ,.y_cord_width_p(hb_y_cord_width_gp)
        ) hor_tieoff (
          .clk_i(hb_clk_i)
          ,.reset_i(hb_tag_data_lo.reset)
          ,.link_sif_i(hor_link_sif_lo[i][j][k])
          ,.link_sif_o(hor_link_sif_li[i][j][k])
        );
      end
    end
  end

  // ruche tieoff
  for (genvar i = W; i <= E; i++) begin
    for (genvar j = 0; j < hb_num_pods_y_gp; j++) begin
      for (genvar k = 0; k < hb_num_tiles_y_gp; k++) begin
        for (genvar l = 0; l < hb_ruche_factor_X_gp; l++) begin
          bsg_manycore_ruche_x_link_sif_tieoff #(
            .addr_width_p(hb_addr_width_gp)
            ,.data_width_p(hb_data_width_gp)
            ,.x_cord_width_p(hb_x_cord_width_gp)
            ,.y_cord_width_p(hb_y_cord_width_gp)
            ,.ruche_stage_p(l)
            ,.ruche_factor_X_p(hb_ruche_factor_X_gp)
            ,.west_not_east_p(i==W ? 1 : 0)
          ) ruche_tieoff (
            .clk_i(hb_clk_i)
            ,.reset_i(hb_tag_data_lo.reset)
            ,.ruche_link_i(ruche_link_lo[i][j][k][l])
            ,.ruche_link_o(ruche_link_li[i][j][k][l]) 
          );
        end  
      end
    end
  end


  // io tieoff
  for (genvar i = 1; i < hb_num_pods_x_gp*hb_num_tiles_x_gp; i++) begin
    bsg_manycore_link_sif_tieoff #(
      .addr_width_p(hb_addr_width_gp)
      ,.data_width_p(hb_data_width_gp)
      ,.x_cord_width_p(hb_x_cord_width_gp)
      ,.y_cord_width_p(hb_y_cord_width_gp)
    ) io_n_tieoff (
      .clk_i(hb_clk_i)
      ,.reset_i(hb_tag_data_lo.reset)
      ,.link_sif_i(io_link_sif_lo[N][i])
      ,.link_sif_o(io_link_sif_li[N][i])
    );
  end

  for (genvar i = 0; i < hb_num_pods_x_gp*hb_num_tiles_x_gp; i++) begin
    bsg_manycore_link_sif_tieoff #(
      .addr_width_p(hb_addr_width_gp)
      ,.data_width_p(hb_data_width_gp)
      ,.x_cord_width_p(hb_x_cord_width_gp)
      ,.y_cord_width_p(hb_y_cord_width_gp)
    ) io_s_tieoff (
      .clk_i(hb_clk_i)
      ,.reset_i(hb_tag_data_lo.reset)
      ,.link_sif_i(io_link_sif_lo[S][i])
      ,.link_sif_o(io_link_sif_li[S][i])
    );
  end

endmodule