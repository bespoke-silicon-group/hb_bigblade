
eval file delete [glob -nocomplain ${REPORTS_DIR}/*interface_timing.rpt]

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl


# ver link
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/ver_input.max.interface_timing.rpt {report_timing -from [get_ports "core_ver_link_sif_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/ver_output.max.interface_timing.rpt {report_timing -to [get_ports "core_ver_link_sif_o[$idx]"] -nosplit}
}

# wh link
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(0*$HB_WH_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/wh0_output.max.interface_timing.rpt {report_timing -to [get_ports "core_wh_link_sif_o[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/wh0_input.max.interface_timing.rpt {report_timing -to [get_ports "core_wh_link_sif_i[$idx]"] -nosplit}
 
  set idx [expr $i+(1*$HB_WH_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/wh1_output.max.interface_timing.rpt {report_timing -to [get_ports "core_wh_link_sif_o[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/wh1_input.max.interface_timing.rpt {report_timing -to [get_ports "core_wh_link_sif_i[$idx]"] -nosplit}
}
