`timescale 1ps/1ps

module bsg_gateway_chip

 import bsg_chip_pkg::*;

 ();

  logic upnode_clk, upnode_reset, upnode_en;
  logic uplink_clk, uplink_reset, downlink_reset, async_token_reset;
  logic downstream_clk, downstream_reset;
  logic downnode_clk, downnode_reset, downnode_error;
  logic [31:0] upnode_sent, downnode_received;

  logic uplink_v_li, uplink_ready_lo;
  logic [width_gp-1:0] uplink_data_li;

  logic downstream_v_lo, downstream_ready_li;
  logic [width_gp-1:0] downstream_data_lo;

  bsg_link_sdr_test_node
 #(.num_channels_p      (8)
  ,.channel_width_p     (width_gp/8)
  ,.is_downstream_node_p(0)
  ) upnode
  (// Node side
   .node_clk_i  (upnode_clk)
  ,.node_reset_i(upnode_reset)
  ,.node_en_i   (upnode_en)
  ,.error_o     ()
  ,.sent_o      (upnode_sent)
  ,.received_o  ()
  // Link side
  ,.clk_i       (uplink_clk)
  ,.reset_i     (uplink_reset)
  ,.v_i         (1'b0)
  ,.data_i      ('0)
  ,.ready_o     ()
  ,.v_o         (uplink_v_li)
  ,.data_o      (uplink_data_li)
  ,.yumi_i      (uplink_v_li & uplink_ready_lo)
  );

  //////////////////////////////////////////////////
  //
  // DUT
  //
  bsg_chip DUT
  (.a_core_clk_i             (uplink_clk)
  ,.a_core_uplink_reset_i    (uplink_reset)
  ,.a_core_downlink_reset_i  (1'b1)
  ,.a_core_downstream_reset_i(1'b1)
  ,.a_async_token_reset_i    (async_token_reset)

  ,.a_core_data_i            (uplink_data_li)
  ,.a_core_v_i               (uplink_v_li)
  ,.a_core_ready_o           (uplink_ready_lo)

  ,.a_core_data_o            ()
  ,.a_core_v_o               ()
  ,.a_core_yumi_i            (1'b0)

  ,.b_core_clk_i             (downstream_clk)
  ,.b_core_uplink_reset_i    (1'b1)
  ,.b_core_downlink_reset_i  (downlink_reset)
  ,.b_core_downstream_reset_i(downstream_reset)
  ,.b_async_token_reset_i    (1'b0)

  ,.b_core_data_i            ('0)
  ,.b_core_v_i               (1'b0)
  ,.b_core_ready_o           ()

  ,.b_core_data_o            (downstream_data_lo)
  ,.b_core_v_o               (downstream_v_lo)
  ,.b_core_yumi_i            (downstream_v_lo & downstream_ready_li)
  );

  bsg_link_sdr_test_node
 #(.num_channels_p      (8)
  ,.channel_width_p     (width_gp/8)
  ,.is_downstream_node_p(1)
  ) downnode
  (// Node side
   .node_clk_i  (downnode_clk)
  ,.node_reset_i(downnode_reset)
  ,.node_en_i   ()
  ,.error_o     (downnode_error)
  ,.sent_o      ()
  ,.received_o  (downnode_received)
  // Link side
  ,.clk_i       (downstream_clk)
  ,.reset_i     (downstream_reset)
  ,.v_i         (downstream_v_lo)
  ,.data_i      (downstream_data_lo)
  ,.ready_o     (downstream_ready_li)
  ,.v_o         ()
  ,.data_o      ()
  ,.yumi_i      (1'b0)
  );

  // Simulation of Clock
  always #600 upnode_clk     = ~upnode_clk;
  always #600 uplink_clk     = ~uplink_clk;
  always #600 downstream_clk = ~downstream_clk;
  always #600 downnode_clk   = ~downnode_clk;

  initial 
  begin

    $display("Start Simulation\n");

    // Init
    upnode_clk     = 1;
    uplink_clk     = 1;
    downstream_clk = 1;
    downnode_clk   = 1;

    uplink_reset      = 1;
    async_token_reset = 0;
    upnode_reset      = 1;
    downnode_reset    = 1;
    downstream_reset  = 1;

    upnode_en = 0;

    #100000;

    // async token reset
    async_token_reset = 1;
    async_token_reset = 1;

    #100000;

    async_token_reset = 0;
    async_token_reset = 0;

    #100000;

    // upstream io reset
    @(posedge uplink_clk); #1;
    uplink_reset = 0;

    #10000;

    // reset signals propagate to downstream after io_clk is generated
    @(posedge uplink_clk); #1;
    downlink_reset = 1;

    #100000;

    // downstream IO reset
    @(posedge uplink_clk); #1;
    downlink_reset = 0;

    #100000;

    // core link reset
    @(posedge downstream_clk); #1;
    downstream_reset = 0;

    #100000

    // node reset
    @(posedge upnode_clk); #1;
    upnode_reset = 0;
    @(posedge downnode_clk); #1;
    downnode_reset = 0;

    #100000

    // node enable
    @(posedge upnode_clk); #1;
    upnode_en = 1;

    #5000000

    // node disable
    @(posedge upnode_clk); #1;
    upnode_en = 0;

    #500000

    assert(downnode_error == 0)
    else 
      begin
        $error("\nFAIL... Error in test node");
        $finish;
      end

    assert(upnode_sent == downnode_received)
    else 
      begin
        $error("\nFAIL... Test node sent %d packets but received only %d\n", upnode_sent, downnode_received);
        $finish;
      end

    $display("\nPASS!\n");
    $display("Test node sent and received %d packets\n", upnode_sent);
    $finish;

  end

endmodule
