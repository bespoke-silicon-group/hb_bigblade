puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl

# ==========================================================
# Clock Constraints
# ==========================================================

set manycore_clk_name             "manycore_clk"
set manycore_clk_port             "ext_clk_i"
set manycore_clk_period_ps        1000.0
set manycore_clk_uncertainty_ps   20

set_input_transition 50 [get_port $manycore_clk_port]
create_clock -period $manycore_clk_period_ps -name $manycore_clk_name [get_ports $manycore_clk_port]
set_clock_uncertainty $manycore_clk_uncertainty_ps [get_clocks $manycore_clk_name]


# clock gen
# TODO


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


# async path
bsg_async_icl [all_clocks]

puts "BSG-info: Completed script [info script]\n"
