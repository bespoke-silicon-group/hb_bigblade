
`include "bp_common_defines.svh"
`include "bp_me_defines.svh"

module bsg_blackparrot_unicore_tile_sdr
 import bsg_chip_pkg::*;
 import blackparrot_chip_pkg::*;
 import bsg_mesh_router_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_manycore_pkg::*;
 import bp_common_pkg::*;
 import bp_me_pkg::*;
 #(localparam bp_params_e bp_params_p = e_bp_bigblade_unicore_cfg
   `declare_bp_proc_params(bp_params_p)

   , localparam io_mem_payload_width_lp   = `bp_bedrock_mem_payload_width(lce_id_width_p, lce_assoc_p)
   , localparam hb_mem_payload_width_lp   = `bp_bedrock_mem_payload_width(lce_id_width_p, lce_assoc_p)
   , localparam uce_mem_payload_width_lp  = `bp_bedrock_mem_payload_width(lce_id_width_p, lce_assoc_p)
   , localparam dram_mem_payload_width_lp = `bp_bedrock_mem_payload_width(lce_id_width_p, lce_assoc_p)

   , localparam fwd_width_lp =
       `bsg_manycore_packet_width(hb_addr_width_gp, hb_data_width_gp, hb_x_cord_width_gp, hb_y_cord_width_gp)
   , localparam rev_width_lp =
       `bsg_manycore_return_packet_width(hb_x_cord_width_gp, hb_y_cord_width_gp, hb_data_width_gp)
   )
  (input                                          clk_i
   , input                                        reset_i

   , input [hb_y_cord_width_gp-1:0]               global_y_cord_i

   , input                                        async_uplink_reset_i
   , input                                        async_downlink_reset_i
   , input                                        async_downstream_reset_i
   , input                                        async_token_reset_i

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
  `declare_bp_bedrock_mem_if(paddr_width_p, dword_width_gp, lce_id_width_p, lce_assoc_p, uce);
  `declare_bp_bedrock_mem_if(paddr_width_p, word_width_gp, lce_id_width_p, lce_assoc_p, dram);

  `declare_bsg_manycore_link_sif_s(hb_addr_width_gp, hb_data_width_gp, hb_x_cord_width_gp, hb_y_cord_width_gp);
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

  bp_bedrock_uce_mem_msg_s io_cmd_lo;
  logic io_cmd_v_lo, io_cmd_ready_li;
  bp_bedrock_uce_mem_msg_s io_resp_li;
  logic io_resp_v_li, io_resp_yumi_lo;
  bp_bedrock_uce_mem_msg_s io_cmd_li;
  logic io_cmd_v_li, io_cmd_yumi_lo;
  bp_bedrock_uce_mem_msg_s io_resp_lo;
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
     ,.io_cmd_ready_and_i(io_cmd_ready_li)

     ,.io_resp_i(io_resp_li)
     ,.io_resp_v_i(io_resp_v_li)
     ,.io_resp_yumi_o(io_resp_yumi_lo)

     ,.io_cmd_i(io_cmd_li)
     ,.io_cmd_v_i(io_cmd_v_li)
     ,.io_cmd_yumi_o(io_cmd_yumi_lo)

     ,.io_resp_o(io_resp_lo)
     ,.io_resp_v_o(io_resp_v_lo)
     ,.io_resp_ready_and_i(io_resp_ready_li)

     ,.mem_cmd_o(mem_cmd_lo)
     ,.mem_cmd_v_o(mem_cmd_v_lo)
     ,.mem_cmd_ready_and_i(mem_cmd_ready_li)

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

  bp_bedrock_io_mem_msg_s hb_cmd_lo;
  logic hb_cmd_v_lo, hb_cmd_ready_li;
  bp_bedrock_io_mem_msg_s hb_resp_li;
  logic hb_resp_v_li, hb_resp_yumi_lo;

  assign hb_cmd_lo = io_cmd_lo;
  assign hb_cmd_v_lo = io_cmd_v_lo;
  assign io_cmd_ready_li = hb_cmd_ready_li;

  assign io_resp_li = hb_resp_li;
  assign io_resp_v_li = hb_resp_v_li;
  assign hb_resp_yumi_lo = io_resp_yumi_lo;

  bp_bedrock_io_mem_msg_s hb_cmd_li;
  logic hb_cmd_v_li, hb_cmd_yumi_lo;
  bp_bedrock_io_mem_msg_s hb_resp_lo;
  logic hb_resp_v_lo, hb_resp_ready_li;

  assign io_cmd_li = hb_cmd_li;
  assign io_cmd_v_li = hb_cmd_v_li;
  assign hb_cmd_yumi_lo = io_cmd_yumi_lo;

  assign hb_resp_lo = io_resp_lo;
  assign hb_resp_v_lo = io_resp_v_lo;
  assign io_resp_ready_li = hb_resp_ready_li;

  //bp_cce_serializer
  // #(.bp_params_p(bp_params_p))
  // io_serializer
  //  (.clk_i(clk_i)
  //   ,.reset_i(reset_r)

  //   ,.io_cmd_i(io_cmd_lo)
  //   ,.io_cmd_v_i(io_cmd_v_lo)
  //   ,.io_cmd_ready_and_o(io_cmd_ready_li)

  //   ,.io_resp_o(io_resp_li)
  //   ,.io_resp_v_o(io_resp_v_li)
  //   ,.io_resp_ready_and_i(io_resp_yumi_lo)

  //   ,.io_cmd_o(hb_cmd_lo)
  //   ,.io_cmd_v_o(hb_cmd_v_lo)
  //   ,.io_cmd_ready_and_i(hb_cmd_ready_li)

  //   ,.io_resp_i(hb_resp_li)
  //   ,.io_resp_v_i(hb_resp_v_li)
  //   ,.io_resp_ready_and_o(hb_resp_ready_and_lo)
  //   );



  wire [hb_x_cord_width_gp-1:0] host_mmio_x_cord_li = '0;
  wire [hb_y_cord_width_gp-1:0] host_mmio_y_cord_li = global_y_cord_i;
  bp_cce_to_mc_bridge
   #(.bp_params_p(bp_params_p)
     ,.host_enable_p(1)
     ,.mc_max_outstanding_p(mc_max_outstanding_host_gp)
     ,.hb_x_cord_width_p(hb_x_cord_width_gp)
     ,.hb_x_subcord_width_p(hb_x_subcord_width_gp)
     ,.hb_pod_x_cord_width_p(hb_pod_x_cord_width_gp)
     ,.hb_y_cord_width_p(hb_y_cord_width_gp)
     ,.hb_y_subcord_width_p(hb_y_subcord_width_gp)
     ,.hb_pod_y_cord_width_p(hb_pod_y_cord_width_gp)
     ,.hb_data_width_p(hb_data_width_gp)
     ,.hb_addr_width_p(hb_addr_width_gp)
     ,.hb_num_vcache_rows_p(num_vcache_rows_gp)
     ,.hb_vcache_block_size_in_words_p(vcache_block_size_in_words_gp)
     ,.hb_vcache_size_p(vcache_size_gp)
     ,.hb_vcache_sets_p(vcache_sets_gp)
     ,.hb_num_tiles_x_p(hb_num_tiles_x_gp)
     ,.hb_num_tiles_y_p(hb_num_tiles_y_gp)
     )
   host_link
    (.clk_i(clk_i)
     ,.reset_i(reset_r)

     ,.io_cmd_i(hb_cmd_lo)
     ,.io_cmd_v_i(hb_cmd_v_lo)
     ,.io_cmd_ready_o(hb_cmd_ready_li)

     ,.io_resp_o(hb_resp_li)
     ,.io_resp_v_o(hb_resp_v_li)
     ,.io_resp_yumi_i(hb_resp_yumi_lo)

     ,.io_cmd_o(hb_cmd_li)
     ,.io_cmd_v_o(hb_cmd_v_li)
     ,.io_cmd_yumi_i(hb_cmd_yumi_lo)

     ,.io_resp_i(hb_resp_lo)
     ,.io_resp_v_i(hb_resp_v_lo)
     ,.io_resp_ready_o(hb_resp_ready_li)

     ,.link_sif_i(proc_link_sif_li[0])
     ,.link_sif_o(proc_link_sif_lo[0])

     ,.my_x_i(host_mmio_x_cord_li)
     ,.my_y_i(host_mmio_y_cord_li)
     );

  for (genvar i = 0; i < 2; i++)
    begin : d
      wire [hb_x_cord_width_gp-1:0] host_dram_x_cord_li = '0;
      wire [hb_y_cord_width_gp-1:0] host_dram_y_cord_li = global_y_cord_i + 1'b1 + i;
      bp_cce_to_mc_bridge
       #(.bp_params_p(bp_params_p)
         ,.host_enable_p(0)
         ,.mc_max_outstanding_p(mc_max_outstanding_dram_gp)
         ,.hb_x_cord_width_p(hb_x_cord_width_gp)
         ,.hb_x_subcord_width_p(hb_x_subcord_width_gp)
         ,.hb_pod_x_cord_width_p(hb_pod_x_cord_width_gp)
         ,.hb_y_cord_width_p(hb_y_cord_width_gp)
         ,.hb_y_subcord_width_p(hb_y_subcord_width_gp)
         ,.hb_pod_y_cord_width_p(hb_pod_y_cord_width_gp)
         ,.hb_data_width_p(hb_data_width_gp)
         ,.hb_addr_width_p(hb_addr_width_gp)
         ,.hb_num_vcache_rows_p(num_vcache_rows_gp)
         ,.hb_vcache_block_size_in_words_p(vcache_block_size_in_words_gp)
         ,.hb_vcache_size_p(vcache_size_gp)
         ,.hb_vcache_sets_p(vcache_sets_gp)
         ,.hb_num_tiles_x_p(hb_num_tiles_x_gp)
         ,.hb_num_tiles_y_p(hb_num_tiles_y_gp)
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

  bsg_manycore_link_sif_s [2:0] ep_link_sif_li, ep_link_sif_lo;     
  for (genvar i = 0; i < 3; i++)
    begin : links
      // Convert credit links to ready
      bsg_manycore_link_resp_credit_to_ready_and_handshake
       #(.addr_width_p(hb_addr_width_gp)
         ,.data_width_p(hb_data_width_gp)
         ,.x_cord_width_p(hb_x_cord_width_gp)
         ,.y_cord_width_p(hb_y_cord_width_gp)
         )
       rev_c2r
        (.clk_i(clk_i)
         ,.reset_i(reset_i)

         ,.credit_link_sif_i(proc_link_sif_lo[i])
         ,.credit_link_sif_o(proc_link_sif_li[i])

         ,.ready_and_link_sif_i(ep_link_sif_li[i])
         ,.ready_and_link_sif_o(ep_link_sif_lo[i])
         );

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

         ,.core_data_i(ep_link_sif_lo[i].fwd.data)
         ,.core_v_i(ep_link_sif_lo[i].fwd.v)
         ,.core_ready_o(ep_link_sif_li[i].fwd.ready_and_rev)

         ,.core_data_o(ep_link_sif_li[i].fwd.data)
         ,.core_v_o(ep_link_sif_li[i].fwd.v)
         ,.core_yumi_i(ep_link_sif_li[i].fwd.v & ep_link_sif_lo[i].fwd.ready_and_rev)

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

         ,.core_data_i(ep_link_sif_lo[i].rev.data)
         ,.core_v_i(ep_link_sif_lo[i].rev.v)
         ,.core_ready_o(ep_link_sif_li[i].rev.ready_and_rev)

         ,.core_data_o(ep_link_sif_li[i].rev.data)
         ,.core_v_o(ep_link_sif_li[i].rev.v)
         ,.core_yumi_i(ep_link_sif_li[i].rev.v & ep_link_sif_lo[i].rev.ready_and_rev)

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

