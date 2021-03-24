
`include "bp_common_defines.svh"
`include "bp_me_defines.svh"

module bsg_blackparrot_unicore_tile_sdr
 import bsg_chip_pkg::*;
 import bsg_mesh_router_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_manycore_pkg::*;
 import bp_common_pkg::*;
 import bp_me_pkg::*;
 #(localparam bp_params_e bp_params_p = bp_cfg_gp
   `declare_bp_proc_params(bp_params_p)

   , localparam io_mem_payload_width_lp   = `bp_bedrock_mem_payload_width(lce_id_width_p, lce_assoc_p)
   , localparam mc_mem_payload_width_lp   = `bp_bedrock_mem_payload_width(lce_id_width_p, lce_assoc_p)
   , localparam uce_mem_payload_width_lp  = `bp_bedrock_mem_payload_width(lce_id_width_p, lce_assoc_p)
   , localparam dram_mem_payload_width_lp = `bp_bedrock_mem_payload_width(lce_id_width_p, lce_assoc_p)

   , localparam fwd_width_lp =
       `bsg_manycore_packet_width(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp)
   , localparam rev_width_lp =
       `bsg_manycore_return_packet_width(mc_x_cord_width_gp, mc_y_cord_width_gp, mc_data_width_gp)
   )
  (input                                          clk_i
   , input                                        reset_i

   , input [2:0][mc_y_cord_width_gp-1:0]          global_y_cord_i

   , input                                        async_uplink_reset_i
   , input                                        async_downlink_reset_i
   , input                                        async_downstream_reset_i
   , input                                        async_token_reset_i

   , output logic                                 async_uplink_reset_o
   , output logic                                 async_downlink_reset_o
   , output logic                                 async_downstream_reset_o
   , output logic                                 async_token_reset_o

   , output logic [2:0]                           io_fwd_link_clk_o
   , output logic [2:0][fwd_width_lp-1:0]         io_fwd_link_data_o
   , output logic [2:0]                           io_fwd_link_v_o
   , input [2:0]                                  io_fwd_link_token_i

   , input [2:0]                                  io_fwd_link_clk_i
   , input [2:0][fwd_width_lp-1:0]                io_fwd_link_data_i
   , input [2:0]                                  io_fwd_link_v_i
   , output logic [2:0]                           io_fwd_link_token_o

   , output logic [2:0]                           io_rev_link_clk_o
   , output logic [2:0][rev_width_lp-1:0]         io_rev_link_data_o
   , output logic [2:0]                           io_rev_link_v_o
   , input [2:0]                                  io_rev_link_token_i

   , input [2:0]                                  io_rev_link_clk_i
   , input [2:0][rev_width_lp-1:0]                io_rev_link_data_i
   , input [2:0]                                  io_rev_link_v_i
   , output logic [2:0]                           io_rev_link_token_o
   );

  `declare_bp_bedrock_mem_if(paddr_width_p, word_width_gp, lce_id_width_p, lce_assoc_p, io);
  `declare_bp_bedrock_mem_if(paddr_width_p, word_width_gp, lce_id_width_p, lce_assoc_p, mc);
  `declare_bp_bedrock_mem_if(paddr_width_p, dword_width_gp, lce_id_width_p, lce_assoc_p, uce);
  `declare_bp_bedrock_mem_if(paddr_width_p, word_width_gp, lce_id_width_p, lce_assoc_p, dram);

  `declare_bsg_manycore_link_sif_s(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp);
  bsg_manycore_link_sif_s [2:0] proc_link_sif_li, proc_link_sif_lo;

  // Latch reset to meet timing
  logic reset_r;
  bsg_dff
   #(.width_p(1))
   reset_reg
    (.clk_i(clk_i)
     ,.data_i(reset_i)
     ,.data_o(reset_r)
     );

  logic uplink_reset_sync;
  bsg_sync_sync
   #(.width_p(1))
   up_bss
    (.oclk_i(clk_i)
     ,.iclk_data_i(async_uplink_reset_i)
     ,.oclk_data_o(uplink_reset_sync)
     );

  logic downstream_reset_sync;
  bsg_sync_sync
   #(.width_p(1))
   down_bss
    (.oclk_i(clk_i)
     ,.iclk_data_i(async_downstream_reset_i)
     ,.oclk_data_o(downstream_reset_sync)
     );

  assign async_uplink_reset_o     = async_uplink_reset_i;
  assign async_downlink_reset_o   = async_downlink_reset_i;
  assign async_downstream_reset_o = async_downstream_reset_i;
  assign async_token_reset_o      = async_token_reset_i;

  bp_bedrock_io_mem_msg_s io_cmd_lo;
  logic io_cmd_v_lo, io_cmd_ready_li;
  bp_bedrock_io_mem_msg_s io_resp_li;
  logic io_resp_v_li, io_resp_yumi_lo;
  bp_bedrock_io_mem_msg_s io_cmd_li;
  logic io_cmd_v_li, io_cmd_yumi_lo;
  bp_bedrock_io_mem_msg_s io_resp_lo;
  logic io_resp_v_lo, io_resp_ready_li;
  bp_bedrock_uce_mem_msg_s mem_cmd_lo;
  logic mem_cmd_v_lo, mem_cmd_ready_li;
  bp_bedrock_uce_mem_msg_s mem_resp_li;
  logic mem_resp_v_li, mem_resp_yumi_lo;
  bp_unicore_lite
   #(.bp_params_p(bp_params_p))
   blackparrot
    (.clk_i(clk_i)
     ,.reset_i(reset_r)

     ,.io_cmd_o(io_cmd_lo)
     ,.io_cmd_v_o(io_cmd_v_lo)
     ,.io_cmd_ready_i(io_cmd_ready_li)

     ,.io_resp_i(io_resp_li)
     ,.io_resp_v_i(io_resp_v_li)
     ,.io_resp_yumi_o(io_resp_yumi_lo)

     ,.io_cmd_i(io_cmd_li)
     ,.io_cmd_v_i(io_cmd_v_li)
     ,.io_cmd_yumi_o(io_cmd_yumi_lo)

     ,.io_resp_o(io_resp_lo)
     ,.io_resp_v_o(io_resp_v_lo)
     ,.io_resp_ready_i(io_resp_ready_li)

     ,.mem_cmd_o(mem_cmd_lo)
     ,.mem_cmd_v_o(mem_cmd_v_lo)
     ,.mem_cmd_ready_i(mem_cmd_ready_li)

     ,.mem_resp_i(mem_resp_li)
     ,.mem_resp_v_i(mem_resp_v_li)
     ,.mem_resp_yumi_o(mem_resp_yumi_lo)
     );

  bp_bedrock_dram_mem_msg_s [1:0] dram_cmd_lo;
  logic [1:0] dram_cmd_v_lo, dram_cmd_ready_li;
  bp_bedrock_dram_mem_msg_s [1:0] dram_resp_li;
  logic [1:0] dram_resp_v_li, dram_resp_yumi_lo;
  bp_cce_splitter
   #(.bp_params_p(bp_params_p))
   dram_splitter
    (.clk_i(clk_i)
     ,.reset_i(reset_r)

     ,.io_cmd_i(mem_cmd_lo)
     ,.io_cmd_v_i(mem_cmd_v_lo)
     ,.io_cmd_ready_o(mem_cmd_ready_li)

     ,.io_resp_o(mem_resp_li)
     ,.io_resp_v_o(mem_resp_v_li)
     ,.io_resp_yumi_i(mem_resp_yumi_lo)

     ,.io_cmd_o(dram_cmd_lo)
     ,.io_cmd_v_o(dram_cmd_v_lo)
     ,.io_cmd_ready_i(dram_cmd_ready_li)

     ,.io_resp_i(dram_resp_li)
     ,.io_resp_v_i(dram_resp_v_li)
     ,.io_resp_yumi_o(dram_resp_yumi_lo)
     );

  wire [mc_x_cord_width_gp-1:0] host_mmio_x_cord_li = '0;
  wire [mc_y_cord_width_gp-1:0] host_mmio_y_cord_li = global_y_cord_i[0];
  bp_cce_to_mc_bridge
   #(.bp_params_p(bp_params_p)
     ,.host_enable_p(1)
     ,.mc_max_outstanding_p(mc_max_outstanding_host_gp)
     ,.mc_x_cord_width_p(mc_x_cord_width_gp)
     ,.mc_x_subcord_width_p(mc_x_subcord_width_gp)
     ,.mc_y_cord_width_p(mc_y_cord_width_gp)
     ,.mc_y_subcord_width_p(mc_y_subcord_width_gp)
     ,.mc_data_width_p(mc_data_width_gp)
     ,.mc_addr_width_p(mc_addr_width_gp)
     ,.mc_vcache_block_size_in_words_p(mc_vcache_block_size_in_words_gp)
     ,.mc_vcache_size_p(mc_vcache_size_gp)
     ,.mc_vcache_sets_p(mc_vcache_sets_gp)
     ,.mc_num_tiles_x_p(mc_num_tiles_x_gp)
     ,.mc_num_tiles_y_p(mc_num_tiles_y_gp)
     )
   host_link
    (.clk_i(clk_i)
     ,.reset_i(reset_r)

     ,.io_cmd_i(io_cmd_lo)
     ,.io_cmd_v_i(io_cmd_v_lo)
     ,.io_cmd_ready_o(io_cmd_ready_li)

     ,.io_resp_o(io_resp_li)
     ,.io_resp_v_o(io_resp_v_li)
     ,.io_resp_yumi_i(io_resp_yumi_lo)

     ,.io_cmd_o(io_cmd_li)
     ,.io_cmd_v_o(io_cmd_v_li)
     ,.io_cmd_yumi_i(io_cmd_yumi_lo)

     ,.io_resp_i(io_resp_lo)
     ,.io_resp_v_i(io_resp_v_lo)
     ,.io_resp_ready_o(io_resp_ready_li)

     ,.link_sif_i(proc_link_sif_li[0])
     ,.link_sif_o(proc_link_sif_lo[0])

     ,.my_x_i(host_mmio_x_cord_li)
     ,.my_y_i(host_mmio_y_cord_li)
     );

  for (genvar i = 0; i < 2; i++)
    begin : d
      wire [mc_x_cord_width_gp-1:0] host_dram_x_cord_li = '0;
      wire [mc_y_cord_width_gp-1:0] host_dram_y_cord_li = global_y_cord_i[1+i];
      bp_cce_to_mc_bridge
       #(.bp_params_p(bp_params_p)
         ,.host_enable_p(0)
         ,.mc_max_outstanding_p(mc_max_outstanding_dram_gp)
         ,.mc_x_cord_width_p(mc_x_cord_width_gp)
         ,.mc_x_subcord_width_p(mc_x_subcord_width_gp)
         ,.mc_y_cord_width_p(mc_y_cord_width_gp)
         ,.mc_y_subcord_width_p(mc_y_subcord_width_gp)
         ,.mc_data_width_p(mc_data_width_gp)
         ,.mc_addr_width_p(mc_addr_width_gp)
         ,.mc_vcache_block_size_in_words_p(mc_vcache_block_size_in_words_gp)
         ,.mc_vcache_size_p(mc_vcache_size_gp)
         ,.mc_vcache_sets_p(mc_vcache_sets_gp)
         ,.mc_num_tiles_x_p(mc_num_tiles_x_gp)
         ,.mc_num_tiles_y_p(mc_num_tiles_y_gp)
         )
       dram_link
        (.clk_i(clk_i)
         ,.reset_i(reset_r)

         ,.io_cmd_i(dram_cmd_lo[i])
         ,.io_cmd_v_i(dram_cmd_v_lo[i])
         ,.io_cmd_ready_o(dram_cmd_ready_li[i])

         ,.io_resp_o(dram_resp_li[i])
         ,.io_resp_v_o(dram_resp_v_li[i])
         ,.io_resp_yumi_i(dram_resp_yumi_lo[i])

         ,.io_cmd_o()
         ,.io_cmd_v_o()
         ,.io_cmd_yumi_i('0)

         ,.io_resp_i('0)
         ,.io_resp_v_i('0)
         ,.io_resp_ready_o()

         ,.link_sif_i(proc_link_sif_li[1+i])
         ,.link_sif_o(proc_link_sif_lo[1+i])

         ,.my_x_i(host_dram_x_cord_li)
         ,.my_y_i(host_dram_y_cord_li)
         );
    end

  for (genvar i = 0; i < 3; i++)
    begin : links
      bsg_link_sdr
       #(.width_p(fwd_width_lp)
         ,.lg_fifo_depth_p(sdr_lg_fifo_depth_gp)
         ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_gp)
         )
       fwd_sdr
        (.core_clk_i(clk_i)
         ,.core_uplink_reset_i(uplink_reset_sync)
         ,.core_downstream_reset_i(downstream_reset_sync)
         ,.async_downlink_reset_i(async_downlink_reset_i)
         ,.async_token_reset_i(async_token_reset_i)

         ,.core_data_i(proc_link_sif_lo[i].fwd.data)
         ,.core_v_i(proc_link_sif_lo[i].fwd.v)
         ,.core_ready_o(proc_link_sif_li[i].fwd.ready_and_rev)

         ,.core_data_o(proc_link_sif_li[i].fwd.data)
         ,.core_v_o(proc_link_sif_li[i].fwd.v)
         ,.core_yumi_i(proc_link_sif_li[i].fwd.v & proc_link_sif_lo[i].fwd.ready_and_rev)

         ,.link_clk_o(io_fwd_link_clk_o[i])
         ,.link_data_o(io_fwd_link_data_o[i])
         ,.link_v_o(io_fwd_link_v_o[i])
         ,.link_token_i(io_fwd_link_token_i[i])

         ,.link_clk_i(io_fwd_link_clk_i[i])
         ,.link_data_i(io_fwd_link_data_i[i])
         ,.link_v_i(io_fwd_link_v_i[i])
         ,.link_token_o(io_fwd_link_token_o[i])
         );

      bsg_link_sdr
       #(.width_p(rev_width_lp)
         ,.lg_fifo_depth_p(sdr_lg_fifo_depth_gp)
         ,.lg_credit_to_token_decimation_p(sdr_lg_credit_to_token_decimation_gp)
         )
       rev_sdr
        (.core_clk_i(clk_i)
         ,.core_uplink_reset_i(uplink_reset_sync)
         ,.core_downstream_reset_i(downstream_reset_sync)
         ,.async_downlink_reset_i(async_downlink_reset_i)
         ,.async_token_reset_i(async_token_reset_i)

         ,.core_data_i(proc_link_sif_lo[i].rev.data)
         ,.core_v_i(proc_link_sif_lo[i].rev.v)
         ,.core_ready_o(proc_link_sif_li[i].rev.ready_and_rev)

         ,.core_data_o(proc_link_sif_li[i].rev.data)
         ,.core_v_o(proc_link_sif_li[i].rev.v)
         ,.core_yumi_i(proc_link_sif_li[i].rev.v & proc_link_sif_lo[i].rev.ready_and_rev)

         ,.link_clk_o(io_rev_link_clk_o[i])
         ,.link_data_o(io_rev_link_data_o[i])
         ,.link_v_o(io_rev_link_v_o[i])
         ,.link_token_i(io_rev_link_token_i[i])

         ,.link_clk_i(io_rev_link_clk_i[i])
         ,.link_data_i(io_rev_link_data_i[i])
         ,.link_v_i(io_rev_link_v_i[i])
         ,.link_token_o(io_rev_link_token_o[i])
         );
    end

endmodule

