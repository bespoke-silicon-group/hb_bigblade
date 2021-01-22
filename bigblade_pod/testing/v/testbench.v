`include "bsg_noc_links.vh"


module testbench();
  import bsg_noc_pkg::*;
  import bsg_tag_pkg::*;
  import bsg_chip_pkg::*;
  import bsg_manycore_pkg::*;

  // clock + reset
  bit clk;
  bit global_reset;
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
    ,.async_reset_o(global_reset)
  );


  // TAG MASTER
  logic tag_done_lo;
  bsg_tag_s [S:N] pod_tags_lo;
  bsg_nonsynth_manycore_tag_master #(
    .num_pods_x_p(1)
    ,.num_pods_y_p(1)
    ,.wh_cord_width_p(wh_cord_width_gp)
  ) mtm (
    .clk_i(clk)
    ,.reset_i(global_reset)
    ,.tag_done_o(tag_done_lo)
    ,.pod_tags_o(pod_tags_lo)
  );

  logic reset_r;
  bsg_dff_chain #(
    .width_p(1)
    ,.num_stages_p(3)
  ) rdff (
    .clk_i(clk)
    ,.data_i(~tag_done_lo)
    ,.data_o(reset_r)
  );


  // BSG CHIP POD
  `declare_bsg_manycore_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  `declare_bsg_manycore_ruche_x_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  `declare_bsg_ready_and_link_sif_s(wh_flit_width_gp, wh_link_sif_s);

  bsg_manycore_link_sif_s [S:N][hb_num_tiles_x_gp-1:0] ver_link_sif_li;
  bsg_manycore_link_sif_s [S:N][hb_num_tiles_x_gp-1:0] ver_link_sif_lo;
  bsg_manycore_link_sif_s [E:W][hb_num_tiles_y_gp-1:0] hor_link_sif_li;
  bsg_manycore_link_sif_s [E:W][hb_num_tiles_y_gp-1:0] hor_link_sif_lo;

  bsg_manycore_ruche_x_link_sif_s [E:W][hb_num_tiles_y_gp-1:0][hb_ruche_factor_X_gp-1:0] ruche_link_li;
  bsg_manycore_ruche_x_link_sif_s [E:W][hb_num_tiles_y_gp-1:0][hb_ruche_factor_X_gp-1:0] ruche_link_lo;

  wh_link_sif_s [E:W][wh_ruche_factor_gp-1:0] north_wh_link_sif_li;
  wh_link_sif_s [E:W][wh_ruche_factor_gp-1:0] north_wh_link_sif_lo;
  wh_link_sif_s [E:W][wh_ruche_factor_gp-1:0] south_wh_link_sif_li;
  wh_link_sif_s [E:W][wh_ruche_factor_gp-1:0] south_wh_link_sif_lo;


  bsg_chip_pod DUT (
    .clk_i(clk)

    ,.ver_link_sif_i(ver_link_sif_li)
    ,.ver_link_sif_o(ver_link_sif_lo)

    ,.hor_link_sif_i(hor_link_sif_li)
    ,.hor_link_sif_o(hor_link_sif_lo)

    ,.ruche_link_i(ruche_link_li)
    ,.ruche_link_o(ruche_link_lo)

    ,.north_wh_link_sif_i(north_wh_link_sif_li)
    ,.north_wh_link_sif_o(north_wh_link_sif_lo)
    ,.north_vcache_pod_x_i(hb_pod_x_cord_width_gp'('b001))
    ,.north_vcache_pod_y_i(hb_pod_y_cord_width_gp'('b0000))
    ,.north_bsg_tag_i(pod_tags_lo[N])

    ,.south_wh_link_sif_i(south_wh_link_sif_li)
    ,.south_wh_link_sif_o(south_wh_link_sif_lo)
    ,.south_vcache_pod_x_i(hb_pod_x_cord_width_gp'('b001))
    ,.south_vcache_pod_y_i(hb_pod_y_cord_width_gp'('b0010))
    ,.south_bsg_tag_i(pod_tags_lo[S])

    ,.pod_x_i(hb_pod_x_cord_width_gp'('b001))
    ,.pod_y_i(hb_pod_y_cord_width_gp'('b0001))
  );


  // IO ROUTERS on west side
  bsg_manycore_link_sif_s [hb_num_tiles_y_gp-1:0] proc_link_sif_li;
  bsg_manycore_link_sif_s [hb_num_tiles_y_gp-1:0] proc_link_sif_lo;

  bsg_manycore_link_sif_s [S:N] io_ver_link_sif_li;
  bsg_manycore_link_sif_s [S:N] io_ver_link_sif_lo;
  bsg_manycore_link_sif_s [hb_num_tiles_y_gp-1:0][E:W] io_hor_link_sif_li;
  bsg_manycore_link_sif_s [hb_num_tiles_y_gp-1:0][E:W] io_hor_link_sif_lo;
  
  bsg_manycore_ruche_x_link_sif_s [hb_num_tiles_y_gp-1:0][E:W] io_ruche_link_li;
  bsg_manycore_ruche_x_link_sif_s [hb_num_tiles_y_gp-1:0][E:W] io_ruche_link_lo;
  
  logic [hb_num_tiles_y_gp-1:0][hb_y_cord_width_gp-1:0] io_global_y;
  for (genvar i = 0; i < hb_num_tiles_y_gp; i++) begin
    assign io_global_y[i] = {4'b0001, hb_y_subcord_width_gp'(i)};
  end
  
  bsg_manycore_hor_io_router_column #(
    .addr_width_p(hb_addr_width_gp)
    ,.data_width_p(hb_data_width_gp)
    ,.x_cord_width_p(hb_x_cord_width_gp)
    ,.y_cord_width_p(hb_y_cord_width_gp)
    ,.ruche_factor_X_p(hb_ruche_factor_X_gp)
    ,.tieoff_west_p('{hb_num_tiles_y_gp{1'b1}})
    ,.tieoff_east_p('{hb_num_tiles_y_gp{1'b0}})
    ,.num_row_p(hb_num_tiles_y_gp)
  ) io_rtr_col (
    .clk_i(clk)
    ,.reset_i(reset_r)

    ,.ver_link_sif_i(io_ver_link_sif_li)
    ,.ver_link_sif_o(io_ver_link_sif_lo)
    ,.hor_link_sif_i(io_hor_link_sif_li)
    ,.hor_link_sif_o(io_hor_link_sif_lo)

    ,.proc_link_sif_i(proc_link_sif_li)
    ,.proc_link_sif_o(proc_link_sif_lo)

    ,.ruche_link_i(io_ruche_link_li)
    ,.ruche_link_o(io_ruche_link_lo)

    ,.global_x_i(hb_x_cord_width_gp'('b0001111))
    ,.global_y_i(io_global_y)
  );

  // connect io rtr column to the pod
  for (genvar i = 0; i < hb_num_tiles_y_gp; i++) begin
    assign io_hor_link_sif_li[i][E] = hor_link_sif_lo[W][i];
    assign hor_link_sif_li[W][i] = io_hor_link_sif_lo[i][E];


    bsg_ruche_buffer #(
      .width_p($bits(bsg_manycore_ruche_x_link_sif_s))
      ,.ruche_factor_p(hb_ruche_factor_X_gp)
      ,.ruche_stage_p(0)
      ,.harden_p(0)
    ) rb_e (
      .i(io_ruche_link_lo[i][E])
      ,.o(ruche_link_li[W][i][1])
    );

    bsg_ruche_buffer #(
      .width_p($bits(bsg_manycore_ruche_x_link_sif_s))
      ,.ruche_factor_p(hb_ruche_factor_X_gp)
      ,.ruche_stage_p(2)
      ,.harden_p(0)
    ) rb_w (
      .i(ruche_link_lo[W][i][1])
      ,.o(io_ruche_link_li[i][E])
    );
  end


  // HOST CONNECTION
  bsg_nonsynth_manycore_io_complex #(
    .addr_width_p(hb_addr_width_gp)
    ,.data_width_p(hb_data_width_gp)
    ,.x_cord_width_p(hb_x_cord_width_gp)
    ,.y_cord_width_p(hb_y_cord_width_gp)
    ,.io_x_cord_p(7'b0001111)
    ,.io_y_cord_p(7'b0001000)
  ) host (
    .clk_i(clk)
    ,.reset_i(reset_r)
    ,.io_link_sif_i(proc_link_sif_lo[0])
    ,.io_link_sif_o(proc_link_sif_li[0])
    ,.loader_done_o()
    ,.print_stat_v_o()
    ,.print_stat_tag_o()
  );



  // OFF CHIP MEMORY MODEL 
  localparam longint unsigned mem_size_lp = (2**31); // 2GB each

  // north memory
  wh_link_sif_s [S:N][wh_ruche_factor_gp-1:0] test_mem_wh_link_li;
  wh_link_sif_s [S:N][wh_ruche_factor_gp-1:0] test_mem_wh_link_lo;

  for (genvar i = 0; i < wh_ruche_factor_gp; i++) begin: wh
    bsg_ruche_anti_buffer #(
      .width_p($bits(wh_link_sif_s))
      ,.ruche_factor_p(wh_ruche_factor_gp)
      ,.ruche_stage_p(i)
      ,.west_not_east_p(1)
      ,.input_not_output_p(0)
      ,.harden_p(0)
    ) n_abuf_w (
      .i(north_wh_link_sif_lo[W][i])
      ,.o(test_mem_wh_link_li[N][(wh_ruche_factor_gp-i)%wh_ruche_factor_gp])
    );

    bsg_ruche_anti_buffer #(
      .width_p($bits(wh_link_sif_s))
      ,.ruche_factor_p(wh_ruche_factor_gp)
      ,.ruche_stage_p(i)
      ,.west_not_east_p(1)
      ,.input_not_output_p(1)
      ,.harden_p(0)
    ) n_abuf_e (
      .i(test_mem_wh_link_lo[N][(wh_ruche_factor_gp-i)%wh_ruche_factor_gp])
      ,.o(north_wh_link_sif_li[W][i])
    );

    bsg_ruche_anti_buffer #(
      .width_p($bits(wh_link_sif_s))
      ,.ruche_factor_p(wh_ruche_factor_gp)
      ,.ruche_stage_p(i)
      ,.west_not_east_p(1)
      ,.input_not_output_p(0)
      ,.harden_p(0)
    ) s_abuf_w (
      .i(south_wh_link_sif_lo[W][i])
      ,.o(test_mem_wh_link_li[S][(wh_ruche_factor_gp-i)%wh_ruche_factor_gp])
    );

    bsg_ruche_anti_buffer #(
      .width_p($bits(wh_link_sif_s))
      ,.ruche_factor_p(wh_ruche_factor_gp)
      ,.ruche_stage_p(i)
      ,.west_not_east_p(1)
      ,.input_not_output_p(1)
      ,.harden_p(0)
    ) s_abuf_e (
      .i(test_mem_wh_link_lo[S][(wh_ruche_factor_gp-i)%wh_ruche_factor_gp])
      ,.o(south_wh_link_sif_li[W][i])
    );
  end

  // wormhole concentrator
  wh_link_sif_s wh_conc_link_sif_li;
  wh_link_sif_s wh_conc_link_sif_lo;
  bsg_wormhole_concentrator #(
    .flit_width_p(wh_flit_width_gp)
    ,.len_width_p(wh_len_width_gp)
    ,.cid_width_p(wh_cid_width_gp)
    ,.cord_width_p(wh_cord_width_gp)
    ,.num_in_p(wh_ruche_factor_gp*2) // both north and south
  ) conc (
    .clk_i(clk)
    ,.reset_i(reset_r)

    ,.links_i(test_mem_wh_link_li)
    ,.links_o(test_mem_wh_link_lo)

    ,.concentrated_link_i(wh_conc_link_sif_li)
    ,.concentrated_link_o(wh_conc_link_sif_lo)
  );

  bsg_nonsynth_wormhole_test_mem #(
    .vcache_data_width_p(vcache_data_width_gp)
    ,.vcache_block_size_in_words_p(vcache_block_size_in_words_gp)
    ,.vcache_dma_data_width_p(vcache_dma_data_width_gp)
    ,.num_vcaches_p(hb_num_tiles_x_gp)
    ,.wh_cid_width_p(wh_cid_width_gp)
    ,.wh_flit_width_p(wh_flit_width_gp)
    ,.wh_cord_width_p(wh_cord_width_gp) 
    ,.wh_len_width_p(wh_len_width_gp)
    
    ,.mem_size_p(mem_size_lp)
  ) test_mem (
    .clk_i(clk)
    ,.reset_i(reset_r)
  
    ,.wh_link_sif_i(wh_conc_link_sif_lo)
    ,.wh_link_sif_o(wh_conc_link_sif_li)
  );







