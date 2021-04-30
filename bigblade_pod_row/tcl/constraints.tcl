puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl

# ==========================================================
# Clock Constraints
# ==========================================================

set manycore_clk_name             "manycore_clk"
set manycore_clk_port             "ext_clk_i"
set manycore_clk_period_ps        1200.0
set manycore_clk_uncertainty_ps   20

set_input_transition 75 [get_port $manycore_clk_port]
create_clock -period $manycore_clk_period_ps -name $manycore_clk_name [get_ports $manycore_clk_port]
set_clock_uncertainty $manycore_clk_uncertainty_ps [get_clocks $manycore_clk_name]



# bsg_tag
set tag_clk_ports [list]
append_to_collection tag_clk_ports [get_ports "pod_tag_clk_i*"]
append_to_collection tag_clk_ports [get_ports "async_reset_tag_clk_i*"]
create_clock -period 5000 -name "tag_clk" $tag_clk_ports
set_clock_uncertainty 20 [get_clocks "tag_clk"]
set_input_transition 75 $tag_clk_ports

set tag_data_ports [list]
append_to_collection tag_data_ports [get_ports "pod_tag_data_i*"]
append_to_collection tag_data_ports [get_ports "async_reset_tag_data_i*"]
set_input_delay -max 200 -clock "tag_clk" $tag_data_ports
set_input_delay -min 200 -clock "tag_clk" $tag_data_ports
set_driving_cell -min -no_design_rule -lib_cell "SC7P5T_INVX8_SSC14R" $tag_data_ports
set_driving_cell -max -no_design_rule -lib_cell "SC7P5T_INVX2_SSC14R" $tag_data_ports

set tag_id_ports [list]
append_to_collection tag_id_ports [get_ports "pod_tag_node_id_offset_i*"]
append_to_collection tag_id_ports [get_ports "async_reset_tag_node_id_offset_i*"]
set_false_path -from $tag_id_ports


# global x/y
set_false_path -from [get_ports global_*_i*]


# async path
bsg_async_icl [all_clocks]

puts "BSG-info: Completed script [info script]\n"
