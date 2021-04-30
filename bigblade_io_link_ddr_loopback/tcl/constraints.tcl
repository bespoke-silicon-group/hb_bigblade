puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl
source -echo -verbose $::env(BASEJUMP_STL_DIR)/hard/gf_14/bsg_link/tcl/bsg_link_ddr.constraints.tcl


########################################
## App Var Setup
# Needed for CDC multiple clock path constraints
set_app_var timing_enable_multiple_clocks_per_reg true
# Needed for automatic clock-gate insertions
set_app_var case_analysis_propagate_through_icg true
########################################

#set tag_clk_name           "tag_clk"
#set tag_clk_period_ps      10000.0 ;# 100 MHz
#set tag_clk_uncertainty_ps 20
#create_clock -period $tag_clk_period_ps -name $tag_clk_name [get_pins pad_ML0_0_i/Y]
#create_clock -period $tag_clk_period_ps -name $tag_clk_name [get_ports p_pad_ML0_0_i]
#set_clock_uncertainty $tag_clk_uncertainty_ps  [get_clocks $tag_clk_name]

set osc_period_ps         250.0 ;# Raw oscillator frequency
set osc_uncertainty_ps    20
set ds_uncertainty_ps     20

set ext_io_clk_name           "ext_io_clk"
create_clock -period $osc_period_ps -name $ext_io_clk_name [get_pins pad_CT0_0_i/Y]
set_clock_uncertainty $osc_uncertainty_ps  [get_clocks $ext_io_clk_name]

set ext_noc_clk_name           "ext_noc_clk"
create_clock -period $osc_period_ps -name $ext_noc_clk_name [get_pins pad_CT0_1_i/Y]
set_clock_uncertainty $osc_uncertainty_ps  [get_clocks $ext_noc_clk_name]


# tag constraints
#set tag_in_pins [get_pins {pad_ML0_1_i/Y pad_ML0_2_i/Y}]
#set tag_in_ports [get_ports {p_pad_ML0_1_i p_pad_ML0_2_i}]
#set_input_delay [expr $tag_clk_period_ps/2] -clock $tag_clk_name -source_latency_included -network_latency_included $tag_in_ports

# regard tag_clk_i as data pin
set_attribute [get_lib_pins */bsg_chip_noc_mem_link/tag_clk_i] clock false

set_data_check -from [get_pins mem_link*0*link/tag_clk_i] -to [get_pins mem_link*0*link/tag_data_i] 5000
set_data_check -from [get_pins mem_link*1*link/tag_clk_i] -to [get_pins mem_link*1*link/tag_data_i] 5000
set_data_check -from [get_pins mem_link*2*link/tag_clk_i] -to [get_pins mem_link*2*link/tag_data_i] 5000
set_data_check -from [get_pins mem_link*3*link/tag_clk_i] -to [get_pins mem_link*3*link/tag_data_i] 5000
set_data_check -from [get_pins mem_link*4*link/tag_clk_i] -to [get_pins mem_link*4*link/tag_data_i] 5000
set_data_check -from [get_pins mem_link*5*link/tag_clk_i] -to [get_pins mem_link*5*link/tag_data_i] 5000
set_data_check -from [get_pins mem_link*6*link/tag_clk_i] -to [get_pins mem_link*6*link/tag_data_i] 5000
set_data_check -from [get_pins mem_link*7*link/tag_clk_i] -to [get_pins mem_link*7*link/tag_data_i] 5000


# false path
set_false_path -from [get_ports p_pad_CT0_v_i]


# Source-sync link constraints
set io_clk_name               "io_clk"
set io_clk_period_ps          800 ;# 1.25 GHz
set link_clk_period_ps        [expr $io_clk_period_ps*2.0]
set link_clk_uncertainty_ps   20
set max_io_output_margin_ps   200
set max_io_input_margin_ps    200

#for {set i 0} {$i < 1} {incr i} {
#
#  set link_clk_i_pin                          [get_pins -of_objects [get_cells -of_objects [get_ports "p_pad_DL${i}_clk_i"]] -filter "name==Y"]
#  set link_tkn_i_pin                          [get_pins -of_objects [get_cells -of_objects [get_ports "p_pad_DL${i}_tkn_i"]] -filter "name==Y"]
#  set link_dv_i_pin   [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports "p_pad_DL${i}_*_i"]] -filter "name==Y"] {$link_clk_i_pin link_tkn_i_pin}]
#  set link_clk_o_pin                          [get_pins -of_objects [get_cells -of_objects [get_ports "p_pad_DL${i}_clk_o"]] -filter "name==DATA"]
#  set link_tkn_o_pin                          [get_pins -of_objects [get_cells -of_objects [get_ports "p_pad_DL${i}_tkn_o"]] -filter "name==DATA"]
#  set link_dv_o_pin   [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports "p_pad_DL${i}_*_o"]] -filter "name==DATA"] {$link_clk_o_pin link_tkn_o_pin}]
#
#  bsg_link_ddr_constraints                    \
#    $io_clk_name                              \
#    "link_out_clk_DL${i}"                     \
#    $link_clk_period_ps                       \
#    $max_io_output_margin_ps                  \
#    [get_ports io_link_clk_o]                 \
#    [get_ports {io_link_data_o io_link_v_o}]  \
#    "link_in_clk_DL${i}"                      \
#    $link_clk_period_ps                       \
#    $max_io_input_margin_ps                   \
#    [get_ports io_link_clk_i]                 \
#    [get_ports {io_link_data_i io_link_v_i}]  \
#    "link_tkn_clk_DL${i}"                     \
#    [get_ports io_link_token_i]               \
#    $link_clk_uncertainty_ps
#}


# CDC
set cdc_clocks [all_clocks]
bsg_async_icl $cdc_clocks


# ungroup


# Derate
bsg_chip_derate_cells
bsg_chip_derate_mems
#report_timing_derate

# Disabled or false paths


puts "BSG-info: Completed script [info script]\n"

