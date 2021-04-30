### constraints.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/bsg_clk_gen.constraints.tcl

# ==============================================================================
# Clock Generator Constraints
# ==============================================================================

set osc_period_ps       250.0   ;# 4 GHz
set osc_uncertainty_ps  20.0

create_clock -period $osc_period_ps -name "ext_clk" [get_ports "ext_clk_i"]
set_clock_uncertainty $osc_uncertainty_ps [get_clocks "ext_clk"]
set_input_transition 75.0 [get_ports "ext_clk_i"]

bsg_clk_gen_clock_create \
  "clk_gen_inst/"        \
  "clk_out"              \
  $osc_period_ps         \
  $osc_period_ps         \
  $osc_uncertainty_ps    \
  $osc_uncertainty_ps    \
  $osc_uncertainty_ps

# We dont time the output clock but we load it to make sure
# that the output signal is moderately well driven.
set_load [load_of [get_lib_pin "*/SC7P5T_INVX8_SSC14R/A"]] [get_ports "clk_o"]

# ==============================================================================
# Async Disable
# ==============================================================================

# TODO: is this correct?
set_false_path -from [get_port "async_output_disable_i"]

# ==============================================================================
# Tag Constraints
# ==============================================================================

set tag_period_ps       6666.0  ;# 150 MHz
set tag_uncertainty_ps  20.0
set tag_input_delay_ps  6000.0  ;# ~90% of the tag clock tag delay

set tag_clk_port      [get_ports "tag_clk_i"]
set tag_data_en_ports [get_ports "tag_en_i *_tag_op_param_i"]

create_clock -period $tag_period_ps -name "tag_clk" $tag_clk_port
set_clock_uncertainty $tag_uncertainty_ps $tag_clk_port
set_input_transition 75.0 $tag_clk_port

set_input_delay -max $tag_input_delay_ps -clock "tag_clk" $tag_data_en_ports
set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX1_SSC14R" $tag_data_en_ports

set_input_delay  -min 0 -clock "tag_clk" $tag_data_en_ports
set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $tag_data_en_ports

# ==============================================================================
# CDC Between Clocks
# ==============================================================================

foreach_in_collection launch_clk [all_clocks] {
  foreach_in_collection latch_clk [remove_from_collection [all_clocks] $launch_clk] {
    set launch_period [get_attribute $launch_clk period]
    set latch_period  [get_attribute $latch_clk  period]
    set max_delay_ps  [expr min($launch_period, $latch_period) / 2.0]
    set min_delay_ps  0
    set_max_delay $max_delay_ps -from $launch_clk -to $latch_clk -ignore_clock_latency
    set_min_delay $min_delay_ps -from $launch_clk -to $latch_clk -ignore_clock_latency
  }
}

