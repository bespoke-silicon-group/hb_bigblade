
module bsg_blackparrot_unicore_tile_node
 import bsg_chip_pkg::*;
 import bsg_mesh_router_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_manycore_pkg::*;
 import bp_common_pkg::*;
 import bp_common_aviary_pkg::*;
 import bp_me_pkg::*;
 #(localparam bp_params_e bp_params_p = bp_cfg_gp
   , localparam mc_link_sif_width_lp = `bsg_manycore_link_sif_width(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp)
   , localparam mc_ruche_x_link_sif_width_lp = `bsg_manycore_ruche_x_link_sif_width(mc_addr_width_gp,mc_data_width_gp,mc_x_cord_width_gp,mc_y_cord_width_gp)
   )
  (input                                                  bp_clk_i
   , input                                                bp_reset_i

   , input                                                mc_clk_i
   , input                                                mc_reset_i

   , input [pod_y_cord_width_gp-1:0]                      my_y_pod_i
   , input [bp_y_cord_width_gp-1:0]                       my_y_bp_cord_i

   , input [E:E][mc_ruche_x_link_sif_width_lp-1:0]        mc_ruche_links_i
   , output logic [E:E][mc_ruche_x_link_sif_width_lp-1:0] mc_ruche_links_o

   , input [E:E][mc_link_sif_width_lp-1:0]                mc_hor_links_i
   , output logic [E:E][mc_link_sif_width_lp-1:0]         mc_hor_links_o

   , input [S:N][mc_link_sif_width_lp-1:0]                mc_ver_links_i
   , output logic [S:N][mc_link_sif_width_lp-1:0]         mc_ver_links_o
   );

  `declare_bsg_manycore_link_sif_s(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp);
  `declare_bsg_manycore_ruche_x_link_sif_s(mc_addr_width_gp,mc_data_width_gp,mc_x_cord_width_gp,mc_y_cord_width_gp);

  wire [mc_x_cord_width_gp-1:0] mc_global_x_li = '0;
  logic [3:0][mc_y_cord_width_gp-1:0] mc_global_y_li;
  for (genvar i = 0; i < 4; i++)
    begin : rof1
      wire [mc_y_subcord_width_gp-1:0] y_subcord_li = (my_y_bp_cord_i << 2'b10) + i;
      assign mc_global_y_li[i] = {my_y_pod_i, y_subcord_li};
    end

  bsg_manycore_link_sif_s [3:0] bp_proc_links_li, bp_proc_links_lo;
  bsg_blackparrot_unicore_tile
   tile
    (.clk_i(bp_clk_i)
     ,.reset_i(bp_reset_i)

     ,.my_mc_y_cords_i(mc_global_y_li)

     ,.links_i(bp_proc_links_li)
     ,.links_o(bp_proc_links_lo)
     );

  bsg_manycore_link_sif_s [3:0][E:W] mc_hor_links_li, mc_hor_links_lo;
  bsg_manycore_ruche_x_link_sif_s [3:0][E:W] mc_ruche_links_li, mc_ruche_links_lo;
  bsg_manycore_link_sif_s [3:0] mc_proc_links_li, mc_proc_links_lo;
  for (genvar i = 0; i < 4; i++)
    begin : rof2
      bsg_async_noc_link
       #(.width_p($bits(bsg_manycore_link_sif_s)-2), .lg_size_p(3))
       cdc
        (.aclk_i(bp_clk_i)
         ,.areset_i(bp_reset_i)
     
         ,.bclk_i(mc_clk_i)
         ,.breset_i(mc_reset_i)
     
         ,.alink_i(bp_proc_links_li[i])
         ,.alink_o(bp_proc_links_lo[i])
     
         ,.blink_i(mc_proc_links_li[i])
         ,.blink_o(mc_proc_links_lo[i])
         );

      assign mc_hor_links_li[i][E] = mc_hor_links_i[E];
      assign mc_hor_links_li[i][W] = '0;
      assign mc_hor_links_o[E] = mc_hor_links_lo[E];

      assign mc_ruche_links_li[i][E] = mc_ruche_links_i;
      assign mc_ruche_links_li[i][W] = '0;
      assign mc_ruche_links_o[E] = mc_ruche_links_lo[E];
    end

  bsg_manycore_hor_io_router_column
   #(.addr_width_p(mc_addr_width_gp)
     ,.data_width_p(mc_data_width_gp)
     ,.x_cord_width_p(mc_x_cord_width_gp)
     ,.y_cord_width_p(mc_y_cord_width_gp)
     ,.ruche_factor_X_p(ruche_factor_X_gp)
     ,.tieoff_west_p(4'b1111)
     ,.tieoff_east_p(4'b0000)
     ,.num_row_p(4)
     )
   io_routers
    (.clk_i(mc_clk_i)
     ,.reset_i(mc_reset_i)

     ,.ver_link_sif_i(mc_ver_links_i[S:N])
     ,.ver_link_sif_o(mc_ver_links_o[S:N])
     ,.hor_link_sif_i(mc_hor_links_li)
     ,.hor_link_sif_o(mc_hor_links_lo)

     ,.proc_link_sif_i(mc_proc_links_lo)
     ,.proc_link_sif_o(mc_proc_links_li)

     ,.ruche_link_i(mc_ruche_links_li)
     ,.ruche_link_o(mc_ruche_links_lo)
    
     ,.global_x_i(mc_global_x_li)
     ,.global_y_i(mc_global_y_li)
     );

endmodule

