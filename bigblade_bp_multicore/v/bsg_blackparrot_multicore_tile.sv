
`include "bp_common_defines.svh"
`include "bp_me_defines.svh"

module bsg_blackparrot_multicore_tile
 import bsg_chip_pkg::*;
 import bsg_mesh_router_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_manycore_pkg::*;
 import bp_common_pkg::*;
 import bp_me_pkg::*;
 #(localparam bp_params_e bp_params_p = bp_cfg_gp
   `declare_bp_proc_params(bp_params_p)
   `declare_bp_bedrock_lce_if_widths(paddr_width_p, cce_block_width_p, lce_id_width_p, cce_id_width_p, lce_assoc_p, lce)

   , localparam cce_mem_payload_width_lp  = `bp_bedrock_mem_payload_width(lce_id_width_p, lce_assoc_p)
   , localparam io_mem_payload_width_lp   = `bp_bedrock_mem_payload_width(lce_id_width_p, lce_assoc_p)
   , localparam dram_mem_payload_width_lp = `bp_bedrock_mem_payload_width(lce_id_width_p, lce_assoc_p)
   , localparam mc_link_sif_width_lp      = `bsg_manycore_link_sif_width(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp)
   , localparam coh_noc_ral_link_width_lp = `bsg_ready_and_link_sif_width(coh_noc_flit_width_p)
   )
  (input                                                clk_i
   , input                                              reset_i

   , input [2:0][mc_y_cord_width_gp-1:0]                my_mc_y_cords_i
   , input [coh_noc_cord_width_p-1:0]                   my_bp_cord_i

   , input [2:0][mc_link_sif_width_lp-1:0]              mc_links_i
   , output logic [2:0][mc_link_sif_width_lp-1:0]       mc_links_o

   , input [S:N][coh_noc_ral_link_width_lp-1:0]         lce_req_links_i
   , output logic [S:N][coh_noc_ral_link_width_lp-1:0]  lce_req_links_o

   , input [S:N][coh_noc_ral_link_width_lp-1:0]         lce_cmd_links_i
   , output logic [S:N][coh_noc_ral_link_width_lp-1:0]  lce_cmd_links_o

   , input [S:N][coh_noc_ral_link_width_lp-1:0]         lce_resp_links_i
   , output logic [S:N][coh_noc_ral_link_width_lp-1:0]  lce_resp_links_o
   );

  `declare_bsg_ready_and_link_sif_s(coh_noc_flit_width_p, bp_coh_ready_and_link_s);
  `declare_bp_bedrock_mem_if(paddr_width_p, cce_block_width_p, lce_id_width_p, lce_assoc_p, cce);
  `declare_bp_bedrock_mem_if(paddr_width_p, word_width_gp, lce_id_width_p, lce_assoc_p, io);
  `declare_bp_bedrock_mem_if(paddr_width_p, word_width_gp, lce_id_width_p, lce_assoc_p, dram);
  `declare_bp_bedrock_lce_if(paddr_width_p, cce_block_width_p, lce_id_width_p, cce_id_width_p, lce_assoc_p, lce);
  `declare_bsg_wormhole_concentrator_packet_s(coh_noc_cord_width_p, coh_noc_len_width_p, coh_noc_cid_width_p, lce_cmd_msg_width_lp, lce_cmd_packet_s);

  // Latch reset to meet timing
  logic reset_r;
  bsg_dff
   #(.width_p(1))
   reset_reg
    (.clk_i(clk_i)
     ,.data_i(reset_i)
     ,.data_o(reset_r)
     );

  bp_coh_ready_and_link_s [S:P] lce_req_link_li, lce_req_link_lo;
  bp_coh_ready_and_link_s [S:P] lce_cmd_link_li, lce_cmd_link_lo;
  bp_coh_ready_and_link_s [S:P] lce_resp_link_li, lce_resp_link_lo;
  bp_bedrock_cce_mem_msg_s mem_cmd_lo;
  logic mem_cmd_v_lo, mem_cmd_ready_li;
  bp_bedrock_cce_mem_msg_s mem_resp_li;
  logic mem_resp_v_li, mem_resp_yumi_lo;
  bp_tile_lite
   #(.bp_params_p(bp_params_p))
   tile
    (.clk_i(clk_i)
     ,.reset_i(reset_r)

     ,.my_cord_i(my_bp_cord_i)

     ,.lce_req_link_i(lce_req_link_lo[P])
     ,.lce_req_link_o(lce_req_link_li[P])

     ,.lce_cmd_link_i(lce_cmd_link_lo[P])
     ,.lce_cmd_link_o(lce_cmd_link_li[P])

     ,.lce_resp_link_i(lce_resp_link_lo[P])
     ,.lce_resp_link_o(lce_resp_link_li[P])

     ,.mem_cmd_o(mem_cmd_lo)
     ,.mem_cmd_v_o(mem_cmd_v_lo)
     ,.mem_cmd_ready_i(mem_cmd_ready_li)

     ,.mem_resp_i(mem_resp_li)
     ,.mem_resp_v_i(mem_resp_v_li)
     ,.mem_resp_yumi_o(mem_resp_yumi_lo)
     );

  bp_nd_socket
   #(.flit_width_p(coh_noc_flit_width_p)
     ,.len_width_p(coh_noc_len_width_p)
     ,.dims_p(coh_noc_dims_p)
     ,.cord_dims_p(coh_noc_dims_p)
     ,.cord_markers_pos_p(coh_noc_cord_markers_pos_p)
     ,.els_p(3)
     )
   coh_routers
    (.tile_clk_i(clk_i)
     ,.tile_reset_i(reset_r)

     ,.network_clk_i(clk_i)
     ,.network_reset_i(reset_r)

     ,.my_cord_i(my_bp_cord_i)

     ,.network_link_i({lce_resp_link_li[S:W], lce_cmd_link_li[S:W], lce_req_link_li[S:W]})
     ,.network_link_o({lce_resp_link_lo[S:W], lce_cmd_link_lo[S:W], lce_req_link_lo[S:W]})

     ,.tile_link_i({lce_resp_link_li[P], lce_cmd_link_li[P], lce_req_link_li[P]})
     ,.tile_link_o({lce_resp_link_lo[P], lce_cmd_link_lo[P], lce_req_link_lo[P]})
     );
  // Stub south links
  assign lce_req_link_li[S]  = '0;
  assign lce_cmd_link_li[S]  = '0;
  assign lce_resp_link_li[S] = '0;

  // Transpose W to N
  assign lce_req_link_li[W] = lce_req_links_i[N];
  assign lce_cmd_link_li[W] = lce_cmd_links_i[N];
  assign lce_resp_link_li[W] = lce_resp_links_i[N];
  assign lce_req_links_o[N] = lce_req_link_lo[W];
  assign lce_cmd_links_o[N] = lce_cmd_link_lo[W];
  assign lce_resp_links_o[N] = lce_resp_link_lo[W];

  // Transpose E to S
  assign lce_req_link_li[E] = lce_req_links_i[S];
  assign lce_cmd_link_li[E] = lce_cmd_links_i[S];
  assign lce_resp_link_li[E] = lce_resp_links_i[S];
  assign lce_req_links_o[S] = lce_req_link_lo[E];
  assign lce_cmd_links_o[S] = lce_cmd_link_lo[E];
  assign lce_resp_links_o[S] = lce_resp_link_lo[E];

  // Stub N LCE resp
  assign lce_resp_link_li[N] = '0;
  // Other North links go to I/O
  bp_bedrock_lce_req_msg_s  cce_lce_req_li, lce_lce_req_lo;
  logic cce_lce_req_v_li, cce_lce_req_yumi_lo, lce_lce_req_v_lo, lce_lce_req_ready_li;
  bp_bedrock_lce_cmd_msg_s cce_lce_cmd_lo, lce_lce_cmd_li;
  logic cce_lce_cmd_v_lo, cce_lce_cmd_ready_li, lce_lce_cmd_v_li, lce_lce_cmd_yumi_lo;

  bp_bedrock_cce_mem_msg_s cce_io_cmd_lo, lce_io_cmd_li;
  logic cce_io_cmd_v_lo, cce_io_cmd_ready_li, lce_io_cmd_v_li, lce_io_cmd_yumi_lo;
  bp_bedrock_cce_mem_msg_s cce_io_resp_li, lce_io_resp_lo;
  logic cce_io_resp_v_li, cce_io_resp_yumi_lo, lce_io_resp_v_lo, lce_io_resp_ready_li;

  bp_bedrock_io_mem_msg_s mmio_cmd_lo;
  logic mmio_cmd_v_lo, mmio_cmd_ready_li;
  bp_bedrock_io_mem_msg_s mmio_resp_li;
  logic mmio_resp_v_li, mmio_resp_yumi_lo;

  bp_bedrock_io_mem_msg_s mmio_cmd_li;
  logic mmio_cmd_v_li, mmio_cmd_yumi_lo;
  bp_bedrock_io_mem_msg_s mmio_resp_lo;
  logic mmio_resp_v_lo, mmio_resp_ready_li;

  `declare_bp_lce_req_wormhole_packet_s(coh_noc_flit_width_p, coh_noc_cord_width_p, coh_noc_len_width_p, coh_noc_cid_width_p, bp_bedrock_lce_req_msg_header_s, cce_block_width_p);
  bp_lce_req_wormhole_packet_s lce_req_packet_li, lce_req_packet_lo;
  bp_lce_req_wormhole_header_s lce_req_header_li, lce_req_header_lo;
  bp_me_wormhole_packet_encode_lce_req
   #(.bp_params_p(bp_params_p))
   req_encode
    (.lce_req_header_i(lce_lce_req_lo.header)
     ,.wh_header_o(lce_req_header_lo)
     );
  assign lce_req_packet_lo = '{header: lce_req_header_lo, data: lce_lce_req_lo.data};

  localparam lce_req_wh_payload_width_lp = `bp_coh_wormhole_payload_width(coh_noc_flit_width_p, coh_noc_cord_width_p, coh_noc_len_width_p, coh_noc_cid_width_p, $bits(bp_bedrock_lce_req_msg_header_s), cce_block_width_p);
  bsg_wormhole_router_adapter
   #(.max_payload_width_p(lce_req_wh_payload_width_lp)
     ,.len_width_p(coh_noc_len_width_p)
     ,.cord_width_p(coh_noc_cord_width_p)
     ,.flit_width_p(coh_noc_flit_width_p)
     )
   lce_req_adapter
    (.clk_i(clk_i)
     ,.reset_i(reset_r)

     ,.packet_i(lce_req_packet_lo)
     ,.v_i(lce_lce_req_v_lo)
     ,.ready_o(lce_lce_req_ready_li)

     ,.link_i(lce_req_link_lo[N])
     ,.link_o(lce_req_link_li[N])

     ,.packet_o(lce_req_packet_li)
     ,.v_o(cce_lce_req_v_li)
     ,.yumi_i(cce_lce_req_yumi_lo)
     );
  assign cce_lce_req_li = '{header: lce_req_packet_li.header.msg_hdr, data: lce_req_packet_li.data};

  `declare_bp_lce_cmd_wormhole_packet_s(coh_noc_flit_width_p, coh_noc_cord_width_p, coh_noc_len_width_p, coh_noc_cid_width_p, bp_bedrock_lce_cmd_msg_header_s, cce_block_width_p);
  bp_lce_cmd_wormhole_packet_s lce_cmd_packet_li, lce_cmd_packet_lo;
  bp_lce_cmd_wormhole_header_s lce_cmd_header_li, lce_cmd_header_lo;
  bp_me_wormhole_packet_encode_lce_cmd
   #(.bp_params_p(bp_params_p))
   cmd_encode
    (.lce_cmd_header_i(cce_lce_cmd_lo.header)
     ,.wh_header_o(lce_cmd_header_lo)
     );
  assign lce_cmd_packet_lo = '{header: lce_cmd_header_lo, data: cce_lce_cmd_lo.data};

  localparam lce_cmd_wh_payload_width_lp = `bp_coh_wormhole_payload_width(coh_noc_flit_width_p, coh_noc_cord_width_p, coh_noc_len_width_p, coh_noc_cid_width_p, $bits(bp_bedrock_lce_cmd_msg_header_s), cce_block_width_p);
  bsg_wormhole_router_adapter
   #(.max_payload_width_p(lce_cmd_wh_payload_width_lp)
     ,.len_width_p(coh_noc_len_width_p)
     ,.cord_width_p(coh_noc_cord_width_p)
     ,.flit_width_p(coh_noc_flit_width_p)
     )
   lce_cmd_adapter
    (.clk_i(clk_i)
     ,.reset_i(reset_r)

     ,.packet_i(lce_cmd_packet_lo)
     ,.v_i(cce_lce_cmd_v_lo)
     ,.ready_o(cce_lce_cmd_ready_li)

     ,.link_i(lce_cmd_link_lo[N])
     ,.link_o(lce_cmd_link_li[N])

     ,.packet_o(lce_cmd_packet_li)
     ,.v_o(lce_lce_cmd_v_li)
     ,.yumi_i(lce_lce_cmd_yumi_lo)
     );
  assign lce_lce_cmd_li = '{header: lce_cmd_packet_li.header.msg_hdr, data: lce_cmd_packet_li.data};

  logic [cce_id_width_p-1:0]  cce_id_li;
  logic [lce_id_width_p-1:0]  lce_id_li;
  bp_me_cord_to_id
   #(.bp_params_p(bp_params_p))
   id_map
    (.cord_i(my_bp_cord_i)
     ,.core_id_o()
     ,.cce_id_o(cce_id_li)
     ,.lce_id0_o(lce_id_li)
     ,.lce_id1_o()
     );

  bp_io_link_to_lce
   #(.bp_params_p(bp_params_p))
   lce_link
    (.clk_i(clk_i)
     ,.reset_i(reset_r)

     ,.lce_id_i(lce_id_li)

     ,.io_cmd_i(lce_io_cmd_li)
     ,.io_cmd_v_i(lce_io_cmd_v_li)
     ,.io_cmd_yumi_o(lce_io_cmd_yumi_lo)

     ,.io_resp_o(lce_io_resp_lo)
     ,.io_resp_v_o(lce_io_resp_v_lo)
     ,.io_resp_ready_i(lce_io_resp_ready_li)

     ,.lce_req_o(lce_lce_req_lo)
     ,.lce_req_v_o(lce_lce_req_v_lo)
     ,.lce_req_ready_i(lce_lce_req_ready_li)

     ,.lce_cmd_i(lce_lce_cmd_li)
     ,.lce_cmd_v_i(lce_lce_cmd_v_li)
     ,.lce_cmd_yumi_o(lce_lce_cmd_yumi_lo)
     );

  bp_io_cce
   #(.bp_params_p(bp_params_p))
   io_cce
    (.clk_i(clk_i)
     ,.reset_i(reset_r)

     ,.cce_id_i(cce_id_li)

     ,.lce_req_i(cce_lce_req_li)
     ,.lce_req_v_i(cce_lce_req_v_li)
     ,.lce_req_yumi_o(cce_lce_req_yumi_lo)

     ,.lce_cmd_o(cce_lce_cmd_lo)
     ,.lce_cmd_v_o(cce_lce_cmd_v_lo)
     ,.lce_cmd_ready_i(cce_lce_cmd_ready_li)

     ,.io_cmd_o(cce_io_cmd_lo)
     ,.io_cmd_v_o(cce_io_cmd_v_lo)
     ,.io_cmd_ready_i(cce_io_cmd_ready_li)

     ,.io_resp_i(cce_io_resp_li)
     ,.io_resp_v_i(cce_io_resp_v_li)
     ,.io_resp_yumi_o(cce_io_resp_yumi_lo)
     );

  // TODO: Better arbitration? Loopback?
  wire [3:0] device_cmd_li = cce_io_cmd_lo.header.addr[20+:4];

  assign mmio_cmd_lo = cce_io_cmd_lo;
  assign mmio_cmd_v_lo = cce_io_cmd_v_lo;
  assign cce_io_cmd_ready_li = mmio_cmd_ready_li;

  assign cce_io_resp_li = mmio_resp_li;
  assign cce_io_resp_v_li = mmio_resp_v_li;
  assign mmio_resp_yumi_lo = mmio_resp_v_li & cce_io_resp_yumi_lo;

  assign lce_io_cmd_li = mmio_cmd_li;
  assign lce_io_cmd_v_li = mmio_cmd_v_li;
  assign mmio_cmd_yumi_lo = lce_io_cmd_yumi_lo;

  assign mmio_resp_lo = lce_io_resp_lo;
  assign mmio_resp_v_lo = lce_io_resp_v_lo;
  assign lce_io_resp_ready_li = mmio_resp_ready_li;

  wire [mc_x_cord_width_gp-1:0] host_mmio_x_cord_li = '0;
  wire [mc_y_cord_width_gp-1:0] host_mmio_y_cord_li = my_mc_y_cords_i[0];
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

     ,.io_cmd_i(mmio_cmd_lo)
     ,.io_cmd_v_i(mmio_cmd_v_lo)
     ,.io_cmd_ready_o(mmio_cmd_ready_li)

     ,.io_resp_o(mmio_resp_li)
     ,.io_resp_v_o(mmio_resp_v_li)
     ,.io_resp_yumi_i(mmio_resp_yumi_lo)

     ,.io_cmd_o(mmio_cmd_li)
     ,.io_cmd_v_o(mmio_cmd_v_li)
     ,.io_cmd_yumi_i(mmio_cmd_yumi_lo)

     ,.io_resp_i(mmio_resp_lo)
     ,.io_resp_v_i(mmio_resp_v_lo)
     ,.io_resp_ready_o(mmio_resp_ready_li)

     ,.link_sif_i(mc_links_i[0])
     ,.link_sif_o(mc_links_o[0])

     ,.my_x_i(host_mmio_x_cord_li)
     ,.my_y_i(host_mmio_y_cord_li)
     );

  // TODO: Non-functional, actually split into multiple requests using stream
  bp_bedrock_dram_mem_msg_s [1:0] dram_cmd_lo;
  logic [1:0] dram_cmd_v_lo, dram_cmd_ready_li;
  bp_bedrock_dram_mem_msg_s [1:0] dram_resp_li;
  logic [1:0] dram_resp_v_li, dram_resp_yumi_lo;
  assign dram_cmd_lo[0] = mem_cmd_lo;
  assign dram_cmd_v_lo[0] = mem_cmd_v_lo;
  assign dram_cmd_lo[1] = mem_cmd_lo;
  assign dram_cmd_v_lo[1] = mem_cmd_v_lo;
  assign mem_cmd_ready_li = &dram_cmd_ready_li;

  assign mem_resp_li = dram_resp_v_li[0] ? dram_resp_li[0] : dram_resp_li[1];
  assign mem_resp_v_li = |dram_resp_v_li;
  assign dram_resp_yumi_lo[0] = |(dram_resp_v_li & {2{mem_resp_yumi_lo}});

  for (genvar i = 0; i < 2; i++)
    begin : d
      wire [mc_x_cord_width_gp-1:0] host_dram_x_cord_li = '0;
      wire [mc_y_cord_width_gp-1:0] host_dram_y_cord_li = my_mc_y_cords_i[2+i];
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

         ,.link_sif_i(mc_links_i[1+i])
         ,.link_sif_o(mc_links_o[1+i])

         ,.my_x_i(host_dram_x_cord_li)
         ,.my_y_i(host_dram_y_cord_li)
         );
    end

endmodule

