
module bsg_manycore_link_async_to_wormhole

  import bsg_manycore_pkg::*;

 #(// Manycore link parameters
   parameter addr_width_p="inv"
  ,parameter data_width_p="inv"
  ,parameter x_cord_width_p="inv"
  ,parameter y_cord_width_p="inv"
  
  // bsg link parameters
  ,parameter bsg_link_width_p = "inv"
  
  ,localparam num_nets_lp = 2
  ,localparam bsg_manycore_link_sif_width_lp = `bsg_manycore_link_sif_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p)
  ,localparam bsg_ready_and_link_sif_width_lp = `bsg_ready_and_link_sif_width(bsg_link_width_p)
  )

  (// Manycore side
   input mc_clk_i
  ,input mc_reset_i
  
  // Manycore links
  ,input  [bsg_manycore_link_sif_width_lp-1:0] mc_links_sif_i
  ,output [bsg_manycore_link_sif_width_lp-1:0] mc_links_sif_o
  
  // bsg link side
  ,input bsg_link_clk_i
  ,input bsg_link_reset_i

  // bsg links: {fwd_link, rev_link}
  ,input  [num_nets_lp-1:0][bsg_ready_and_link_sif_width_lp-1:0] bsg_link_i
  ,output [num_nets_lp-1:0][bsg_ready_and_link_sif_width_lp-1:0] bsg_link_o
  );

  // Packet format is {fwd_link, rev_link}
  localparam fwd_index_lp = 1;
  localparam rev_index_lp = 0;
  
  genvar i;
  
  // Define manycore link, fwd and rev packets
  `declare_bsg_manycore_link_sif_s(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p);
  `declare_bsg_manycore_packet_s  (addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p);
  
  // Manycore packet width
  localparam manycore_fwd_packet_width_lp = $bits(bsg_manycore_packet_s);
  localparam manycore_rev_packet_width_lp = $bits(bsg_manycore_return_packet_s);
  
  // Cast of manycore link packets
  bsg_manycore_link_sif_s mc_links_sif_i_cast, mc_links_sif_o_cast;
  
  assign mc_links_sif_i_cast = mc_links_sif_i;
  assign mc_links_sif_o      = mc_links_sif_o_cast;

  // Fwd link
  bsg_ready_and_link_async_to_bsg_link
 #(.ral_link_width_p  (manycore_fwd_packet_width_lp)
  ,.bsg_link_width_p  (bsg_link_width_p      )
  ) fwd
  (.ral_clk_i      (mc_clk_i      )
  ,.ral_reset_i    (mc_reset_i    )
  ,.ral_link_i     (mc_links_sif_i_cast.fwd)
  ,.ral_link_o     (mc_links_sif_o_cast.fwd)

  ,.bsg_link_clk_i   (bsg_link_clk_i      )
  ,.bsg_link_reset_i (bsg_link_reset_i    )
  ,.bsg_link_i       (bsg_link_i[fwd_index_lp])
  ,.bsg_link_o       (bsg_link_o[fwd_index_lp])
  );

  // Rev link
  bsg_ready_and_link_async_to_bsg_link
 #(.ral_link_width_p  (manycore_rev_packet_width_lp)
  ,.bsg_link_width_p  (bsg_link_width_p      )
  ) rev
  (.ral_clk_i      (mc_clk_i      )
  ,.ral_reset_i    (mc_reset_i    )
  ,.ral_link_i     (mc_links_sif_i_cast.rev)
  ,.ral_link_o     (mc_links_sif_o_cast.rev)

  ,.bsg_link_clk_i   (bsg_link_clk_i      )
  ,.bsg_link_reset_i (bsg_link_reset_i    )
  ,.bsg_link_i       (bsg_link_i[rev_index_lp])
  ,.bsg_link_o       (bsg_link_o[rev_index_lp])
  );

endmodule