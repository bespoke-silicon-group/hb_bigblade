`include "bsg_noc_links.vh"

module bsg_chip_pod
  import bsg_chip_pkg::*;
  import bsg_noc_pkg::*;
  import bsg_manycore_pkg::*;
  import bsg_tag_pkg::*;
  #(parameter manycore_link_sif_width_lp =
      `bsg_manycore_link_sif_width(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp)
    , parameter manycore_ruche_link_sif_width_lp =
      `bsg_manycore_ruche_x_link_sif_width(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp)
    , parameter wh_link_sif_width_lp =
      `bsg_ready_and_link_sif_width(wh_flit_width_gp)
  )
  (
    input clk_i

    // manycore
    , input  [E:W][hb_num_tiles_y_gp-1:0][manycore_link_sif_width_lp-1:0] hor_link_sif_i
    , output [E:W][hb_num_tiles_y_gp-1:0][manycore_link_sif_width_lp-1:0] hor_link_sif_o

    , input  [S:N][hb_num_tiles_x_gp-1:0][manycore_link_sif_width_lp-1:0] ver_link_sif_i
    , output [S:N][hb_num_tiles_x_gp-1:0][manycore_link_sif_width_lp-1:0] ver_link_sif_o

    , input  [E:W][hb_num_tiles_y_gp-1:0][hb_ruche_factor_X_gp-1:0][manycore_ruche_link_sif_width_lp-1:0] ruche_link_i
    , output [E:W][hb_num_tiles_y_gp-1:0][hb_ruche_factor_X_gp-1:0][manycore_ruche_link_sif_width_lp-1:0] ruche_link_o

    // north vcache
    , input  [E:W][wh_ruche_factor_gp-1:0][wh_link_sif_width_lp-1:0] north_wh_link_sif_i
    , output [E:W][wh_ruche_factor_gp-1:0][wh_link_sif_width_lp-1:0] north_wh_link_sif_o
    , input [hb_pod_x_cord_width_gp-1:0] north_vcache_pod_x_i
    , input [hb_pod_y_cord_width_gp-1:0] north_vcache_pod_y_i
    , input bsg_tag_s north_bsg_tag_i

    // south vcache
    , input  [E:W][wh_ruche_factor_gp-1:0][wh_link_sif_width_lp-1:0] south_wh_link_sif_i
    , output [E:W][wh_ruche_factor_gp-1:0][wh_link_sif_width_lp-1:0] south_wh_link_sif_o
    , input [hb_pod_x_cord_width_gp-1:0] south_vcache_pod_x_i
    , input [hb_pod_y_cord_width_gp-1:0] south_vcache_pod_y_i
    , input bsg_tag_s south_bsg_tag_i

    // pod cord
    , input [hb_pod_x_cord_width_gp-1:0] pod_x_i
    , input [hb_pod_y_cord_width_gp-1:0] pod_y_i
  );


  bsg_manycore_pod_ruche #(
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

  ) pod (
    .clk_i(clk_i)

    ,.hor_link_sif_i(hor_link_sif_i)
    ,.hor_link_sif_o(hor_link_sif_o)

    ,.ver_link_sif_i(ver_link_sif_i)
    ,.ver_link_sif_o(ver_link_sif_o)

    ,.ruche_link_i(ruche_link_i)
    ,.ruche_link_o(ruche_link_o)

    ,.north_wh_link_sif_i(north_wh_link_sif_i)
    ,.north_wh_link_sif_o(north_wh_link_sif_o)
    ,.north_vcache_pod_x_i(north_vcache_pod_x_i)
    ,.north_vcache_pod_y_i(north_vcache_pod_y_i)
    ,.north_bsg_tag_i(north_bsg_tag_i)

    ,.south_wh_link_sif_i(south_wh_link_sif_i)
    ,.south_wh_link_sif_o(south_wh_link_sif_o)
    ,.south_vcache_pod_x_i(south_vcache_pod_x_i)
    ,.south_vcache_pod_y_i(south_vcache_pod_y_i)
    ,.south_bsg_tag_i(south_bsg_tag_i)

    ,.pod_x_i(pod_x_i)
    ,.pod_y_i(pod_y_i)

  );

endmodule
