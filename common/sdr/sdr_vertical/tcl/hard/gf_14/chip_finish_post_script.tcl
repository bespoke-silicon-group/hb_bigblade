eval file delete [glob -nocomplain ${REPORTS_DIR}/*interface_timing.rpt]

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl

set min_scenario {"sspg_0p72v_125c_sigcmax" "ffpg_0p88v_125c_sigcmin" "ffpg_0p88v_m40c_sigcmin" }


for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/core_link_input.max.interface_timing.rpt {report_timing -from [get_ports "core_link_sif_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/core_link_output.max.interface_timing.rpt {report_timing -to [get_ports "core_link_sif_o[$idx]"] -nosplit}
}


foreach scenario $min_scenario {
  for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
    set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
    redirect -append -file ${REPORTS_DIR}/core_link_input.${scenario}.min.interface_timing.rpt {report_timing -from [get_ports "core_link_sif_i[$idx]"] -nosplit -delay_type min -scenario $scenario} 
    redirect -append -file ${REPORTS_DIR}/core_link_output.${scenario}.min.interface_timing.rpt {report_timing -to [get_ports "core_link_sif_o[$idx]"] -nosplit -delay_type min -scenario $scenario}
  }
}
