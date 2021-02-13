puts "BSG-info: Running script [info script]\n"

#set min_scenario sspg_0p72v_125c_sigcmax
#set min_scenario ffpg_0p88v_125c_sigcmin
#set min_scenario ffpg_0p88v_m40c_sigcmin

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hb_design_constants.tcl

# local link
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  # west
  set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/west_input.max.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/west_output.max.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/west_input.min.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file ${REPORTS_DIR}/west_output.min.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min}
  # east
  set idx [expr $i+(1*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/east_input.max.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/east_output.max.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/east_input.min.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file ${REPORTS_DIR}/east_output.min.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min}
  # north
  set idx [expr $i+(2*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/north_input.max.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/north_output.max.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/north_input.min.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file ${REPORTS_DIR}/north_output.min.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min}
  # south
  set idx [expr $i+(3*$HB_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/south_input.max.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/south_output.max.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/south_input.min.interface_timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file ${REPORTS_DIR}/south_output.min.interface_timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min}
}


# ruche link
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  # RW0
  set idx [expr $i+(0*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/rw0_input.max.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/rw0_output.max.interface_timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/rw0_input.min.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file ${REPORTS_DIR}/rw0_output.min.interface_timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit -delay_type min}
  # RE0
  set idx [expr $i+(1*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file ${REPORTS_DIR}/re0_input.max.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/re0_output.max.interface_timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit}
  redirect -append -file ${REPORTS_DIR}/re0_input.min.interface_timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file ${REPORTS_DIR}/re0_output.min.interface_timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit -delay_type min}
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


puts "BSG-info: Completed script [info script]\n"
