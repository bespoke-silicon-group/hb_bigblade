puts "BSG-info: Running script [info script]\n"

#set_app_option -name clock_opt.flow.enable_clock_power_recovery -value none
#set_app_option -name clock_opt.flow.enable_ccd -value false

set TCL_USER_CLOCK_OPT_OPTO_SCRIPT "$::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/user_clock_opt_opto_script.tcl"
set REPORT_QOR_REPORT_CONGESTION 0
set REPORT_QOR false

puts "BSG-info: Completed script [info script]\n"
