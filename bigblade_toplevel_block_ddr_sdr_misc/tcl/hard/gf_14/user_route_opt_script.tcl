
if {[file exists [which $ROUTE_OPT_STARRC_CONFIG_FILE]]} {
	set_app_options -name extract.starrc_mode -value true
	set_starrc_in_design -config $ROUTE_OPT_STARRC_CONFIG_FILE ;# example: route_opt.starrc_config_example.txt
	
	## Update timing with StarRC extraction
	;#
	;# The tool automatically performs RC extraction when it updates the timing information.
	;#
	;# Timing is automatically updated by commands that need the information, such as the
	;# report_timing command. The update_timing command explicitly prepares the design for
	;# further analysis. The default is to perform an incremental analysis, which updates
	;# only out-of-date information and runs more quickly. Since there is no change in design
	;# between first and second route_opt runs, automatic incremental analysis means no
	;# analysis at all. Therefore, second route_opt run will use out-of-date timing and
	;# RC extraction, resulting in poor QoR.
	;#
	;# To use the parasitic information from the StarRC extraction, we override this default
	;# behavior using the -full option, which causes the entire timing update to be performed
	;# from the beginning. Runtime is longer with -full option.
	puts "RM-info: Running update_timing with StarRC extraction"
	update_timing -full
} elseif {$ROUTE_OPT_STARRC_CONFIG_FILE != ""} {
	puts "RM-error: ROUTE_OPT_STARRC_CONFIG_FILE($ROUTE_OPT_STARRC_CONFIG_FILE) is invalid. Please correct it."
}
