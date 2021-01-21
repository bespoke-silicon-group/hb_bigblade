`timescale 1ps/1ps

`ifndef BLACKPARROT_CLK_PERIOD
  `define BLACKPARROT_CLK_PERIOD 2100.0
  `define BLACKPARROT_IO_DELAY 400.0
`endif

module bsg_gateway_chip

import bsg_chip_pkg::*;

import bp_common_pkg::*;
import bp_common_aviary_pkg::*;
import bp_be_pkg::*;
import bp_me_pkg::*;
import bsg_noc_pkg::*;
import bsg_wormhole_router_pkg::*;
import bsg_manycore_pkg::*;

#(localparam bp_params_e bp_params_p = e_bp_unicore_cfg `declare_bp_proc_params(bp_params_p)
  `declare_bp_bedrock_mem_if_widths(paddr_width_p, cce_block_width_p, lce_id_width_p, lce_assoc_p, cce))
  ();


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
  // DUT
  //
  `declare_bp_bedrock_mem_if(paddr_width_p, cce_block_width_p, lce_id_width_p, lce_assoc_p, cce);
  `declare_bsg_manycore_link_sif_s(mc_addr_width_gp, mc_data_width_gp, mc_x_cord_width_gp, mc_y_cord_width_gp);
  `declare_bsg_manycore_ruche_x_link_sif_s(mc_addr_width_gp,mc_data_width_gp,mc_x_cord_width_gp,mc_y_cord_width_gp);
  bsg_manycore_ruche_x_link_sif_s [0:0][E:E] mc_ruche_links_li, mc_ruche_links_lo;
  bsg_manycore_link_sif_s [3:0][E:E] mc_hor_links_li, mc_hor_links_lo;
  bsg_manycore_link_sif_s [S:N] mc_ver_links_li, mc_ver_links_lo;

  bsg_blackparrot_unicore_tile_node
   DUT
    (.bp_clk_i(blackparrot_clk)
     ,.bp_reset_i(blackparrot_reset)

     ,.mc_clk_i(blackparrot_clk)
     ,.mc_reset_i(blackparrot_reset)

     // TODO: connect
     ,.bsg_tag_i('0)

     ,.mc_ruche_links_i(mc_ruche_links_li)
     ,.mc_ruche_links_o(mc_ruche_links_lo)

     ,.mc_hor_links_i(mc_hor_links_li)
     ,.mc_hor_links_o(mc_hor_links_lo)

     ,.mc_ver_links_i(mc_ver_links_li)
     ,.mc_ver_links_o(mc_ver_links_lo)
     );

  // Network parameters
  localparam cb_num_in_x_lp = mc_num_tiles_x_gp+1;
  localparam cb_num_in_y_lp = mc_num_tiles_y_gp+1;
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
     ,.reset_i(blackparrot_reset)

     ,.links_sif_i(link_in)
     ,.links_sif_o(link_out)
     );

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
     ,.reset_i(blackparrot_reset)

     ,.io_link_sif_i(link_out[0][0])
     ,.io_link_sif_o(link_in[0][0])
     ,.print_stat_v_o()
     ,.print_stat_tag_o()
     ,.loader_done_o()
     );

  for (genvar i = 1; i < 5; i++)
    begin : bp_connect
      assign link_in[i][0] = mc_hor_links_lo[i-1];
      assign mc_hor_links_li[i-1] = link_in[i][0];
    end

  // Inject ruche link to an arbitrary spot in the "manycore". Rev link should come back via crossbar
  assign link_in[5][0].fwd = `bsg_manycore_ruche_x_link_fwd_inject_src_y(mc_x_cord_width_gp,mc_y_cord_width_gp,mc_ruche_links_lo[0][E].fwd, mc_y_cord_width_gp'(3'd5));
  assign link_in[5][0].rev = `bsg_manycore_ruche_x_link_rev_inject_dest_y(mc_x_cord_width_gp,mc_y_cord_width_gp,mc_ruche_links_lo[0][E].rev, mc_y_cord_width_gp'(3'd5));
  assign mc_ruche_links_li[0][E] = '0;

  for (genvar i = 6; i < 8; i++)
    begin : bp_tieoff
      assign link_in[i][0] = '0;
    end

  // tie off where the manycore would be
  for (genvar i = 1; i < mc_num_tiles_y_gp; i++)
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
          localparam y_idx_lp = (i == S) ? mc_num_tiles_y_gp : 0;
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
             ,.reset_i(blackparrot_reset)

             ,.link_sif_i(link_out[y_idx_lp][x_idx_lp])
             ,.link_sif_o(link_in[y_idx_lp][x_idx_lp])

             ,.my_x_i(my_x_li)
             ,.my_y_i(my_y_li)
             );
        end
    end
  assign link_in[mc_num_tiles_y_gp][0] = '0;

  // ver_links are unused with a single tile_node
  assign mc_ver_links_li = '0;

endmodule

