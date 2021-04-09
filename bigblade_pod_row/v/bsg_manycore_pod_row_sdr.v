/**
 *    bsg_manycore_pod_row_sdr.v
 *
 */


module bsg_manycore_pod_row_sdr
  import bsg_manycore_pkg::*;
  import bsg_noc_pkg::*;
  import bsg_tag_pkg::*;
  import bsg_chip_pkg::*;
  #(parameter fwd_width_lp =
      `bsg_manycore_packet_width(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp)
    , parameter rev_width_lp =
      `bsg_manycore_return_packet_width(hb_x_cord_width_gp,hb_y_cord_width_gp,hb_data_width_gp)

    ,  parameter total_num_tiles_x_lp=(hb_num_pods_x_gp*hb_num_tiles_x_gp)
  )
  (
    // clk gen
      input [3:0] async_reset_tag_lines_i
    , input [3:0] osc_tag_lines_i
    , input [3:0] osc_trigger_tag_lines_i
    , input [3:0] ds_tag_lines_i
    , input [3:0] sel_tag_lines_i
    , input async_output_disable_i
    , input ext_clk_i
    , input tag_clk_i

    // pod tag
    , input bsg_tag_s [hb_num_pods_x_gp-1:0] pod_tags_i
    , input [2+total_num_tiles_x_lp-1:0][hb_x_cord_width_gp-1:0] global_x_i
    , input [2+total_num_tiles_x_lp-1:0][hb_y_cord_width_gp-1:0] global_y_i

    // sdr async reset (going horizontally through ver sdr)
    , input [S:N] hor_sdr_async_uplink_reset_i
    , input [S:N] hor_sdr_async_downlink_reset_i
    , input [S:N] hor_sdr_async_downstream_reset_i
    , input [S:N] hor_sdr_async_token_reset_i

    // sdr async reset (going vertically through corner and hor sdr)
    , input [E:W] ver_sdr_async_uplink_reset_i
    , input [E:W] ver_sdr_async_downlink_reset_i
    , input [E:W] ver_sdr_async_downstream_reset_i
    , input [E:W] ver_sdr_async_token_reset_i

    // ver IO
    , output [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_fwd_link_clk_o
    , output [S:N][2+total_num_tiles_x_lp-1:0][fwd_width_lp-1:0]  ver_io_fwd_link_data_o
    , output [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_fwd_link_v_o
    , input  [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_fwd_link_token_i

    , input  [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_fwd_link_clk_i
    , input  [S:N][2+total_num_tiles_x_lp-1:0][fwd_width_lp-1:0]  ver_io_fwd_link_data_i
    , input  [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_fwd_link_v_i
    , output [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_fwd_link_token_o

    , output [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_rev_link_clk_o
    , output [S:N][2+total_num_tiles_x_lp-1:0][rev_width_lp-1:0]  ver_io_rev_link_data_o
    , output [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_rev_link_v_o
    , input  [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_rev_link_token_i

    , input  [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_rev_link_clk_i
    , input  [S:N][2+total_num_tiles_x_lp-1:0][rev_width_lp-1:0]  ver_io_rev_link_data_i
    , input  [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_rev_link_v_i
    , output [S:N][2+total_num_tiles_x_lp-1:0]                    ver_io_rev_link_token_o

    // hor manycore IO
    , output [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_fwd_link_clk_o
    , output [E:W][hb_num_tiles_y_gp-1:0][fwd_width_lp-1:0]       hor_io_fwd_link_data_o
    , output [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_fwd_link_v_o
    , input  [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_fwd_link_token_i

    , input  [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_fwd_link_clk_i
    , input  [E:W][hb_num_tiles_y_gp-1:0][fwd_width_lp-1:0]       hor_io_fwd_link_data_i
    , input  [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_fwd_link_v_i
    , output [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_fwd_link_token_o

    , output [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_rev_link_clk_o
    , output [E:W][hb_num_tiles_y_gp-1:0][rev_width_lp-1:0]       hor_io_rev_link_data_o
    , output [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_rev_link_v_o
    , input  [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_rev_link_token_i

    , input  [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_rev_link_clk_i
    , input  [E:W][hb_num_tiles_y_gp-1:0][rev_width_lp-1:0]       hor_io_rev_link_data_i
    , input  [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_rev_link_v_i
    , output [E:W][hb_num_tiles_y_gp-1:0]                         hor_io_rev_link_token_o

    // wh IO
    , output [E:W][S:N][wh_ruche_factor_gp-1:0]                           io_wh_link_clk_o
    , output [E:W][S:N][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0]     io_wh_link_data_o
    , output [E:W][S:N][wh_ruche_factor_gp-1:0]                           io_wh_link_v_o
    , input  [E:W][S:N][wh_ruche_factor_gp-1:0]                           io_wh_link_token_i

    , input  [E:W][S:N][wh_ruche_factor_gp-1:0]                           io_wh_link_clk_i
    , input  [E:W][S:N][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0]     io_wh_link_data_i
    , input  [E:W][S:N][wh_ruche_factor_gp-1:0]                           io_wh_link_v_i
    , output [E:W][S:N][wh_ruche_factor_gp-1:0]                           io_wh_link_token_o
  );


  // link structs
  `declare_bsg_manycore_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  `declare_bsg_manycore_ruche_x_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  `declare_bsg_ready_and_link_sif_s(wh_flit_width_gp, wh_link_sif_s);


  // CLOCK GEN
  wire bsg_tag_s async_reset_tag_lines_li = {tag_clk_i, async_reset_tag_lines_i[2:0]};
  wire bsg_tag_s osc_tag_lines_li         = {tag_clk_i, osc_tag_lines_i        [2:0]};
  wire bsg_tag_s osc_trigger_tag_lines_li = {tag_clk_i, osc_trigger_tag_lines_i[2:0]};
  wire bsg_tag_s ds_tag_lines_li          = {tag_clk_i, ds_tag_lines_i         [2:0]};
  wire bsg_tag_s sel_tag_lines_li         = {tag_clk_i, sel_tag_lines_i        [2:0]};

  logic core_clk;

  bsg_chip_clk_gen
 #(.ds_width_p             (clk_gen_ds_width_gp     )
  ,.num_adgs_p             (clk_gen_num_adgs_gp     )
  ) clk_gen
  (.async_reset_tag_lines_i(async_reset_tag_lines_li)
  ,.osc_tag_lines_i        (osc_tag_lines_li        )
  ,.osc_trigger_tag_lines_i(osc_trigger_tag_lines_li)
  ,.ds_tag_lines_i         (ds_tag_lines_li         )
  ,.sel_tag_lines_i        (sel_tag_lines_li        )
  ,.async_output_disable_i (async_output_disable_i  )
  ,.ext_clk_i              (ext_clk_i               )
  ,.clk_o                  (core_clk                )
  );

  // BSG_TAG CLIENT
  logic [hb_num_pods_x_gp-1:0] core_reset_lo;
  logic [hb_num_pods_x_gp-1:0][hb_num_tiles_x_gp-1:0] core_reset_r;

  for (genvar x = 0; x < hb_num_pods_x_gp; x++) begin: tx
    bsg_tag_client #(
      .width_p(1)
      ,.default_p(0)
    ) btc (
      .bsg_tag_i(pod_tags_i[x])
      ,.recv_clk_i(core_clk)
      ,.recv_reset_i(1'b0)
      ,.recv_new_r_o()
      ,.recv_data_r_o(core_reset_lo[x])
    );

    bsg_dff_chain #(
      .width_p(hb_num_tiles_x_gp)
      ,.num_stages_p(2)
    ) reset_dff (
      .clk_i(core_clk)
      ,.data_i({hb_num_tiles_x_gp{core_reset_lo[x]}})
      ,.data_o(core_reset_r[x])
    );
  end


  // POD array
  logic [total_num_tiles_x_lp-1:0] pod_reset_li;
  logic [total_num_tiles_x_lp-1:0][hb_x_cord_width_gp-1:0] pod_global_x_li;
  logic [total_num_tiles_x_lp-1:0][hb_y_cord_width_gp-1:0] pod_global_y_li;

  bsg_manycore_link_sif_s [S:N][total_num_tiles_x_lp-1:0] pod_ver_link_sif_li, pod_ver_link_sif_lo;
  wh_link_sif_s [E:W][S:N][wh_ruche_factor_gp-1:0] pod_wh_link_sif_li, pod_wh_link_sif_lo;
  bsg_manycore_link_sif_s [E:W][hb_num_tiles_y_gp-1:0] pod_hor_link_sif_li, pod_hor_link_sif_lo;
  bsg_manycore_ruche_x_link_sif_s [E:W][hb_num_tiles_y_gp-1:0] pod_ruche_link_li, pod_ruche_link_lo;

  bsg_manycore_pod_ruche_row #(
    .num_tiles_x_p        (hb_num_tiles_x_gp)
    ,.num_tiles_y_p       (hb_num_tiles_y_gp)
    ,.pod_x_cord_width_p  (hb_pod_x_cord_width_gp)
    ,.pod_y_cord_width_p  (hb_pod_y_cord_width_gp)
    ,.x_cord_width_p      (hb_x_cord_width_gp)
    ,.y_cord_width_p      (hb_y_cord_width_gp)
    ,.addr_width_p        (hb_addr_width_gp)
    ,.data_width_p        (hb_data_width_gp)
    ,.ruche_factor_X_p    (hb_ruche_factor_X_gp)

    ,.num_subarray_x_p    (hb_num_subarray_x_gp)
    ,.num_subarray_y_p    (hb_num_subarray_y_gp)

    ,.dmem_size_p         (hb_dmem_size_gp)
    ,.icache_entries_p    (hb_icache_entries_gp)
    ,.icache_tag_width_p  (hb_icache_tag_width_gp)

    ,.num_vcache_rows_p   (num_vcache_rows_gp)
    ,.vcache_addr_width_p (vcache_addr_width_gp)
    ,.vcache_data_width_p (vcache_data_width_gp)
    ,.vcache_ways_p       (vcache_ways_gp)
    ,.vcache_sets_p       (vcache_sets_gp)
    ,.vcache_block_size_in_words_p  (vcache_block_size_in_words_gp)
    ,.vcache_size_p                 (vcache_size_gp)
    ,.vcache_dma_data_width_p       (vcache_dma_data_width_gp)

    ,.wh_ruche_factor_p   (wh_ruche_factor_gp)
    ,.wh_cid_width_p      (wh_cid_width_gp)
    ,.wh_flit_width_p     (wh_flit_width_gp)
    ,.wh_cord_width_p     (wh_cord_width_gp)
    ,.wh_len_width_p      (wh_len_width_gp)

    ,.num_pods_x_p        (hb_num_pods_x_gp)
  ) podrow (
    .clk_i              (core_clk)
    ,.reset_i           (pod_reset_li)

    ,.ver_link_sif_i    (pod_ver_link_sif_li)
    ,.ver_link_sif_o    (pod_ver_link_sif_lo)

    ,.wh_link_sif_i     (pod_wh_link_sif_li)
    ,.wh_link_sif_o     (pod_wh_link_sif_lo)

    ,.hor_link_sif_i    (pod_hor_link_sif_li)
    ,.hor_link_sif_o    (pod_hor_link_sif_lo)

    ,.ruche_link_i      (pod_ruche_link_li)
    ,.ruche_link_o      (pod_ruche_link_lo)

    ,.global_x_i        (pod_global_x_li)
    ,.global_y_i        (pod_global_y_li)
  );


  // NORTH SDR
  logic [total_num_tiles_x_lp-1:0] sdr_n_core_reset_li, sdr_n_core_reset_lo;
  logic [total_num_tiles_x_lp-1:0][hb_x_cord_width_gp-1:0] sdr_n_core_global_x_li, sdr_n_core_global_x_lo;
  logic [total_num_tiles_x_lp-1:0][hb_y_cord_width_gp-1:0] sdr_n_core_global_y_li, sdr_n_core_global_y_lo;
  logic [total_num_tiles_x_lp-1:0] sdr_n_async_uplink_reset_li,     sdr_n_async_uplink_reset_lo;
  logic [total_num_tiles_x_lp-1:0] sdr_n_async_downlink_reset_li,   sdr_n_async_downlink_reset_lo;
  logic [total_num_tiles_x_lp-1:0] sdr_n_async_downstream_reset_li, sdr_n_async_downstream_reset_lo;
  logic [total_num_tiles_x_lp-1:0] sdr_n_async_token_reset_li,      sdr_n_async_token_reset_lo;

  for (genvar x = 0; x < total_num_tiles_x_lp; x++) begin: sdr_n_x
    bsg_manycore_link_to_sdr_north #(
      .lg_fifo_depth_p                  (sdr_lg_fifo_depth_gp)
      ,.lg_credit_to_token_decimation_p (sdr_lg_credit_to_token_decimation_gp)
      ,.x_cord_width_p      (hb_x_cord_width_gp)
      ,.y_cord_width_p      (hb_y_cord_width_gp)
      ,.addr_width_p        (hb_addr_width_gp)
      ,.data_width_p        (hb_data_width_gp)
    ) sdr_n (
      .core_clk_i(core_clk)
      ,.core_reset_i(sdr_n_core_reset_li[x])
      ,.core_reset_o(sdr_n_core_reset_lo[x])

      ,.core_global_x_i(sdr_n_core_global_x_li[x])
      ,.core_global_y_i(sdr_n_core_global_y_li[x])
      ,.core_global_x_o(sdr_n_core_global_x_lo[x])
      ,.core_global_y_o(sdr_n_core_global_y_lo[x])

      ,.core_link_sif_i           (pod_ver_link_sif_lo[N][x])
      ,.core_link_sif_o           (pod_ver_link_sif_li[N][x])

      ,.async_uplink_reset_i      (sdr_n_async_uplink_reset_li[x])
      ,.async_downlink_reset_i    (sdr_n_async_downlink_reset_li[x])
      ,.async_downstream_reset_i  (sdr_n_async_downstream_reset_li[x])
      ,.async_token_reset_i       (sdr_n_async_token_reset_li[x])

      ,.async_uplink_reset_o      (sdr_n_async_uplink_reset_lo[x])
      ,.async_downlink_reset_o    (sdr_n_async_downlink_reset_lo[x])
      ,.async_downstream_reset_o  (sdr_n_async_downstream_reset_lo[x])
      ,.async_token_reset_o       (sdr_n_async_token_reset_lo[x])

      ,.io_fwd_link_clk_o         (ver_io_fwd_link_clk_o[N][x+1])
      ,.io_fwd_link_data_o        (ver_io_fwd_link_data_o[N][x+1])
      ,.io_fwd_link_v_o           (ver_io_fwd_link_v_o[N][x+1])
      ,.io_fwd_link_token_i       (ver_io_fwd_link_token_i[N][x+1])

      ,.io_fwd_link_clk_i         (ver_io_fwd_link_clk_i[N][x+1])
      ,.io_fwd_link_data_i        (ver_io_fwd_link_data_i[N][x+1])
      ,.io_fwd_link_v_i           (ver_io_fwd_link_v_i[N][x+1])
      ,.io_fwd_link_token_o       (ver_io_fwd_link_token_o[N][x+1])

      ,.io_rev_link_clk_o         (ver_io_rev_link_clk_o[N][x+1])
      ,.io_rev_link_data_o        (ver_io_rev_link_data_o[N][x+1])
      ,.io_rev_link_v_o           (ver_io_rev_link_v_o[N][x+1])
      ,.io_rev_link_token_i       (ver_io_rev_link_token_i[N][x+1])

      ,.io_rev_link_clk_i         (ver_io_rev_link_clk_i[N][x+1])
      ,.io_rev_link_data_i        (ver_io_rev_link_data_i[N][x+1])
      ,.io_rev_link_v_i           (ver_io_rev_link_v_i[N][x+1])
      ,.io_rev_link_token_o       (ver_io_rev_link_token_o[N][x+1])
    );

    // connect async reset port
    if (x == 0) begin
      assign sdr_n_async_uplink_reset_li[x]     = hor_sdr_async_uplink_reset_i[N];
      assign sdr_n_async_downlink_reset_li[x]   = hor_sdr_async_downlink_reset_i[N];
      assign sdr_n_async_downstream_reset_li[x] = hor_sdr_async_downstream_reset_i[N];
      assign sdr_n_async_token_reset_li[x]      = hor_sdr_async_token_reset_i[N];
    end

    // connect async_reset between sdr
    if (x < total_num_tiles_x_lp-1) begin
      assign sdr_n_async_uplink_reset_li[x+1]     = sdr_n_async_uplink_reset_lo[x];
      assign sdr_n_async_downlink_reset_li[x+1]   = sdr_n_async_downlink_reset_lo[x];
      assign sdr_n_async_downstream_reset_li[x+1] = sdr_n_async_downstream_reset_lo[x];
      assign sdr_n_async_token_reset_li[x+1]      = sdr_n_async_token_reset_lo[x];
    end
  end

  assign sdr_n_core_reset_li = core_reset_r;
  assign pod_reset_li = sdr_n_core_reset_lo;
  assign sdr_n_core_global_x_li = global_x_i[1+:total_num_tiles_x_lp];
  assign sdr_n_core_global_y_li = global_y_i[1+:total_num_tiles_x_lp];
  assign pod_global_x_li = sdr_n_core_global_x_lo;
  assign pod_global_y_li = sdr_n_core_global_y_lo;


  // SOUTH SDR
  logic [total_num_tiles_x_lp-1:0] sdr_s_async_uplink_reset_li,     sdr_s_async_uplink_reset_lo;
  logic [total_num_tiles_x_lp-1:0] sdr_s_async_downlink_reset_li,   sdr_s_async_downlink_reset_lo;
  logic [total_num_tiles_x_lp-1:0] sdr_s_async_downstream_reset_li, sdr_s_async_downstream_reset_lo;
  logic [total_num_tiles_x_lp-1:0] sdr_s_async_token_reset_li,      sdr_s_async_token_reset_lo;

  for (genvar x = 0; x < total_num_tiles_x_lp; x++) begin: sdr_s_x
    bsg_manycore_link_to_sdr_south #(
      .lg_fifo_depth_p                  (sdr_lg_fifo_depth_gp)
      ,.lg_credit_to_token_decimation_p (sdr_lg_credit_to_token_decimation_gp)

      ,.x_cord_width_p      (hb_x_cord_width_gp)
      ,.y_cord_width_p      (hb_y_cord_width_gp)
      ,.addr_width_p        (hb_addr_width_gp)
      ,.data_width_p        (hb_data_width_gp)
    ) sdr_s (
      .core_clk_i(core_clk)
      ,.core_reset_i('0)
      ,.core_reset_o()

      ,.core_global_x_i('0)
      ,.core_global_y_i('0)
      ,.core_global_x_o()
      ,.core_global_y_o()

      ,.core_link_sif_i           (pod_ver_link_sif_lo[S][x])
      ,.core_link_sif_o           (pod_ver_link_sif_li[S][x])

      ,.async_uplink_reset_i      (sdr_s_async_uplink_reset_li[x])
      ,.async_downlink_reset_i    (sdr_s_async_downlink_reset_li[x])
      ,.async_downstream_reset_i  (sdr_s_async_downstream_reset_li[x])
      ,.async_token_reset_i       (sdr_s_async_token_reset_li[x])

      ,.async_uplink_reset_o      (sdr_s_async_uplink_reset_lo[x])
      ,.async_downlink_reset_o    (sdr_s_async_downlink_reset_lo[x])
      ,.async_downstream_reset_o  (sdr_s_async_downstream_reset_lo[x])
      ,.async_token_reset_o       (sdr_s_async_token_reset_lo[x])

      ,.io_fwd_link_clk_o         (ver_io_fwd_link_clk_o[S][x+1])
      ,.io_fwd_link_data_o        (ver_io_fwd_link_data_o[S][x+1])
      ,.io_fwd_link_v_o           (ver_io_fwd_link_v_o[S][x+1])
      ,.io_fwd_link_token_i       (ver_io_fwd_link_token_i[S][x+1])

      ,.io_fwd_link_clk_i         (ver_io_fwd_link_clk_i[S][x+1])
      ,.io_fwd_link_data_i        (ver_io_fwd_link_data_i[S][x+1])
      ,.io_fwd_link_v_i           (ver_io_fwd_link_v_i[S][x+1])
      ,.io_fwd_link_token_o       (ver_io_fwd_link_token_o[S][x+1])

      ,.io_rev_link_clk_o         (ver_io_rev_link_clk_o[S][x+1])
      ,.io_rev_link_data_o        (ver_io_rev_link_data_o[S][x+1])
      ,.io_rev_link_v_o           (ver_io_rev_link_v_o[S][x+1])
      ,.io_rev_link_token_i       (ver_io_rev_link_token_i[S][x+1])

      ,.io_rev_link_clk_i         (ver_io_rev_link_clk_i[S][x+1])
      ,.io_rev_link_data_i        (ver_io_rev_link_data_i[S][x+1])
      ,.io_rev_link_v_i           (ver_io_rev_link_v_i[S][x+1])
      ,.io_rev_link_token_o       (ver_io_rev_link_token_o[S][x+1])
    );

    // connect async_reset port on west
    if (x == 0) begin
      assign sdr_s_async_uplink_reset_li[x]     = hor_sdr_async_uplink_reset_i[S];
      assign sdr_s_async_downlink_reset_li[x]   = hor_sdr_async_downlink_reset_i[S];
      assign sdr_s_async_downstream_reset_li[x] = hor_sdr_async_downstream_reset_i[S];
      assign sdr_s_async_token_reset_li[x]      = hor_sdr_async_token_reset_i[S];
    end

    // connect async_reset between sdr
    if (x < total_num_tiles_x_lp-1) begin
      assign sdr_s_async_uplink_reset_li[x+1]     = sdr_s_async_uplink_reset_lo[x];
      assign sdr_s_async_downlink_reset_li[x+1]   = sdr_s_async_downlink_reset_lo[x];
      assign sdr_s_async_downstream_reset_li[x+1] = sdr_s_async_downstream_reset_lo[x];
      assign sdr_s_async_token_reset_li[x+1]      = sdr_s_async_token_reset_lo[x];
    end
  end


  // WEST SDR
  logic [hb_num_tiles_y_gp-1:0] sdr_w_core_reset_li, sdr_w_core_reset_lo;
  logic [hb_num_tiles_y_gp-1:0][hb_x_cord_width_gp-1:0] sdr_w_core_global_x_li, sdr_w_core_global_x_lo;
  logic [hb_num_tiles_y_gp-1:0][hb_y_cord_width_gp-1:0] sdr_w_core_global_y_li, sdr_w_core_global_y_lo;


  bsg_manycore_link_sif_s [hb_num_tiles_y_gp-1:0][S:N] sdr_w_ver_link_sif_li, sdr_w_ver_link_sif_lo;
  logic [hb_num_tiles_y_gp-1:0] sdr_w_async_uplink_reset_li,     sdr_w_async_uplink_reset_lo;
  logic [hb_num_tiles_y_gp-1:0] sdr_w_async_downlink_reset_li,   sdr_w_async_downlink_reset_lo;
  logic [hb_num_tiles_y_gp-1:0] sdr_w_async_downstream_reset_li, sdr_w_async_downstream_reset_lo;
  logic [hb_num_tiles_y_gp-1:0] sdr_w_async_token_reset_li,      sdr_w_async_token_reset_lo;

  for (genvar y = 0; y < hb_num_tiles_y_gp; y++) begin: sdr_w_y
    bsg_manycore_link_ruche_to_sdr_west #(
      .lg_fifo_depth_p                  (sdr_lg_fifo_depth_gp)
      ,.lg_credit_to_token_decimation_p (sdr_lg_credit_to_token_decimation_gp)

      ,.x_cord_width_p      (hb_x_cord_width_gp)
      ,.y_cord_width_p      (hb_y_cord_width_gp)
      ,.addr_width_p        (hb_addr_width_gp)
      ,.data_width_p        (hb_data_width_gp)
      ,.ruche_factor_X_p    (hb_ruche_factor_X_gp)
    ) sdr_w (
      .core_clk_i       (core_clk)
      ,.core_reset_i    (sdr_w_core_reset_li[y])
      ,.core_reset_o    (sdr_w_core_reset_lo[y])

      ,.core_ver_link_sif_i   (sdr_w_ver_link_sif_li[y])
      ,.core_ver_link_sif_o   (sdr_w_ver_link_sif_lo[y])

      ,.core_hor_link_sif_i   (pod_hor_link_sif_lo[W][y])
      ,.core_hor_link_sif_o   (pod_hor_link_sif_li[W][y])

      ,.core_ruche_link_i     (pod_ruche_link_lo[W][y])
      ,.core_ruche_link_o     (pod_ruche_link_li[W][y])

      ,.core_global_x_i       (sdr_w_core_global_x_li[y])
      ,.core_global_y_i       (sdr_w_core_global_y_li[y])
      ,.core_global_x_o       (sdr_w_core_global_x_lo[y])
      ,.core_global_y_o       (sdr_w_core_global_y_lo[y])

      ,.async_uplink_reset_i      (sdr_w_async_uplink_reset_li[y])
      ,.async_downlink_reset_i    (sdr_w_async_downlink_reset_li[y])
      ,.async_downstream_reset_i  (sdr_w_async_downstream_reset_li[y])
      ,.async_token_reset_i       (sdr_w_async_token_reset_li[y])

      ,.async_uplink_reset_o      (sdr_w_async_uplink_reset_lo[y])
      ,.async_downlink_reset_o    (sdr_w_async_downlink_reset_lo[y])
      ,.async_downstream_reset_o  (sdr_w_async_downstream_reset_lo[y])
      ,.async_token_reset_o       (sdr_w_async_token_reset_lo[y])

      ,.io_fwd_link_clk_o       (hor_io_fwd_link_clk_o[W][y])
      ,.io_fwd_link_data_o      (hor_io_fwd_link_data_o[W][y])
      ,.io_fwd_link_v_o         (hor_io_fwd_link_v_o[W][y])
      ,.io_fwd_link_token_i     (hor_io_fwd_link_token_i[W][y])

      ,.io_fwd_link_clk_i       (hor_io_fwd_link_clk_i[W][y])
      ,.io_fwd_link_data_i      (hor_io_fwd_link_data_i[W][y])
      ,.io_fwd_link_v_i         (hor_io_fwd_link_v_i[W][y])
      ,.io_fwd_link_token_o     (hor_io_fwd_link_token_o[W][y])

      ,.io_rev_link_clk_o       (hor_io_rev_link_clk_o[W][y])
      ,.io_rev_link_data_o      (hor_io_rev_link_data_o[W][y])
      ,.io_rev_link_v_o         (hor_io_rev_link_v_o[W][y])
      ,.io_rev_link_token_i     (hor_io_rev_link_token_i[W][y])

      ,.io_rev_link_clk_i       (hor_io_rev_link_clk_i[W][y])
      ,.io_rev_link_data_i      (hor_io_rev_link_data_i[W][y])
      ,.io_rev_link_v_i         (hor_io_rev_link_v_i[W][y])
      ,.io_rev_link_token_o     (hor_io_rev_link_token_o[W][y])
    );

    // connect between sdr west
    if (y < hb_num_tiles_y_gp-1) begin
      // ver link
      assign sdr_w_ver_link_sif_li[y][S] = sdr_w_ver_link_sif_lo[y+1][N];
      assign sdr_w_ver_link_sif_li[y+1][N] = sdr_w_ver_link_sif_lo[y][S];
      // async reset
      assign sdr_w_async_uplink_reset_li[y+1] = sdr_w_async_uplink_reset_lo[y];
      assign sdr_w_async_downlink_reset_li[y+1] = sdr_w_async_downlink_reset_lo[y];
      assign sdr_w_async_downstream_reset_li[y+1] = sdr_w_async_downstream_reset_lo[y];
      assign sdr_w_async_token_reset_li[y+1] = sdr_w_async_token_reset_lo[y];
      // core reset
      assign sdr_w_core_reset_li[y+1] = sdr_w_core_reset_lo[y];
      // core global cord
      assign sdr_w_core_global_x_li[y+1] = sdr_w_core_global_x_lo[y];
      assign sdr_w_core_global_y_li[y+1] = sdr_w_core_global_y_lo[y];
    end

  end

  // EAST SDR
  logic [hb_num_tiles_y_gp-1:0] sdr_e_core_reset_li, sdr_e_core_reset_lo;
  logic [hb_num_tiles_y_gp-1:0][hb_x_cord_width_gp-1:0] sdr_e_core_global_x_li, sdr_e_core_global_x_lo;
  logic [hb_num_tiles_y_gp-1:0][hb_y_cord_width_gp-1:0] sdr_e_core_global_y_li, sdr_e_core_global_y_lo;

  bsg_manycore_link_sif_s [hb_num_tiles_y_gp-1:0][S:N] sdr_e_ver_link_sif_li, sdr_e_ver_link_sif_lo;
  logic [hb_num_tiles_y_gp-1:0] sdr_e_async_uplink_reset_li,     sdr_e_async_uplink_reset_lo;
  logic [hb_num_tiles_y_gp-1:0] sdr_e_async_downlink_reset_li,   sdr_e_async_downlink_reset_lo;
  logic [hb_num_tiles_y_gp-1:0] sdr_e_async_downstream_reset_li, sdr_e_async_downstream_reset_lo;
  logic [hb_num_tiles_y_gp-1:0] sdr_e_async_token_reset_li,      sdr_e_async_token_reset_lo;

  for (genvar y = 0; y < hb_num_tiles_y_gp; y++) begin: sdr_e_y
    bsg_manycore_link_ruche_to_sdr_east #(
      .lg_fifo_depth_p                  (sdr_lg_fifo_depth_gp)
      ,.lg_credit_to_token_decimation_p (sdr_lg_credit_to_token_decimation_gp)

      ,.x_cord_width_p      (hb_x_cord_width_gp)
      ,.y_cord_width_p      (hb_y_cord_width_gp)
      ,.addr_width_p        (hb_addr_width_gp)
      ,.data_width_p        (hb_data_width_gp)
      ,.ruche_factor_X_p    (hb_ruche_factor_X_gp)
    ) sdr_e (
      .core_clk_i       (core_clk)
      ,.core_reset_i    (sdr_e_core_reset_li[y])
      ,.core_reset_o    (sdr_e_core_reset_lo[y])

      ,.core_ver_link_sif_i   (sdr_e_ver_link_sif_li[y])
      ,.core_ver_link_sif_o   (sdr_e_ver_link_sif_lo[y])

      ,.core_hor_link_sif_i   (pod_hor_link_sif_lo[E][y])
      ,.core_hor_link_sif_o   (pod_hor_link_sif_li[E][y])

      ,.core_ruche_link_i     (pod_ruche_link_lo[E][y])
      ,.core_ruche_link_o     (pod_ruche_link_li[E][y])

      ,.core_global_x_i       (sdr_e_core_global_x_li[y])
      ,.core_global_y_i       (sdr_e_core_global_y_li[y])
      ,.core_global_x_o       (sdr_e_core_global_x_lo[y])
      ,.core_global_y_o       (sdr_e_core_global_y_lo[y])

      ,.async_uplink_reset_i      (sdr_e_async_uplink_reset_li[y])
      ,.async_downlink_reset_i    (sdr_e_async_downlink_reset_li[y])
      ,.async_downstream_reset_i  (sdr_e_async_downstream_reset_li[y])
      ,.async_token_reset_i       (sdr_e_async_token_reset_li[y])

      ,.async_uplink_reset_o      (sdr_e_async_uplink_reset_lo[y])
      ,.async_downlink_reset_o    (sdr_e_async_downlink_reset_lo[y])
      ,.async_downstream_reset_o  (sdr_e_async_downstream_reset_lo[y])
      ,.async_token_reset_o       (sdr_e_async_token_reset_lo[y])

      ,.io_fwd_link_clk_o       (hor_io_fwd_link_clk_o[E][y])
      ,.io_fwd_link_data_o      (hor_io_fwd_link_data_o[E][y])
      ,.io_fwd_link_v_o         (hor_io_fwd_link_v_o[E][y])
      ,.io_fwd_link_token_i     (hor_io_fwd_link_token_i[E][y])

      ,.io_fwd_link_clk_i       (hor_io_fwd_link_clk_i[E][y])
      ,.io_fwd_link_data_i      (hor_io_fwd_link_data_i[E][y])
      ,.io_fwd_link_v_i         (hor_io_fwd_link_v_i[E][y])
      ,.io_fwd_link_token_o     (hor_io_fwd_link_token_o[E][y])

      ,.io_rev_link_clk_o       (hor_io_rev_link_clk_o[E][y])
      ,.io_rev_link_data_o      (hor_io_rev_link_data_o[E][y])
      ,.io_rev_link_v_o         (hor_io_rev_link_v_o[E][y])
      ,.io_rev_link_token_i     (hor_io_rev_link_token_i[E][y])

      ,.io_rev_link_clk_i       (hor_io_rev_link_clk_i[E][y])
      ,.io_rev_link_data_i      (hor_io_rev_link_data_i[E][y])
      ,.io_rev_link_v_i         (hor_io_rev_link_v_i[E][y])
      ,.io_rev_link_token_o     (hor_io_rev_link_token_o[E][y])
    );

    // connect between sdr east
    if (y < hb_num_tiles_y_gp-1) begin
      // ver link
      assign sdr_e_ver_link_sif_li[y][S] = sdr_e_ver_link_sif_lo[y+1][N];
      assign sdr_e_ver_link_sif_li[y+1][N] = sdr_e_ver_link_sif_lo[y][S];
      // async reset
      assign sdr_e_async_uplink_reset_li[y+1] = sdr_e_async_uplink_reset_lo[y];
      assign sdr_e_async_downlink_reset_li[y+1] = sdr_e_async_downlink_reset_lo[y];
      assign sdr_e_async_downstream_reset_li[y+1] = sdr_e_async_downstream_reset_lo[y];
      assign sdr_e_async_token_reset_li[y+1] = sdr_e_async_token_reset_lo[y];
      // core reset
      assign sdr_e_core_reset_li[y+1] = sdr_e_core_reset_lo[y];
      // core global cord
      assign sdr_e_core_global_x_li[y+1] = sdr_e_core_global_x_lo[y];
      assign sdr_e_core_global_y_li[y+1] = sdr_e_core_global_y_lo[y];
    end


  end

  // CORNER SDR NW
  bsg_manycore_link_wh_to_sdr_nw #(
    .lg_fifo_depth_p(sdr_lg_fifo_depth_gp)
    ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_gp)

    ,.x_cord_width_p      (hb_x_cord_width_gp)
    ,.y_cord_width_p      (hb_y_cord_width_gp)
    ,.addr_width_p        (hb_addr_width_gp)
    ,.data_width_p        (hb_data_width_gp)

    ,.wh_ruche_factor_p   (wh_ruche_factor_gp)
    ,.wh_flit_width_p     (wh_flit_width_gp)
  ) sdr_nw (
    .core_clk_i         (core_clk)
    ,.core_reset_i      (core_reset_r[0][0])
    ,.core_reset_o      (sdr_w_core_reset_li[0])

    ,.core_global_x_i   (global_x_i[0])
    ,.core_global_y_i   (global_y_i[0])
    ,.core_global_x_o   (sdr_w_core_global_x_li[0])
    ,.core_global_y_o   (sdr_w_core_global_y_li[0])

    ,.core_ver_link_sif_i         (sdr_w_ver_link_sif_lo[0][N])
    ,.core_ver_link_sif_o         (sdr_w_ver_link_sif_li[0][N])

    ,.core_wh_link_sif_i          (pod_wh_link_sif_lo[W][N])
    ,.core_wh_link_sif_o          (pod_wh_link_sif_li[W][N])

    ,.async_uplink_reset_i        (ver_sdr_async_uplink_reset_i[W])
    ,.async_downlink_reset_i      (ver_sdr_async_downlink_reset_i[W])
    ,.async_downstream_reset_i    (ver_sdr_async_downstream_reset_i[W])
    ,.async_token_reset_i         (ver_sdr_async_token_reset_i[W])

    ,.async_uplink_reset_o        (sdr_w_async_uplink_reset_li[0])
    ,.async_downlink_reset_o      (sdr_w_async_downlink_reset_li[0])
    ,.async_downstream_reset_o    (sdr_w_async_downstream_reset_li[0])
    ,.async_token_reset_o         (sdr_w_async_token_reset_li[0])

    ,.io_fwd_link_clk_o           (ver_io_fwd_link_clk_o[N][0])
    ,.io_fwd_link_data_o          (ver_io_fwd_link_data_o[N][0])
    ,.io_fwd_link_v_o             (ver_io_fwd_link_v_o[N][0])
    ,.io_fwd_link_token_i         (ver_io_fwd_link_token_i[N][0])

    ,.io_fwd_link_clk_i           (ver_io_fwd_link_clk_i[N][0])
    ,.io_fwd_link_data_i          (ver_io_fwd_link_data_i[N][0])
    ,.io_fwd_link_v_i             (ver_io_fwd_link_v_i[N][0])
    ,.io_fwd_link_token_o         (ver_io_fwd_link_token_o[N][0])

    ,.io_rev_link_clk_o           (ver_io_rev_link_clk_o[N][0])
    ,.io_rev_link_data_o          (ver_io_rev_link_data_o[N][0])
    ,.io_rev_link_v_o             (ver_io_rev_link_v_o[N][0])
    ,.io_rev_link_token_i         (ver_io_rev_link_token_i[N][0])

    ,.io_rev_link_clk_i           (ver_io_rev_link_clk_i[N][0])
    ,.io_rev_link_data_i          (ver_io_rev_link_data_i[N][0])
    ,.io_rev_link_v_i             (ver_io_rev_link_v_i[N][0])
    ,.io_rev_link_token_o         (ver_io_rev_link_token_o[N][0])

    ,.io_wh_link_clk_o            (io_wh_link_clk_o[W][N])
    ,.io_wh_link_data_o           (io_wh_link_data_o[W][N])
    ,.io_wh_link_v_o              (io_wh_link_v_o[W][N])
    ,.io_wh_link_token_i          (io_wh_link_token_i[W][N])

    ,.io_wh_link_clk_i            (io_wh_link_clk_i[W][N])
    ,.io_wh_link_data_i           (io_wh_link_data_i[W][N])
    ,.io_wh_link_v_i              (io_wh_link_v_i[W][N])
    ,.io_wh_link_token_o          (io_wh_link_token_o[W][N])
  );

  // CORNER SDR NE
  bsg_manycore_link_wh_to_sdr_ne #(
    .lg_fifo_depth_p(sdr_lg_fifo_depth_gp)
    ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_gp)

    ,.x_cord_width_p      (hb_x_cord_width_gp)
    ,.y_cord_width_p      (hb_y_cord_width_gp)
    ,.addr_width_p        (hb_addr_width_gp)
    ,.data_width_p        (hb_data_width_gp)

    ,.wh_ruche_factor_p   (wh_ruche_factor_gp)
    ,.wh_flit_width_p     (wh_flit_width_gp)
  ) sdr_ne (
    .core_clk_i         (core_clk)
    ,.core_reset_i      (core_reset_r[hb_num_pods_x_gp-1][hb_num_tiles_x_gp-1])
    ,.core_reset_o      (sdr_e_core_reset_li[0])

    ,.core_global_x_i   (global_x_i[2+total_num_tiles_x_lp-1])
    ,.core_global_y_i   (global_y_i[2+total_num_tiles_x_lp-1])
    ,.core_global_x_o   (sdr_e_core_global_x_li[0])
    ,.core_global_y_o   (sdr_e_core_global_y_li[0])

    ,.core_ver_link_sif_i         (sdr_e_ver_link_sif_lo[0][N])
    ,.core_ver_link_sif_o         (sdr_e_ver_link_sif_li[0][N])

    ,.core_wh_link_sif_i          (pod_wh_link_sif_lo[E][N])
    ,.core_wh_link_sif_o          (pod_wh_link_sif_li[E][N])

    ,.async_uplink_reset_i        (ver_sdr_async_uplink_reset_i[E])
    ,.async_downlink_reset_i      (ver_sdr_async_downlink_reset_i[E])
    ,.async_downstream_reset_i    (ver_sdr_async_downstream_reset_i[E])
    ,.async_token_reset_i         (ver_sdr_async_token_reset_i[E])

    ,.async_uplink_reset_o        (sdr_e_async_uplink_reset_li[0])
    ,.async_downlink_reset_o      (sdr_e_async_downlink_reset_li[0])
    ,.async_downstream_reset_o    (sdr_e_async_downstream_reset_li[0])
    ,.async_token_reset_o         (sdr_e_async_token_reset_li[0])

    ,.io_fwd_link_clk_o           (ver_io_fwd_link_clk_o[N][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_data_o          (ver_io_fwd_link_data_o[N][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_v_o             (ver_io_fwd_link_v_o[N][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_token_i         (ver_io_fwd_link_token_i[N][2+total_num_tiles_x_lp-1])

    ,.io_fwd_link_clk_i           (ver_io_fwd_link_clk_i[N][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_data_i          (ver_io_fwd_link_data_i[N][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_v_i             (ver_io_fwd_link_v_i[N][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_token_o         (ver_io_fwd_link_token_o[N][2+total_num_tiles_x_lp-1])

    ,.io_rev_link_clk_o           (ver_io_rev_link_clk_o[N][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_data_o          (ver_io_rev_link_data_o[N][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_v_o             (ver_io_rev_link_v_o[N][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_token_i         (ver_io_rev_link_token_i[N][2+total_num_tiles_x_lp-1])

    ,.io_rev_link_clk_i           (ver_io_rev_link_clk_i[N][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_data_i          (ver_io_rev_link_data_i[N][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_v_i             (ver_io_rev_link_v_i[N][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_token_o         (ver_io_rev_link_token_o[N][2+total_num_tiles_x_lp-1])

    ,.io_wh_link_clk_o            (io_wh_link_clk_o[E][N])
    ,.io_wh_link_data_o           (io_wh_link_data_o[E][N])
    ,.io_wh_link_v_o              (io_wh_link_v_o[E][N])
    ,.io_wh_link_token_i          (io_wh_link_token_i[E][N])

    ,.io_wh_link_clk_i            (io_wh_link_clk_i[E][N])
    ,.io_wh_link_data_i           (io_wh_link_data_i[E][N])
    ,.io_wh_link_v_i              (io_wh_link_v_i[E][N])
    ,.io_wh_link_token_o          (io_wh_link_token_o[E][N])
  );

  // CORNER SDR SW
  bsg_manycore_link_wh_to_sdr_sw #(
    .lg_fifo_depth_p(sdr_lg_fifo_depth_gp)
    ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_gp)

    ,.x_cord_width_p      (hb_x_cord_width_gp)
    ,.y_cord_width_p      (hb_y_cord_width_gp)
    ,.addr_width_p        (hb_addr_width_gp)
    ,.data_width_p        (hb_data_width_gp)

    ,.wh_ruche_factor_p   (wh_ruche_factor_gp)
    ,.wh_flit_width_p     (wh_flit_width_gp)
  ) sdr_sw (
    .core_clk_i         (core_clk)
    ,.core_reset_i      (sdr_w_core_reset_lo[hb_num_tiles_y_gp-1])
    ,.core_reset_o      ()

    ,.core_global_x_i   ('0)
    ,.core_global_y_i   ('0)
    ,.core_global_x_o   ()
    ,.core_global_y_o   ()

    ,.core_ver_link_sif_i         (sdr_w_ver_link_sif_lo[hb_num_tiles_y_gp-1][S])
    ,.core_ver_link_sif_o         (sdr_w_ver_link_sif_li[hb_num_tiles_y_gp-1][S])

    ,.core_wh_link_sif_i          (pod_wh_link_sif_lo[W][S])
    ,.core_wh_link_sif_o          (pod_wh_link_sif_li[W][S])

    ,.async_uplink_reset_i        (sdr_w_async_uplink_reset_lo[hb_num_tiles_y_gp-1])
    ,.async_downlink_reset_i      (sdr_w_async_downlink_reset_lo[hb_num_tiles_y_gp-1])
    ,.async_downstream_reset_i    (sdr_w_async_downstream_reset_lo[hb_num_tiles_y_gp-1])
    ,.async_token_reset_i         (sdr_w_async_token_reset_lo[hb_num_tiles_y_gp-1])

    ,.async_uplink_reset_o        ()
    ,.async_downlink_reset_o      ()
    ,.async_downstream_reset_o    ()
    ,.async_token_reset_o         ()

    ,.io_fwd_link_clk_o           (ver_io_fwd_link_clk_o[S][0])
    ,.io_fwd_link_data_o          (ver_io_fwd_link_data_o[S][0])
    ,.io_fwd_link_v_o             (ver_io_fwd_link_v_o[S][0])
    ,.io_fwd_link_token_i         (ver_io_fwd_link_token_i[S][0])

    ,.io_fwd_link_clk_i           (ver_io_fwd_link_clk_i[S][0])
    ,.io_fwd_link_data_i          (ver_io_fwd_link_data_i[S][0])
    ,.io_fwd_link_v_i             (ver_io_fwd_link_v_i[S][0])
    ,.io_fwd_link_token_o         (ver_io_fwd_link_token_o[S][0])

    ,.io_rev_link_clk_o           (ver_io_rev_link_clk_o[S][0])
    ,.io_rev_link_data_o          (ver_io_rev_link_data_o[S][0])
    ,.io_rev_link_v_o             (ver_io_rev_link_v_o[S][0])
    ,.io_rev_link_token_i         (ver_io_rev_link_token_i[S][0])

    ,.io_rev_link_clk_i           (ver_io_rev_link_clk_i[S][0])
    ,.io_rev_link_data_i          (ver_io_rev_link_data_i[S][0])
    ,.io_rev_link_v_i             (ver_io_rev_link_v_i[S][0])
    ,.io_rev_link_token_o         (ver_io_rev_link_token_o[S][0])

    ,.io_wh_link_clk_o            (io_wh_link_clk_o[W][S])
    ,.io_wh_link_data_o           (io_wh_link_data_o[W][S])
    ,.io_wh_link_v_o              (io_wh_link_v_o[W][S])
    ,.io_wh_link_token_i          (io_wh_link_token_i[W][S])

    ,.io_wh_link_clk_i            (io_wh_link_clk_i[W][S])
    ,.io_wh_link_data_i           (io_wh_link_data_i[W][S])
    ,.io_wh_link_v_i              (io_wh_link_v_i[W][S])
    ,.io_wh_link_token_o          (io_wh_link_token_o[W][S])
  );

  // CORNER SDR SE
  bsg_manycore_link_wh_to_sdr_se #(
    .lg_fifo_depth_p(sdr_lg_fifo_depth_gp)
    ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_gp)

    ,.x_cord_width_p      (hb_x_cord_width_gp)
    ,.y_cord_width_p      (hb_y_cord_width_gp)
    ,.addr_width_p        (hb_addr_width_gp)
    ,.data_width_p        (hb_data_width_gp)

    ,.wh_ruche_factor_p   (wh_ruche_factor_gp)
    ,.wh_flit_width_p     (wh_flit_width_gp)
  ) sdr_se (
    .core_clk_i         (core_clk)
    ,.core_reset_i      (sdr_e_core_reset_lo[hb_num_tiles_y_gp-1])
    ,.core_reset_o      ()

    ,.core_global_x_i   ('0)
    ,.core_global_y_i   ('0)
    ,.core_global_x_o   ()
    ,.core_global_y_o   ()

    ,.core_ver_link_sif_i         (sdr_e_ver_link_sif_lo[hb_num_tiles_y_gp-1][S])
    ,.core_ver_link_sif_o         (sdr_e_ver_link_sif_li[hb_num_tiles_y_gp-1][S])

    ,.core_wh_link_sif_i          (pod_wh_link_sif_lo[E][S])
    ,.core_wh_link_sif_o          (pod_wh_link_sif_li[E][S])


    ,.async_uplink_reset_i        (sdr_e_async_uplink_reset_lo[hb_num_tiles_y_gp-1])
    ,.async_downlink_reset_i      (sdr_e_async_downlink_reset_lo[hb_num_tiles_y_gp-1])
    ,.async_downstream_reset_i    (sdr_e_async_downstream_reset_lo[hb_num_tiles_y_gp-1])
    ,.async_token_reset_i         (sdr_e_async_token_reset_lo[hb_num_tiles_y_gp-1])

    ,.async_uplink_reset_o()
    ,.async_downlink_reset_o()
    ,.async_downstream_reset_o()
    ,.async_token_reset_o()

    ,.io_fwd_link_clk_o           (ver_io_fwd_link_clk_o[S][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_data_o          (ver_io_fwd_link_data_o[S][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_v_o             (ver_io_fwd_link_v_o[S][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_token_i         (ver_io_fwd_link_token_i[S][2+total_num_tiles_x_lp-1])

    ,.io_fwd_link_clk_i           (ver_io_fwd_link_clk_i[S][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_data_i          (ver_io_fwd_link_data_i[S][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_v_i             (ver_io_fwd_link_v_i[S][2+total_num_tiles_x_lp-1])
    ,.io_fwd_link_token_o         (ver_io_fwd_link_token_o[S][2+total_num_tiles_x_lp-1])

    ,.io_rev_link_clk_o           (ver_io_rev_link_clk_o[S][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_data_o          (ver_io_rev_link_data_o[S][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_v_o             (ver_io_rev_link_v_o[S][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_token_i         (ver_io_rev_link_token_i[S][2+total_num_tiles_x_lp-1])

    ,.io_rev_link_clk_i           (ver_io_rev_link_clk_i[S][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_data_i          (ver_io_rev_link_data_i[S][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_v_i             (ver_io_rev_link_v_i[S][2+total_num_tiles_x_lp-1])
    ,.io_rev_link_token_o         (ver_io_rev_link_token_o[S][2+total_num_tiles_x_lp-1])

    ,.io_wh_link_clk_o            (io_wh_link_clk_o[E][S])
    ,.io_wh_link_data_o           (io_wh_link_data_o[E][S])
    ,.io_wh_link_v_o              (io_wh_link_v_o[E][S])
    ,.io_wh_link_token_i          (io_wh_link_token_i[E][S])

    ,.io_wh_link_clk_i            (io_wh_link_clk_i[E][S])
    ,.io_wh_link_data_i           (io_wh_link_data_i[E][S])
    ,.io_wh_link_v_i              (io_wh_link_v_i[E][S])
    ,.io_wh_link_token_o          (io_wh_link_token_o[E][S])
  );


endmodule
