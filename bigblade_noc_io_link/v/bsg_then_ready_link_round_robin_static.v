
`include "bsg_defines.v"
`include "bsg_noc_links.vh"

module bsg_then_ready_link_round_robin_static 

 #(parameter width_p       = "inv"
  ,parameter num_in_p      = "inv"
  ,parameter link_width_lp = `bsg_then_ready_link_sif_width(width_p)
  ,parameter ptr_width_lp  = `BSG_SAFE_CLOG2(num_in_p)
  )

  (input clk_i
  ,input reset_i

  // single link
  ,input  [link_width_lp-1:0] single_link_i
  ,output [link_width_lp-1:0] single_link_o

  // multiple links
  ,input  [num_in_p-1:0][link_width_lp-1:0] links_i
  ,output [num_in_p-1:0][link_width_lp-1:0] links_o
  );

  // bsg ready and link hub
  `declare_bsg_then_ready_link_sif_s(width_p, bsg_then_ready_link_sif_s);

  bsg_then_ready_link_sif_s [num_in_p-1:0] links_i_cast, links_o_cast;
  bsg_then_ready_link_sif_s single_link_i_cast, single_link_o_cast;

  assign links_i_cast = links_i;
  assign links_o = links_o_cast;

  assign single_link_i_cast = single_link_i;
  assign single_link_o = single_link_o_cast;

  logic [num_in_p-1:0] links_v_li, links_yumi_lo;
  logic [num_in_p-1:0] links_v_lo, links_yumi_li;
  logic [num_in_p-1:0][width_p-1:0] links_data_li;

  for (genvar i = 0; i < num_in_p; i++)
  begin
    assign links_v_li   [i] = links_i_cast[i].v;
    assign links_data_li[i] = links_i_cast[i].data;
    assign links_yumi_li[i] = links_i_cast[i].then_ready_rev;

    assign links_o_cast[i].v              = links_v_lo   [i];
    assign links_o_cast[i].data           = single_link_i_cast.data;
    assign links_o_cast[i].then_ready_rev = links_yumi_lo[i];
  end

  // static circular ptrs
  logic [ptr_width_lp-1:0] conc_ptr_r, unconc_ptr_r;

  bsg_circular_ptr
 #(.slots_p  (num_in_p)
  ,.max_add_p(1)
  ) conc_ptr
  (.clk      (clk_i)
  ,.reset_i  (reset_i)
  ,.add_i    (single_link_i_cast.then_ready_rev)
  ,.o        (conc_ptr_r)
  ,.n_o      ()
  );

  bsg_circular_ptr
 #(.slots_p  (num_in_p)
  ,.max_add_p(1)
  ) unconc_ptr
  (.clk      (clk_i)
  ,.reset_i  (reset_i)
  ,.add_i    (single_link_o_cast.then_ready_rev)
  ,.o        (unconc_ptr_r)
  ,.n_o      ()
  );

  // concentrate
  assign single_link_o_cast.v    = links_v_li   [conc_ptr_r];
  assign single_link_o_cast.data = links_data_li[conc_ptr_r];
  bsg_decode_with_v
 #(.num_out_p(num_in_p)
  ) conc_bdwv
  (.i        (conc_ptr_r)
  ,.v_i      (single_link_i_cast.then_ready_rev)
  ,.o        (links_yumi_lo)
  );

  // unconcentrate
  assign single_link_o_cast.then_ready_rev = links_yumi_li[unconc_ptr_r];
  bsg_decode_with_v
 #(.num_out_p(num_in_p)
  ) unconc_bdwv
  (.i        (unconc_ptr_r)
  ,.v_i      (single_link_i_cast.v)
  ,.o        (links_v_lo)
  );

endmodule