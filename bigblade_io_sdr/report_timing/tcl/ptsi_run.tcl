restore_session "$::env(TOP_HIER_BLOCK)_ss"

redirect         -file $::env(PTSI_LOG_FILE) { report_timing -nosplit -to   [get_ports {io_*_link_data_o io_*_link_v_o}] -path_type end -delay_type max }

redirect -append -file $::env(PTSI_LOG_FILE) { report_timing -nosplit -to   [get_ports {io_*_link_data_o io_*_link_v_o}] -path_type end -delay_type min }

redirect -append -file $::env(PTSI_LOG_FILE) { report_timing -nosplit -from [get_ports {io_*_link_data_i io_*_link_v_i}] -path_type end -delay_type max }

redirect -append -file $::env(PTSI_LOG_FILE) { report_timing -nosplit -from [get_ports {io_*_link_data_i io_*_link_v_i}] -path_type end -delay_type min }

exit