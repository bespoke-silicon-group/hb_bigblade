`timescale 1ps/1ps

`define TAG_CLK_PERIOD  5000
`define EXT_CLK_PERIOD  10000

module bsg_gateway_chip ();
  import bsg_tag_pkg::*;
  import bsg_chip_pkg::*;

  logic tag_clk, tag_reset, ext_clk;
  logic async_clk_gen_disable;

  // ==========================================================
  // NONSYNTH CLK/RESET GENERATORS
  // ==========================================================

  bsg_nonsynth_clock_gen #(.cycle_time_p(`TAG_CLK_PERIOD))
    tag_clk_gen
      (.o(tag_clk)
      );

  bsg_nonsynth_clock_gen #(.cycle_time_p(`EXT_CLK_PERIOD))
    ext_clk_gen
      (.o(ext_clk)
      );

  bsg_nonsynth_reset_gen #(.num_clocks_p(1), .reset_cycles_lo_p(10), .reset_cycles_hi_p(5))
    tag_reset_gen
      (.clk_i(tag_clk)
      ,.async_reset_o(tag_reset)
      );

  // ==========================================================
  // BSG TAG TRACK REPLAY
  // ==========================================================

  localparam tag_num_masters_lp          = 1;
  localparam tag_num_clients_lp          = tag_els_gp;
  localparam tag_max_payload_width_lp    = tag_max_payload_width_gp;
  localparam tag_lg_max_payload_width_lp = `BSG_SAFE_CLOG2(tag_max_payload_width_lp+1);
  localparam tag_trace_rom_addr_width_lp = 32;
  localparam tag_trace_rom_data_width_lp = 4 + tag_num_masters_lp + `BSG_SAFE_CLOG2(tag_num_clients_lp) + 1 + tag_lg_max_payload_width_lp + tag_max_payload_width_lp;

  logic [tag_trace_rom_addr_width_lp-1:0] rom_addr_li;
  logic [tag_trace_rom_data_width_lp-1:0] rom_data_lo;

  logic tag_trace_valid_lo, tag_trace_data_lo, tag_trace_done_lo;

  bsg_tag_boot_rom #(.width_p(tag_trace_rom_data_width_lp)
                    ,.addr_width_p(tag_trace_rom_addr_width_lp)
                    )
    tag_trace_rom
      (.addr_i(rom_addr_li)
      ,.data_o(rom_data_lo)
      );

  bsg_tag_trace_replay #(.rom_addr_width_p(tag_trace_rom_addr_width_lp)
                        ,.rom_data_width_p(tag_trace_rom_data_width_lp)
                        ,.num_masters_p(tag_num_masters_lp)
                        ,.num_clients_p(tag_num_clients_lp)
                        ,.max_payload_width_p(tag_max_payload_width_lp)
                        )
    tag_trace_replay
      (.clk_i(tag_clk)
      ,.reset_i(tag_reset)
      ,.en_i(1'b1)

      ,.rom_addr_o(rom_addr_li)
      ,.rom_data_i(rom_data_lo)

      ,.valid_i(1'b0)
      ,.data_i('0)
      ,.ready_o()

      ,.valid_o(tag_trace_valid_lo)
      ,.en_r_o()
      ,.tag_data_o(tag_trace_data_lo)
      ,.yumi_i(tag_trace_valid_lo)

      ,.done_o(tag_trace_done_lo)
      ,.error_o()
      ) ;

  // ==========================================================
  // DEVICE UNDER TEST (DUT)
  // ==========================================================

  logic clk_o, clk_monitor_o;

  bigblade_clk_gen
    DUT
      (.tag_clk_i(tag_clk)
      ,.tag_data_i(tag_trace_data_lo & tag_trace_valid_lo)
      ,.tag_node_id_offset_i('0)

      ,.ext_clk_i(ext_clk)
      ,.async_output_disable_i(async_clk_gen_disable)

      ,.clk_o(clk_o)
      ,.clk_monitor_o(clk_monitor_o)
      );

  // ==========================================================
  // CLOCK GENERATOR WATCHER
  // ==========================================================

  // filter out first cycle to eliminate glitch from ds
  logic watch_state;
  always_ff @(posedge clk_o) begin
    if (clk_o !== 1'bX) begin
      if (watch_state === 1'bX) begin
        watch_state <= 1'b0;
      end else if (watch_state === 1'b0) begin
        watch_state <= 1'b1;
      end
    end
  end

  wire watch_clk = (watch_state === 1'b1) ? clk_o : 1'b0;

  bsg_nonsynth_clk_watcher #(.tolerance_p(1))
    watcher
      (.clk_i(watch_clk)
      );

  // ==========================================================
  // BSG TAG MASTER INSTANCE
  // ==========================================================

  initial 
  begin
    async_clk_gen_disable = 1;
    @(negedge tag_reset)
    async_clk_gen_disable = 0;
    while (tag_trace_done_lo == 1'b0)
      #5000;
    $display("Clock Sweep Done!\n");
    $finish;
  end

endmodule
