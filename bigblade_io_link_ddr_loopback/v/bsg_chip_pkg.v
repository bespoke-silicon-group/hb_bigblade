`ifndef BSG_CHIP_PKG_V
`define BSG_CHIP_PKG_V

package bsg_chip_pkg;

  `include "bsg_defines.v"
  `include "bsg_noc_links.vh"
  import bsg_noc_pkg::*;
  import bsg_tag_pkg::*;

  //////////////////////////////////////////////////
  //
  // BSG CLOCK GENERATOR PARAMETERS
  //

  //localparam clk_gen_num_endpoints_gp = 3;
  localparam clk_gen_ds_width_gp      = 6;
  localparam clk_gen_num_adgs_gp      = 1;


  //////////////////////////////////////////////////
  //
  // BSG CHIP IO PARAMETERS
  //

  localparam mem_link_num_gp = 16;
  localparam io_link_num_gp  = 2;

  localparam mem_link_channel_width_gp                 = 16;
  localparam mem_link_num_channels_gp                  = 1;
  localparam mem_link_width_gp                         = 33;
  localparam mem_link_lg_fifo_depth_gp                 = 6;
  localparam mem_link_lg_credit_to_token_decimation_gp = 3;
  localparam mem_link_use_extra_data_bit_gp            = 1;

  localparam mem_link_rr_ratio_gp = 2;
  localparam mem_link_conc_num_gp = mem_link_num_gp/mem_link_rr_ratio_gp;

  localparam io_link_channel_width_gp                 = 16;
  localparam io_link_num_channels_gp                  = 1;
  localparam io_link_width_gp                         = 33;
  localparam io_link_lg_fifo_depth_gp                 = 6;
  localparam io_link_lg_credit_to_token_decimation_gp = 3;
  localparam io_link_use_extra_data_bit_gp            = 1;

  //localparam io_ct_num_in_gp                = 2;
  //localparam io_ct_tag_width_gp             = `BSG_SAFE_CLOG2(io_ct_num_in_gp + 1);
  //localparam io_ct_width_gp                 = io_link_width_gp - io_ct_tag_width_gp;
  //localparam io_ct_remote_credits_gp        = 64;
  //localparam io_ct_credit_decimation_gp     = io_ct_remote_credits_gp/4;
  //localparam io_ct_lg_credit_decimation_gp  = `BSG_SAFE_CLOG2(io_ct_credit_decimation_gp/2+1);
  //localparam io_ct_use_pseudo_large_fifo_gp = 1;

  `declare_bsg_ready_and_link_sif_s(io_link_width_gp, bsg_chip_io_link_sif_s);
  `declare_bsg_ready_and_link_sif_s(mem_link_width_gp, bsg_chip_mem_link_sif_s);


  //////////////////////////////////////////////////
  //
  // HAMMERBLADE PARAMETERS
  //

  parameter hb_x_cord_width_gp = 7; // (global X)
  parameter hb_data_width_gp   = 32;

  parameter vcache_data_width_gp = hb_data_width_gp;
  parameter vcache_block_size_in_words_gp = 8;
  parameter vcache_dma_data_width_gp = hb_data_width_gp;

  // wormhole parameters
  parameter wh_ruche_factor_gp    = 2;
  parameter wh_cid_width_gp       = `BSG_SAFE_CLOG2(2*wh_ruche_factor_gp);
  parameter wh_flit_width_gp      = vcache_dma_data_width_gp;
  parameter wh_cord_width_gp      = hb_x_cord_width_gp;
  parameter wh_len_width_gp       = `BSG_SAFE_CLOG2(1+(vcache_block_size_in_words_gp*vcache_data_width_gp/vcache_dma_data_width_gp)); // header + addr + data

  `declare_bsg_ready_and_link_sif_s(wh_flit_width_gp, bsg_chip_wh_link_sif_s);

  //////////////////////////////////////////////////
  //
  // SDR PARAMETERS
  //

  parameter sdr_lg_fifo_depth_gp = 3;
  parameter sdr_lg_credit_to_token_decimation_gp = 0;


  //////////////////////////////////////////////////
  //
  // BSG CHIP TAG PARAMETERS AND STRUCTS
  //

  //typedef struct packed {
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_core;
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_io;
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_noc_sel;
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_noc_ds;
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_noc_osc_trigger;
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_noc_osc;
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_noc_async_reset;
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_io_sel;
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_io_ds;
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_io_osc_trigger;
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_io_osc;
  //  bsg_tag_s [mem_link_num_gp-1:0] mem_link_io_async_reset;
  //
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_core;
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_io;
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_noc_sel;
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_noc_ds;
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_noc_osc_trigger;
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_noc_osc;
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_noc_async_reset;
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_io_sel;
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_io_ds;
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_io_osc_trigger;
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_io_osc;
  //  bsg_tag_s [io_link_num_gp-1:0] io_link_io_async_reset;
  //} bsg_chip_tag_lines_s;

  // Total number of clients the master will be driving
  localparam tag_num_masters_gp = 2;
  localparam tag_num_clients_gp = 512; //$bits(bsg_chip_tag_lines_s)/$bits(bsg_tag_s);

  // Set mininum payload width to 9-bits
  localparam tag_max_payload_width_gp = 9;

  // The number of bits required to represent the max payload width
  localparam tag_lg_max_payload_width_gp = `BSG_SAFE_CLOG2(tag_max_payload_width_gp + 1);

endpackage // bsg_chip_pkg

`endif // BSG_CHIP_PKG_V
