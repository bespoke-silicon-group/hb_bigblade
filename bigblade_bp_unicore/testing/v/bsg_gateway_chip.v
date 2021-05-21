`timescale 1ps/1ps

`ifndef BLACKPARROT_CLK_PERIOD
  `define BLACKPARROT_CLK_PERIOD 2000.0
`endif

`ifndef MANYCORE_CLK_PERIOD
  `define MANYCORE_CLK_PERIOD 1500.0
`endif

`ifndef TAG_CLK_PERIOD
  `define TAG_CLK_PERIOD 20000.0
`endif


  //////////////////////////////////////////////////
  // This testbench is structured like this, with the overlying network being
  //   a 2-D mesh of routers and infinite memories instead of vcaches
  //       PX=0                                       PX=1
  // PY=0 [ 00 ]  [ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ]
  //
  //      [ IO ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ BP ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ BP ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  // PY=1 [ BP ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ 00 ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ 00 ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ 00 ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ 00 ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //
  // PY=2 [ 00 ]  [ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ]
  //
  //
  //
  // TODO: Implement for testing
  //
  //
  // PY=3 [ 00 ]  [ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ]
  //
  //      [ IO ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ BP ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ BP ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  // PY=4 [ 00 ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ BP ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ BP ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ BP ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //      [ BP ]  [ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  //
  // PY=5 [ 00 ]  [ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ]

