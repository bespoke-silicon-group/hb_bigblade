puts "BSG-info: running [info script]"

#set_app_options -name clock_opt.flow.enable_clock_power_recovery -value none
#set_app_options -name route_opt.flow.enable_clock_power_recovery -value none

set TCL_USER_PLACE_OPT_SCRIPT "$::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/user_place_opt_script.tcl"
set REPORT_QOR_REPORT_CONGESTION 0
set REPORT_QOR false

puts "BSG-info: finished [info script]"
