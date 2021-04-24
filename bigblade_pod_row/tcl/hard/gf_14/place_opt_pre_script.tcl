puts "BSG-info: running place_opt_pre_script"

set_app_options -name clock_opt.flow.enable_clock_power_recovery -value none
set_app_options -name route_opt.flow.enable_clock_power_recovery -value none

set TCL_USER_PLACE_OPT_SCRIPT "$::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/user_place_opt_script.tcl"

puts "BSG-info: finished place_opt_pre_script"