// ------------------------------------------------------------------------------- //
//        TIE OFFS                                                                 //
// ------------------------------------------------------------------------------- //



  // TIE OFF pod north
  for (genvar i = 0; i < hb_num_tiles_x_gp; i++) begin: n
    bsg_manycore_link_sif_tieoff #(
      .addr_width_p(hb_addr_width_gp)
      ,.data_width_p(hb_data_width_gp)
      ,.x_cord_width_p(hb_x_cord_width_gp)
      ,.y_cord_width_p(hb_y_cord_width_gp)
    ) tieoff_n (
      .clk_i(clk)
      ,.reset_i(reset_r)
      ,.link_sif_i(ver_link_sif_lo[N][i])
      ,.link_sif_o(ver_link_sif_li[N][i])
    );

  end

  // tieoff pod south 
  for (genvar i = 0; i < hb_num_tiles_x_gp; i++) begin: s
    bsg_manycore_link_sif_tieoff #(
      .addr_width_p(hb_addr_width_gp)
      ,.data_width_p(hb_data_width_gp)
      ,.x_cord_width_p(hb_x_cord_width_gp)
      ,.y_cord_width_p(hb_y_cord_width_gp)
    ) tieoff_s (
      .clk_i(clk)
      ,.reset_i(reset_r)
      ,.link_sif_i(ver_link_sif_lo[S][i])
      ,.link_sif_o(ver_link_sif_li[S][i])
    );
  end


  // tieoff pod east
  for (genvar i = 0; i < hb_num_tiles_y_gp; i++) begin: e
    // tieoff east local link
    bsg_manycore_link_sif_tieoff #(
      .addr_width_p(hb_addr_width_gp)
      ,.data_width_p(hb_data_width_gp)
      ,.x_cord_width_p(hb_x_cord_width_gp)
      ,.y_cord_width_p(hb_y_cord_width_gp)
    ) e_tieoff (
      .clk_i(clk)
      ,.reset_i(reset_r)
      ,.link_sif_i(hor_link_sif_lo[E][i])
      ,.link_sif_o(hor_link_sif_li[E][i])
    );
    
    // tieoff east manycore ruche link
    for (genvar j = 0; j < hb_ruche_factor_X_gp; j++) begin: rf
      bsg_manycore_ruche_x_link_sif_tieoff #(
        .addr_width_p(hb_addr_width_gp)
        ,.data_width_p(hb_data_width_gp)
        ,.x_cord_width_p(hb_x_cord_width_gp)
        ,.y_cord_width_p(hb_y_cord_width_gp)
        ,.ruche_stage_p(j)
        ,.ruche_factor_X_p(hb_ruche_factor_X_gp)
        ,.west_not_east_p(0)
      ) re_tieoff (
        .clk_i(clk)
        ,.reset_i(reset_r)
        ,.ruche_link_i(ruche_link_lo[E][i][j])
        ,.ruche_link_o(ruche_link_li[E][i][j])
      );
    end
  end


  // tieoff pod unused west ruche links
  for (genvar i = 0; i < hb_num_tiles_y_gp; i++) begin: w
    for (genvar j = 0; j < hb_ruche_factor_X_gp-1; j++) begin: rf
      bsg_manycore_ruche_x_link_sif_tieoff #(
        .addr_width_p(hb_addr_width_gp)
        ,.data_width_p(hb_data_width_gp)
        ,.x_cord_width_p(hb_x_cord_width_gp)
        ,.y_cord_width_p(hb_y_cord_width_gp)
        ,.ruche_stage_p((j+hb_ruche_factor_X_gp-1)%hb_ruche_factor_X_gp)
        ,.ruche_factor_X_p(hb_ruche_factor_X_gp)
        ,.west_not_east_p(1)
      ) rw_tieoff (
        .clk_i(clk)
        ,.reset_i(reset_r)
        ,.ruche_link_i(ruche_link_lo[W][i][(j+hb_ruche_factor_X_gp-1)%hb_ruche_factor_X_gp])
        ,.ruche_link_o(ruche_link_li[W][i][(j+hb_ruche_factor_X_gp-1)%hb_ruche_factor_X_gp])
      );
    end
  end

  // wh east tie off
  for (genvar j = 0; j < wh_ruche_factor_gp; j++) begin: we
    bsg_ruche_link_sif_tieoff #(
      .link_data_width_p(wh_flit_width_gp)
      ,.ruche_factor_p(wh_ruche_factor_gp)
      ,.ruche_stage_p(j)
      ,.west_not_east_p(0)
    ) north_wh_e_tieoff (
      .clk_i(clk)
      ,.reset_i(reset_r)
      ,.ruche_link_i(north_wh_link_sif_lo[E][j])
      ,.ruche_link_o(north_wh_link_sif_li[E][j])
    );

    bsg_ruche_link_sif_tieoff #(
      .link_data_width_p(wh_flit_width_gp)
      ,.ruche_factor_p(wh_ruche_factor_gp)
      ,.ruche_stage_p(j)
      ,.west_not_east_p(0)
    ) south_wh_e_tieoff (
      .clk_i(clk)
      ,.reset_i(reset_r)
      ,.ruche_link_i(south_wh_link_sif_lo[E][j])
      ,.ruche_link_o(south_wh_link_sif_li[E][j])
    );
  end


  // io ver tieoff
  for (genvar i = N; i <= S; i++) begin: io_v
    bsg_manycore_link_sif_tieoff #(
      .addr_width_p(hb_addr_width_gp)
      ,.data_width_p(hb_data_width_gp)
      ,.x_cord_width_p(hb_x_cord_width_gp)
      ,.y_cord_width_p(hb_y_cord_width_gp)
    ) io_v_tieoff (
      .clk_i(clk)
      ,.reset_i(reset_r)
      ,.link_sif_i(io_ver_link_sif_lo[i])
      ,.link_sif_o(io_ver_link_sif_li[i])
    );
  end

  // io unused proc tieoff
  for (genvar i = 1; i < hb_num_tiles_y_gp; i++) begin: io_p
    bsg_manycore_link_sif_tieoff #(
      .addr_width_p(hb_addr_width_gp)
      ,.data_width_p(hb_data_width_gp)
      ,.x_cord_width_p(hb_x_cord_width_gp)
      ,.y_cord_width_p(hb_y_cord_width_gp)
    ) io_p_tieoff (
      .clk_i(clk)
      ,.reset_i(reset_r)
      ,.link_sif_i(proc_link_sif_lo[i])
      ,.link_sif_o(proc_link_sif_li[i])
    );
  end



endmodule