module bsg_gateway_chip
 import bsg_chip_pkg::*;

 import bp_common_pkg::*;
 import bp_be_pkg::*;
 import bp_me_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_wormhole_router_pkg::*;
 import bsg_manycore_pkg::*;
 import bsg_tag_pkg::*;

 #(localparam bp_params_e bp_params_p = e_bp_bigblade_unicore_cfg
  `declare_bp_proc_params(bp_params_p)
  `declare_bp_bedrock_mem_if_widths(paddr_width_p, cce_block_width_p, lce_id_width_p, lce_assoc_p, cce))
  ();

  //////////////////////////////////////////////////
  //
  // Testbench Parameters
  //

  parameter no_bind_p = 0;
  
  parameter commit_trace_p = 0;
  parameter bridge_trace_p = 0;
  
  parameter cosim_p = 0;
  parameter cosim_cfg_file_p = "prog.cfg";

  //////////////////////////////////////////////////
  //
  // Nonsynth Clock Generator(s)
  //

  logic blackparrot_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`BLACKPARROT_CLK_PERIOD)) blackparrot_clk_gen (.o(blackparrot_clk));

  logic manycore_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`MANYCORE_CLK_PERIOD)) manycore_clk_gen (.o(manycore_clk));

  logic tag_clk_raw, tag_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`TAG_CLK_PERIOD)) tag_clk_gen (.o(tag_clk_raw));

  //////////////////////////////////////////////////
  //
  // Nonsynth Reset Generator(s)
  //

  logic reset_done;

  logic manycore_reset;
  bsg_nonsynth_reset_gen #(.num_clocks_p(1),.reset_cycles_lo_p(10),.reset_cycles_hi_p(5))
    manycore_reset_gen
      (.clk_i(manycore_clk)
      ,.async_reset_o(manycore_reset)
      );

  logic tag_reset;
  bsg_nonsynth_reset_gen #(.num_clocks_p(1),.reset_cycles_lo_p(10),.reset_cycles_hi_p(5))
    tag_reset_gen
      (.clk_i(tag_clk_raw)
      ,.async_reset_o(tag_reset)
      );

  //////////////////////////////////////////////////
  //


  //////////////////////////////////////////////////
  //
  // Waveform Dump
  //

  initial
    begin
      $vcdpluson;
      $vcdplusmemon;
      $vcdplusautoflushon;
    end

  initial
    begin
      $assertoff();
      @(posedge blackparrot_clk);
      @(posedge reset_done);
      @(posedge blackparrot_clk);
      $asserton();
    end

  logic trigger_saif;
  initial
    begin
      $set_gate_level_monitoring("rtl_on");
      $set_toggle_region(DUT);
      @(posedge blackparrot_clk);
      @(posedge reset_done);
      @(posedge trigger_saif);
      $toggle_start();
    end

  final
    begin
      $toggle_stop();
      $toggle_report("run.saif", 1.0e-12, DUT);
    end
  assign trigger_saif = '0;

  //////////////////////////////////////////////////
  //
  // BSG Tag Track Replay
  //

  localparam tag_trace_rom_addr_width_lp = 32;
  localparam tag_trace_rom_data_width_lp = 4+tag_num_masters_gp+tag_lg_els_gp+1+tag_lg_width_gp+tag_max_payload_width_gp;

  logic [tag_trace_rom_addr_width_lp-1:0] rom_addr_li;
  logic [tag_trace_rom_data_width_lp-1:0] rom_data_lo;

  logic                          tag_trace_valid_lo;
  logic [tag_num_masters_gp-1:0] tag_trace_en_r_lo;
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
                        ,.num_masters_p      ( tag_num_masters_gp )
                        ,.num_clients_p      ( tag_els_gp )
                        ,.max_payload_width_p( tag_max_payload_width_gp )
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
      ,.tag_data_o ( p_tag_data_lo )
      ,.yumi_i     ( tag_trace_valid_lo )

      ,.done_o  ( tag_trace_done_lo )
      ,.error_o ()
      ) ;
  assign reset_done = tag_trace_done_lo;

  assign p_tag_en_lo = tag_trace_en_r_lo[1] & tag_trace_valid_lo;

  assign tag_clk = (tag_trace_done_lo === 1'b1)? 1'b1 : tag_clk_raw;

  // Emulate TAG behavior from inside BP
  // tag master instance
  bsg_chip_halfpod_tag_lines_s tag_lines_lo;
  bsg_tag_master_decentralized
 #(.els_p      (tag_els_gp)
  ,.local_els_p(tag_halfpod_local_els_gp)
  ,.lg_width_p (tag_lg_width_gp)
  ) btm
  (.clk_i           (tag_clk)
  ,.data_i          (tag_trace_en_r_lo[0] & tag_trace_valid_lo ? p_tag_data_lo : 1'b0)
  ,.node_id_offset_i('0)
  ,.clients_o       (tag_lines_lo)
  );

  logic async_uplink_reset, async_downlink_reset, async_downstream_reset, async_token_reset;
  bsg_tag_client_unsync #(.width_p(1)) btc0
  (.bsg_tag_i     (tag_lines_lo.sdr.token_reset)
  ,.data_async_r_o(async_token_reset));
  bsg_tag_client_unsync #(.width_p(1)) btc1
  (.bsg_tag_i     (tag_lines_lo.sdr.downstream_reset)
  ,.data_async_r_o(async_downstream_reset));
  bsg_tag_client_unsync #(.width_p(1)) btc2
  (.bsg_tag_i     (tag_lines_lo.sdr.downlink_reset)
  ,.data_async_r_o(async_downlink_reset));
  bsg_tag_client_unsync #(.width_p(1)) btc3
  (.bsg_tag_i     (tag_lines_lo.sdr.uplink_reset)
  ,.data_async_r_o(async_uplink_reset));

  //////////////////////////////////////////////////
  //
  // DUT
  //
  `declare_bp_bedrock_mem_if(paddr_width_p, cce_block_width_p, lce_id_width_p, lce_assoc_p, cce);
  `declare_bsg_manycore_link_sif_s(hb_addr_width_gp, hb_data_width_gp, hb_x_cord_width_gp, hb_y_cord_width_gp);
  bsg_manycore_link_sif_s [3:1][P:P] mc_proc_links_li, mc_proc_links_lo;

  logic [3:1] io_fwd_link_clk_lo, io_fwd_link_v_lo, io_fwd_link_token_li;
  logic [3:1][$bits(bsg_manycore_fwd_link_sif_s)-3:0] io_fwd_link_data_lo;
  logic [3:1] io_rev_link_clk_lo, io_rev_link_v_lo, io_rev_link_token_li;
  logic [3:1][$bits(bsg_manycore_rev_link_sif_s)-3:0] io_rev_link_data_lo;
  logic [3:1] io_fwd_link_clk_li, io_fwd_link_v_li, io_fwd_link_token_lo;
  logic [3:1][$bits(bsg_manycore_fwd_link_sif_s)-3:0] io_fwd_link_data_li;
  logic [3:1] io_rev_link_clk_li, io_rev_link_v_li, io_rev_link_token_lo;
  logic [3:1][$bits(bsg_manycore_rev_link_sif_s)-3:0] io_rev_link_data_li;
  bsg_blackparrot_halfpod
   DUT
    (.clk_i(blackparrot_clk)

     ,.tag_clk_i(~tag_clk)
     ,.tag_data_i(tag_trace_en_r_lo[0] & tag_trace_valid_lo ? p_tag_data_lo : 1'b0)
     ,.tag_node_id_offset_i('0)

     ,.sdr_disable_o()

     ,.io_fwd_link_clk_o(io_fwd_link_clk_lo)
     ,.io_fwd_link_data_o(io_fwd_link_data_lo)
     ,.io_fwd_link_v_o(io_fwd_link_v_lo)
     ,.io_fwd_link_token_i(io_fwd_link_token_li)

     ,.io_rev_link_clk_o(io_rev_link_clk_lo)
     ,.io_rev_link_data_o(io_rev_link_data_lo)
     ,.io_rev_link_v_o(io_rev_link_v_lo)
     ,.io_rev_link_token_i(io_rev_link_token_li)

     ,.io_fwd_link_clk_i(io_fwd_link_clk_li)
     ,.io_fwd_link_data_i(io_fwd_link_data_li)
     ,.io_fwd_link_v_i(io_fwd_link_v_li)
     ,.io_fwd_link_token_o(io_fwd_link_token_lo)

     ,.io_rev_link_clk_i(io_rev_link_clk_li)
     ,.io_rev_link_data_i(io_rev_link_data_li)
     ,.io_rev_link_v_i(io_rev_link_v_li)
     ,.io_rev_link_token_o(io_rev_link_token_lo)
     );

  for (genvar i = 1; i < 4; i++)
    begin : sdr
      bsg_link_sdr
       #(.width_p($bits(bsg_manycore_fwd_link_sif_s)-2)
         ,.lg_fifo_depth_p(3)
         ,.lg_credit_to_token_decimation_p(0)
         )
       fwd_sdr
        (.core_clk_i(manycore_clk)
         ,.core_uplink_reset_i(async_uplink_reset)
         ,.core_downstream_reset_i(async_downstream_reset)
         ,.async_downlink_reset_i(async_downlink_reset)
         ,.async_token_reset_i(async_token_reset)

         ,.core_data_i(mc_proc_links_li[i][P].fwd.data)
         ,.core_v_i(mc_proc_links_li[i][P].fwd.v)
         ,.core_ready_o(mc_proc_links_lo[i][P].fwd.ready_and_rev)

         ,.core_data_o(mc_proc_links_lo[i][P].fwd.data)
         ,.core_v_o(mc_proc_links_lo[i][P].fwd.v)
         ,.core_yumi_i(mc_proc_links_lo[i][P].fwd.v & mc_proc_links_li[i][P].fwd.ready_and_rev)

         ,.link_clk_o(io_fwd_link_clk_li[i])
         ,.link_data_o(io_fwd_link_data_li[i])
         ,.link_v_o(io_fwd_link_v_li[i])
         ,.link_token_i(io_fwd_link_token_lo[i])

         ,.link_clk_i(io_fwd_link_clk_lo[i])
         ,.link_data_i(io_fwd_link_data_lo[i])
         ,.link_v_i(io_fwd_link_v_lo[i])
         ,.link_token_o(io_fwd_link_token_li[i])
         );

      bsg_link_sdr
       #(.width_p($bits(bsg_manycore_rev_link_sif_s)-2)
         ,.lg_fifo_depth_p(3)
         ,.lg_credit_to_token_decimation_p(0)
         )
       rev_sdr
        (.core_clk_i(manycore_clk)
         ,.core_uplink_reset_i(async_uplink_reset)
         ,.core_downstream_reset_i(async_downstream_reset)
         ,.async_downlink_reset_i(async_downlink_reset)
         ,.async_token_reset_i(async_token_reset)

         ,.core_data_i(mc_proc_links_li[i][P].rev.data)
         ,.core_v_i(mc_proc_links_li[i][P].rev.v)
         ,.core_ready_o(mc_proc_links_lo[i][P].rev.ready_and_rev)

         ,.core_data_o(mc_proc_links_lo[i][P].rev.data)
         ,.core_v_o(mc_proc_links_lo[i][P].rev.v)
         ,.core_yumi_i(mc_proc_links_lo[i][P].rev.v & mc_proc_links_li[i][P].rev.ready_and_rev)

         ,.link_clk_o(io_rev_link_clk_li[i])
         ,.link_data_o(io_rev_link_data_li[i])
         ,.link_v_o(io_rev_link_v_li[i])
         ,.link_token_i(io_rev_link_token_lo[i])

         ,.link_clk_i(io_rev_link_clk_lo[i])
         ,.link_data_i(io_rev_link_data_lo[i])
         ,.link_v_i(io_rev_link_v_lo[i])
         ,.link_token_o(io_rev_link_token_li[i])
         );
    end

  // Router Network
  // All routers on this network uses 2 element FIFOs and no credit counting on any port
  // Real manycore uses 3 element FIFOs on the P port and credit counting on the P port

  localparam num_links_y_lp = hb_num_tiles_y_gp+2;
  localparam num_links_x_lp = hb_num_tiles_x_gp+1;
  localparam num_rtrs_y_lp = num_links_y_lp;
  localparam num_rtrs_x_lp = num_links_x_lp;

  bsg_manycore_link_sif_s [num_links_y_lp-1:0][num_links_x_lp-1:0][S:W] link_in;;
  bsg_manycore_link_sif_s [num_links_y_lp-1:0][num_links_x_lp-1:0][S:W] link_out;
  bsg_manycore_link_sif_s [num_links_y_lp-1:0][num_links_x_lp-1:0] proc_link_in;
  bsg_manycore_link_sif_s [num_links_y_lp-1:0][num_links_x_lp-1:0] proc_link_out;

  genvar i, j;

  // Router for PX = 0, PY = 0
  bsg_manycore_mesh_node
    #(.addr_width_p(hb_addr_width_gp)
     ,.data_width_p(hb_data_width_gp)
     ,.x_cord_width_p(hb_x_cord_width_gp)
     ,.y_cord_width_p(hb_y_cord_width_gp)
     // This router does not talk to anything, so stub all ports
     ,.stub_p(4'b0101) // SNEW
     // 2-D mesh routing
     ,.dims_p(2)
     )
    rtr00
    (.clk_i(manycore_clk)
    ,.reset_i(manycore_reset | ~tag_trace_done_lo)

    ,.links_sif_i(link_in[0][0])
    ,.links_sif_o(link_out[0][0])

    ,.proc_link_sif_i(proc_link_in[0][0])
    ,.proc_link_sif_o(proc_link_out[0][0])

    ,.global_x_i({hb_pod_x_cord_width_gp'(1'b0), hb_x_subcord_width_gp'(1'b0)})
    ,.global_y_i({hb_pod_y_cord_width_gp'(1'b0), hb_y_subcord_width_gp'(1'b0)})
    );

  // Router for PX = 0, PY = 2
  bsg_manycore_mesh_node
    #(.addr_width_p(hb_addr_width_gp)
     ,.data_width_p(hb_data_width_gp)
     ,.x_cord_width_p(hb_x_cord_width_gp)
     ,.y_cord_width_p(hb_y_cord_width_gp)
     // This router does not talk to anything, so stub all ports
     ,.stub_p(4'b1001) // SNEW
     )
    rtr02
    (.clk_i(manycore_clk)
    ,.reset_i(manycore_reset | ~tag_trace_done_lo)

    ,.links_sif_i(link_in[num_links_y_lp-1][0])
    ,.links_sif_o(link_out[num_links_y_lp-1][0])

    ,.proc_link_sif_i(proc_link_in[num_links_y_lp-1][0])
    ,.proc_link_sif_o(proc_link_out[num_links_y_lp-1][0])

    ,.global_x_i({hb_pod_x_cord_width_gp'(1'b0), hb_x_subcord_width_gp'(1'b0)})
    ,.global_y_i({hb_pod_y_cord_width_gp'(2'b10), hb_y_subcord_width_gp'(1'b0)})
    );
  
  // Stub proc links for above routers since they are unused
  assign proc_link_in[0][0] = '0;
  assign proc_link_in[num_links_y_lp-1][0] = '0;

  // Routers for PX = 0, PY = 1 --> I/O + BP
  for(i = 1; i < num_rtrs_y_lp-1; i++)
    begin : x0y1
      bsg_manycore_mesh_node
      #(.addr_width_p(hb_addr_width_gp)
      ,.data_width_p(hb_data_width_gp)
      ,.x_cord_width_p(hb_x_cord_width_gp)
      ,.y_cord_width_p(hb_y_cord_width_gp)
      // W port is not used
      ,.stub_p(4'b0001) // SNEW
      )
      rtr
      (.clk_i(manycore_clk)
      ,.reset_i(manycore_reset | ~tag_trace_done_lo)

      ,.links_sif_i(link_in[i][0])
      ,.links_sif_o(link_out[i][0])

      // BlackParrot and I/O should be on the P ports
      ,.proc_link_sif_i(proc_link_in[i][0])
      ,.proc_link_sif_o(proc_link_out[i][0])

      ,.global_x_i({hb_pod_x_cord_width_gp'(1'b0), hb_x_subcord_width_gp'(1'b0)})
      ,.global_y_i({hb_pod_y_cord_width_gp'(1'b1), hb_y_subcord_width_gp'(i-1)})
      );
    end

  // Router Network for PX = 1, PY = 0 --> North V$
  for(i = 1; i < num_rtrs_x_lp; i++)
    begin : x1y0
      bsg_manycore_mesh_node
      #(.addr_width_p(hb_addr_width_gp)
      ,.data_width_p(hb_data_width_gp)
      ,.x_cord_width_p(hb_x_cord_width_gp)
      ,.y_cord_width_p(hb_y_cord_width_gp)
      ,.stub_p(4'b0100) // SNEW
      )
      rtr
      (.clk_i(manycore_clk)
      ,.reset_i(manycore_reset | ~tag_trace_done_lo)

      ,.links_sif_i(link_in[0][i])
      ,.links_sif_o(link_out[0][i])

      ,.proc_link_sif_i(proc_link_in[0][i])
      ,.proc_link_sif_o(proc_link_out[0][i])

      ,.global_x_i({hb_pod_x_cord_width_gp'(1'b1), hb_x_subcord_width_gp'(i-1)})
      ,.global_y_i({hb_pod_y_cord_width_gp'(1'b0), hb_y_subcord_width_gp'('1)})
      );
    end

  // Router Network for PX = 1, PY = 2 --> South V$
  for(i = 1; i < num_rtrs_x_lp; i++)
    begin : x1y2
      bsg_manycore_mesh_node
      #(.addr_width_p(hb_addr_width_gp)
      ,.data_width_p(hb_data_width_gp)
      ,.x_cord_width_p(hb_x_cord_width_gp)
      ,.y_cord_width_p(hb_y_cord_width_gp)
      ,.stub_p(4'b1000) // SNEW
      )
      rtr
      (.clk_i(manycore_clk)
      ,.reset_i(manycore_reset | ~tag_trace_done_lo)

      ,.links_sif_i(link_in[num_links_y_lp-1][i])
      ,.links_sif_o(link_out[num_links_y_lp-1][i])

      ,.proc_link_sif_i(proc_link_in[num_links_y_lp-1][i])
      ,.proc_link_sif_o(proc_link_out[num_links_y_lp-1][i])

      ,.global_x_i({hb_pod_x_cord_width_gp'(1'b1), hb_x_subcord_width_gp'(i-1)})
      ,.global_y_i({hb_pod_y_cord_width_gp'(2'b10), hb_y_subcord_width_gp'('0)})
      );
    end

  // Router Network for PX = 1, PY = 1 --> Compute array
  for(i = 1; i < num_rtrs_x_lp; i++)
    begin : x
      for (j = 1; j < num_rtrs_y_lp-1; j++)
        begin : y
          bsg_manycore_mesh_node
          #(.addr_width_p(hb_addr_width_gp)
          ,.data_width_p(hb_data_width_gp)
          ,.x_cord_width_p(hb_x_cord_width_gp)
          ,.y_cord_width_p(hb_y_cord_width_gp)
          // All SNEW ports will be used for routing
          // P ports are stubbed because there are no compute tiles
          ,.stub_p(4'b0000) // SNEW
          // 2-D mesh routing
          ,.dims_p(2)
          )
          rtr
          (.clk_i(manycore_clk)
          ,.reset_i(manycore_reset | ~tag_trace_done_lo)

          ,.links_sif_i(link_in[j][i])
          ,.links_sif_o(link_out[j][i])

          ,.proc_link_sif_i(proc_link_in[j][i])
          ,.proc_link_sif_o(proc_link_out[j][i])

          ,.global_x_i({hb_pod_x_cord_width_gp'(1'b1), hb_x_subcord_width_gp'(i-1)})
          ,.global_y_i({hb_pod_y_cord_width_gp'(1'b1), hb_y_subcord_width_gp'(j-1)})
          );
        end
    end

  // Stitch the links together
  bsg_manycore_link_sif_s [E:W][num_links_y_lp-1:0] link_hor_in;
  bsg_manycore_link_sif_s [E:W][num_links_y_lp-1:0] link_hor_out;
  bsg_manycore_link_sif_s [S:N][num_links_x_lp-1:0] link_ver_in;
  bsg_manycore_link_sif_s [S:N][num_links_x_lp-1:0] link_ver_out;
  bsg_mesh_stitch
   #(.width_p($bits(bsg_manycore_link_sif_s))
    ,.x_max_p(num_rtrs_x_lp)
    ,.y_max_p(num_rtrs_y_lp)
    )
    mesh
    (.outs_i(link_out)
    ,.ins_o(link_in)
    
    ,.hor_i(link_hor_in)
    ,.hor_o(link_hor_out)
    ,.ver_i(link_ver_in)
    ,.ver_o(link_ver_out)
    );

  // Tie off the greater links
  assign link_hor_in = '0;
  assign link_ver_in = '0;
    
  // I/O Complex (At PX = 0, P_subX = 0, PY = 1, P_subY = 0)
  bsg_nonsynth_manycore_io_complex
   #(.addr_width_p(hb_addr_width_gp)
     ,.data_width_p(hb_data_width_gp)
     ,.x_cord_width_p(hb_x_cord_width_gp)
     ,.y_cord_width_p(hb_y_cord_width_gp)
     ,.io_x_cord_p({hb_pod_x_cord_width_gp'(1'b0), hb_x_subcord_width_gp'(1'b0)})
     ,.io_y_cord_p({hb_pod_y_cord_width_gp'(1'b1), hb_y_subcord_width_gp'(1'b0)})
     )
   io
    (.clk_i(manycore_clk)
     ,.reset_i(manycore_reset | ~tag_trace_done_lo)

     ,.io_link_sif_i(proc_link_out[1][0])
     ,.io_link_sif_o(proc_link_in[1][0])
     ,.print_stat_v_o()
     ,.print_stat_tag_o()
     ,.loader_done_o()
     );

  // BP <--> Fake network connections
  // mc_proc_link[0] = I/O
  // mc_proc_link[1] = DRAM 1
  // mc_proc_link[2] = DRAM 2
  for (i = 2; i <= 4; i++)
    begin : bp_connect
      assign proc_link_in[i][0] = mc_proc_links_lo[i-1];
      assign mc_proc_links_li[i-1] = proc_link_out[i][0];
    end
  
  // Tie off all links below BP
  for (i = 5; i < num_links_y_lp-1; i++)
    begin : below_bp
      assign proc_link_in[i][0] = '0;
    end

  // Tie off proc_links where the compute tiles would be
  for (i = 1; i < num_links_y_lp - 1; i++)
    begin : tile_stubs_y
      for (j = 1; j < num_links_x_lp; j++)
        begin : tile_stubs_x
          assign proc_link_in[i][j] = '0;
        end
    end

  // Connect infinite memories where the V$s would be
  for (i = N; i <= S; i++)
    begin : mem_row
      for (j = 1; j <= hb_num_tiles_x_gp; j++)
        begin : mem_col
          localparam x_idx_lp = j;
          localparam y_idx_lp = (i == S) ? hb_num_tiles_y_gp+1 : 0;
          localparam x_pod_lp = 1;
          localparam y_pod_lp = (i == S) ? 2 : 0;
          wire [hb_x_cord_width_gp-1:0] my_x_li = {hb_pod_x_cord_width_gp'(x_pod_lp), hb_x_subcord_width_gp'(x_idx_lp)};
          wire [hb_y_cord_width_gp-1:0] my_y_li = {hb_pod_y_cord_width_gp'(y_pod_lp), hb_y_subcord_width_gp'(1'b0)};

          bsg_nonsynth_mem_infinite
           #(.data_width_p(hb_data_width_gp)
             ,.addr_width_p(hb_addr_width_gp)
             ,.x_cord_width_p(hb_x_cord_width_gp)
             ,.y_cord_width_p(hb_y_cord_width_gp)
             ,.id_p(i*hb_num_tiles_x_gp+j)
             ,.mem_els_p(2**25)
             )
           mem_inf
            (.clk_i(manycore_clk)
             ,.reset_i(manycore_reset | ~tag_trace_done_lo)

             ,.link_sif_i(proc_link_out[y_idx_lp][x_idx_lp])
             ,.link_sif_o(proc_link_in[y_idx_lp][x_idx_lp])

             ,.my_x_i(my_x_li)
             ,.my_y_i(my_y_li)
             );
        end
    end

    if (no_bind_p == 0)
      begin: do_bind
        //bind bp_be_top
        //  bp_nonsynth_cosim
        //    #(.bp_params_p(bp_params_p))
        //    cosim
        //    (.clk_i(clk_i)
        //      ,.reset_i(reset_i)
        //      ,.freeze_i(calculator.pipe_sys.csr.cfg_bus_cast_i.freeze)

        //      // We want to pass these values as parameters, but cannot in Verilator 4.025
        //      // Parameter-resolved constants must not use dotted references
        //      ,.cosim_en_i($root.`BSG_TOP_SIM_MODULE.cosim_p == 1)
        //      ,.trace_en_i($root.`BSG_TOP_SIM_MODULE.commit_trace_p == 1)
        //      ,.checkpoint_i(1'b0)
        //      ,.num_core_i($root.`BSG_TOP_SIM_MODULE.num_core_p)
        //      ,.mhartid_i(calculator.pipe_sys.csr.cfg_bus_cast_i.core_id)
        //      ,.config_file_i($root.`BSG_TOP_SIM_MODULE.cosim_cfg_file_p)
        //      ,.instr_cap_i(0)
        //      ,.memsize_i(128)
        //      ,.amo_en_i(1'b0)

        //      ,.decode_i(calculator.reservation_n.decode)

        //      ,.is_debug_mode_i(calculator.pipe_sys.csr.is_debug_mode)
        //      ,.commit_pkt_i(calculator.commit_pkt_cast_o)

        //      ,.priv_mode_i(calculator.pipe_sys.csr.priv_mode_r)
        //      ,.mstatus_i(calculator.pipe_sys.csr.mstatus_lo)
        //      ,.mcause_i(calculator.pipe_sys.csr.mcause_lo)
        //      ,.scause_i(calculator.pipe_sys.csr.scause_lo)

        //      ,.ird_w_v_i(scheduler.iwb_pkt_cast_i.ird_w_v)
        //      ,.ird_addr_i(scheduler.iwb_pkt_cast_i.rd_addr)
        //      ,.ird_data_i(scheduler.iwb_pkt_cast_i.rd_data)

        //      ,.frd_w_v_i(scheduler.fwb_pkt_cast_i.frd_w_v)
        //      ,.frd_addr_i(scheduler.fwb_pkt_cast_i.rd_addr)
        //      ,.frd_data_i(scheduler.fwb_pkt_cast_i.rd_data)
        //      );

        bind bp_be_top
          bp_nonsynth_watchdog
          #(.bp_params_p(bp_params_p)
            ,.timeout_cycles_p(100000)
            ,.heartbeat_instr_p(100000)
            )
          watchdog
            (.clk_i(clk_i)
            ,.reset_i(reset_i)
            ,.freeze_i(calculator.pipe_sys.csr.cfg_bus_cast_i.freeze)
            ,.wfi_i(director.is_wait)

            ,.mhartid_i(calculator.pipe_sys.csr.cfg_bus_cast_i.core_id)

            ,.npc_i(calculator.pipe_sys.csr.apc_r)
            ,.instret_i(calculator.commit_pkt_cast_o.instret)
            );

