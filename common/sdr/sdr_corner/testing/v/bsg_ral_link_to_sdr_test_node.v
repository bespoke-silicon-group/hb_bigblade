
module  bsg_ral_link_to_sdr_test_node

 import bsg_noc_pkg::*;

 #(parameter flit_width_p = "inv"
  ,parameter master_p     = "inv"

  ,localparam link_sif_width_lp =
    `bsg_ready_and_link_sif_width(flit_width_p)

  ,localparam channel_width_p = 8
  ,localparam num_channels_p = flit_width_p/channel_width_p
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

  `declare_bsg_ready_and_link_sif_s(flit_width_p, link_sif_s);
  link_sif_s links_int_li, links_int_lo;

  bsg_noc_repeater_node
 #(.width_p       (flit_width_p)
  ) rep_node
  (.clk_i         (clk_i)
  ,.reset_i       (reset_r)
  ,.side_A_links_i(links_sif_i)
  ,.side_A_links_o(links_sif_o)
  ,.side_B_links_i(links_int_li)
  ,.side_B_links_o(links_int_lo)
  );

  logic [width_p-1:0] data_gen, data_check;

  if (master_p == 0)
  begin: client
    assign links_int_li = links_int_lo;
  end
  else
  begin: master
    assign links_int_li.ready_and_rev = 1'b1;
    assign links_int_li.v = en_i;
    assign links_int_li.data = {'0, data_gen};

    test_bsg_data_gen
   #(.channel_width_p(channel_width_p)
    ,.num_channels_p(num_channels_p)
    ) gen_out
    (.clk_i  (clk_i)
    ,.reset_i(reset_r)
    ,.yumi_i (links_int_li.v & links_int_lo.ready_and_rev)
    ,.o      (data_gen)
    );

    test_bsg_data_gen
   #(.channel_width_p(channel_width_p)
    ,.num_channels_p(num_channels_p)
    ) gen_in
    (.clk_i  (clk_i)
    ,.reset_i(reset_r)
    ,.yumi_i (links_int_lo.v)
    ,.o      (data_check)
    );

    // synopsys translate_off
    always_ff @(negedge clk_i)
      if (links_int_lo.v & ~reset_r)
        assert(data_check == links_int_lo.data[width_p-1:0])
          else $error("check mismatch %x %x ", data_check,links_int_lo.data[width_p-1:0]);
    // synopsys translate_on

    always_ff @(posedge clk_i)
      if (reset_r) 
          error_o <= 0;
      else 
          if (links_int_lo.v & data_check != links_int_lo.data[width_p-1:0])
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
    ,.up_i   (links_int_li.v & links_int_lo.ready_and_rev)
    ,.count_o(sent_o)
    );

    bsg_counter_clear_up 
   #(.max_val_p(1<<32-1)
    ,.init_val_p(0)
    ) received_count
    (.clk_i  (clk_i)
    ,.reset_i(reset_r)
    ,.clear_i(1'b0)
    ,.up_i   (links_int_lo.v)
    ,.count_o(received_o)
    );
  end

endmodule