puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_clk_gen.constraints.tcl

# ==========================================================
# Clock Constraints
# ==========================================================

set manycore_clk_name           "manycore_clk"
set manycore_clk_period_ps      1000.0 ;# 1 GHz
set manycore_clk_uncertainty_ps 20
set osc_period_ps               250.0 ;# Raw oscillator frequency
set osc_uncertainty_ps          20
set ds_uncertainty_ps           20
bsg_clk_gen_clock_create clk_gen/clk_gen_inst/ ${manycore_clk_name} ${osc_period_ps} ${manycore_clk_period_ps} ${osc_uncertainty_ps} ${ds_uncertainty_ps} ${manycore_clk_uncertainty_ps}

set ext_clk_name                "ext_clk"
create_clock -period $osc_period_ps -name $ext_clk_name [get_ports ext_clk_i]
set_clock_uncertainty $osc_uncertainty_ps  [get_clocks $ext_clk_name]

set tag_clk_name                "tag_clk"
set tag_clk_period_ps           5000.0 ;# 200 MHz
set tag_clk_uncertainty_ps      20
create_clock -period $tag_clk_period_ps -name $tag_clk_name [get_ports tag_clk_i]
set_clock_uncertainty $tag_clk_uncertainty_ps  [get_clocks $tag_clk_name]


# clock gen
proc constraint_input_ports {clk_name ports max_delay min_delay} {
  set_input_delay -max $max_delay -clock $clk_name $ports
  set_input_delay -min $min_delay -clock $clk_name $ports
  set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $ports
  set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_INVX2_SSC14R" $ports
}

set tag_in_ports [get_ports {*_tag_lines_i*op* *_tag_lines_i*param*}]
constraint_input_ports $tag_clk_name $tag_in_ports     4800  50

set_false_path -from [get_ports async_output_disable_i]
set_false_path -from [get_ports {*_tag_lines_i*clk* *_tag_lines_i*en*}]

# pod tag
create_clock -period 5000 -name "pod_tag_clk" [get_ports "pod_tags_i[0]\[clk\]"]
set_clock_uncertainty 20 [get_clocks "pod_tag_clk"]
set_input_transition 50 [get_ports "pod_tags_i[0]\[clk\]"]
set tag_ports [list]
append_to_collection tag_ports [get_ports "pod_tags_i[0]\[op\]"]
append_to_collection tag_ports [get_ports "pod_tags_i[0]\[param\]"]
append_to_collection tag_ports [get_ports "pod_tags_i[0]\[en\]"]
set_input_delay -max 200 -clock "pod_tag_clk" $tag_ports
set_input_delay -min 200 -clock "pod_tag_clk" $tag_ports
set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $tag_ports
set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_INVX2_SSC14R" $tag_ports

# global x/y
set_false_path -from [get_ports global_*_i*]


# async reset
set_false_path -from [get_ports hor_sdr_async_*_reset_i*]
set_false_path -from [get_ports ver_sdr_async_*_reset_i*]


# ==========================================================
# Async Paths
# ==========================================================

set cdc_clocks [all_clocks]
bsg_async_icl $cdc_clocks

puts "BSG-info: Completed script [info script]\n"
