`timescale 1ps/1ps

`define BSG_GATEWAY_CHIP_MODULE_NAME_TO_STR(name) "``name``"

module bsg_gateway_chip

 import bsg_manycore_pkg::*;

 #(parameter toplevel_lg_fifo_depth_p                 = "inv"
  ,parameter toplevel_lg_credit_to_token_decimation_p = "inv"
  ,parameter toplevel_addr_width_p                    = "inv"
  ,parameter toplevel_data_width_p                    = "inv"
  ,parameter toplevel_x_cord_width_p                  = "inv"
  ,parameter toplevel_y_cord_width_p                  = "inv"

  ,parameter lg_fifo_depth_p                 = toplevel_lg_fifo_depth_p
  ,parameter lg_credit_to_token_decimation_p = toplevel_lg_credit_to_token_decimation_p
  ,parameter addr_width_p                    = toplevel_addr_width_p
  ,parameter data_width_p                    = toplevel_data_width_p
  ,parameter x_cord_width_p                  = toplevel_x_cord_width_p
  ,parameter y_cord_width_p                  = toplevel_y_cord_width_p

  ,parameter link_sif_width_lp =
    `bsg_manycore_link_sif_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p)
  ,parameter fwd_width_lp =
    `bsg_manycore_packet_width(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p)
  ,parameter rev_width_lp =
    `bsg_manycore_return_packet_width(x_cord_width_p,y_cord_width_p,data_width_p)
  )

 ();

  `declare_bsg_manycore_link_sif_s(addr_width_p,data_width_p,x_cord_width_p,y_cord_width_p);
  bsg_manycore_link_sif_s upnode_link_sif_li, upnode_link_sif_lo;
  bsg_manycore_link_sif_s downnode_link_sif_li, downnode_link_sif_lo;

  logic async_uplink_reset;
  logic async_downlink_reset;
  logic async_downstream_reset;
  logic async_token_reset;

  logic upnode_clk, upnode_reset;
  logic upnode_en, upnode_error;
  logic [31:0] upnode_sent, upnode_received;

  logic fwd_link_clk_lo, fwd_link_v_lo, fwd_link_token_li;
  logic fwd_link_clk_li, fwd_link_v_li, fwd_link_token_lo;
  logic [fwd_width_lp-1:0] fwd_link_data_li, fwd_link_data_lo;

  logic rev_link_clk_lo, rev_link_v_lo, rev_link_token_li;
  logic rev_link_clk_li, rev_link_v_li, rev_link_token_lo;
  logic [rev_width_lp-1:0] rev_link_data_li, rev_link_data_lo;

  logic downnode_clk, downnode_reset;
  logic downnode_en, downnode_error;
  logic [31:0] downnode_sent, downnode_received;

  // Avoid X bits going into DUT
  bsg_manycore_link_sif_s upnode_link_sif_lo_raw, downnode_link_sif_lo_raw;
  always_comb
    begin
      for (integer i = 0; i < link_sif_width_lp; i++)
        begin
          if (upnode_link_sif_lo_raw[i] === 1'bX) upnode_link_sif_lo[i] = 1'b0;
          else upnode_link_sif_lo[i] = upnode_link_sif_lo_raw[i];
          if (downnode_link_sif_lo_raw[i] === 1'bX) downnode_link_sif_lo[i] = 1'b0;
          else downnode_link_sif_lo[i] = downnode_link_sif_lo_raw[i];
        end
    end

  // Add delay to synchronous signals going into DUT
  logic upnode_reset_dly;
  bsg_manycore_link_sif_s upnode_link_sif_lo_dly;

  bsg_nonsynth_delay_line #(.width_p(1),.delay_p(500)) upnode_reset_bndl
    (.i(upnode_reset),.o(upnode_reset_dly));
  bsg_nonsynth_delay_line #(.width_p(link_sif_width_lp),.delay_p(500)) upnode_link_bndl
    (.i(upnode_link_sif_lo),.o(upnode_link_sif_lo_dly));


  bsg_manycore_link_to_sdr_test_node
 #(.addr_width_p   (addr_width_p)
  ,.data_width_p   (data_width_p)
  ,.x_cord_width_p (x_cord_width_p)
  ,.y_cord_width_p (y_cord_width_p)
  ) upnode
  (.clk_i      (upnode_clk)
  ,.reset_i    (upnode_reset)
  ,.en_i       (upnode_en)
  
  ,.error_o    (upnode_error)
  ,.sent_o     (upnode_sent)
  ,.received_o (upnode_received)

  ,.links_sif_i(upnode_link_sif_li)
  ,.links_sif_o(upnode_link_sif_lo_raw)
  );


  //////////////////////////////////////////////////
  //
  // DUT
  //
  `DUT_MODULE_NAME
`ifndef NETLIST_LIBRARY_NAME
 #(.lg_fifo_depth_p                (lg_fifo_depth_p                )
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
  ,.addr_width_p                   (addr_width_p                   )
  ,.data_width_p                   (data_width_p                   )
  ,.x_cord_width_p                 (x_cord_width_p                 )
  ,.y_cord_width_p                 (y_cord_width_p                 )
  )
