`include "bsg_noc_links.vh"
`include "bsg_defines.v"


module testbench();
  import bsg_noc_pkg::*;
  import bsg_chip_pkg::*;
  import bsg_manycore_pkg::*;

  bit clk;
  bit reset;

  bsg_nonsynth_clock_gen #(
    .cycle_time_p(1000)
  ) cg0 (
    .o(clk)
  );

  bsg_nonsynth_reset_gen #(
    .reset_cycles_lo_p(0)
    ,.reset_cycles_hi_p(16)
  ) rg0 (
    .clk_i(clk)
    ,.async_reset_o(reset)
  );

  localparam reset_depth_gp=3;
  logic reset_r;
  bsg_dff_chain #(
    .width_p(1)
    ,.num_stages_p(reset_depth_gp)
  ) reset_dff (
    .clk_i(clk)
    ,.data_i(reset)
    ,.data_o(reset_r)
  );


  `declare_bsg_manycore_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
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
  assign dest_wh_cord_li[W] = {3'b000, 4'b1111}; // pod, subpod
  assign dest_wh_cord_li[E] = {3'b101, 4'b0000};

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
    .clk_i(clk)
    ,.reset_i(reset)

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

  // HOST CONNECTION
  bsg_nonsynth_manycore_io_complex #(
    .addr_width_p(hb_addr_width_gp)
    ,.data_width_p(hb_data_width_gp)
    ,.x_cord_width_p(hb_x_cord_width_gp)
    ,.y_cord_width_p(hb_y_cord_width_gp)
    ,.io_x_cord_p(7'b0010000)
    ,.io_y_cord_p(7'b0000000)
  ) host (
    .clk_i(clk)
    ,.reset_i(reset_r)
    ,.io_link_sif_i(io_link_sif_lo[N][0])
    ,.io_link_sif_o(io_link_sif_li[N][0])
    ,.loader_done_o()
    ,.print_stat_v_o()
    ,.print_stat_tag_o()
  );


  // wormhole test mem
  localparam int unsigned mem_size_lp = (2**31); // 2GB each

  for (genvar i = W; i <= E; i++) begin
    for (genvar j = 0; j < 2*hb_num_pods_y_gp; j++) begin
      bsg_nonsynth_wormhole_test_mem #(
        .vcache_data_width_p(vcache_data_width_gp)
        ,.vcache_dma_data_width_p(vcache_dma_data_width_gp)
        ,.vcache_block_size_in_words_p(vcache_block_size_in_words_gp)
        ,.num_vcaches_p(hb_num_tiles_x_gp*2)
        ,.wh_cid_width_p(wh_cid_width_gp)
        ,.wh_flit_width_p(wh_flit_width_gp)
        ,.wh_cord_width_p(wh_cord_width_gp)
        ,.wh_len_width_p(wh_len_width_gp)

        ,.mem_size_p(mem_size_lp)

      ) test_mem (
        .clk_i(clk)
        ,.reset_i(reset_r)
      
        ,.wh_link_sif_i(wh_link_sif_lo[i][j])
        ,.wh_link_sif_o(wh_link_sif_li[i][j])
      );
    end
  end



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
          .clk_i(clk)
          ,.reset_i(reset_r)
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
            .clk_i(clk)
            ,.reset_i(reset_r)
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
      .clk_i(clk)
      ,.reset_i(reset_r)
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
      .clk_i(clk)
      ,.reset_i(reset_r)
      ,.link_sif_i(io_link_sif_lo[S][i])
      ,.link_sif_o(io_link_sif_li[S][i])
    );
  end
  

endmodule
