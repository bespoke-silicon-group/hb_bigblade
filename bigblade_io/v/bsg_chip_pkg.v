`ifndef BSG_CHIP_PKG_V
`define BSG_CHIP_PKG_V

package bsg_chip_pkg;

  `include "bsg_defines.v"
  import bsg_noc_pkg::*;
  import bsg_tag_pkg::*;

  //////////////////////////////////////////////////
  //
  // BSG CLOCK GENERATOR PARAMETERS
  //

  localparam clk_gen_num_endpoints_gp = 3;
  localparam clk_gen_ds_width_gp      = 6;
  localparam clk_gen_num_adgs_gp      = 1;


  //////////////////////////////////////////////////
  //
  // BSG CHIP IO PARAMETERS
  //

  localparam mem_link_channel_width_gp                 = 8;
  localparam mem_link_num_channels_gp                  = 1;
  localparam mem_link_width_gp                         = 32;
  localparam mem_link_lg_fifo_depth_gp                 = 6;
  localparam mem_link_lg_credit_to_token_decimation_gp = 3;
  localparam mem_link_use_extra_data_bit_gp            = 0;

  localparam io_link_channel_width_gp                 = 8;
  localparam io_link_num_channels_gp                  = 1;
  localparam io_link_width_gp                         = 34;
  localparam io_link_lg_fifo_depth_gp                 = 6;
  localparam io_link_lg_credit_to_token_decimation_gp = 3;
  localparam io_link_use_extra_data_bit_gp            = 1;

  localparam io_ct_num_in_gp                = 2;
  localparam io_ct_tag_width_gp             = `BSG_SAFE_CLOG2(io_ct_num_in_gp + 1);
  localparam io_ct_width_gp                 = io_link_width_gp - io_ct_tag_width_gp;
  localparam io_ct_remote_credits_gp        = 64;
  localparam io_ct_credit_decimation_gp     = io_ct_remote_credits_gp/4;
  localparam io_ct_lg_credit_decimation_gp  = `BSG_SAFE_CLOG2(io_ct_credit_decimation_gp/2+1);
  localparam io_ct_use_pseudo_large_fifo_gp = 1;
  
  `declare_bsg_ready_and_link_sif_s(io_ct_width_gp, bsg_chip_io_link_sif_s);
  `declare_bsg_ready_and_link_sif_s(mem_link_width_gp, bsg_chip_mem_link_sif_s);

  // FIXME: ADD REAL MAPPING
  localparam int io_link_mapping_gp [4]  = {11,10,1,0};
  localparam int mem_link_mapping_gp[16] = {19,18,17,16,15,14,13,12,9,8,7,6,5,4,3,2};


  //////////////////////////////////////////////////
  //
  // HAMMERBLADE PARAMETERS
  //

  parameter hb_num_pods_x_gp   = 4;
  parameter hb_num_pods_y_gp   = 4;

  parameter hb_x_cord_width_gp = 7; // (global X)
  parameter hb_y_cord_width_gp = 7; // (global Y)

  parameter wh_cord_width_gp   = hb_x_cord_width_gp;

  //////////////////////////////////////////////////
  //
  // BSG CHIP TAG PARAMETERS AND STRUCTS
  //

  typedef struct packed {
    bsg_tag_s [1:0] hb_dest_cord;
    bsg_tag_s hb_reset;

    bsg_tag_s [15:0] mem_link_core;
    bsg_tag_s [15:0] mem_link_io;
    bsg_tag_s [15:0] mem_link_sel;
    bsg_tag_s [15:0] mem_link_ds;
    bsg_tag_s [15:0] mem_link_osc_trigger;
    bsg_tag_s [15:0] mem_link_osc;

    bsg_tag_s [3:0] io_link_core;
    bsg_tag_s [3:0] io_link_io;
    bsg_tag_s [3:0] io_link_sel;
    bsg_tag_s [3:0] io_link_ds;
    bsg_tag_s [3:0] io_link_osc_trigger;
    bsg_tag_s [3:0] io_link_osc;

    bsg_tag_s [clk_gen_num_endpoints_gp-1:0] clk_gen_sel;
    bsg_tag_s [clk_gen_num_endpoints_gp-1:0] clk_gen_ds;
    bsg_tag_s [clk_gen_num_endpoints_gp-1:0] clk_gen_osc_trigger;
    bsg_tag_s [clk_gen_num_endpoints_gp-1:0] clk_gen_osc;
    bsg_tag_s async_reset;
  } bsg_chip_tag_lines_s;

  // Total number of clients the master will be driving
  localparam tag_num_masters_gp = 2;
  localparam tag_num_clients_gp = $bits(bsg_chip_tag_lines_s)/$bits(bsg_tag_s);

  localparam tag_max_payload_width_in_hb_gp = wh_cord_width_gp;
  localparam tag_max_payload_width_in_clk_gen_pd_gp = `BSG_MAX(clk_gen_ds_width_gp+1, clk_gen_num_adgs_gp+4);

  // Set mininum payload width to 10-bits (fixed to 10 most of the time)
  localparam tag_max_payload_width_gp = `BSG_MAX(tag_max_payload_width_in_hb_gp
                                      , `BSG_MAX(tag_max_payload_width_in_clk_gen_pd_gp
                                      , 10));

  // The number of bits required to represent the max payload width
  localparam tag_lg_max_payload_width_gp = `BSG_SAFE_CLOG2(tag_max_payload_width_gp + 1);

endpackage // bsg_chip_pkg

`endif // BSG_CHIP_PKG_V

