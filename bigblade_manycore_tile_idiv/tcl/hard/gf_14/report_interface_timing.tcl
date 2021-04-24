puts "BSG-info: Running script [info script]\n"

eval file delete [glob -nocomplain reports/*interface_timing.rpt]

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl

set min_scenario {"sspg_0p72v_125c_sigcmax" "ffpg_0p88v_125c_sigcmin" "ffpg_0p88v_m40c_sigcmin"}


# local link
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  # west
  set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/west_input.max.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/west_output.max.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
  # east
  set idx [expr $i+(1*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/east_input.max.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/east_output.max.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
  # north
  set idx [expr $i+(2*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/north_input.max.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/north_output.max.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
  # south
  set idx [expr $i+(3*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/south_input.max.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/south_output.max.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
}


# ruche link
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  # RW0
  set idx [expr $i+(0*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/rw0_input.max.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/rw0_output.max.interface_timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit}
  # RE0
  set idx [expr $i+(1*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/re0_input.max.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/re0_output.max.interface_timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit}
  # RW1
  #set idx [expr $i+(2*$HB_RUCHE_LINK_WIDTH_P)]
  #redirect -append -file ${REPORTS_DIR}/rw1.max.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  #redirect -append -file ${REPORTS_DIR}/rw1.min.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min -scenario $min_scenario}
  # RE1
  #set idx [expr $i+(3*$HB_RUCHE_LINK_WIDTH_P)]
  #redirect -append -file ${REPORTS_DIR}/re1.max.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  #redirect -append -file ${REPORTS_DIR}/re1.min.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min -scenario $min_scenario}
  # RW2
  #set idx [expr $i+(4*$HB_RUCHE_LINK_WIDTH_P)]
  #redirect -append -file ${REPORTS_DIR}/rw2.max.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  #redirect -append -file ${REPORTS_DIR}/rw2.min.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min -scenario $min_scenario}
  # RE2
  #set idx [expr $i+(5*$HB_RUCHE_LINK_WIDTH_P)]
  #redirect -append -file ${REPORTS_DIR}/re2.max.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  #redirect -append -file ${REPORTS_DIR}/re2.min.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min -scenario $min_scenario}
}


foreach scenario $min_scenario {
  # local link
  for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
    # west
    set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
    redirect -append -file ${REPORTS_DIR}/west_input.${scenario}.min.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min -scenario $scenario}
    redirect -append -file ${REPORTS_DIR}/west_output.${scenario}.min.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min -scenario $scenario}
    # east
    set idx [expr $i+(1*$HB_LINK_WIDTH_P)]
    redirect -append -file ${REPORTS_DIR}/east_input.${scenario}.min.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min -scenario $scenario}
    redirect -append -file ${REPORTS_DIR}/east_output.${scenario}.min.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min -scenario $scenario}
    # north
    set idx [expr $i+(2*$HB_LINK_WIDTH_P)]
    redirect -append -file ${REPORTS_DIR}/north_input.${scenario}.min.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min -scenario $scenario}
    redirect -append -file ${REPORTS_DIR}/north_output.${scenario}.min.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min -scenario $scenario}
    # south
    set idx [expr $i+(3*$HB_LINK_WIDTH_P)]
    redirect -append -file ${REPORTS_DIR}/south_input.${scenario}.min.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min -scenario $scenario}
    redirect -append -file ${REPORTS_DIR}/south_output.${scenario}.min.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min -scenario $scenario}
  }


  # ruche link
  for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
    # RW0
    set idx [expr $i+(0*$HB_RUCHE_LINK_WIDTH_P)]
    redirect -append -file ${REPORTS_DIR}/rw0_input.${scenario}.min.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min -scenario $scenario}
    redirect -append -file ${REPORTS_DIR}/rw0_output.${scenario}.min.interface_timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit -delay_type min -scenario $scenario}
    # RE0
    set idx [expr $i+(1*$HB_RUCHE_LINK_WIDTH_P)]
    redirect -append -file ${REPORTS_DIR}/re0_input.${scenario}.min.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min -scenario $scenario}
    redirect -append -file ${REPORTS_DIR}/re0_output.${scenario}.min.interface_timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit -delay_type min -scenario $scenario}
  }
  

}


puts "BSG-info: Completed script [info script]\n"
