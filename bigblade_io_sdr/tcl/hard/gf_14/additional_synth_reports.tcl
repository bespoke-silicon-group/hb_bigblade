
eval file delete [glob -nocomplain ${REPORTS_DIR}/*interface_timing.rpt]

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl



# ver link
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  # north
  set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/north_input.max.interface_timing.rpt {report_timing -from [get_ports "core_ver_link_sif_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/north_output.max.interface_timing.rpt {report_timing -to [get_ports "core_ver_link_sif_o[$idx]"] -nosplit}
  # south
  set idx [expr $i+(1*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/south_input.max.interface_timing.rpt {report_timing -from [get_ports "core_ver_link_sif_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/south_output.max.interface_timing.rpt {report_timing -to [get_ports "core_ver_link_sif_o[$idx]"] -nosplit}
}

# local hor link
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/hor_input.max.interface_timing.rpt {report_timing -from [get_ports "core_hor_link_sif_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/hor_output.max.interface_timing.rpt {report_timing -to [get_ports "core_hor_link_sif_o[$idx]"] -nosplit}
}

# ruche hor link
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  redirect -append -file ${REPORTS_DIR}/ruche_input.max.interface_timing.rpt {report_timing -from [get_ports "core_ruche_link_i[$i]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/ruche_output.max.interface_timing.rpt {report_timing -to [get_ports "core_ruche_link_o[$i]"] -nosplit}
}
