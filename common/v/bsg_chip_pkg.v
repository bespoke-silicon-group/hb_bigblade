package bsg_chip_pkg;
  
  `include "bsg_defines.v"

  // clock generator parameters
  localparam clk_gen_ds_width_gp = 6;
  localparam clk_gen_num_adgs_gp = 1;

  // manycore parameters
  // x_cord_width_gp = pod_x_cord_width_gp + hb_x_subcord_width_gp
  parameter hb_x_cord_width_gp = 7; // (global X)
  parameter hb_y_cord_width_gp = 7; // (global Y)
  parameter hb_pod_x_cord_width_gp = 3;
  parameter hb_pod_y_cord_width_gp = 4;
  parameter hb_num_tiles_x_gp  = 16;
  parameter hb_num_tiles_y_gp  = 8;
  parameter hb_x_subcord_width_gp = `BSG_SAFE_CLOG2(hb_num_tiles_x_gp);
  parameter hb_y_subcord_width_gp = `BSG_SAFE_CLOG2(hb_num_tiles_y_gp);
  parameter hb_addr_width_gp   = 28; // word addr
  parameter hb_data_width_gp   = 32;

  parameter hb_num_pods_x_gp   = 1;
  parameter hb_num_pods_y_gp   = 4;

  parameter hb_num_subarray_x_gp = 1;
  parameter hb_num_subarray_y_gp = 4;

  parameter hb_dmem_size_gp           = 1024;
  parameter hb_icache_entries_gp      = 1024;
  parameter hb_icache_tag_width_gp    = 12;

  parameter hb_ruche_factor_X_gp       = 3;

  parameter num_vcache_rows_gp = 1;
  parameter vcache_addr_width_gp = hb_addr_width_gp+`BSG_SAFE_CLOG2(hb_data_width_gp>>3)-1; // byte addr width
  parameter vcache_ways_gp = 4;
  parameter vcache_sets_gp = 64;
  parameter vcache_data_width_gp = hb_data_width_gp;
  parameter vcache_block_size_in_words_gp = 8;
  parameter vcache_size_gp = vcache_ways_gp*vcache_sets_gp*vcache_block_size_in_words_gp; // in # of words
  parameter vcache_dma_data_width_gp = hb_data_width_gp;


  parameter wh_ruche_factor_gp    = 2;
  parameter wh_cid_width_gp       = `BSG_SAFE_CLOG2(wh_ruche_factor_gp*2);
  parameter wh_flit_width_gp      = vcache_dma_data_width_gp;
  parameter wh_cord_width_gp      = hb_x_cord_width_gp;
  parameter wh_len_width_gp       = `BSG_SAFE_CLOG2(1+(vcache_block_size_in_words_gp*vcache_data_width_gp/vcache_dma_data_width_gp)); // header + addr + data

  parameter sdr_lg_fifo_depth_gp = 3;
  parameter sdr_lg_credit_to_token_decimation_gp = 0;

endpackage
