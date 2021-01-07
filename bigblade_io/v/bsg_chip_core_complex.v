
module bsg_chip_core_complex

 import bsg_chip_pkg::*;
 import bsg_manycore_pkg::*;

  (input                      hb_clk_i
  ,input bsg_chip_tag_lines_s tag_lines_i

  ,input  bsg_chip_io_link_sif_s [3:0][io_ct_num_in_gp-1:0] io_links_i
  ,output bsg_chip_io_link_sif_s [3:0][io_ct_num_in_gp-1:0] io_links_o

  ,input  bsg_chip_mem_link_sif_s [15:0] mem_links_i
  ,output bsg_chip_mem_link_sif_s [15:0] mem_links_o
  );

  //////////////////////////////////////////////////
  //
  // BSG Tag Client Instance
  //

  // Tag payload for hb control signals
  typedef struct packed { 
      logic padding;
      logic reset;
  } hb_tag_payload_s;

  hb_tag_payload_s hb_tag_data_lo;
  logic            hb_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(hb_tag_data_lo) ), .default_p( 0 ))
    btc_hb
      (.bsg_tag_i     ( tag_lines_i.hb_reset )
      ,.recv_clk_i    ( hb_clk_i )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( hb_tag_new_data_lo )
      ,.recv_data_r_o ( hb_tag_data_lo )
      );


  // Tag payload for hb dest cords
  typedef struct packed { 
      logic [wh_cord_width_gp-1:0] cord;
  } hb_dest_cord_tag_payload_s;

  hb_dest_cord_tag_payload_s [1:0] hb_dest_cord_tag_data_lo;
  logic                      [1:0] hb_dest_cord_tag_new_data_lo;

  for (genvar i = 0; i < 2; i++)
  begin
    bsg_tag_client #(.width_p( $bits(hb_dest_cord_tag_data_lo[i]) ), .default_p( 0 ))
      btc_hb_dest_cord
        (.bsg_tag_i     ( tag_lines_i.hb_dest_cord[i] )
        ,.recv_clk_i    ( hb_clk_i )
        ,.recv_reset_i  ( 1'b0 )
        ,.recv_new_r_o  ( hb_dest_cord_tag_new_data_lo[i] )
        ,.recv_data_r_o ( hb_dest_cord_tag_data_lo[i] )
        );
  end


  //////////////////////////////////////////////////
  //
  // Loopback
  //
  assign io_links_o  = io_links_i;
  assign mem_links_o = mem_links_i;


  //////////////////////////////////////////////////
  //
  // Manycore Adapter
  //
  //`declare_bsg_manycore_link_sif_s(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp);
  //bsg_manycore_link_sif_s [3:0] manycore_links_li;
  //bsg_manycore_link_sif_s [3:0] manycore_links_lo;
  //
  //for (genvar i = 0; i < 4; i++)
  //begin: mc_io
  //  bsg_manycore_link_async_to_wormhole
  // #(.addr_width_p    (hb_addr_width_gp  )
  //  ,.data_width_p    (hb_data_width_gp  )
  //  ,.x_cord_width_p  (hb_x_cord_width_gp)
  //  ,.y_cord_width_p  (hb_y_cord_width_gp)
  //  ,.bsg_link_width_p(io_ct_width_gp    )
  //  ) mc_adapter
  //  (.mc_clk_i        (hb_clk_i)
  //  ,.mc_reset_i      (tag_lines_i.hb_reset)
  //  ,.mc_links_sif_i  (manycore_links_lo[i])
  //  ,.mc_links_sif_o  (manycore_links_li[i])
  //
  //  ,.bsg_link_clk_i  (hb_clk_i)
  //  ,.bsg_link_reset_i(tag_lines_i.hb_reset)
  //  ,.bsg_link_i      (io_links_i[i])
  //  ,.bsg_link_o      (io_links_o[i])
  //  );
  //end


  //////////////////////////////////////////////////
  //
  // Manycore Array
  //

endmodule