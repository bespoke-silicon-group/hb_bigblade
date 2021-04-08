eval file delete [glob -nocomplain ${REPORTS_DIR}/*route_opt_post_timing.rpt]

redirect -append -file ${REPORTS_DIR}/core_clk.min.route_opt_post_timing.rpt    {report_timing -from core_clk -to core_clk   -path_type full -delay_type min -variation -attributes -max_paths 20 -nosplit -transition_time -capacitance -nets -input_pins -physical -crosstalk_delta}