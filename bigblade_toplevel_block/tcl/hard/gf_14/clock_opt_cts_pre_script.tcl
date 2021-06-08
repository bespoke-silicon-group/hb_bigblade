puts "BSG-info: Running script [info script]\n"

set TCL_USER_CLOCK_OPT_CTS_SCRIPT "$::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/user_clock_opt_cts_script.tcl"
set REPORT_QOR_REPORT_CONGESTION 0
set REPORT_QOR false

puts "BSG-info: Completed script [info script]\n"
