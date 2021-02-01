
`include "bp_common_defines.svh"
`include "bp_me_defines.svh"

module bsg_blackparrot_multicore_pod
 import bsg_chip_pkg::*;
 import bsg_mesh_router_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_manycore_pkg::*;
 import bp_common_pkg::*;
 import bp_me_pkg::*;
 #(localparam bp_params_e bp_params_p = bp_cfg_gp
   `declare_bp_proc_params(bp_params_p)

   , localparam coh_noc_ral_link_width_lp = `bsg_ready_and_link_sif_width(coh_noc_flit_width_p)
   , localparam mc_link_sif_width_lp = `bsg_manycore_link_sif_width(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp)
   , localparam mc_ruche_x_link_sif_width_lp = `bsg_manycore_ruche_x_link_sif_width(mc_addr_width_gp,mc_data_width_gp,mc_x_cord_width_gp,mc_y_cord_width_gp)
   )
  (input                                                       bp_clk_i
   , input                                                     bp_reset_i

   , input                                                     mc_clk_i
   , input                                                     mc_reset_i

   , input [pod_y_cord_width_gp-1:0]                           my_y_pod_i

   // We use 4 * 6 = 24 manycore links per BlackParrot pod
   , input [5:0][E:E][mc_ruche_x_link_sif_width_lp-1:0]        mc_ruche_links_i
   , output logic [5:0][E:E][mc_ruche_x_link_sif_width_lp-1:0] mc_ruche_links_o

   , input [23:0][E:E][mc_link_sif_width_lp-1:0]                mc_hor_links_i
   , output logic [23:0][E:E][mc_link_sif_width_lp-1:0]         mc_hor_links_o
   );

  `declare_bsg_manycore_link_sif_s(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp);
  `declare_bsg_ready_and_link_sif_s(coh_noc_flit_width_p, bp_coh_ready_and_link_s);

  bsg_manycore_link_sif_s [5:0][S:N] mc_ver_links_li, mc_ver_links_lo;
  bp_coh_ready_and_link_s [5:0][S:N] bp_lce_req_links_li, bp_lce_req_links_lo;
  bp_coh_ready_and_link_s [5:0][S:N] bp_lce_cmd_links_li, bp_lce_cmd_links_lo;
  bp_coh_ready_and_link_s [5:0][S:N] bp_lce_resp_links_li, bp_lce_resp_links_lo;
  for (genvar i = 0; i < 6; i++)
    begin : n
      bsg_blackparrot_multicore_tile_node
       tile_node
        (.bp_clk_i(bp_clk_i)
         ,.bp_reset_i(bp_reset_i)
         ,.mc_clk_i(mc_clk_i)
         ,.mc_reset_i(mc_reset_i)

         ,.my_y_pod_i(my_y_pod_i)
         ,.my_y_bp_cord_i(bp_y_cord_width_gp'(i))

         ,.mc_ruche_links_i(mc_ruche_links_i[i])
         ,.mc_ruche_links_o(mc_ruche_links_o[i])

         ,.mc_hor_links_i(mc_hor_links_i[4*i+:4])
         ,.mc_hor_links_o(mc_hor_links_o[4*i+:4])

         ,.mc_ver_links_i(mc_ver_links_li[i])
         ,.mc_ver_links_o(mc_ver_links_lo[i])

         ,.bp_lce_req_links_i(bp_lce_req_links_li[i])
         ,.bp_lce_req_links_o(bp_lce_req_links_lo[i])

         ,.bp_lce_cmd_links_i(bp_lce_cmd_links_li[i])
         ,.bp_lce_cmd_links_o(bp_lce_cmd_links_lo[i])

         ,.bp_lce_resp_links_i(bp_lce_resp_links_li[i])
         ,.bp_lce_resp_links_o(bp_lce_resp_links_lo[i])
         );
    end
  assign mc_ver_links_li[0][N] = '0;
  assign mc_ver_links_li[1][N] = mc_ver_links_lo[0][S];
  assign mc_ver_links_li[2][N] = mc_ver_links_lo[1][S];
  assign mc_ver_links_li[3][N] = mc_ver_links_lo[2][S];
  assign mc_ver_links_li[4][N] = mc_ver_links_lo[3][S];
  assign mc_ver_links_li[5][N] = mc_ver_links_lo[4][S];
  //assign mc_ver_links_o[S] = mc_ver_links_lo[5][S];

  assign mc_ver_links_li[5][S] = '0;
  assign mc_ver_links_li[4][S] = mc_ver_links_lo[5][N];
  assign mc_ver_links_li[3][S] = mc_ver_links_lo[4][N];
  assign mc_ver_links_li[2][S] = mc_ver_links_lo[3][N];
  assign mc_ver_links_li[1][S] = mc_ver_links_lo[2][N];
  assign mc_ver_links_li[0][S] = mc_ver_links_lo[1][N];
  //assign mc_ver_links_o[N] = mc_ver_links_lo[0][N];

  assign bp_lce_req_links_li[0][N] = '0;
  assign bp_lce_req_links_li[1][N] = bp_lce_req_links_lo[0][S];
  assign bp_lce_req_links_li[2][N] = bp_lce_req_links_lo[1][S];
  assign bp_lce_req_links_li[3][N] = bp_lce_req_links_lo[2][S];
  assign bp_lce_req_links_li[4][N] = bp_lce_req_links_lo[3][S];
  assign bp_lce_req_links_li[5][N] = bp_lce_req_links_lo[4][S];
  //assign bp_lce_req_links_o[S] = bp_lce_req_links_lo[5][S];

  assign bp_lce_req_links_li[5][S] = '0;
  assign bp_lce_req_links_li[4][S] = bp_lce_req_links_lo[5][N];
  assign bp_lce_req_links_li[3][S] = bp_lce_req_links_lo[4][N];
  assign bp_lce_req_links_li[2][S] = bp_lce_req_links_lo[3][N];
  assign bp_lce_req_links_li[1][S] = bp_lce_req_links_lo[2][N];
  assign bp_lce_req_links_li[0][S] = bp_lce_req_links_lo[1][N];
  //assign bp_lce_req_links_o[N] = bp_lce_req_links_lo[0][N];

  assign bp_lce_cmd_links_li[0][N] = '0;
  assign bp_lce_cmd_links_li[1][N] = bp_lce_cmd_links_lo[0][S];
  assign bp_lce_cmd_links_li[2][N] = bp_lce_cmd_links_lo[1][S];
  assign bp_lce_cmd_links_li[3][N] = bp_lce_cmd_links_lo[2][S];
  assign bp_lce_cmd_links_li[4][N] = bp_lce_cmd_links_lo[3][S];
  assign bp_lce_cmd_links_li[5][N] = bp_lce_cmd_links_lo[4][S];
  //assign bp_lce_cmd_links_o[S] = bp_lce_cmd_links_lo[5][S];

  assign bp_lce_cmd_links_li[5][S] = '0;
  assign bp_lce_cmd_links_li[4][S] = bp_lce_cmd_links_lo[5][N];
  assign bp_lce_cmd_links_li[3][S] = bp_lce_cmd_links_lo[4][N];
  assign bp_lce_cmd_links_li[2][S] = bp_lce_cmd_links_lo[3][N];
  assign bp_lce_cmd_links_li[1][S] = bp_lce_cmd_links_lo[2][N];
  assign bp_lce_cmd_links_li[0][S] = bp_lce_cmd_links_lo[1][N];
  //assign bp_lce_cmd_links_o[N] = bp_lce_cmd_links_lo[0][N];

  assign bp_lce_resp_links_li[0][N] = '0;
  assign bp_lce_resp_links_li[1][N] = bp_lce_resp_links_lo[0][S];
  assign bp_lce_resp_links_li[2][N] = bp_lce_resp_links_lo[1][S];
  assign bp_lce_resp_links_li[3][N] = bp_lce_resp_links_lo[2][S];
  assign bp_lce_resp_links_li[4][N] = bp_lce_resp_links_lo[3][S];
  assign bp_lce_resp_links_li[5][N] = bp_lce_resp_links_lo[4][S];
  //assign bp_lce_resp_links_o[S] = bp_lce_resp_links_lo[5][S];

  assign bp_lce_resp_links_li[5][S] = '0;
  assign bp_lce_resp_links_li[4][S] = bp_lce_resp_links_lo[5][N];
  assign bp_lce_resp_links_li[3][S] = bp_lce_resp_links_lo[4][N];
  assign bp_lce_resp_links_li[2][S] = bp_lce_resp_links_lo[3][N];
  assign bp_lce_resp_links_li[1][S] = bp_lce_resp_links_lo[2][N];
  assign bp_lce_resp_links_li[0][S] = bp_lce_resp_links_lo[1][N];
  //assign bp_lce_resp_links_o[N] = bp_lce_resp_links_lo[0][N];

endmodule


