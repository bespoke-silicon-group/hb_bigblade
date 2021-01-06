`ifndef BSG_CHIP_PKG_V
`define BSG_CHIP_PKG_V

package bsg_chip_pkg;

  `include "bsg_defines.v"
  //`include "bsg_manycore_packet.vh"
  //`include "bsg_cache_dma_pkt.vh"

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

  // FIXME: ADD REAL MAPPING
  localparam int io_link_mapping_gp [4]  = {11,10,1,0};
  localparam int mem_link_mapping_gp[16] = {19,18,17,16,15,14,13,12,9,8,7,6,5,4,3,2};

  localparam io_wh_len_width_gp          = 2;
  localparam io_wh_cord_markers_pos_x_gp = 4;
  localparam io_wh_cord_width_gp         = io_wh_cord_markers_pos_x_gp;

  localparam mem_wh_len_width_gp          = 4;
  localparam mem_wh_cord_markers_pos_x_gp = 6;
  localparam mem_wh_cord_width_gp         = mem_wh_cord_markers_pos_x_gp;

  //////////////////////////////////////////////////
  //
  // BSG CHIP TAG PARAMETERS AND STRUCTS
  //

  // Total number of clients the master will be driving.
  // Set mininum client_id_width to 6-bits (fixed to 6 most of the time)
  localparam tag_num_clients_gp = `BSG_MAX((1<<5)+2, 54);

  localparam tag_max_payload_width_in_io_gp = (`BSG_MAX(io_wh_cord_width_gp, mem_wh_cord_width_gp) + 1);
  localparam tag_max_payload_width_in_clk_gen_pd_gp = `BSG_MAX(clk_gen_ds_width_gp+1, clk_gen_num_adgs_gp+4);

  // Set mininum payload width to 10-bits (fixed to 10 most of the time)
  localparam tag_max_payload_width_gp = `BSG_MAX(tag_max_payload_width_in_io_gp
                                      , `BSG_MAX(tag_max_payload_width_in_clk_gen_pd_gp
                                      , 10));

  // The number of bits required to represent the max payload width
  localparam tag_lg_max_payload_width_gp = `BSG_SAFE_CLOG2(tag_max_payload_width_gp + 1);

endpackage // bsg_chip_pkg

`endif // BSG_CHIP_PKG_V

