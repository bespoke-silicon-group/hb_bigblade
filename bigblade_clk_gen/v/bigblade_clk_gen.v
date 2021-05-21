module bigblade_clk_gen
  import bsg_chip_pkg::*;
  import bsg_tag_pkg::bsg_tag_s;

#( ds_width_p     = bsg_link_clk_gen_ds_width_gp
 , num_adgs_p     = bsg_link_clk_gen_num_adgs_gp
 , tag_els_p      = tag_els_gp
 , tag_lg_width_p = tag_lg_els_gp
 )

( input                                  tag_clk_i
, input                                  tag_data_i
, input [`BSG_SAFE_CLOG2(tag_els_p)-1:0] tag_node_id_offset_i

, input                                  ext_clk_i
, input                                  async_output_disable_i

, output logic                           clk_o
);

  bsg_tag_s [4:0] tag_lines_lo;

  bsg_tag_master_decentralized #(.els_p(tag_els_p)
                                ,.local_els_p(5)
                                ,.lg_width_p(tag_lg_width_p)
                                )
    btm
      (.clk_i(tag_clk_i)
      ,.data_i(tag_data_i)
      ,.node_id_offset_i(tag_node_id_offset_i)
      ,.clients_o(tag_lines_lo)
      );

  wire bsg_tag_s async_reset_tag_lines_li = tag_lines_lo[0];
  wire bsg_tag_s sel_tag_lines_li         = tag_lines_lo[1];
  wire bsg_tag_s osc_tag_lines_li         = tag_lines_lo[2];
  wire bsg_tag_s osc_trigger_tag_lines_li = tag_lines_lo[3];
  wire bsg_tag_s ds_tag_lines_li          = tag_lines_lo[4];

  logic [1:0] clk_select_lo;
  logic       async_reset_lo;

  bsg_tag_client_unsync #(.width_p(1))
    btc_async_reset
      (.bsg_tag_i(async_reset_tag_lines_li)
      ,.data_async_r_o(async_reset_lo)
      );

  bsg_tag_client_unsync #(.width_p(2))
    btc_clk_select
      (.bsg_tag_i(sel_tag_lines_li)
      ,.data_async_r_o(clk_select_lo)
      );

  wire [1:0] clk_select_n = async_output_disable_i ? 2'b11 : clk_select_lo;

  bsg_clk_gen #(.downsample_width_p(ds_width_p)
               ,.num_adgs_p(num_adgs_p)
               ,.version_p(2)
               )
    clk_gen_inst
      (.bsg_osc_tag_i(osc_tag_lines_li)
      ,.bsg_osc_trigger_tag_i(osc_trigger_tag_lines_li)
      ,.bsg_ds_tag_i(ds_tag_lines_li)
      ,.async_osc_reset_i(async_reset_lo)
      ,.ext_clk_i(ext_clk_i)
      ,.select_i(clk_select_n)
      ,.clk_o(clk_o)
      );

endmodule // bigblade_clk_gen
