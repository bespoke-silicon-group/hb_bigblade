
`include "bp_common_defines.svh"
`include "bp_me_defines.svh"

module bsg_blackparrot_unicore_tile_small
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
   , localparam mc_link_sif_width_lp      = `bsg_manycore_link_sif_width(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp)
   )
  (input                                          clk_i
   , input                                        reset_i

   , input bsg_tag_s [1:0]                        bsg_tag_i

   , input [1:0][mc_link_sif_width_lp-1:0]        links_i
   , output logic [1:0][mc_link_sif_width_lp-1:0] links_o
   );

  `declare_bp_bedrock_mem_if(paddr_width_p, word_width_gp, lce_id_width_p, lce_assoc_p, io);
  `declare_bp_bedrock_mem_if(paddr_width_p, word_width_gp, lce_id_width_p, lce_assoc_p, mc);
  `declare_bp_bedrock_mem_if(paddr_width_p, dword_width_gp, lce_id_width_p, lce_assoc_p, uce);
  `declare_bp_bedrock_mem_if(paddr_width_p, word_width_gp, lce_id_width_p, lce_assoc_p, dram);

  // Latch reset to meet timing
  logic reset_r;
  bsg_dff
   #(.width_p(1))
   reset_reg
    (.clk_i(clk_i)
     ,.data_i(reset_i)
     ,.data_o(reset_r)
     );

  wire [mc_x_cord_width_gp-1:0] mc_global_x_li = '0;
  logic [1:0][mc_y_cord_width_gp-1:0] mc_global_y_li;
  for (genvar i = 0; i < 2; i++)
    begin : btc
      bsg_tag_client
       #(.width_p(mc_y_cord_width_gp), .default_p(0))
       btc
        (.bsg_tag_i(bsg_tag_i[i])

         ,.recv_clk_i(clk_i)
         ,.recv_reset_i(1'b0)
         ,.recv_new_r_o()
         ,.recv_data_r_o(mc_global_y_li[i])
         );
    end

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

  bp_bedrock_dram_mem_msg_s dram_cmd_lo;
  logic dram_cmd_v_lo, dram_cmd_ready_li;
  bp_bedrock_dram_mem_msg_s dram_resp_li;
  logic dram_resp_v_li, dram_resp_yumi_lo;
  bp_cce_serializer
   #(.bp_params_p(bp_params_p))
   dram_serilizer
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
  wire [mc_y_cord_width_gp-1:0] host_mmio_y_cord_li = mc_global_y_li[0];
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

     ,.link_sif_i(links_i[0])
     ,.link_sif_o(links_o[0])

     ,.my_x_i(host_mmio_x_cord_li)
     ,.my_y_i(host_mmio_y_cord_li)
     );

  wire [mc_x_cord_width_gp-1:0] host_dram_x_cord_li = '0;
  wire [mc_y_cord_width_gp-1:0] host_dram_y_cord_li = mc_global_y_li[1];
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

     ,.io_cmd_i(dram_cmd_lo)
     ,.io_cmd_v_i(dram_cmd_v_lo)
     ,.io_cmd_ready_o(dram_cmd_ready_li)

     ,.io_resp_o(dram_resp_li)
     ,.io_resp_v_o(dram_resp_v_li)
     ,.io_resp_yumi_i(dram_resp_yumi_lo)

     ,.io_cmd_o()
     ,.io_cmd_v_o()
     ,.io_cmd_yumi_i('0)

     ,.io_resp_i('0)
     ,.io_resp_v_i('0)
     ,.io_resp_ready_o()

     ,.link_sif_i(links_i[1])
     ,.link_sif_o(links_o[1])

     ,.my_x_i(host_dram_x_cord_li)
     ,.my_y_i(host_dram_y_cord_li)
     );

endmodule

