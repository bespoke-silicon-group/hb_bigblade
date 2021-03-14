`timescale 1ps/1ps

`ifndef BLACKPARROT_CLK_PERIOD
  `define BLACKPARROT_CLK_PERIOD 2100.0
`endif


  //////////////////////////////////////////////////
  // This testbench is structured like this, with the overlying network being
  //   a giant crossbar and infinite memories instead of vcaches
  // [ IO ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ]
  // [ BP ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  // [ 00 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  // [ 00 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ] 
  // [ 00 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  // [ 00 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  // [ 00 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ][ 0 ]
  // [ 00 ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ][ M ]

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

  //////////////////////////////////////////////////
  //
  // Nonsynth Reset Generator(s)
  //

  logic blackparrot_reset;
  bsg_nonsynth_reset_gen #(.num_clocks_p(1),.reset_cycles_lo_p(10),.reset_cycles_hi_p(5))
    blackparrot_reset_gen
      (.clk_i(blackparrot_clk)
      ,.async_reset_o(blackparrot_reset)
      );

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
      @(negedge blackparrot_reset);
      $asserton();
    end

  logic trigger_saif;
  initial
    begin
      $set_gate_level_monitoring("rtl_on");
      $set_toggle_region(DUT);
      @(posedge blackparrot_clk);
      @(negedge blackparrot_reset);
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
  // bsg_tag
  localparam num_clients_lp = 3;
  localparam payload_width_lp = 7;
  localparam max_payload_width_lp = 10;
  localparam lg_payload_width_lp = `BSG_WIDTH(max_payload_width_lp);
  localparam rom_data_width_lp = 4+1+`BSG_SAFE_CLOG2(num_clients_lp)+1+lg_payload_width_lp+max_payload_width_lp;
  localparam rom_addr_width_lp = 12;
  
  logic tr_valid_lo, tr_data_lo, tr_done_lo;
  logic [rom_data_width_lp-1:0] rom_data;
  logic [rom_addr_width_lp-1:0] rom_addr;
  bsg_tag_trace_replay
   #(.rom_addr_width_p(rom_addr_width_lp)
     ,.rom_data_width_p(rom_data_width_lp)
     ,.num_clients_p(num_clients_lp)
     ,.max_payload_width_p(max_payload_width_lp)
     )
   tr
    (.clk_i(blackparrot_clk)
     ,.reset_i(blackparrot_reset)
     ,.en_i(1'b1)

     ,.rom_addr_o(rom_addr)
     ,.rom_data_i(rom_data)

     ,.valid_i(1'b0)
     ,.data_i('0)
     ,.ready_o()

     ,.valid_o(tr_valid_lo)
     ,.en_r_o()
     ,.tag_data_o(tr_data_lo)
     ,.yumi_i(tr_valid_lo)
     
     ,.done_o(tr_done_lo)
     ,.error_o()
     );  

  bsg_nonsynth_test_rom
   #(.filename_p("trace.tr")
     ,.data_width_p(rom_data_width_lp)
     ,.addr_width_p(rom_addr_width_lp)
     )
   rom
    (.addr_i(rom_addr)
     ,.data_o(rom_data)
     );

  bsg_tag_s [2:0] bsg_tag_li;
  bsg_tag_master
   #(.els_p(num_clients_lp), .lg_width_p(lg_payload_width_lp))
   btm
    (.clk_i(blackparrot_clk)
     ,.data_i(tr_valid_lo & tr_data_lo)
     ,.en_i(1'b1)
     ,.clients_r_o(bsg_tag_li)
     );

  //////////////////////////////////////////////////
  //
  // DUT
  //
  `declare_bp_bedrock_mem_if(paddr_width_p, cce_block_width_p, lce_id_width_p, lce_assoc_p, cce);
  `declare_bsg_manycore_link_sif_s(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp);
  bsg_manycore_link_sif_s [2:0][E:E] mc_hor_links_li, mc_hor_links_lo;

  bsg_blackparrot_unicore_tile
   DUT
    (.clk_i(blackparrot_clk)
     ,.reset_i(blackparrot_reset | ~tr_done_lo)

     ,.bsg_tag_i(bsg_tag_li)

     ,.links_i(mc_hor_links_li)
     ,.links_o(mc_hor_links_lo)
     );

  // Fake network --> Giant crossbar to mimic where hammerblade will sit
  // Network parameters
  localparam cb_num_in_x_lp = mc_num_tiles_x_gp+1;
  localparam cb_num_in_y_lp = mc_num_tiles_y_gp;
  localparam cb_num_in_lp = cb_num_in_x_lp*cb_num_in_y_lp;
  localparam cb_fwd_fifo_els_lp = 32;
  localparam cb_rev_fifo_els_lp = 32;

  typedef int fifo_els_arr_t[cb_num_in_lp-1:0];
  function logic [cb_num_in_lp-1:0] get_fwd_use_credits();
    logic [cb_num_in_lp-1:0] retval;
    for (int i = 0; i < cb_num_in_y_lp; i++) begin
      for (int j = 0; j < cb_num_in_x_lp; j++) begin
        retval[(i*cb_num_in_x_lp)+j] = 1'b0;
      end
    end

    return retval;
  endfunction

  function fifo_els_arr_t get_fwd_fifo_els();
    fifo_els_arr_t retval;

    for (int i = 0; i < cb_num_in_y_lp; i++) begin
      for (int j = 0; j < cb_num_in_x_lp; j++) begin
        retval[(i*cb_num_in_x_lp)+j] = cb_fwd_fifo_els_lp;
      end
    end

    return retval;
  endfunction

  function logic [cb_num_in_lp-1:0] get_rev_use_credits();
    logic [cb_num_in_lp-1:0] retval;
    for (int i = 0; i < cb_num_in_y_lp; i++) begin
      for (int j = 0; j < cb_num_in_x_lp; j++) begin
        retval[(i*cb_num_in_x_lp)+j] = 1'b0;
      end
    end
    return retval;
  endfunction

  function fifo_els_arr_t get_rev_fifo_els();
    fifo_els_arr_t retval;

    for (int i = 0; i < cb_num_in_y_lp; i++) begin
      for (int j = 0; j < cb_num_in_x_lp; j++) begin
        retval[(i*cb_num_in_x_lp)+j] = cb_rev_fifo_els_lp;
      end
    end

    return retval;
  endfunction

  bsg_manycore_link_sif_s [cb_num_in_y_lp-1:0][cb_num_in_x_lp-1:0] link_in;
  bsg_manycore_link_sif_s [cb_num_in_y_lp-1:0][cb_num_in_x_lp-1:0] link_out;
  bsg_manycore_crossbar
   #(.num_in_x_p(cb_num_in_x_lp)
     ,.num_in_y_p(cb_num_in_y_lp)

     ,.addr_width_p(mc_addr_width_gp)
     ,.data_width_p(mc_data_width_gp)
     ,.x_cord_width_p(mc_x_cord_width_gp)
     ,.y_cord_width_p(mc_y_cord_width_gp)

     ,.fwd_use_credits_p(get_fwd_use_credits())
     ,.fwd_fifo_els_p(get_fwd_fifo_els())
     ,.rev_use_credits_p(get_rev_use_credits())
     ,.rev_fifo_els_p(get_rev_fifo_els())
     )
   network
    (.clk_i(blackparrot_clk)
     ,.reset_i(blackparrot_reset | ~tr_done_lo)

     ,.links_sif_i(link_in)
     ,.links_sif_o(link_out)
     );

  // I/O Complex --> At coordinates (0, 0)
  bsg_nonsynth_manycore_io_complex
   #(.addr_width_p(mc_addr_width_gp)
     ,.data_width_p(mc_data_width_gp)
     ,.x_cord_width_p(mc_x_cord_width_gp)
     ,.y_cord_width_p(mc_y_cord_width_gp)
     ,.io_x_cord_p(0)
     ,.io_y_cord_p(0)
     )
   io
    (.clk_i(blackparrot_clk)
     ,.reset_i(blackparrot_reset | ~tr_done_lo)

     ,.io_link_sif_i(link_out[0][0])
     ,.io_link_sif_o(link_in[0][0])
     ,.print_stat_v_o()
     ,.print_stat_tag_o()
     ,.loader_done_o()
     );

  // BP <--> Fake network connections
  // mc_hor_link[0] = I/O
  // mc_hor_link[1] = DRAM 1
  // mc_hor_link[2] = DRAM 2
  for (genvar i = 1; i <= 3; i++)
    begin : bp_connect
      assign link_in[i][0] = mc_hor_links_lo[i-1];
      assign mc_hor_links_li[i-1] = link_out[i][0];
    end

  // Tie off all links below BP
  for (genvar i = 4; i < 8; i++)
    begin : bp_tieoff
      assign link_in[i][0] = '0;
    end

  // Tie off where the manycore would be
  for (genvar i = 1; i < mc_num_tiles_y_gp-1; i++)
    begin : tile_stubs_y
      for (genvar j = 1; j <= mc_num_tiles_x_gp; j++)
        begin : tile_stubs_x
          assign link_in[i][j] = '0;
        end
    end

  // Connect infinite memories where the caches would be
  for (genvar i = N; i <= S; i++)
    begin : mem_row
      for (genvar j = 1; j <= mc_num_tiles_x_gp; j++)
        begin : mem_col
          localparam x_idx_lp = j;
          localparam y_idx_lp = (i == S) ? mc_num_tiles_y_gp-1 : 0;
          wire [mc_x_cord_width_gp-1:0] my_x_li = x_idx_lp;
          wire [mc_y_cord_width_gp-1:0] my_y_li = y_idx_lp;

          bsg_nonsynth_mem_infinite
           #(.data_width_p(mc_data_width_gp)
             ,.addr_width_p(mc_addr_width_gp)
             ,.x_cord_width_p(mc_x_cord_width_gp)
             ,.y_cord_width_p(mc_y_cord_width_gp)
             ,.id_p(i*mc_num_tiles_x_gp+j)
             ,.mem_els_p(2**25)
             )
           mem_inf
            (.clk_i(blackparrot_clk)
             ,.reset_i(blackparrot_reset | ~tr_done_lo)

             ,.link_sif_i(link_out[y_idx_lp][x_idx_lp])
             ,.link_sif_o(link_in[y_idx_lp][x_idx_lp])

             ,.my_x_i(my_x_li)
             ,.my_y_i(my_y_li)
             );
        end
    end

    if (no_bind_p == 0)
      begin: do_bind
        bind bp_be_top
          bp_nonsynth_cosim
            #(.bp_params_p(bp_params_p))
            cosim
            (.clk_i(clk_i)
              ,.reset_i(reset_i)
              ,.freeze_i(calculator.pipe_sys.csr.cfg_bus_cast_i.freeze)

              // We want to pass these values as parameters, but cannot in Verilator 4.025
              // Parameter-resolved constants must not use dotted references
              ,.cosim_en_i($root.`BSG_TOP_SIM_MODULE.cosim_p == 1)
              ,.trace_en_i($root.`BSG_TOP_SIM_MODULE.commit_trace_p == 1)
              ,.checkpoint_i(1'b0)
              ,.num_core_i($root.`BSG_TOP_SIM_MODULE.num_core_p)
              ,.mhartid_i(calculator.pipe_sys.csr.cfg_bus_cast_i.core_id)
              ,.config_file_i($root.`BSG_TOP_SIM_MODULE.cosim_cfg_file_p)
              ,.instr_cap_i(0)
              ,.memsize_i(128)
              ,.amo_en_i(1'b0)

              ,.decode_i(calculator.reservation_n.decode)

              ,.is_debug_mode_i(calculator.pipe_sys.csr.is_debug_mode)
              ,.commit_pkt_i(calculator.commit_pkt_cast_o)

              ,.priv_mode_i(calculator.pipe_sys.csr.priv_mode_r)
              ,.mstatus_i(calculator.pipe_sys.csr.mstatus_lo)
              ,.mcause_i(calculator.pipe_sys.csr.mcause_lo)
              ,.scause_i(calculator.pipe_sys.csr.scause_lo)

              ,.ird_w_v_i(scheduler.iwb_pkt_cast_i.ird_w_v)
              ,.ird_addr_i(scheduler.iwb_pkt_cast_i.rd_addr)
              ,.ird_data_i(scheduler.iwb_pkt_cast_i.rd_data)

              ,.frd_w_v_i(scheduler.fwb_pkt_cast_i.frd_w_v)
              ,.frd_addr_i(scheduler.fwb_pkt_cast_i.rd_addr)
              ,.frd_data_i(scheduler.fwb_pkt_cast_i.rd_data)
              );

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

        bind DUT.host_link
          bp_cce_to_mc_bridge_tracer
          #(.bp_params_p(bp_params_p)
            ,.trace_file_p("host"))
          host_tracer
            (.clk_i(clk_i)
            ,.reset_i(reset_i)
            ,.trace_en_i($root.`BSG_TOP_SIM_MODULE.bridge_trace_p == 1)

            ,.io_cmd_i(io_cmd_i)
            ,.io_cmd_v_i(io_cmd_v_i)
            ,.io_cmd_ready_o(io_cmd_ready_o)

            ,.io_resp_o(io_resp_cast_o)
            ,.io_resp_v_o(io_resp_v_o)
            ,.io_resp_yumi_i(io_resp_yumi_i)

            ,.io_cmd_o(io_cmd_cast_o)
            ,.io_cmd_v_o(io_cmd_v_o)
            ,.io_cmd_yumi_i(io_cmd_yumi_i)

            ,.io_resp_i(io_resp_i)
            ,.io_resp_v_i(io_resp_v_i)
            ,.io_resp_ready_o(io_resp_ready_o)

            ,.out_v_li(out_v_li)
            ,.out_packet_li(out_packet_li)
            ,.out_ready_lo(out_ready_lo)

            ,.returned_data_r_lo(returned_data_r_lo)
            ,.returned_reg_id_r_lo(returned_reg_id_r_lo)
            ,.returned_v_r_lo(returned_v_r_lo)
            ,.returned_yumi_li(returned_yumi_li)
            ,.returned_pkt_type_r_lo(returned_pkt_type_r_lo)
            ,.returned_fifo_full_lo(returned_fifo_full_lo)
            ,.returned_credit_v_r_lo(returned_credit_v_r_lo)
            ,.returned_credit_reg_id_r_lo(returned_credit_reg_id_r_lo)
            
            ,.in_v_lo(in_v_lo)
            ,.in_data_lo(in_data_lo)
            ,.in_mask_lo(in_mask_lo)
            ,.in_addr_lo(in_addr_lo)
            ,.in_we_lo(in_we_lo)
            ,.in_load_info_lo(in_load_info_lo)
            ,.in_src_x_cord_lo(in_src_x_cord_lo)
            ,.in_src_y_cord_lo(in_src_y_cord_lo)
            ,.in_yumi_li(in_yumi_li)

            ,.returning_data_li(returning_data_li)
            ,.returning_v_li(returning_v_li)
            );

        bind DUT.d[0].dram_link
          bp_cce_to_mc_bridge_tracer
            #(.bp_params_p(bp_params_p)
              ,.trace_file_p("dram_0"))
            dram0_tracer
              (.clk_i(clk_i)
              ,.reset_i(reset_i)
              ,.trace_en_i($root.`BSG_TOP_SIM_MODULE.bridge_trace_p == 1)

              ,.io_cmd_i(io_cmd_i)
              ,.io_cmd_v_i(io_cmd_v_i)
              ,.io_cmd_ready_o(io_cmd_ready_o)

              ,.io_resp_o(io_resp_cast_o)
              ,.io_resp_v_o(io_resp_v_o)
              ,.io_resp_yumi_i(io_resp_yumi_i)

              ,.io_cmd_o(io_cmd_cast_o)
              ,.io_cmd_v_o(io_cmd_v_o)
              ,.io_cmd_yumi_i(io_cmd_yumi_i)

              ,.io_resp_i(io_resp_i)
              ,.io_resp_v_i(io_resp_v_i)
              ,.io_resp_ready_o(io_resp_ready_o)

              ,.out_v_li(out_v_li)
              ,.out_packet_li(out_packet_li)
              ,.out_ready_lo(out_ready_lo)

              ,.returned_data_r_lo(returned_data_r_lo)
              ,.returned_reg_id_r_lo(returned_reg_id_r_lo)
              ,.returned_v_r_lo(returned_v_r_lo)
              ,.returned_yumi_li(returned_yumi_li)
              ,.returned_pkt_type_r_lo(returned_pkt_type_r_lo)
              ,.returned_fifo_full_lo(returned_fifo_full_lo)
              ,.returned_credit_v_r_lo(returned_credit_v_r_lo)
              ,.returned_credit_reg_id_r_lo(returned_credit_reg_id_r_lo)
              
              ,.in_v_lo(in_v_lo)
              ,.in_data_lo(in_data_lo)
              ,.in_mask_lo(in_mask_lo)
              ,.in_addr_lo(in_addr_lo)
              ,.in_we_lo(in_we_lo)
              ,.in_load_info_lo(in_load_info_lo)
              ,.in_src_x_cord_lo(in_src_x_cord_lo)
              ,.in_src_y_cord_lo(in_src_y_cord_lo)
              ,.in_yumi_li(in_yumi_li)

              ,.returning_data_li(returning_data_li)
              ,.returning_v_li(returning_v_li)
              );

        bind DUT.d[1].dram_link
          bp_cce_to_mc_bridge_tracer
            #(.bp_params_p(bp_params_p)
              ,.trace_file_p("dram_1"))
            dram1_tracer
              (.clk_i(clk_i)
              ,.reset_i(reset_i)
              ,.trace_en_i($root.`BSG_TOP_SIM_MODULE.bridge_trace_p == 1)

              ,.io_cmd_i(io_cmd_i)
              ,.io_cmd_v_i(io_cmd_v_i)
              ,.io_cmd_ready_o(io_cmd_ready_o)

              ,.io_resp_o(io_resp_cast_o)
              ,.io_resp_v_o(io_resp_v_o)
              ,.io_resp_yumi_i(io_resp_yumi_i)

              ,.io_cmd_o(io_cmd_cast_o)
              ,.io_cmd_v_o(io_cmd_v_o)
              ,.io_cmd_yumi_i(io_cmd_yumi_i)

              ,.io_resp_i(io_resp_i)
              ,.io_resp_v_i(io_resp_v_i)
              ,.io_resp_ready_o(io_resp_ready_o)

              ,.out_v_li(out_v_li)
              ,.out_packet_li(out_packet_li)
              ,.out_ready_lo(out_ready_lo)

              ,.returned_data_r_lo(returned_data_r_lo)
              ,.returned_reg_id_r_lo(returned_reg_id_r_lo)
              ,.returned_v_r_lo(returned_v_r_lo)
              ,.returned_yumi_li(returned_yumi_li)
              ,.returned_pkt_type_r_lo(returned_pkt_type_r_lo)
              ,.returned_fifo_full_lo(returned_fifo_full_lo)
              ,.returned_credit_v_r_lo(returned_credit_v_r_lo)
              ,.returned_credit_reg_id_r_lo(returned_credit_reg_id_r_lo)
              
              ,.in_v_lo(in_v_lo)
              ,.in_data_lo(in_data_lo)
              ,.in_mask_lo(in_mask_lo)
              ,.in_addr_lo(in_addr_lo)
              ,.in_we_lo(in_we_lo)
              ,.in_load_info_lo(in_load_info_lo)
              ,.in_src_x_cord_lo(in_src_x_cord_lo)
              ,.in_src_y_cord_lo(in_src_y_cord_lo)
              ,.in_yumi_li(in_yumi_li)

              ,.returning_data_li(returning_data_li)
              ,.returning_v_li(returning_v_li)
              );
      end

endmodule

