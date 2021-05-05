package bsg_chip_pkg;

  `include "bsg_defines.v"

  //////////////////////////////////////////////////
  //
  // BSG CLOCK GENERATOR PARAMETERS
  //

  localparam bsg_link_clk_gen_ds_width_gp      = 6;
  localparam bsg_link_clk_gen_num_adgs_gp      = 1;


  //////////////////////////////////////////////////
  //
  // BSG CHIP IO PARAMETERS
  //

  localparam mem_link_num_gp = 16;
  localparam io_link_num_gp  = 2;

  localparam bsg_link_channel_width_gp                 = 16;
  localparam bsg_link_num_channels_gp                  = 1;
  localparam bsg_link_width_gp                         = 33;
  localparam bsg_link_lg_fifo_depth_gp                 = 6;
  localparam bsg_link_lg_credit_to_token_decimation_gp = 3;
  localparam bsg_link_use_extra_data_bit_gp            = 1;

  localparam mem_link_rr_ratio_gp = 2;
  localparam mem_link_conc_num_gp = mem_link_num_gp/mem_link_rr_ratio_gp;

  localparam ct_num_in_gp                = 2;
  localparam ct_tag_width_gp             = `BSG_SAFE_CLOG2(ct_num_in_gp + 1);
  localparam ct_width_gp                 = bsg_link_width_gp - ct_tag_width_gp;
  localparam ct_remote_credits_gp        = 64;
  localparam ct_credit_decimation_gp     = ct_remote_credits_gp/4;
  localparam ct_lg_credit_decimation_gp  = `BSG_SAFE_CLOG2(ct_credit_decimation_gp/2+1);
  localparam ct_use_pseudo_large_fifo_gp = 0;


  //////////////////////////////////////////////////
  //
  // HAMMERBLADE PARAMETERS
  //

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

  parameter hb_num_pods_x_gp   = 4;
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


  //////////////////////////////////////////////////
  //
  // SDR PARAMETERS
  //

  parameter sdr_lg_fifo_depth_gp = 3;
  parameter sdr_lg_credit_to_token_decimation_gp = 0;


  //////////////////////////////////////////////////
  //
  // BSG CHIP TAG PARAMETERS
  //

  localparam tag_num_masters_gp = 2;

  // Total number of clients the master will be driving
  localparam tag_els_gp = 1024;
  localparam tag_lg_els_gp = `BSG_SAFE_CLOG2(tag_els_gp);

  // Set maximum payload width to 9-bits
  localparam tag_max_payload_width_gp = 9;

  // The number of bits required to represent the max payload width
  localparam tag_lg_width_gp = `BSG_SAFE_CLOG2(tag_max_payload_width_gp + 1);


endpackage
