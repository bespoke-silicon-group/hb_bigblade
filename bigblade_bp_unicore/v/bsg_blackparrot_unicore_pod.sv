
module bsg_blackparrot_unicore_pod
 import bsg_chip_pkg::*;
 import bsg_mesh_router_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_manycore_pkg::*;
 import bp_common_pkg::*;
 import bp_common_aviary_pkg::*;
 import bp_me_pkg::*;
 #(localparam bp_params_e bp_params_p = bp_cfg_gp
   `declare_bp_proc_params(bp_params_p)
   `declare_bp_bedrock_mem_if_widths(paddr_width_p, cce_block_width_p, lce_id_width_p, lce_assoc_p, cce)

   , localparam mc_link_sif_width_lp = `bsg_manycore_link_sif_width(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp)
   , localparam mc_ruche_x_link_sif_width_lp = `bsg_manycore_ruche_x_link_sif_width(mc_addr_width_gp,mc_data_width_gp,mc_x_cord_width_gp,mc_y_cord_width_gp)
   )
  (input                                                                         bp_clk_i
   , input                                                                       bp_reset_i

   , input                                                                       mc_clk_i
   , input                                                                       mc_reset_i

   , input [pod_y_cord_width_gp-1:0]                                             my_y_pod_i

   // We use 8 manycore links per BlackParrot pod
   , input [1:0][ruche_factor_X_gp-1:0][mc_ruche_x_link_sif_width_lp-1:0]        mc_ruche_links_i
   , output logic [1:0][ruche_factor_X_gp-1:0][mc_ruche_x_link_sif_width_lp-1:0] mc_ruche_links_o

   , input [1:0][E:E][mc_link_sif_width_lp-1:0]                                  mc_hor_links_i
   , output logic [1:0][E:E][mc_link_sif_width_lp-1:0]                           mc_hor_links_o

   , input [S:N][mc_link_sif_width_lp-1:0]                                       mc_ver_links_i
   , output logic [S:N][mc_link_sif_width_lp-1:0]                                mc_ver_links_o
   );

  `declare_bsg_manycore_link_sif_s(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp);

  bsg_manycore_link_sif_s [1:0][S:N] mc_ver_links_li, mc_ver_links_lo;
  bsg_manycore_link_sif_s [1:0][E:E] mc_hor_links_li, mc_hor_links_lo;
  for (genvar i = 0; i < 2; i++)
    begin : n
      bsg_blackparrot_unicore_tile_node
       tile_node
        (.bp_clk_i(bp_clk_i)
         ,.bp_reset_i(bp_reset_i)
         ,.mc_clk_i(mc_clk_i)
         ,.mc_reset_i(mc_reset_i)

         ,.my_y_pod_i(my_y_pod_i)
         ,.my_y_bp_cord_i(bp_y_cord_width_gp'(i))

         ,.mc_ruche_links_i(mc_ruche_links_i[i])
         ,.mc_ruche_links_o(mc_ruche_links_o[i])

         ,.mc_hor_links_i(mc_hor_links_li[i])
         ,.mc_hor_links_o(mc_hor_links_lo[i])

         ,.mc_ver_links_i(mc_ver_links_li[i])
         ,.mc_ver_links_o(mc_ver_links_lo[i])
         );
    end
  assign mc_ver_links_li[0][N] = mc_ver_links_i[N];
  assign mc_ver_links_li[1][N] = mc_ver_links_lo[0][S];
  assign mc_ver_links_o[S] = mc_ver_links_lo[1][S];

  assign mc_ver_links_li[1][S] = mc_ver_links_i[S];
  assign mc_ver_links_li[0][S] = mc_ver_links_lo[1][N];
  assign mc_ver_links_o[N] = mc_ver_links_lo[0][N];

  assign mc_hor_links_li = mc_hor_links_i;
  assign mc_hor_links_o = mc_hor_links_lo;

endmodule

