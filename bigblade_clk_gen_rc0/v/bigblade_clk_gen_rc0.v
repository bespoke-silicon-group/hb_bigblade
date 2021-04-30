module bigblade_clk_gen_rc0
  import bsg_tag_pkg::bsg_tag_s;

 #( ds_width_p = 8, num_adgs_p = 1 )

( input         ext_clk_i
, input         async_output_disable_i

, input         tag_clk_i
, input         tag_en_i
, input  [1:0]  async_reset_tag_op_param_i
, input  [1:0]  sel_tag_op_param_i
, input  [1:0]  osc_tag_op_param_i
, input  [1:0]  osc_trigger_tag_op_param_i
, input  [1:0]  ds_tag_op_param_i

, output logic  clk_o
);

  bsg_tag_s  async_reset_tag_lines_li;
  bsg_tag_s  sel_tag_lines_li;
  bsg_tag_s  osc_tag_lines_li;
  bsg_tag_s  osc_trigger_tag_lines_li;
  bsg_tag_s  ds_tag_lines_li;

  bsg_tag_lines_join #(.els_p(5))
    tag_lines_join_BSG_UNGROUP
      (.bsg_tag_clk_i(tag_clk_i)
      ,.bsg_tag_en_i(tag_en_i)
      ,.bsg_tag_op_param_i({
          async_reset_tag_op_param_i,
          sel_tag_op_param_i,
          osc_tag_op_param_i,
          osc_trigger_tag_op_param_i,
          ds_tag_op_param_i
      })
      ,.bsg_tag_o({
          async_reset_tag_lines_li,
          sel_tag_lines_li,
          osc_tag_lines_li,
          osc_trigger_tag_lines_li,
          ds_tag_lines_li
      })
      );

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

endmodule // bigblade_clk_gen_rc0
