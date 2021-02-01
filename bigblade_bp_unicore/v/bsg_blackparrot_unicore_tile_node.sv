
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

   , input bsg_tag_s [3:0]                                bsg_tag_i

   , input [E:E][mc_ruche_x_link_sif_width_lp-1:0]        mc_ruche_links_i
   , output logic [E:E][mc_ruche_x_link_sif_width_lp-1:0] mc_ruche_links_o

   , input [3:0][E:E][mc_link_sif_width_lp-1:0]           mc_hor_links_i
   , output logic [3:0][E:E][mc_link_sif_width_lp-1:0]    mc_hor_links_o

   , input [S:N][mc_link_sif_width_lp-1:0]                mc_ver_links_i
   , output logic [S:N][mc_link_sif_width_lp-1:0]         mc_ver_links_o
   );

  `declare_bsg_manycore_link_sif_s(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp);
  `declare_bsg_manycore_ruche_x_link_sif_s(mc_addr_width_gp,mc_data_width_gp,mc_x_cord_width_gp,mc_y_cord_width_gp);

  wire [mc_x_cord_width_gp-1:0] mc_global_x_li = '0;
  logic [3:0][mc_y_cord_width_gp-1:0] mc_global_y_li;
  for (genvar i = 0; i < 4; i++)
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
  bsg_manycore_link_sif_s [3:0] mc_proc_links_li, mc_proc_links_lo;
  for (genvar i = 0; i < 4; i++)
    begin : rof2
      bsg_async_noc_link
       #(.width_p($bits(bsg_manycore_fwd_link_sif_s)-2), .lg_size_p(3))
       fwd_cdc
        (.aclk_i(bp_clk_i)
         ,.areset_i(bp_reset_i)
     
         ,.bclk_i(mc_clk_i)
         ,.breset_i(mc_reset_i)
     
         ,.alink_i(bp_proc_links_lo[i].fwd)
         ,.alink_o(bp_proc_links_li[i].fwd)
     
         ,.blink_i(mc_proc_links_li[i].fwd)
         ,.blink_o(mc_proc_links_lo[i].fwd)
         );

      bsg_async_noc_link
       #(.width_p($bits(bsg_manycore_rev_link_sif_s)-2), .lg_size_p(3))
       rev_cdc
        (.aclk_i(bp_clk_i)
         ,.areset_i(bp_reset_i)
     
         ,.bclk_i(mc_clk_i)
         ,.breset_i(mc_reset_i)
     
         ,.alink_i(bp_proc_links_lo[i].rev)
         ,.alink_o(bp_proc_links_li[i].rev)
     
         ,.blink_i(mc_proc_links_li[i].rev)
         ,.blink_o(mc_proc_links_lo[i].rev)
         );

      assign mc_hor_links_li[i][E] = mc_hor_links_i[i][E];
      assign mc_hor_links_li[i][W] = '0;
      assign mc_hor_links_o[i][E] = mc_hor_links_lo[i][E];
    end

  bsg_manycore_ruche_x_link_sif_s [3:0][E:W] mc_ruche_links_li, mc_ruche_links_lo;
  assign mc_ruche_links_li[0]    = '0;
  assign mc_ruche_links_li[1][W] = '0;
  assign mc_ruche_links_li[2]    = '0;
  assign mc_ruche_links_li[3]    = '0;

  assign mc_ruche_links_li[1][E] = mc_ruche_links_i;
  assign mc_ruche_links_o = mc_ruche_links_lo[1][E];
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

     ,.ver_link_sif_i(mc_ver_links_i)
     ,.ver_link_sif_o(mc_ver_links_o)
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

