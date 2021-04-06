
eval file delete [glob -nocomplain ${REPORTS_DIR}/*interface_timing.rpt]

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl


# local link
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/core_link_input.max.interface_timing.rpt {report_timing -from [get_ports "core_link_sif_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/core_link_output.max.interface_timing.rpt {report_timing -to [get_ports "core_link_sif_o[$idx]"] -nosplit}
}
