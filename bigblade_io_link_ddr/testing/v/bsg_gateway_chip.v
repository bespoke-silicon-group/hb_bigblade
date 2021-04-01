`timescale 1ps/1ps

`define BSG_GATEWAY_CHIP_MODULE_NAME_TO_STR(name) "``name``"

`define NODE_CLK_PERIOD   1000
`define M_CORE_CLK_PERIOD 1000
`define S_CORE_CLK_PERIOD 1000
`define M_IO_CLK_PERIOD   1000
`define S_IO_CLK_PERIOD   1000
`define TAG_CLK_PERIOD    5000

module bsg_gateway_chip

 import bsg_tag_pkg::*;

 #(parameter toplevel_ds_width_p                      = "inv"
  ,parameter toplevel_num_adgs_p                      = "inv"
  ,parameter toplevel_width_p                         = "inv"
  ,parameter toplevel_channel_width_p                 = "inv"
  ,parameter toplevel_num_channels_p                  = "inv"
  ,parameter toplevel_lg_fifo_depth_p                 = "inv"
  ,parameter toplevel_lg_credit_to_token_decimation_p = "inv"
  ,parameter toplevel_use_extra_data_bit_p            = "inv"

  ,parameter ds_width_p                      = toplevel_ds_width_p
  ,parameter num_adgs_p                      = toplevel_num_adgs_p
  ,parameter width_p                         = toplevel_width_p
  ,parameter channel_width_p                 = toplevel_channel_width_p
  ,parameter num_channels_p                  = toplevel_num_channels_p
  ,parameter lg_fifo_depth_p                 = toplevel_lg_fifo_depth_p
  ,parameter lg_credit_to_token_decimation_p = toplevel_lg_credit_to_token_decimation_p
  ,parameter use_extra_data_bit_p            = toplevel_use_extra_data_bit_p
  )

 ();

  logic tag_clk, tag_reset;
  logic async_clk_gen_disable;

  logic node_clk, node_reset, node_en, node_error;
  logic [31:0] node_sent, node_received;

  logic m_core_clk, m_core_reset;
  logic m_io_clk;

  logic s_core_clk, s_core_reset;
  logic s_io_clk;

  logic m_core_v_li, m_core_ready_lo;
  logic [width_p-1:0] m_core_data_li;

  logic m_core_v_lo, m_core_ready_li;
  logic [width_p-1:0] m_core_data_lo;

  logic s_core_v_li, s_core_ready_lo;
  logic [width_p-1:0] s_core_data_li;

  logic s_core_v_lo, s_core_ready_li;
  logic [width_p-1:0] s_core_data_lo;

  logic [num_channels_p-1:0] m_link_clk, m_link_v, m_link_token;
  logic [num_channels_p-1:0][channel_width_p-1:0] m_link_data;

  logic [num_channels_p-1:0] s_link_clk, s_link_v, s_link_token;
  logic [num_channels_p-1:0][channel_width_p-1:0] s_link_data;


  //////////////////////////////////////////////////
  //
  // Nonsynth Clock Generator(s)
  //
  bsg_nonsynth_clock_gen #(.cycle_time_p(`NODE_CLK_PERIOD  )) node_clk_gen   (.o(node_clk  ));
  bsg_nonsynth_clock_gen #(.cycle_time_p(`M_CORE_CLK_PERIOD)) m_core_clk_gen (.o(m_core_clk));
  bsg_nonsynth_clock_gen #(.cycle_time_p(`S_CORE_CLK_PERIOD)) s_core_clk_gen (.o(s_core_clk));
  bsg_nonsynth_clock_gen #(.cycle_time_p(`M_IO_CLK_PERIOD  )) m_io_clk_gen   (.o(m_io_clk  ));
  bsg_nonsynth_clock_gen #(.cycle_time_p(`S_IO_CLK_PERIOD  )) s_io_clk_gen   (.o(s_io_clk  ));
  bsg_nonsynth_clock_gen #(.cycle_time_p(`TAG_CLK_PERIOD   )) tag_clk_gen    (.o(tag_clk   ));


  //////////////////////////////////////////////////
  //
  // Nonsynth Reset Generator(s)
  //
  bsg_nonsynth_reset_gen #(.num_clocks_p(1),.reset_cycles_lo_p(10),.reset_cycles_hi_p(5))
    tag_reset_gen (.clk_i(tag_clk),.async_reset_o(tag_reset));

  assign async_clk_gen_disable = 1'b0;


  //////////////////////////////////////////////////
  //
  // BSG Tag Track Replay
  //

  localparam tag_num_masters_lp          = 1;
  localparam tag_num_clients_lp          = 9;
  localparam tag_max_payload_width_lp    = 7;
  localparam tag_lg_max_payload_width_lp = `BSG_SAFE_CLOG2(tag_max_payload_width_lp+1);

  localparam tag_trace_rom_addr_width_lp = 32;
  localparam tag_trace_rom_data_width_lp = 4+tag_num_masters_lp+`BSG_SAFE_CLOG2(tag_num_clients_lp)+1+tag_lg_max_payload_width_lp+tag_max_payload_width_lp;

  logic [tag_trace_rom_addr_width_lp-1:0] rom_addr_li;
  logic [tag_trace_rom_data_width_lp-1:0] rom_data_lo;

  logic                          tag_trace_valid_lo;
  logic                          tag_trace_data_lo;
  logic [tag_num_masters_lp-1:0] tag_trace_en_r_lo;
  logic                          tag_trace_done_lo;

  // TAG TRACE ROM
  bsg_tag_boot_rom #(.width_p( tag_trace_rom_data_width_lp )
                    ,.addr_width_p( tag_trace_rom_addr_width_lp )
                    )
    tag_trace_rom
      (.addr_i( rom_addr_li )
      ,.data_o( rom_data_lo )
      );

  // TAG TRACE REPLAY
  bsg_tag_trace_replay #(.rom_addr_width_p   ( tag_trace_rom_addr_width_lp )
                        ,.rom_data_width_p   ( tag_trace_rom_data_width_lp )
                        ,.num_masters_p      ( tag_num_masters_lp )
                        ,.num_clients_p      ( tag_num_clients_lp )
                        ,.max_payload_width_p( tag_max_payload_width_lp )
                        )
    tag_trace_replay
      (.clk_i   ( tag_clk )
      ,.reset_i ( tag_reset    )
      ,.en_i    ( 1'b1            )

      ,.rom_addr_o( rom_addr_li )
      ,.rom_data_i( rom_data_lo )

      ,.valid_i ( 1'b0 )
      ,.data_i  ( '0 )
      ,.ready_o ()

      ,.valid_o    ( tag_trace_valid_lo )
      ,.en_r_o     ( tag_trace_en_r_lo )
      ,.tag_data_o ( tag_trace_data_lo )
      ,.yumi_i     ( tag_trace_valid_lo )

      ,.done_o  ( tag_trace_done_lo )
      ,.error_o ()
      ) ;


  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance
  //

  // All tag lines from the btm
  bsg_tag_s [tag_num_clients_lp-1:0] tag_lines;

  // BSG tag master instance
  bsg_tag_master #(.els_p( tag_num_clients_lp )
                  ,.lg_width_p( tag_lg_max_payload_width_lp )
                  )
    btm
      (.clk_i      ( tag_clk )
      ,.data_i     ( tag_trace_en_r_lo[0] & tag_trace_valid_lo ? tag_trace_data_lo : 1'b0 )
      ,.en_i       ( 1'b1 )
      ,.clients_r_o( tag_lines )
      );


  //////////////////////////////////////////////////
  //
  // BSG Tag Client Instance
  //
  bsg_tag_client #(.width_p( 1 ), .default_p( 0 ))
    btc_m_core
      (.bsg_tag_i     ( tag_lines[7] )
      ,.recv_clk_i    ( m_core_clk )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  (  )
      ,.recv_data_r_o ( m_core_reset )
      );

  bsg_tag_client #(.width_p( 1 ), .default_p( 0 ))
    btc_s_core
      (.bsg_tag_i     ( tag_lines[7] )
      ,.recv_clk_i    ( s_core_clk )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  (  )
      ,.recv_data_r_o ( s_core_reset )
      );

  bsg_tag_client #(.width_p( 1 ), .default_p( 0 ))
    btc_node
      (.bsg_tag_i     ( tag_lines[8] )
      ,.recv_clk_i    ( node_clk )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  (  )
      ,.recv_data_r_o ( node_reset )
      );


  bsg_gateway_chip_io_link_ddr_test_node
 #(.width_p        (width_p)
  ,.channel_width_p(8)
  ) node
  (// Node side
   .node_clk_i  (node_clk)
  ,.node_reset_i(node_reset)
  ,.node_en_i   (node_en)
  ,.error_o     (node_error)
  ,.sent_o      (node_sent)
  ,.received_o  (node_received)
  // Link side
  ,.clk_i       (m_core_clk)
  ,.reset_i     (m_core_reset)
  ,.v_i         (m_core_v_lo)
  ,.data_i      (m_core_data_lo)
  ,.ready_o     (m_core_ready_li)
  ,.v_o         (m_core_v_li)
  ,.data_o      (m_core_data_li)
  ,.yumi_i      (m_core_v_li & m_core_ready_lo)
  );

  //////////////////////////////////////////////////
  //
  // DUT
  //
  `DUT_MODULE_NAME
`ifndef NETLIST_LIBRARY_NAME
 #(.ds_width_p                     (ds_width_p                     )
  ,.num_adgs_p                     (num_adgs_p                     )
  ,.width_p                        (width_p                        )
  ,.channel_width_p                (channel_width_p                )
  ,.num_channels_p                 (num_channels_p                 )
  ,.lg_fifo_depth_p                (lg_fifo_depth_p                )
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
  ,.use_extra_data_bit_p           (use_extra_data_bit_p           )
  )
`endif
  DUT
  (.core_clk_i                 (m_core_clk)
  ,.ext_clk_i                  (m_io_clk)
  ,.async_output_disable_i     (async_clk_gen_disable)

  ,.tag_clk_i                  (tag_clk)
  ,.tag_io_tag_lines_i         (tag_lines[0])
  ,.tag_core_tag_lines_i       (tag_lines[1])
  ,.tag_async_reset_tag_lines_i(tag_lines[2])
  ,.tag_osc_tag_lines_i        (tag_lines[3])
  ,.tag_osc_trigger_tag_lines_i(tag_lines[4])
  ,.tag_ds_tag_lines_i         (tag_lines[5])
  ,.tag_sel_tag_lines_i        (tag_lines[6])

  ,.core_v_i                   (m_core_v_li)
  ,.core_data_i                (m_core_data_li)
  ,.core_ready_and_o           (m_core_ready_lo)

  ,.core_v_o                   (m_core_v_lo)
  ,.core_data_o                (m_core_data_lo)
  ,.core_yumi_i                (m_core_v_lo & m_core_ready_li)

  ,.io_link_clk_o              (m_link_clk)
  ,.io_link_data_o             (m_link_data)
  ,.io_link_v_o                (m_link_v)
  ,.io_link_token_i            (m_link_token)

  ,.io_link_clk_i              (s_link_clk)
  ,.io_link_data_i             (s_link_data)
  ,.io_link_v_i                (s_link_v)
  ,.io_link_token_o            (s_link_token)
  );

  typedef struct packed { 
    logic up_link_reset;
    logic down_link_reset;
    logic async_token_reset;
  } io_tag_payload_s;

  typedef struct packed { 
    logic up_link_reset;
    logic down_link_reset;
  } core_tag_payload_s;

  io_tag_payload_s   s_io_tag_data_lo;
  core_tag_payload_s s_core_tag_data_lo;

  bsg_tag_client 
 #(.width_p       ($bits(s_io_tag_data_lo))
  ,.default_p     (0)
  ) btc_s_link_io
  (.bsg_tag_i     (tag_lines[0])
  ,.recv_clk_i    (s_io_clk)
  ,.recv_reset_i  (1'b0)
  ,.recv_new_r_o  ()
  ,.recv_data_r_o (s_io_tag_data_lo)
  );

  bsg_tag_client 
 #(.width_p       ($bits(s_core_tag_data_lo))
  ,.default_p     (0)
  ) btc_s_link_core
  (.bsg_tag_i     (tag_lines[1])
  ,.recv_clk_i    (s_core_clk)
  ,.recv_reset_i  (1'b0)
  ,.recv_new_r_o  ()
  ,.recv_data_r_o (s_core_tag_data_lo)
  );

  bsg_link_ddr_upstream
 #(.width_p                        (width_p)
  ,.channel_width_p                (channel_width_p)
  ,.num_channels_p                 (num_channels_p)
  ,.lg_fifo_depth_p                (lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
  ,.use_extra_data_bit_p           (use_extra_data_bit_p)
  ,.use_encode_p                   (0)
  ,.bypass_twofer_fifo_p           (1)
  ,.bypass_gearbox_p               (1)
  ) s_uplink
  (.core_clk_i         (s_core_clk)
  ,.core_link_reset_i  (s_core_tag_data_lo.up_link_reset)

  ,.core_data_i        (s_core_data_li)
  ,.core_valid_i       (s_core_v_li)
  ,.core_ready_o       (s_core_ready_lo)

  ,.io_clk_i           (s_io_clk)
  ,.io_link_reset_i    (s_io_tag_data_lo.up_link_reset)
  ,.async_token_reset_i(s_io_tag_data_lo.async_token_reset)

  ,.io_clk_r_o         (s_link_clk)
  ,.io_data_r_o        (s_link_data)
  ,.io_valid_r_o       (s_link_v)
  ,.token_clk_i        (s_link_token)
  );

  logic [num_channels_p-1:0] s_downlink_reset_lo;
  for (genvar i = 0; i < num_channels_p; i++)
  begin: s_down_bss
    bsg_sync_sync #(.width_p(1)) bss
    (.oclk_i     (s_link_clk[i])
    ,.iclk_data_i(s_io_tag_data_lo.down_link_reset)
    ,.oclk_data_o(s_downlink_reset_lo[i])
    );
  end

  bsg_link_ddr_downstream 
 #(.width_p                        (width_p)
  ,.channel_width_p                (channel_width_p)
  ,.num_channels_p                 (num_channels_p)
  ,.lg_fifo_depth_p                (lg_fifo_depth_p)
  ,.lg_credit_to_token_decimation_p(lg_credit_to_token_decimation_p)
  ,.use_extra_data_bit_p           (use_extra_data_bit_p)
  ,.use_encode_p                   (1)
  ,.bypass_twofer_fifo_p           (1)
  ,.bypass_gearbox_p               (0)
  ,.use_hardened_fifo_p            (0)
  ) s_downlink
  (.core_clk_i       (s_core_clk)
  ,.core_link_reset_i(s_core_tag_data_lo.down_link_reset)

  ,.io_link_reset_i  (s_downlink_reset_lo)

  ,.core_data_o      (s_core_data_lo)
  ,.core_valid_o     (s_core_v_lo)
  ,.core_yumi_i      (s_core_v_lo & s_core_ready_li)

  ,.io_clk_i         (m_link_clk)
  ,.io_data_i        (m_link_data)
  ,.io_valid_i       (m_link_v)
  ,.core_token_r_o   (m_link_token)
  );


  bsg_two_fifo
 #(.width_p(width_p)
  ) s_fifo
  (.clk_i  (s_core_clk)
  ,.reset_i(s_core_reset)
  ,.ready_o(s_core_ready_li)
  ,.v_i    (s_core_v_lo)
  ,.data_i (s_core_data_lo)
  ,.v_o    (s_core_v_li)
  ,.data_o (s_core_data_li)
  ,.yumi_i (s_core_v_li & s_core_ready_lo)
  );


  initial 
  begin

    // Init
    node_en = 0;

    #100000;

    // Wait for programming
    while (tag_trace_done_lo == 1'b0) #5000;

    $display("Start Simulation\n");

    #100000;

    // node enable
    @(posedge node_clk); #1;
    node_en = 1;

    #5000000;

    // node disable
    @(posedge node_clk); #1;
    node_en = 0;

    #500000;

    $display("End Simulation\n");
    $display("DUT Name: %0s\n", `BSG_GATEWAY_CHIP_MODULE_NAME_TO_STR(`DUT_MODULE_NAME));

    assert(node_error == 0)
    else 
      begin
        $error("\nFAIL... Error in test node");
        $finish;
      end

    assert(node_sent == node_received)
    else 
      begin
        $error("\nFAIL... Test node sent %d packets but received only %d\n", node_sent, node_received);
        $finish;
      end

    $display("\nPASS!\n");
    $display("Test node sent and received %d packets\n", node_sent);
    $finish;

  end

endmodule