//        bind DUT.host_link
//          bp_cce_to_mc_bridge_tracer
//          #(.bp_params_p(bp_params_p)
//            ,.trace_file_p("host")
//            ,.mc_x_cord_width_p($root.`BSG_TOP_SIM_MODULE.mc_x_cord_width_gp)
//            ,.mc_y_cord_width_p($root.`BSG_TOP_SIM_MODULE.mc_y_cord_width_gp)
//            ,.mc_data_width_p($root.`BSG_TOP_SIM_MODULE.mc_data_width_gp)
//            ,.mc_addr_width_p($root.`BSG_TOP_SIM_MODULE.mc_addr_width_gp)
//            )
//          host_tracer
//            (.clk_i(clk_i)
//            ,.reset_i(reset_i)
//            ,.trace_en_i($root.`BSG_TOP_SIM_MODULE.bridge_trace_p == 1)
//
//            ,.io_cmd_i(io_cmd_i)
//            ,.io_cmd_v_i(io_cmd_v_i)
//            ,.io_cmd_ready_o(io_cmd_ready_o)
//
//            ,.io_resp_o(io_resp_cast_o)
//            ,.io_resp_v_o(io_resp_v_o)
//            ,.io_resp_yumi_i(io_resp_yumi_i)
//
//            ,.io_cmd_o(io_cmd_cast_o)
//            ,.io_cmd_v_o(io_cmd_v_o)
//            ,.io_cmd_yumi_i(io_cmd_yumi_i)
//
//            ,.io_resp_i(io_resp_i)
//            ,.io_resp_v_i(io_resp_v_i)
//            ,.io_resp_ready_o(io_resp_ready_o)
//
//            ,.out_v_li(out_v_li)
//            ,.out_packet_li(out_packet_li)
//            ,.out_ready_lo(out_ready_lo)
//
//            ,.returned_data_r_lo(returned_data_r_lo)
//            ,.returned_reg_id_r_lo(returned_reg_id_r_lo)
//            ,.returned_v_r_lo(returned_v_r_lo)
//            ,.returned_yumi_li(returned_yumi_li)
//            ,.returned_pkt_type_r_lo(returned_pkt_type_r_lo)
//            ,.returned_fifo_full_lo(returned_fifo_full_lo)
//            ,.returned_credit_v_r_lo(returned_credit_v_r_lo)
//            ,.returned_credit_reg_id_r_lo(returned_credit_reg_id_r_lo)
//            
//            ,.in_v_lo(in_v_lo)
//            ,.in_data_lo(in_data_lo)
//            ,.in_mask_lo(in_mask_lo)
//            ,.in_addr_lo(in_addr_lo)
//            ,.in_we_lo(in_we_lo)
//            ,.in_load_info_lo(in_load_info_lo)
//            ,.in_src_x_cord_lo(in_src_x_cord_lo)
//            ,.in_src_y_cord_lo(in_src_y_cord_lo)
//            ,.in_yumi_li(in_yumi_li)
//
//            ,.returning_data_li(returning_data_li)
//            ,.returning_v_li(returning_v_li)
//            );
//
//        bind DUT.d[0].dram_link
//          bp_cce_to_mc_bridge_tracer
//            #(.bp_params_p(bp_params_p)
//              ,.trace_file_p("dram_0")
//              ,.mc_x_cord_width_p($root.`BSG_TOP_SIM_MODULE.mc_x_cord_width_gp)
//              ,.mc_y_cord_width_p($root.`BSG_TOP_SIM_MODULE.mc_y_cord_width_gp)
//              ,.mc_data_width_p($root.`BSG_TOP_SIM_MODULE.mc_data_width_gp)
//              ,.mc_addr_width_p($root.`BSG_TOP_SIM_MODULE.mc_addr_width_gp)
//              )
//            dram0_tracer
//              (.clk_i(clk_i)
//              ,.reset_i(reset_i)
//              ,.trace_en_i($root.`BSG_TOP_SIM_MODULE.bridge_trace_p == 1)
//
//              ,.io_cmd_i(io_cmd_i)
//              ,.io_cmd_v_i(io_cmd_v_i)
//              ,.io_cmd_ready_o(io_cmd_ready_o)
//
//              ,.io_resp_o(io_resp_cast_o)
//              ,.io_resp_v_o(io_resp_v_o)
//              ,.io_resp_yumi_i(io_resp_yumi_i)
//
//              ,.io_cmd_o(io_cmd_cast_o)
//              ,.io_cmd_v_o(io_cmd_v_o)
//              ,.io_cmd_yumi_i(io_cmd_yumi_i)
//
//              ,.io_resp_i(io_resp_i)
//              ,.io_resp_v_i(io_resp_v_i)
//              ,.io_resp_ready_o(io_resp_ready_o)
//
//              ,.out_v_li(out_v_li)
//              ,.out_packet_li(out_packet_li)
//              ,.out_ready_lo(out_ready_lo)
//
//              ,.returned_data_r_lo(returned_data_r_lo)
//              ,.returned_reg_id_r_lo(returned_reg_id_r_lo)
//              ,.returned_v_r_lo(returned_v_r_lo)
//              ,.returned_yumi_li(returned_yumi_li)
//              ,.returned_pkt_type_r_lo(returned_pkt_type_r_lo)
//              ,.returned_fifo_full_lo(returned_fifo_full_lo)
//              ,.returned_credit_v_r_lo(returned_credit_v_r_lo)
//              ,.returned_credit_reg_id_r_lo(returned_credit_reg_id_r_lo)
//              
//              ,.in_v_lo(in_v_lo)
//              ,.in_data_lo(in_data_lo)
//              ,.in_mask_lo(in_mask_lo)
//              ,.in_addr_lo(in_addr_lo)
//              ,.in_we_lo(in_we_lo)
//              ,.in_load_info_lo(in_load_info_lo)
//              ,.in_src_x_cord_lo(in_src_x_cord_lo)
//              ,.in_src_y_cord_lo(in_src_y_cord_lo)
//              ,.in_yumi_li(in_yumi_li)
//
//              ,.returning_data_li(returning_data_li)
//              ,.returning_v_li(returning_v_li)
//              );
//
//        bind DUT.d[1].dram_link
//          bp_cce_to_mc_bridge_tracer
//            #(.bp_params_p(bp_params_p)
//              ,.trace_file_p("dram_1")
//              ,.mc_x_cord_width_p($root.`BSG_TOP_SIM_MODULE.mc_x_cord_width_gp)
//              ,.mc_y_cord_width_p($root.`BSG_TOP_SIM_MODULE.mc_y_cord_width_gp)
//              ,.mc_data_width_p($root.`BSG_TOP_SIM_MODULE.mc_data_width_gp)
//              ,.mc_addr_width_p($root.`BSG_TOP_SIM_MODULE.mc_addr_width_gp)
//              )
//            dram1_tracer
//              (.clk_i(clk_i)
//              ,.reset_i(reset_i)
//              ,.trace_en_i($root.`BSG_TOP_SIM_MODULE.bridge_trace_p == 1)
//
//              ,.io_cmd_i(io_cmd_i)
//              ,.io_cmd_v_i(io_cmd_v_i)
//              ,.io_cmd_ready_o(io_cmd_ready_o)
//
//              ,.io_resp_o(io_resp_cast_o)
//              ,.io_resp_v_o(io_resp_v_o)
//              ,.io_resp_yumi_i(io_resp_yumi_i)
//
//              ,.io_cmd_o(io_cmd_cast_o)
//              ,.io_cmd_v_o(io_cmd_v_o)
//              ,.io_cmd_yumi_i(io_cmd_yumi_i)
//
//              ,.io_resp_i(io_resp_i)
//              ,.io_resp_v_i(io_resp_v_i)
//              ,.io_resp_ready_o(io_resp_ready_o)
//
//              ,.out_v_li(out_v_li)
//              ,.out_packet_li(out_packet_li)
//              ,.out_ready_lo(out_ready_lo)
//
//              ,.returned_data_r_lo(returned_data_r_lo)
//              ,.returned_reg_id_r_lo(returned_reg_id_r_lo)
//              ,.returned_v_r_lo(returned_v_r_lo)
//              ,.returned_yumi_li(returned_yumi_li)
//              ,.returned_pkt_type_r_lo(returned_pkt_type_r_lo)
//              ,.returned_fifo_full_lo(returned_fifo_full_lo)
//              ,.returned_credit_v_r_lo(returned_credit_v_r_lo)
//              ,.returned_credit_reg_id_r_lo(returned_credit_reg_id_r_lo)
//              
//              ,.in_v_lo(in_v_lo)
//              ,.in_data_lo(in_data_lo)
//              ,.in_mask_lo(in_mask_lo)
//              ,.in_addr_lo(in_addr_lo)
//              ,.in_we_lo(in_we_lo)
//              ,.in_load_info_lo(in_load_info_lo)
//              ,.in_src_x_cord_lo(in_src_x_cord_lo)
//              ,.in_src_y_cord_lo(in_src_y_cord_lo)
//              ,.in_yumi_li(in_yumi_li)
//
//              ,.returning_data_li(returning_data_li)
//              ,.returning_v_li(returning_v_li)
//              );
      end

endmodule

