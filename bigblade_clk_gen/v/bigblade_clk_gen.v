module bigblade_clk_gen
  import bsg_chip_pkg::*;
  import bsg_tag_pkg::bsg_tag_s;

#( ds_width_p         = bsg_link_clk_gen_ds_width_gp
 , num_adgs_p         = bsg_link_clk_gen_num_adgs_gp
 , tag_els_p          = tag_els_gp
 , tag_lg_width_p     = tag_lg_width_gp
 , monitor_ds_width_p = bsg_link_clk_gen_lg_monitor_ds_gp
 )

( input                                  tag_clk_i
, input                                  tag_data_i
, input [`BSG_SAFE_CLOG2(tag_els_p)-1:0] tag_node_id_offset_i

, input                                  ext_clk_i
, input                                  async_output_disable_i

, output logic                           clk_o
, output logic                           clk_monitor_o
);

  bsg_chip_clk_gen_tag_lines_s tag_lines;

  bsg_tag_master_decentralized #(.els_p(tag_els_p)
                                ,.local_els_p(5)
                                ,.lg_width_p(tag_lg_width_p)
                                )
    btm
      (.clk_i(tag_clk_i)
      ,.data_i(tag_data_i)
      ,.node_id_offset_i(tag_node_id_offset_i)
      ,.clients_o(tag_lines)
      );

  logic async_reset_lo;

  bsg_tag_client_unsync #(.width_p(1))
    btc_async_reset
      (.bsg_tag_i(tag_lines.async_reset)
      ,.data_async_r_o(async_reset_lo)
      );

  logic [1:0] clk_select_lo;

  bsg_tag_client_unsync #(.width_p(2))
    btc_clk_select
      (.bsg_tag_i(tag_lines.sel)
      ,.data_async_r_o(clk_select_lo)
      );

  wire [1:0] clk_select_n = async_output_disable_i ? 2'b11 : clk_select_lo;

  bsg_clk_gen #(.downsample_width_p(ds_width_p)
               ,.num_adgs_p(num_adgs_p)
               ,.version_p(2)
               )
    clk_gen_inst
      (.bsg_osc_tag_i(tag_lines.osc)
      ,.bsg_osc_trigger_tag_i(tag_lines.osc_trigger)
      ,.bsg_ds_tag_i(tag_lines.ds)
      ,.async_osc_reset_i(async_reset_lo)
      ,.ext_clk_i(ext_clk_i)
      ,.select_i(clk_select_n)
      ,.clk_o(clk_o)
      );

  logic [monitor_ds_width_p:0] monitor_ds_r;

  assign monitor_ds_r[0] = clk_o;
  assign clk_monitor_o = monitor_ds_r[monitor_ds_width_p];

  for (genvar i = 0; i < monitor_ds_width_p; i++)
    begin: monitor_ds
      bsg_dff_async_reset #(.width_p(1))
        dff
          (.clk_i(monitor_ds_r[i])
          ,.async_reset_i(async_output_disable_i)
          ,.data_i(~monitor_ds_r[i+1])
          ,.data_o(monitor_ds_r[i+1])
          );
    end: monitor_ds

endmodule // bigblade_clk_gen
