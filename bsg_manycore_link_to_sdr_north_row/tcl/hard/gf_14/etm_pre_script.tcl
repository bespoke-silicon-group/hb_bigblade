puts "BSG-info: Running ETM pre script..."


# SDR constraints
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BASEJUMP_STL_DIR)/hard/gf_14/bsg_link/tcl/bsg_link_sdr.constraints.tcl

set clk_name "manycore_clk"
set clk_period_ps 1000

set link_clk_period_ps        1000
set link_clk_uncertainty_ps   20
set max_io_output_margin_ps   100
set max_io_input_margin_ps    100

for {set x 0} {$x < $HB_NUM_TILES_X_P} {incr x} {
  # FWD
  set fwd_clk_out_ports  [get_ports "io_fwd_link_clk_o[${x}]"]
  set fwd_clk_in_ports   [get_ports "io_fwd_link_clk_i[${x}]"]
  set fwd_token_in_ports [get_ports "io_fwd_link_token_i[${x}]"]

  set fwd_dv_in_ports [list]
  set fwd_dv_out_ports [list]
  append_to_collection fwd_dv_in_ports  [get_ports "io_fwd_link_v_i[${x}]"]
  append_to_collection fwd_dv_out_ports [get_ports "io_fwd_link_v_o[${x}]"]
  for {set i 0} {$i < $HB_FWD_PACKET_WIDTH} {incr i} {
    set idx [expr $i+($x*$HB_FWD_PACKET_WIDTH)]
    append_to_collection fwd_dv_in_ports  [get_ports "io_fwd_link_data_i[${idx}]"]
    append_to_collection fwd_dv_out_ports [get_ports "io_fwd_link_data_o[${idx}]"]
  }

  bsg_link_sdr_constraints \
    $clk_name \
    [get_ports "core_clk_i"] \
    "fwd_out_clk_${x}" \
    $clk_period_ps \
    $max_io_output_margin_ps \
    $fwd_clk_out_ports \
    $fwd_dv_out_ports \
    "fwd_in_clk_${x}" \
    $link_clk_period_ps \
    $max_io_input_margin_ps \
    $fwd_clk_in_ports \
    $fwd_dv_in_ports \
    "fwd_tkn_clk_${x}" \
    $fwd_token_in_ports \
    $link_clk_uncertainty_ps

  # REV
  set rev_clk_out_ports [get_ports "io_rev_link_clk_o[${x}]"]
  set rev_clk_in_ports [get_ports "io_rev_link_clk_i[${x}]"]
  set rev_token_in_ports [get_ports "io_rev_link_token_i[${x}]"]

  set rev_dv_in_ports [list]
  set rev_dv_out_ports [list]
  append_to_collection rev_dv_in_ports  [get_ports "io_rev_link_v_i[${x}]"]
  append_to_collection rev_dv_out_ports [get_ports "io_rev_link_v_o[${x}]"]
  for {set i 0} {$i < $HB_REV_PACKET_WIDTH} {incr i} {
    set idx [expr $i+($x*$HB_REV_PACKET_WIDTH)]
    append_to_collection rev_dv_in_ports  [get_ports "io_rev_link_data_i[${idx}]"]
    append_to_collection rev_dv_out_ports [get_ports "io_rev_link_data_o[${idx}]"]
  }

  bsg_link_sdr_constraints \
    $clk_name \
    [get_ports "core_clk_i"] \
    "rev_out_clk_${x}" \
    $clk_period_ps \
    $max_io_output_margin_ps \
    $rev_clk_out_ports \
    $rev_dv_out_ports \
    "rev_in_clk_${x}" \
    $link_clk_period_ps \
    $max_io_input_margin_ps \
    $rev_clk_in_ports \
    $rev_dv_in_ports \
    "rev_tkn_clk_${x}" \
    $rev_token_in_ports \
    $link_clk_uncertainty_ps
}
