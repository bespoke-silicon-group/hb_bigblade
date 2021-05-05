
module bsg_gateway_chip_core_complex

 import bsg_chip_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_manycore_pkg::*;

 #(localparam bsg_manycore_link_sif_width_lp =
    `bsg_manycore_link_sif_width(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp)
  ,localparam wh_link_sif_width_lp =
    `bsg_ready_and_link_sif_width(wh_flit_width_gp)
  )

  (input  mc_clk_i
  ,input  tag_trace_done_i

  ,input  [bsg_manycore_link_sif_width_lp-1:0] mc_links_sif_i
  ,output [bsg_manycore_link_sif_width_lp-1:0] mc_links_sif_o

  ,input  [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0][wh_link_sif_width_lp-1:0] wh_links_i
  ,output [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0][wh_link_sif_width_lp-1:0] wh_links_o
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
    ,.io_link_sif_i(mc_links_sif_i)
    ,.io_link_sif_o(mc_links_sif_o)
    ,.loader_done_o()
    ,.print_stat_v_o()
    ,.print_stat_tag_o()
  );


  // wormhole test mem
  // in bytes
  // north + south row of vcache
  localparam longint unsigned mem_size_lp = (2**30)*hb_num_pods_x_gp/wh_ruche_factor_gp/2;
  localparam num_vcaches_per_test_mem_lp = (hb_num_tiles_x_gp*hb_num_pods_x_gp)/wh_ruche_factor_gp/2;

  for (genvar i = 0; i < mem_link_conc_num_gp; i++)
  begin: link
    for (genvar j = N; j <= S; j++)
      begin: ver
        for (genvar r = 0; r < wh_ruche_factor_gp; r++)
          begin: ruche
            bsg_nonsynth_wormhole_test_mem #(
              .vcache_data_width_p(vcache_data_width_gp)
              ,.vcache_dma_data_width_p(vcache_dma_data_width_gp)
              ,.vcache_block_size_in_words_p(vcache_block_size_in_words_gp)
              ,.num_vcaches_p(num_vcaches_per_test_mem_lp)
              ,.wh_cid_width_p(wh_cid_width_gp)
              ,.wh_flit_width_p(wh_flit_width_gp)
              ,.wh_cord_width_p(wh_cord_width_gp)
              ,.wh_len_width_p(wh_len_width_gp)
              ,.wh_ruche_factor_p(wh_ruche_factor_gp)
              ,.no_concentration_p(1)
              ,.mem_size_p(mem_size_lp)
            ) test_mem (
              .clk_i(mc_clk_i)
              ,.reset_i(~tag_trace_done_i)
              ,.wh_link_sif_i(wh_links_i[i][j][r])
              ,.wh_link_sif_o(wh_links_o[i][j][r])
            );
          end
      end
  end

endmodule