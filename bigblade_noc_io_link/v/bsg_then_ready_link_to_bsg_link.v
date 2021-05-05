
`include "bsg_defines.v"
`include "bsg_noc_links.vh"

module bsg_then_ready_link_to_bsg_link

 #(// wide link parameters
   parameter wide_link_width_p = "inv"

  // bsg link parameters
  ,parameter bsg_link_width_p = "inv"

  ,localparam wide_link_sif_width_lp = `bsg_then_ready_link_sif_width(wide_link_width_p)
  ,localparam bsg_link_sif_width_lp = `bsg_then_ready_link_sif_width(bsg_link_width_p)
  )

  (input clk_i
  ,input reset_i

  ,input  [wide_link_sif_width_lp-1:0] wide_link_i
  ,output [wide_link_sif_width_lp-1:0] wide_link_o

  ,input  [bsg_link_sif_width_lp-1:0] bsg_link_i
  ,output [bsg_link_sif_width_lp-1:0] bsg_link_o
  );

  genvar i;


  /********************* Interfacing wide and bsg link *********************/

  `declare_bsg_then_ready_link_sif_s(wide_link_width_p, wide_link_sif_s);
  wide_link_sif_s wide_link_i_cast, wide_link_o_cast;

  assign wide_link_i_cast = wide_link_i;
  assign wide_link_o      = wide_link_o_cast;

  `declare_bsg_then_ready_link_sif_s(bsg_link_width_p, bsg_link_sif_s);
  bsg_link_sif_s bsg_link_i_cast, bsg_link_o_cast;

  assign bsg_link_i_cast = bsg_link_i;
  assign bsg_link_o      = bsg_link_o_cast;

  localparam piso_ratio_lp = `BSG_CDIV(wide_link_width_p, bsg_link_width_p);


  /********************* wide link -> bsg_link *********************/

  // PISO signals
  logic wide_piso_ready_and_lo;
  assign wide_link_o_cast.then_ready_rev = wide_link_i_cast.v & wide_piso_ready_and_lo;

  logic [piso_ratio_lp*bsg_link_width_p-1:0] wide_piso_data_li;
  assign wide_piso_data_li = (piso_ratio_lp*bsg_link_width_p)'(wide_link_i_cast.data);

  // piso
  bsg_parallel_in_serial_out 
 #(.width_p(bsg_link_width_p)
  ,.els_p  (piso_ratio_lp)
  ) piso
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.valid_i(wide_link_i_cast.v)
  ,.data_i (wide_piso_data_li)
  ,.ready_and_o(wide_piso_ready_and_lo)
  ,.valid_o(bsg_link_o_cast.v)
  ,.data_o (bsg_link_o_cast.data)
  ,.yumi_i (bsg_link_i_cast.then_ready_rev)
  );

  /********************* bsg_link -> wide link *********************/

  // SIPOF signals
  logic bsg_link_sipof_ready_and_lo;
  assign bsg_link_o_cast.then_ready_rev = bsg_link_i_cast.v & bsg_link_sipof_ready_and_lo;

  logic [piso_ratio_lp*bsg_link_width_p-1:0] wide_sipof_data_lo;
  assign wide_link_o_cast.data = wide_sipof_data_lo[wide_link_width_p-1:0];

  // sipof
  bsg_serial_in_parallel_out_full
 #(.width_p(bsg_link_width_p)
  ,.els_p  (piso_ratio_lp)
  ) sipof
  (.clk_i  (clk_i)
  ,.reset_i(reset_i)
  ,.v_i    (bsg_link_i_cast.v)
  ,.ready_o(bsg_link_sipof_ready_and_lo)
  ,.data_i (bsg_link_i_cast.data)
  ,.data_o (wide_sipof_data_lo)
  ,.v_o    (wide_link_o_cast.v)
  ,.yumi_i (wide_link_i_cast.then_ready_rev)
  );

endmodule
