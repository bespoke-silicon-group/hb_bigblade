
module bsg_chip_io_link_ddr

 import bsg_tag_pkg::*;
 import bsg_chip_pkg::*;

  (input                core_clk_i
  ,input                ext_io_clk_i
  ,input                ext_noc_clk_i
  ,input                async_output_disable_i
  ,output               noc_clk_o

  ,input                tag_clk_i
  ,input  [3:0]         tag_io_tag_lines_i
  ,input  [3:0]         tag_core_tag_lines_i
  ,input  [3:0]         tag_io_async_reset_tag_lines_i
  ,input  [3:0]         tag_io_osc_tag_lines_i
  ,input  [3:0]         tag_io_osc_trigger_tag_lines_i
  ,input  [3:0]         tag_io_ds_tag_lines_i
  ,input  [3:0]         tag_io_sel_tag_lines_i
  ,input  [3:0]         tag_noc_async_reset_tag_lines_i
  ,input  [3:0]         tag_noc_osc_tag_lines_i
  ,input  [3:0]         tag_noc_osc_trigger_tag_lines_i
  ,input  [3:0]         tag_noc_ds_tag_lines_i
  ,input  [3:0]         tag_noc_sel_tag_lines_i

  ,input                          core_v_i
  ,input  [bsg_link_width_gp-1:0] core_data_i
  ,output                         core_ready_and_o

  ,output                         core_v_o
  ,output [bsg_link_width_gp-1:0] core_data_o
  ,input                          core_yumi_i

  ,input  [bsg_link_num_channels_gp-1:0]                                io_link_clk_i
  ,input  [bsg_link_num_channels_gp-1:0]                                io_link_v_i
  ,input  [bsg_link_num_channels_gp-1:0][bsg_link_channel_width_gp-1:0] io_link_data_i
  ,output [bsg_link_num_channels_gp-1:0]                                io_link_token_o

  ,output [bsg_link_num_channels_gp-1:0]                                io_link_clk_o
  ,output [bsg_link_num_channels_gp-1:0]                                io_link_v_o
  ,output [bsg_link_num_channels_gp-1:0][bsg_link_channel_width_gp-1:0] io_link_data_o
  ,input  [bsg_link_num_channels_gp-1:0]                                io_link_token_i
  );

  wire bsg_tag_s tag_io_tag_lines_li              = {tag_clk_i, tag_io_tag_lines_i             [2:0]};
  wire bsg_tag_s tag_core_tag_lines_li            = {tag_clk_i, tag_core_tag_lines_i           [2:0]};

  wire bsg_tag_s tag_io_async_reset_tag_lines_li  = {tag_clk_i, tag_io_async_reset_tag_lines_i [2:0]};
  wire bsg_tag_s tag_io_osc_tag_lines_li          = {tag_clk_i, tag_io_osc_tag_lines_i         [2:0]};
  wire bsg_tag_s tag_io_osc_trigger_tag_lines_li  = {tag_clk_i, tag_io_osc_trigger_tag_lines_i [2:0]};
  wire bsg_tag_s tag_io_ds_tag_lines_li           = {tag_clk_i, tag_io_ds_tag_lines_i          [2:0]};
  wire bsg_tag_s tag_io_sel_tag_lines_li          = {tag_clk_i, tag_io_sel_tag_lines_i         [2:0]};

  wire bsg_tag_s tag_noc_async_reset_tag_lines_li = {tag_clk_i, tag_noc_async_reset_tag_lines_i[2:0]};
  wire bsg_tag_s tag_noc_osc_tag_lines_li         = {tag_clk_i, tag_noc_osc_tag_lines_i        [2:0]};
  wire bsg_tag_s tag_noc_osc_trigger_tag_lines_li = {tag_clk_i, tag_noc_osc_trigger_tag_lines_i[2:0]};
  wire bsg_tag_s tag_noc_ds_tag_lines_li          = {tag_clk_i, tag_noc_ds_tag_lines_i         [2:0]};
  wire bsg_tag_s tag_noc_sel_tag_lines_li         = {tag_clk_i, tag_noc_sel_tag_lines_i        [2:0]};

  logic io_clk_lo;

  bsg_chip_clk_gen
 #(.ds_width_p             (bsg_link_clk_gen_ds_width_gp)
  ,.num_adgs_p             (bsg_link_clk_gen_num_adgs_gp)
  ) clk_gen_io
  (.async_reset_tag_lines_i(tag_io_async_reset_tag_lines_li)
  ,.osc_tag_lines_i        (tag_io_osc_tag_lines_li        )
  ,.osc_trigger_tag_lines_i(tag_io_osc_trigger_tag_lines_li)
  ,.ds_tag_lines_i         (tag_io_ds_tag_lines_li         )
  ,.sel_tag_lines_i        (tag_io_sel_tag_lines_li        )
  ,.async_output_disable_i (async_output_disable_i         )
  ,.ext_clk_i              (ext_io_clk_i                   )
  ,.clk_o                  (io_clk_lo                      )
  );

  bsg_chip_clk_gen
 #(.ds_width_p             (bsg_link_clk_gen_ds_width_gp)
  ,.num_adgs_p             (bsg_link_clk_gen_num_adgs_gp)
  ) clk_gen_noc
  (.async_reset_tag_lines_i(tag_noc_async_reset_tag_lines_li)
  ,.osc_tag_lines_i        (tag_noc_osc_tag_lines_li        )
  ,.osc_trigger_tag_lines_i(tag_noc_osc_trigger_tag_lines_li)
  ,.ds_tag_lines_i         (tag_noc_ds_tag_lines_li         )
  ,.sel_tag_lines_i        (tag_noc_sel_tag_lines_li        )
  ,.async_output_disable_i (async_output_disable_i          )
  ,.ext_clk_i              (ext_noc_clk_i                   )
  ,.clk_o                  (noc_clk_o                       )
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

  io_tag_payload_s   io_tag_data_lo;
  core_tag_payload_s core_tag_data_lo;

  bsg_tag_client 
 #(.width_p       ($bits(io_tag_data_lo))
  ,.default_p     (0)
  ) btc_io
  (.bsg_tag_i     (tag_io_tag_lines_li)
  ,.recv_clk_i    (io_clk_lo)
  ,.recv_reset_i  (1'b0)
  ,.recv_new_r_o  ()
  ,.recv_data_r_o (io_tag_data_lo)
  );

  bsg_tag_client 
 #(.width_p       ($bits(core_tag_data_lo))
  ,.default_p     (0)
  ) btc_core
  (.bsg_tag_i     (tag_core_tag_lines_li)
  ,.recv_clk_i    (core_clk_i)
  ,.recv_reset_i  (1'b0)
  ,.recv_new_r_o  ()
  ,.recv_data_r_o (core_tag_data_lo)
  );

  bsg_link_ddr_upstream
 #(.width_p                        (bsg_link_width_gp)
  ,.channel_width_p                (bsg_link_channel_width_gp)
  ,.num_channels_p                 (bsg_link_num_channels_gp)
  ,.lg_fifo_depth_p                (bsg_link_lg_fifo_depth_gp)
  ,.lg_credit_to_token_decimation_p(bsg_link_lg_credit_to_token_decimation_gp)
  ,.use_extra_data_bit_p           (bsg_link_use_extra_data_bit_gp)
  ,.use_encode_p                   (1)
  ,.bypass_twofer_fifo_p           (1)
  ,.bypass_gearbox_p               (1)
  ) uplink
  (.core_clk_i         (core_clk_i)
  ,.core_link_reset_i  (core_tag_data_lo.up_link_reset)

  ,.core_data_i        (core_data_i)
  ,.core_valid_i       (core_v_i)
  ,.core_ready_o       (core_ready_and_o)

  ,.io_clk_i           (io_clk_lo)
  ,.io_link_reset_i    (io_tag_data_lo.up_link_reset)
  ,.async_token_reset_i(io_tag_data_lo.async_token_reset)

  ,.io_clk_r_o         (io_link_clk_o)
  ,.io_data_r_o        (io_link_data_o)
  ,.io_valid_r_o       (io_link_v_o)
  ,.token_clk_i        (io_link_token_i)
  );

  logic [bsg_link_num_channels_gp-1:0] downlink_reset_lo;
  for (genvar i = 0; i < bsg_link_num_channels_gp; i++)
  begin: down_bss
    bsg_sync_sync #(.width_p(1)) bss
    (.oclk_i     (io_link_clk_i[i])
    ,.iclk_data_i(io_tag_data_lo.down_link_reset)
    ,.oclk_data_o(downlink_reset_lo[i])
    );
  end

  bsg_link_ddr_downstream 
 #(.width_p                        (bsg_link_width_gp)
  ,.channel_width_p                (bsg_link_channel_width_gp)
  ,.num_channels_p                 (bsg_link_num_channels_gp)
  ,.lg_fifo_depth_p                (bsg_link_lg_fifo_depth_gp)
  ,.lg_credit_to_token_decimation_p(bsg_link_lg_credit_to_token_decimation_gp)
  ,.use_extra_data_bit_p           (bsg_link_use_extra_data_bit_gp)
  ,.use_encode_p                   (0)
  ,.bypass_twofer_fifo_p           (1)
  ,.bypass_gearbox_p               (0)
  ,.use_hardened_fifo_p            (1)
  ) downlink
  (.core_clk_i       (core_clk_i)
  ,.core_link_reset_i(core_tag_data_lo.down_link_reset)

  ,.io_link_reset_i  (downlink_reset_lo)

  ,.core_data_o      (core_data_o)
  ,.core_valid_o     (core_v_o)
  ,.core_yumi_i      (core_yumi_i)

  ,.io_clk_i         (io_link_clk_i)
  ,.io_data_i        (io_link_data_i)
  ,.io_valid_i       (io_link_v_i)
  ,.core_token_r_o   (io_link_token_o)
  );

endmodule
