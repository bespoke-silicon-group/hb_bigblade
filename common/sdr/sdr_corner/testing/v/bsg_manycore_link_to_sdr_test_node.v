
module  bsg_manycore_link_to_sdr_test_node

 import bsg_manycore_pkg::*;

 #(parameter addr_width_p    = "inv"
  ,parameter data_width_p    = "inv"
  ,parameter x_cord_width_p  = "inv"
  ,parameter y_cord_width_p  = "inv"

  ,parameter link_sif_width_lp =
    `bsg_manycore_link_sif_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p)
  ,parameter fwd_width_lp =
    `bsg_manycore_packet_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p)
  ,parameter rev_width_lp =
    `bsg_manycore_return_packet_width(x_cord_width_p,y_cord_width_p,data_width_p)

  ,localparam channel_width_p = 8
  ,localparam num_channels_p = rev_width_lp/channel_width_p
  ,localparam width_p = channel_width_p * num_channels_p
  )

  (input clk_i
  ,input reset_i
  ,input en_i

  ,output logic  error_o
  ,output [31:0] sent_o
  ,output [31:0] received_o

  ,input  [link_sif_width_lp-1:0] links_sif_i
  ,output [link_sif_width_lp-1:0] links_sif_o
  );

  //-------------------------------------------
  //As the manycore will distribute across large area, it will take long
  //time for the reset signal to propgate. We should register the reset
  //signal in each tile
  logic reset_r;
  bsg_dff #(.width_p(1)) dff_reset
  (.clk_i(clk_i),.data_i(reset_i),.data_o(reset_r));

  // Define link packets
  `declare_bsg_manycore_link_sif_s(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p);
  // Define req and resp packets
  `declare_bsg_manycore_packet_s(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p);

  // Cast of link packets
  bsg_manycore_link_sif_s links_sif_li, links_sif_lo;
  assign links_sif_li = links_sif_i;
  assign links_sif_o  = links_sif_lo;

  logic rev_in_v, rev_in_yumi;
  bsg_manycore_return_packet_s rev_in_data;
  logic fwd_out_v, fwd_out_ready;
  bsg_manycore_packet_s fwd_out_data;

  bsg_two_fifo
 #(.width_p(rev_width_lp)
  ) rev_in_fifo
  (.clk_i  (clk_i)
  ,.reset_i(reset_r)
  ,.ready_o(links_sif_lo.rev.ready_and_rev)
  ,.v_i    (links_sif_li.rev.v)
  ,.data_i (links_sif_li.rev.data)
  ,.v_o    (rev_in_v)
  ,.data_o (rev_in_data)
  ,.yumi_i (rev_in_yumi)
  );
  assign rev_in_yumi = rev_in_v;

  bsg_two_fifo
 #(.width_p(fwd_width_lp)
  ) fwd_out_fifo
  (.clk_i  (clk_i)
  ,.reset_i(reset_r)
  ,.ready_o(fwd_out_ready)
  ,.v_i    (fwd_out_v)
  ,.data_i (fwd_out_data)
  ,.v_o    (links_sif_lo.fwd.v)
  ,.data_o (links_sif_lo.fwd.data)
  ,.yumi_i (links_sif_lo.fwd.v & links_sif_li.fwd.ready_and_rev)
  );
  assign fwd_out_v = en_i;

  logic [width_p-1:0] data_gen, data_check;

  test_bsg_data_gen
 #(.channel_width_p(channel_width_p)
  ,.num_channels_p(num_channels_p)
  ) gen_out
  (.clk_i  (clk_i)
  ,.reset_i(reset_r)
  ,.yumi_i (fwd_out_v & fwd_out_ready)
  ,.o      (data_gen)
  );

  assign fwd_out_data = {'0, data_gen};

  test_bsg_data_gen
 #(.channel_width_p(channel_width_p)
  ,.num_channels_p(num_channels_p)
  ) gen_in
  (.clk_i  (clk_i)
  ,.reset_i(reset_r)
  ,.yumi_i (rev_in_v)
  ,.o      (data_check)
  );

  // synopsys translate_off
  always_ff @(negedge clk_i)
    if (rev_in_v & ~reset_r)
      assert(data_check == rev_in_data[width_p-1:0])
        else $error("check mismatch %x %x ", data_check,rev_in_data[width_p-1:0]);
  // synopsys translate_on

  always_ff @(posedge clk_i)
    if (reset_r) 
        error_o <= 0;
    else 
        if (rev_in_v & data_check != rev_in_data[width_p-1:0])
            error_o <= 1;
        else
            error_o <= error_o;

  // Count sent and received packets
  bsg_counter_clear_up 
 #(.max_val_p(1<<32-1)
  ,.init_val_p(0)
  ) sent_count
  (.clk_i  (clk_i)
  ,.reset_i(reset_r)
  ,.clear_i(1'b0)
  ,.up_i   (fwd_out_v & fwd_out_ready)
  ,.count_o(sent_o)
  );

  bsg_counter_clear_up 
 #(.max_val_p(1<<32-1)
  ,.init_val_p(0)
  ) received_count
  (.clk_i  (clk_i)
  ,.reset_i(reset_r)
  ,.clear_i(1'b0)
  ,.up_i   (rev_in_v)
  ,.count_o(received_o)
  );



  logic fwd_in_v, fwd_in_yumi;
  bsg_manycore_packet_s fwd_in_data;
  logic rev_out_v, rev_out_ready;
  bsg_manycore_return_packet_s rev_out_data;

  bsg_two_fifo 
 #(.width_p(fwd_width_lp)
  ) fwd_in_fifo
  (.clk_i  (clk_i)
  ,.reset_i(reset_r)
  ,.ready_o(links_sif_lo.fwd.ready_and_rev)
  ,.v_i    (links_sif_li.fwd.v)
  ,.data_i (links_sif_li.fwd.data)
  ,.v_o    (fwd_in_v)
  ,.data_o (fwd_in_data)
  ,.yumi_i (fwd_in_yumi)
  );

  assign rev_out_v = fwd_in_v;
  assign fwd_in_yumi = rev_out_v & rev_out_ready;

  assign rev_out_data = fwd_in_data;

  bsg_two_fifo 
 #(.width_p(rev_width_lp)
  ) rev_out_fifo
  (.clk_i  (clk_i)
  ,.reset_i(reset_r)
  ,.ready_o(rev_out_ready)
  ,.v_i    (rev_out_v)
  ,.data_i (rev_out_data)
  ,.v_o    (links_sif_lo.rev.v)
  ,.data_o (links_sif_lo.rev.data)
  ,.yumi_i (links_sif_lo.rev.v & links_sif_li.rev.ready_and_rev)
  );

endmodule