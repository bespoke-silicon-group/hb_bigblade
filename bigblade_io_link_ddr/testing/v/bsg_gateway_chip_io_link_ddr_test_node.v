//
// Paul Gao 03/2021
//
//

module bsg_gateway_chip_io_link_ddr_test_node

 #(parameter width_p              = "inv"
  ,parameter channel_width_p      = "inv"
  ,parameter lg_fifo_depth_lp     = 3
  ,parameter num_channels_lp      = (width_p/channel_width_p)
  ,parameter width_lp             = num_channels_lp*channel_width_p
  )

  (// Node side
   input node_clk_i
  ,input node_reset_i
  ,input node_en_i

  ,output logic  error_o
  ,output [31:0] sent_o
  ,output [31:0] received_o

  // Link side
  ,input                clk_i
  ,input                reset_i
  ,input                v_i
  ,input  [width_p-1:0] data_i
  ,output               ready_o
  ,output               v_o
  ,output [width_p-1:0] data_o
  ,input                yumi_i
  );

  // Async fifo signals
  logic node_async_fifo_valid_li, node_async_fifo_ready_lo;
  logic node_async_fifo_valid_lo, node_async_fifo_yumi_li;

  logic [width_p-1:0] node_async_fifo_data_li;
  logic [width_p-1:0] node_async_fifo_data_lo;


  // Generate data packets
  logic [width_lp-1:0] data_gen;
  test_bsg_data_gen
 #(.channel_width_p(channel_width_p)
  ,.num_channels_p (num_channels_lp)
  ) gen_out
  (.clk_i  (node_clk_i)
  ,.reset_i(node_reset_i)
  ,.yumi_i (node_async_fifo_valid_li & node_async_fifo_ready_lo)
  ,.o      (data_gen)
  );

  // Send when node is enabled
  assign node_async_fifo_valid_li = node_en_i;
  assign node_async_fifo_data_li  = data_gen;

  // Count sent packets
  bsg_counter_clear_up
 #(.max_val_p (1<<32-1)
  ,.init_val_p(0)
  ) sent_count
  (.clk_i  (node_clk_i)
  ,.reset_i(node_reset_i)
  ,.clear_i(1'b0)
  ,.up_i   (node_async_fifo_valid_li & node_async_fifo_ready_lo)
  ,.count_o(sent_o)
  );


  // Generate checking packets
  logic [width_lp-1:0] data_check;
  test_bsg_data_gen
 #(.channel_width_p(channel_width_p)
  ,.num_channels_p (num_channels_lp)
  ) gen_in
  (.clk_i  (node_clk_i)
  ,.reset_i(node_reset_i)
  ,.yumi_i (node_async_fifo_yumi_li)
  ,.o      (data_check)
  );

  // Always ready
  assign node_async_fifo_yumi_li = node_async_fifo_valid_lo;

  // Count received packets
  bsg_counter_clear_up
 #(.max_val_p (1<<32-1)
  ,.init_val_p(0)
  ) received_count
  (.clk_i  (node_clk_i)
  ,.reset_i(node_reset_i)
  ,.clear_i(1'b0)
  ,.up_i   (node_async_fifo_yumi_li)
  ,.count_o(received_o)
  );

  // Check errors    
  always_ff @(posedge node_clk_i)
      if (node_reset_i)
          error_o <= 0;
      else
          if (node_async_fifo_yumi_li && data_check != node_async_fifo_data_lo)
            begin
              $error("%m mismatched resp data %x %x",data_check, node_async_fifo_data_lo);
              error_o <= 1;
            end


  /********************* Async fifo to link *********************/

  // Node side async fifo input
  logic  node_async_fifo_full_lo;
  assign node_async_fifo_ready_lo = ~node_async_fifo_full_lo;

  // Link side async fifo input
  logic  link_async_fifo_full_lo;
  assign ready_o = ~link_async_fifo_full_lo;

  bsg_async_fifo
 #(.lg_size_p(lg_fifo_depth_lp)
  ,.width_p  (width_p)
  ) wh_to_mc
  (.w_clk_i  (clk_i)
  ,.w_reset_i(reset_i)
  ,.w_enq_i  (v_i & ready_o)
  ,.w_data_i (data_i)
  ,.w_full_o (link_async_fifo_full_lo)

  ,.r_clk_i  (node_clk_i)
  ,.r_reset_i(node_reset_i)
  ,.r_deq_i  (node_async_fifo_yumi_li)
  ,.r_data_o (node_async_fifo_data_lo)
  ,.r_valid_o(node_async_fifo_valid_lo)
  );

  bsg_async_fifo
 #(.lg_size_p(lg_fifo_depth_lp)
  ,.width_p  (width_p)
  ) mc_to_wh
  (.w_clk_i  (node_clk_i)
  ,.w_reset_i(node_reset_i)
  ,.w_enq_i  (node_async_fifo_valid_li & node_async_fifo_ready_lo)
  ,.w_data_i (node_async_fifo_data_li)
  ,.w_full_o (node_async_fifo_full_lo)

  ,.r_clk_i  (clk_i)
  ,.r_reset_i(reset_i)
  ,.r_deq_i  (yumi_i)
  ,.r_data_o (data_o)
  ,.r_valid_o(v_o)
  );

endmodule