
eval file delete [glob -nocomplain ${REPORTS_DIR}/*interface_timing.rpt]

redirect -append -file ${REPORTS_DIR}/core_v_i.max.interface_timing.rpt {report_timing -from [get_ports core_v_i] -delay_type max -max_paths 10 -nosplit}
redirect -append -file ${REPORTS_DIR}/core_v_i.min.interface_timing.rpt {report_timing -from [get_ports core_v_i] -delay_type min -max_paths 10 -nosplit}
redirect -append -file ${REPORTS_DIR}/core_data_i.max.interface_timing.rpt {report_timing -from [get_ports core_data_i] -delay_type max -max_paths 10 -nosplit}
redirect -append -file ${REPORTS_DIR}/core_data_i.min.interface_timing.rpt {report_timing -from [get_ports core_data_i] -delay_type min -max_paths 10 -nosplit}
redirect -append -file ${REPORTS_DIR}/core_yumi_i.max.interface_timing.rpt {report_timing -from [get_ports core_yumi_i] -delay_type max -max_paths 10 -nosplit}
redirect -append -file ${REPORTS_DIR}/core_yumi_i.min.interface_timing.rpt {report_timing -from [get_ports core_yumi_i] -delay_type min -max_paths 10 -nosplit}

redirect -append -file ${REPORTS_DIR}/core_v_o.max.interface_timing.rpt {report_timing -to [get_ports core_v_o] -delay_type max -max_paths 10 -nosplit}
redirect -append -file ${REPORTS_DIR}/core_v_o.min.interface_timing.rpt {report_timing -to [get_ports core_v_o] -delay_type min -max_paths 10 -nosplit}
redirect -append -file ${REPORTS_DIR}/core_data_o.max.interface_timing.rpt {report_timing -to [get_ports core_data_o] -delay_type max -max_paths 10 -nosplit}
redirect -append -file ${REPORTS_DIR}/core_data_o.min.interface_timing.rpt {report_timing -to [get_ports core_data_o] -delay_type min -max_paths 10 -nosplit}
redirect -append -file ${REPORTS_DIR}/core_ready_and_o.max.interface_timing.rpt {report_timing -to [get_ports core_ready_and_o] -delay_type max -max_paths 10 -nosplit}
redirect -append -file ${REPORTS_DIR}/core_ready_and_o.min.interface_timing.rpt {report_timing -to [get_ports core_ready_and_o] -delay_type min -max_paths 10 -nosplit}

redirect -append -file ${REPORTS_DIR}/tag_lines_i.max.interface_timing.rpt {report_timing -from [get_ports {tag_*_tag_lines_i[1] tag_*_tag_lines_i[2]}] -delay_type max -max_paths 10 -nosplit}
redirect -append -file ${REPORTS_DIR}/tag_lines_i.min.interface_timing.rpt {report_timing -from [get_ports {tag_*_tag_lines_i[1] tag_*_tag_lines_i[2]}] -delay_type min -max_paths 10 -nosplit}
