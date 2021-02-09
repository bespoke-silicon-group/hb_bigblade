
`include "bp_common_defines.svh"
`include "bp_me_defines.svh"

module bsg_blackparrot_unicore_tile_node
 import bsg_chip_pkg::*;
 import bsg_mesh_router_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_manycore_pkg::*;
 import bp_common_pkg::*;
 import bp_me_pkg::*;
 #(localparam bp_params_e bp_params_p = bp_cfg_gp
   , localparam mc_link_sif_width_lp = `bsg_manycore_link_sif_width(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp)
   , localparam mc_ruche_x_link_sif_width_lp = `bsg_manycore_ruche_x_link_sif_width(mc_addr_width_gp,mc_data_width_gp,mc_x_cord_width_gp,mc_y_cord_width_gp)
   )
  (input                                                  bp_clk_i
   , input                                                bp_reset_i

   , input                                                mc_clk_i
   , input                                                mc_reset_i

   , input bsg_tag_s [2:0]                                bsg_tag_i

   , input [2:0][E:E][mc_link_sif_width_lp-1:0]           mc_hor_links_i
   , output logic [2:0][E:E][mc_link_sif_width_lp-1:0]    mc_hor_links_o
   );

  `declare_bsg_manycore_link_sif_s(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp);
  `declare_bsg_manycore_ruche_x_link_sif_s(mc_addr_width_gp,mc_data_width_gp,mc_x_cord_width_gp,mc_y_cord_width_gp);

  wire [mc_x_cord_width_gp-1:0] mc_global_x_li = '0;
  logic [2:0][mc_y_cord_width_gp-1:0] mc_global_y_li;
  for (genvar i = 0; i < 3; i++)
    begin : btc
      bsg_tag_client
       #(.width_p(mc_y_cord_width_gp), .default_p(0))
       btc
        (.bsg_tag_i(bsg_tag_i[i])

         ,.recv_clk_i(bp_clk_i)
         ,.recv_reset_i(1'b0)
         ,.recv_new_r_o()
         ,.recv_data_r_o(mc_global_y_li[i])
         );
    end

  bsg_manycore_link_sif_s [2:0] bp_proc_links_li, bp_proc_links_lo;
  bsg_blackparrot_unicore_tile
   tile
    (.clk_i(bp_clk_i)
     ,.reset_i(bp_reset_i)

     ,.my_mc_y_cords_i(mc_global_y_li)

     ,.links_i(mc_hor_links_i)
     ,.links_o(mc_hor_links_o)
     );

endmodule

