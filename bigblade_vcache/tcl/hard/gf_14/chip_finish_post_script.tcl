puts "BSG-info: Running script [info script]\n"


eval file delete [glob -nocomplain ${REPORTS_DIR}/*interface_timing.rpt]

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl

set min_scenario {"sspg_0p72v_125c_sigcmax" "ffpg_0p88v_125c_sigcmin" "ffpg_0p88v_m40c_sigcmin"}

# ver link
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  # north
  set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/north_input.max.interface_timing.rpt {report_timing -from [get_ports "ver_link_sif_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/north_output.max.interface_timing.rpt {report_timing -to [get_ports "ver_link_sif_o[$idx]"] -nosplit}
  # south
  set idx [expr $i+(1*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/south_input.max.interface_timing.rpt {report_timing -from [get_ports "ver_link_sif_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/south_output.max.interface_timing.rpt {report_timing -to [get_ports "ver_link_sif_o[$idx]"] -nosplit}
}

# wh link
for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
  # west
  set idx [expr $i+(0*$HB_WH_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/west_output.max.interface_timing.rpt {report_timing -to [get_ports "wh_link_sif_o[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/west_input.max.interface_timing.rpt {report_timing -from [get_ports "wh_link_sif_i[$idx]"] -nosplit}
 
  # east
  set idx [expr $i+(1*$HB_WH_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/east_output.max.interface_timing.rpt {report_timing -to [get_ports "wh_link_sif_o[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/east_input.max.interface_timing.rpt {report_timing -from [get_ports "wh_link_sif_i[$idx]"] -nosplit}

}

foreach scenario $min_scenario {
  # ver link
  for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
    # north
    set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
    redirect -append -file ${REPORTS_DIR}/north_input.${scenario}.min.interface_timing.rpt {report_timing -from [get_ports "ver_link_sif_i[$idx]"] -nosplit -delay_type min -scenario $scenario}
    redirect -append -file ${REPORTS_DIR}/north_output.${scenario}.min.interface_timing.rpt {report_timing -to [get_ports "ver_link_sif_o[$idx]"] -nosplit -delay_type min -scenario $scenario}
    # south
    set idx [expr $i+(1*$HB_LINK_WIDTH_P)]
    redirect -append -file ${REPORTS_DIR}/south_input.${scenario}.min.interface_timing.rpt {report_timing -from [get_ports "ver_link_sif_i[$idx]"] -nosplit -delay_type min -scenario $scenario}
    redirect -append -file ${REPORTS_DIR}/south_output.${scenario}.min.interface_timing.rpt {report_timing -to [get_ports "ver_link_sif_o[$idx]"] -nosplit -delay_type min -scenario $scenario}
  }

  # wh link
  for {set i 0} {$i < $HB_WH_LINK_WIDTH_P} {incr i} {
    # west
    set idx [expr $i+(0*$HB_WH_LINK_WIDTH_P)]
    redirect -append -file ${REPORTS_DIR}/west_output.${scenario}.min.interface_timing.rpt {report_timing -to [get_ports "wh_link_sif_o[$idx]"] -nosplit -delay_type min -scenario $scenario}
    redirect -append -file ${REPORTS_DIR}/west_input.${scenario}.min.interface_timing.rpt {report_timing -from [get_ports "wh_link_sif_i[$idx]"] -nosplit -delay_type min -scenario $scenario}
 
    # east
    set idx [expr $i+(1*$HB_WH_LINK_WIDTH_P)]
    redirect -append -file ${REPORTS_DIR}/east_output.${scenario}.min.interface_timing.rpt {report_timing -to [get_ports "wh_link_sif_o[$idx]"] -nosplit -delay_type min -scenario $scenario}
    redirect -append -file ${REPORTS_DIR}/east_input.${scenario}.min.interface_timing.rpt {report_timing -from [get_ports "wh_link_sif_i[$idx]"] -nosplit -delay_type min -scenario $scenario}

  }


}

puts "BSG-info: Completed script [info script]\n"
