package bsg_chip_pkg;

  `include "bsg_defines.v"
  import bsg_tag_pkg::*;
  import bsg_noc_pkg::*;

  //////////////////////////////////////////////////
  //
  // BSG CLOCK GENERATOR PARAMETERS
  //

  localparam bsg_link_clk_gen_ds_width_gp      = 6;
  localparam bsg_link_clk_gen_num_adgs_gp      = 1;
  localparam bsg_link_clk_gen_lg_monitor_ds_gp = 5;


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
  localparam ct_harden_small_fifo_gp     = 1;


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

  // Number of tag_en signals needed in the whole system
  // Usually equal to number of chips (Example: ASIC+Gateway)
  // Note: excluding decentralized tag masters
  localparam tag_num_masters_gp = 2;

  // Total number of clients in the whole system
  localparam tag_els_gp = 1024;
  localparam tag_lg_els_gp = `BSG_SAFE_CLOG2(tag_els_gp);

  // maximum payload width in the whole design
  localparam tag_max_payload_width_gp = 12;

  // The number of bits required to represent the max payload width
  localparam tag_lg_width_gp = `BSG_SAFE_CLOG2(tag_max_payload_width_gp + 1);

  typedef struct packed {
    bsg_tag_s monitor_reset;
    bsg_tag_s sel;
    bsg_tag_s ds;
    bsg_tag_s osc_trigger;
    bsg_tag_s osc;
    bsg_tag_s async_reset;
  } bsg_chip_clk_gen_tag_lines_s;
  localparam tag_clk_gen_local_els_gp = $bits(bsg_chip_clk_gen_tag_lines_s)/$bits(bsg_tag_s);

  typedef struct packed {
    bsg_tag_s uplink_reset;
    bsg_tag_s downlink_reset;
    bsg_tag_s downstream_reset;
    bsg_tag_s token_reset;
  } bsg_chip_sdr_tag_lines_s;
  localparam tag_sdr_local_els_gp = $bits(bsg_chip_sdr_tag_lines_s)/$bits(bsg_tag_s);

  typedef struct packed {
    bsg_chip_clk_gen_tag_lines_s noc_clk;
    bsg_chip_clk_gen_tag_lines_s io_clk;
    bsg_tag_s core;
    bsg_tag_s io;
  } bsg_chip_io_link_ddr_tag_lines_s;

  typedef struct packed {
    bsg_tag_s clk;
    bsg_tag_s [2:0] data;
  } bsg_chip_delay_tag_lines_s;

  typedef struct packed {
    bsg_chip_delay_tag_lines_s odelay;
    bsg_chip_delay_tag_lines_s idelay;
    bsg_chip_io_link_ddr_tag_lines_s main;
  } bsg_chip_ddr_tag_lines_s;

  typedef struct packed {
    bsg_chip_sdr_tag_lines_s sdr;
    bsg_tag_s noc_reset;
    bsg_chip_ddr_tag_lines_s [mem_link_rr_ratio_gp-1:0] ddr;
  } bsg_chip_noc_tag_lines_s;
  localparam tag_noc_local_els_gp = $bits(bsg_chip_noc_tag_lines_s)/$bits(bsg_tag_s);

  typedef struct packed {
    bsg_tag_s core_reset;
    bsg_tag_s global_y_cord;
    bsg_tag_s sdr_disable;
    bsg_chip_sdr_tag_lines_s sdr;
  } bsg_chip_halfpod_tag_lines_s;
  localparam tag_halfpod_local_els_gp = $bits(bsg_chip_halfpod_tag_lines_s)/$bits(bsg_tag_s);

  // Warning: Dander Zone
  // Setting parameters below incorrectly may result in chip failure
  //
  // // Struct for reference only
  // typedef struct packed {
  //   bsg_chip_halfpod_tag_lines_s       [7:0] cgra_hp;
  //   bsg_chip_halfpod_tag_lines_s       [7:0] bp_hp;
  //   bsg_chip_clk_gen_tag_lines_s       [7:0] cgra_clk;
  //   bsg_chip_clk_gen_tag_lines_s       [7:0] bp_clk;
  //   bsg_chip_clk_gen_tag_lines_s       [3:0] mc_clk;
  //   bsg_tag_s                     [3:0][3:0] mc_reset;
  //   bsg_chip_sdr_tag_lines_s      [3:0][7:0] mc_sdr;
  //   bsg_chip_noc_tag_lines_s                 io_link;
  //   bsg_chip_noc_tag_lines_s           [7:0] mem_link;
  // } bsg_chip_tag_lines_s;
  //
  localparam tag_mem_link_offset_gp = 0;
  localparam tag_io_link_offset_gp  = tag_mem_link_offset_gp + (8)  *tag_noc_local_els_gp;
  localparam tag_mc_sdr_offset_gp   = tag_io_link_offset_gp  + (1)  *tag_noc_local_els_gp;
  localparam tag_mc_reset_offset_gp = tag_mc_sdr_offset_gp   + (4*4)*(2*tag_sdr_local_els_gp);
  localparam tag_mc_clk_offset_gp   = tag_mc_reset_offset_gp + (4*4)*1;
  localparam tag_bp_clk_offset_gp   = tag_mc_clk_offset_gp   + (4)  *(tag_clk_gen_local_els_gp);
  localparam tag_cgra_clk_offset_gp = tag_bp_clk_offset_gp   + (8)  *(tag_clk_gen_local_els_gp);
  localparam tag_bp_hp_offset_gp    = tag_cgra_clk_offset_gp + (8)  *(tag_clk_gen_local_els_gp);
  localparam tag_cgra_hp_offset_gp  = tag_bp_hp_offset_gp    + (8)  *(tag_halfpod_local_els_gp);

endpackage
