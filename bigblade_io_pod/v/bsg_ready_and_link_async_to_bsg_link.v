
`include "bsg_defines.v"
`include "bsg_noc_links.vh"

module bsg_ready_and_link_async_to_bsg_link

 #(// ral link parameters
   parameter ral_link_width_p = "inv"
  
  // bsg link parameters
  ,parameter bsg_link_width_p = "inv"

  ,localparam ral_link_sif_width_lp = `bsg_ready_and_link_sif_width(ral_link_width_p)
  ,localparam bsg_link_sif_width_lp = `bsg_ready_and_link_sif_width(bsg_link_width_p)
  )

  (// ral (ready_and_link) side
   input ral_clk_i
  ,input ral_reset_i
  
  ,input  [ral_link_sif_width_lp-1:0] ral_link_i
  ,output [ral_link_sif_width_lp-1:0] ral_link_o
  
  // bsg link side
  ,input bsg_link_clk_i
  ,input bsg_link_reset_i

  ,input  [bsg_link_sif_width_lp-1:0] bsg_link_i
  ,output [bsg_link_sif_width_lp-1:0] bsg_link_o
  );

  // 8 elements should be enough to handle roundtrip latency across async clock domain
  localparam lg_fifo_depth_lp = 3;
  genvar i;
  
  
  /********************* Interfacing ral and bsg link *********************/
  
  `declare_bsg_ready_and_link_sif_s(ral_link_width_p, ral_link_sif_s);
  ral_link_sif_s ral_link_i_cast, ral_link_o_cast;
  
  assign ral_link_i_cast = ral_link_i;
  assign ral_link_o      = ral_link_o_cast;
  
  `declare_bsg_ready_and_link_sif_s(bsg_link_width_p, bsg_link_sif_s);
  bsg_link_sif_s bsg_link_i_cast, bsg_link_o_cast;
  
  assign bsg_link_i_cast = bsg_link_i;
  assign bsg_link_o      = bsg_link_o_cast;
  
  localparam piso_ratio_lp = `BSG_CDIV(ral_link_width_p, bsg_link_width_p);

  
  /********************* ral -> bsg link *********************/
  
  // PISO signals
  logic [piso_ratio_lp*bsg_link_width_p-1:0] ral_piso_data_li;
  assign ral_piso_data_li = (piso_ratio_lp*bsg_link_width_p)'(ral_link_i_cast.data);
  
  // Async fifo signals
  logic ral_async_fifo_valid_li, ral_async_fifo_yumi_lo;
  logic [bsg_link_width_p-1:0] ral_async_fifo_data_li;
  
  // piso
  bsg_parallel_in_serial_out 
 #(.width_p(bsg_link_width_p)
  ,.els_p  (piso_ratio_lp)
  ) piso
  (.clk_i  (ral_clk_i  )
  ,.reset_i(ral_reset_i)
  ,.valid_i(ral_link_i_cast.v            )
  ,.data_i (ral_piso_data_li             )
  ,.ready_and_o(ral_link_o_cast.ready_and_rev)
  ,.valid_o(ral_async_fifo_valid_li      )
  ,.data_o (ral_async_fifo_data_li       )
  ,.yumi_i (ral_async_fifo_yumi_lo       )
  );

  // ral side async fifo input
  logic ral_async_fifo_full_lo;
  assign ral_async_fifo_yumi_lo = ~ral_async_fifo_full_lo & ral_async_fifo_valid_li;
  
  // This async fifo crosses from ral clock to wormhole clock
  bsg_async_fifo
 #(.lg_size_p(lg_fifo_depth_lp)
  ,.width_p  (bsg_link_width_p    )
  ) ral_to_wh
  (.w_clk_i  (ral_clk_i  )
  ,.w_reset_i(ral_reset_i)
  ,.w_enq_i  (ral_async_fifo_yumi_lo)
  ,.w_data_i (ral_async_fifo_data_li)
  ,.w_full_o (ral_async_fifo_full_lo)

  ,.r_clk_i  (bsg_link_clk_i  )
  ,.r_reset_i(bsg_link_reset_i)
  ,.r_deq_i  (bsg_link_o_cast.v & bsg_link_i_cast.ready_and_rev)
  ,.r_data_o (bsg_link_o_cast.data)
  ,.r_valid_o(bsg_link_o_cast.v   )
  );
  
  
  /********************* wormhole -> ral link *********************/
  
  // Async fifo signals
  logic ral_async_fifo_valid_lo, ral_async_fifo_ready_li;
  logic [bsg_link_width_p-1:0] ral_async_fifo_data_lo;
  
  // ral side async fifo output
  logic ral_async_fifo_deq_li;
  assign ral_async_fifo_deq_li = ral_async_fifo_ready_li & ral_async_fifo_valid_lo;
  
  // Wormhole side async fifo input
  logic bsg_link_async_fifo_full_lo;
  assign bsg_link_o_cast.ready_and_rev = ~bsg_link_async_fifo_full_lo;
  
  // This async fifo crosses from wormhole clock to ral clock
  bsg_async_fifo
 #(.lg_size_p(lg_fifo_depth_lp)
  ,.width_p  (bsg_link_width_p    )
  ) wh_to_ral
  (.w_clk_i  (bsg_link_clk_i  )
  ,.w_reset_i(bsg_link_reset_i)
  ,.w_enq_i  (bsg_link_i_cast.v & bsg_link_o_cast.ready_and_rev)
  ,.w_data_i (bsg_link_i_cast.data  )
  ,.w_full_o (bsg_link_async_fifo_full_lo)

  ,.r_clk_i  (ral_clk_i  )
  ,.r_reset_i(ral_reset_i)
  ,.r_deq_i  (ral_async_fifo_deq_li  )
  ,.r_data_o (ral_async_fifo_data_lo )
  ,.r_valid_o(ral_async_fifo_valid_lo)
  );
  
  // SIPOF signals
  logic [piso_ratio_lp*bsg_link_width_p-1:0] ral_sipof_data_lo;
  assign ral_link_o_cast.data = ral_sipof_data_lo[ral_link_width_p-1:0];
  
  // sipof
  bsg_serial_in_parallel_out_full
 #(.width_p(bsg_link_width_p)
  ,.els_p  (piso_ratio_lp)
  ) sipof
  (.clk_i  (ral_clk_i              )
  ,.reset_i(ral_reset_i            )
  ,.v_i    (ral_async_fifo_valid_lo)
  ,.ready_o(ral_async_fifo_ready_li)
  ,.data_i (ral_async_fifo_data_lo )
  ,.data_o (ral_sipof_data_lo      )
  ,.v_o    (ral_link_o_cast.v      )
  ,.yumi_i (ral_link_o_cast.v & ral_link_i_cast.ready_and_rev)
  );
  

endmodule