`endif
  DUT
  (.core_clk_i              (upnode_clk) 
  ,.core_reset_i            (upnode_reset_dly)
  ,.core_reset_o            ()

  ,.core_link_sif_i         (upnode_link_sif_lo_dly)
  ,.core_link_sif_o         (upnode_link_sif_li)

  ,.core_global_x_i         ('0)
  ,.core_global_y_i         ('0)
  ,.core_global_x_o         ()
  ,.core_global_y_o         ()

  ,.async_uplink_reset_i    (async_uplink_reset)
  ,.async_downlink_reset_i  (async_downlink_reset)
  ,.async_downstream_reset_i(async_downstream_reset)
  ,.async_token_reset_i     (async_token_reset)

  ,.async_uplink_reset_o    ()
  ,.async_downlink_reset_o  ()
  ,.async_downstream_reset_o()
  ,.async_token_reset_o     ()

  ,.io_fwd_link_clk_o       (fwd_link_clk_lo)
  ,.io_fwd_link_data_o      (fwd_link_data_lo)
  ,.io_fwd_link_v_o         (fwd_link_v_lo)
  ,.io_fwd_link_token_i     (fwd_link_token_li)

  ,.io_fwd_link_clk_i       (fwd_link_clk_li)
  ,.io_fwd_link_data_i      (fwd_link_data_li)
  ,.io_fwd_link_v_i         (fwd_link_v_li)
  ,.io_fwd_link_token_o     (fwd_link_token_lo)

  ,.io_rev_link_clk_o       (rev_link_clk_lo)
  ,.io_rev_link_data_o      (rev_link_data_lo)
  ,.io_rev_link_v_o         (rev_link_v_lo)
  ,.io_rev_link_token_i     (rev_link_token_li)

  ,.io_rev_link_clk_i       (rev_link_clk_li)
  ,.io_rev_link_data_i      (rev_link_data_li)
  ,.io_rev_link_v_i         (rev_link_v_li)
  ,.io_rev_link_token_o     (rev_link_token_lo)
  );

  logic uplink_reset_sync, downstream_reset_sync;
  bsg_sync_sync #(.width_p(1)) up_bss
  (.oclk_i     (downnode_clk            )
  ,.iclk_data_i(async_uplink_reset  )
  ,.oclk_data_o(uplink_reset_sync)
  );
  bsg_sync_sync #(.width_p(1)) down_bss
  (.oclk_i     (downnode_clk                )
  ,.iclk_data_i(async_downstream_reset  )
  ,.oclk_data_o(downstream_reset_sync)
  );

  bsg_link_sdr
 #(.width_p                        (fwd_width_lp)
  ,.lg_fifo_depth_p                (lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
  ) fwd_sdr
  (.core_clk_i             (downnode_clk)
  ,.core_uplink_reset_i    (uplink_reset_sync)
  ,.core_downstream_reset_i(downstream_reset_sync)
  ,.async_downlink_reset_i (async_downlink_reset)
  ,.async_token_reset_i    (async_token_reset)

  ,.core_data_i (downnode_link_sif_lo.fwd.data)
  ,.core_v_i    (downnode_link_sif_lo.fwd.v)
  ,.core_ready_o(downnode_link_sif_li.fwd.ready_and_rev)

  ,.core_data_o (downnode_link_sif_li.fwd.data)
  ,.core_v_o    (downnode_link_sif_li.fwd.v)
  ,.core_yumi_i (downnode_link_sif_li.fwd.v & downnode_link_sif_lo.fwd.ready_and_rev)

  ,.link_clk_o  (fwd_link_clk_li)
  ,.link_data_o (fwd_link_data_li)
  ,.link_v_o    (fwd_link_v_li)
  ,.link_token_i(fwd_link_token_lo)

  ,.link_clk_i  (fwd_link_clk_lo)
  ,.link_data_i (fwd_link_data_lo)
  ,.link_v_i    (fwd_link_v_lo)
  ,.link_token_o(fwd_link_token_li)
  );

  bsg_link_sdr
 #(.width_p                        (rev_width_lp)
  ,.lg_fifo_depth_p                (lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
  ) rev_sdr
  (.core_clk_i             (downnode_clk)
  ,.core_uplink_reset_i    (uplink_reset_sync)
  ,.core_downstream_reset_i(downstream_reset_sync)
  ,.async_downlink_reset_i (async_downlink_reset)
  ,.async_token_reset_i    (async_token_reset)

  ,.core_data_i (downnode_link_sif_lo.rev.data)
  ,.core_v_i    (downnode_link_sif_lo.rev.v)
  ,.core_ready_o(downnode_link_sif_li.rev.ready_and_rev)

  ,.core_data_o (downnode_link_sif_li.rev.data)
  ,.core_v_o    (downnode_link_sif_li.rev.v)
  ,.core_yumi_i (downnode_link_sif_li.rev.v & downnode_link_sif_lo.rev.ready_and_rev)

  ,.link_clk_o  (rev_link_clk_li)
  ,.link_data_o (rev_link_data_li)
  ,.link_v_o    (rev_link_v_li)
  ,.link_token_i(rev_link_token_lo)

  ,.link_clk_i  (rev_link_clk_lo)
  ,.link_data_i (rev_link_data_lo)
  ,.link_v_i    (rev_link_v_lo)
  ,.link_token_o(rev_link_token_li)
  );

  bsg_manycore_link_to_sdr_test_node
 #(.addr_width_p   (addr_width_p)
  ,.data_width_p   (data_width_p)
  ,.x_cord_width_p (x_cord_width_p)
  ,.y_cord_width_p (y_cord_width_p)
  ) downnode
  (.clk_i      (downnode_clk)
  ,.reset_i    (downnode_reset)
  ,.en_i       (downnode_en)

  ,.error_o    (downnode_error)
  ,.sent_o     (downnode_sent)
  ,.received_o (downnode_received)

  ,.links_sif_i(downnode_link_sif_li)
  ,.links_sif_o(downnode_link_sif_lo_raw)
  );

  // Simulation of Clock
  always #500 upnode_clk = ~upnode_clk;
  always #500 downnode_clk = ~downnode_clk;

  initial 
  begin

    $display("Start Simulation\n");

    // Init
    upnode_clk   = 1;
    upnode_reset = 1;
    upnode_en    = 0;

    downnode_clk   = 1;
    downnode_reset = 1;
    downnode_en    = 0;

    async_uplink_reset     = 1;
    async_downlink_reset   = 1;
    async_downstream_reset = 1;
    async_token_reset      = 0;

    #100000;

    // async token reset
    async_token_reset = 1;

    #100000;

    async_token_reset = 0;

    #100000;

    // upstream io reset
    async_uplink_reset = 0;

    #100000;

    // downstream IO reset
    async_downlink_reset = 0;

    #100000;

    // core link reset
    async_downstream_reset = 0;

    #100000

    // core reset
    @(posedge upnode_clk); #1;
    upnode_reset = 0;
    @(posedge downnode_clk); #1;
    downnode_reset = 0;

    #100000

    // node enable
    @(posedge upnode_clk); #1;
    upnode_en = 1;
    @(posedge downnode_clk); #1;
    downnode_en = 1;

    #5000000

    // node disable
    @(posedge upnode_clk); #1;
    upnode_en = 0;
    @(posedge downnode_clk); #1;
    downnode_en = 0;

    #500000

    $display("End Simulation\n");
    $display("DUT Name: %0s\n", `BSG_GATEWAY_CHIP_MODULE_NAME_TO_STR(`DUT_MODULE_NAME));

    assert(upnode_error == 0)
    else 
      begin
        $error("\nFAIL... Error in test upnode");
        $finish;
      end

    assert(downnode_error == 0)
    else 
      begin
        $error("\nFAIL... Error in test downnode");
        $finish;
      end

    assert(upnode_sent == upnode_received)
    else 
      begin
        $error("\nFAIL... Test upnode sent %d packets but received only %d\n", upnode_sent, upnode_received);
        $finish;
      end

    assert(downnode_sent == downnode_received)
    else 
      begin
        $error("\nFAIL... Test downnode sent %d packets but received only %d\n", downnode_sent, downnode_received);
        $finish;
      end

    $display("\nPASS!\n");
    $display("Test upnode sent and received %d packets\n", upnode_sent);
    $display("Test downnode sent and received %d packets\n", downnode_sent);
    $finish;

  end

endmodule
