

set HB_LINK_WIDTH_P         154
set HB_RUCHE_LINK_WIDTH_P   140

# local link
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  # west
  set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  redirect -append -file west_input.max.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file west_output.max.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
  redirect -append -file west_input.min.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file west_output.min.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min}
  # east
  set idx [expr $i+(1*$HB_LINK_WIDTH_P)]
  redirect -append -file east_input.max.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file east_output.max.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
  redirect -append -file east_input.min.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file east_output.min.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min}
  # north
  set idx [expr $i+(2*$HB_LINK_WIDTH_P)]
  redirect -append -file north_input.max.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file north_output.max.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
  redirect -append -file north_input.min.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file north_output.min.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min}
  # south
  set idx [expr $i+(3*$HB_LINK_WIDTH_P)]
  redirect -append -file south_input.max.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
  redirect -append -file south_output.max.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
  redirect -append -file south_input.min.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file south_output.min.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit -delay_type min}
}


# ruche link
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  # RW0
  set idx [expr $i+(0*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file rw0_input.max.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  redirect -append -file rw0_output.max.timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit}
  redirect -append -file rw0_input.min.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file rw0_output.min.timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit -delay_type min}
  # RE0
  set idx [expr $i+(1*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file re0_input.max.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  redirect -append -file re0_output.max.timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit}
  redirect -append -file re0_input.min.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min}
  redirect -append -file re0_output.min.timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit -delay_type min}
  # RW1
  set idx [expr $i+(2*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file rw1.max.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  redirect -append -file rw1.min.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min}
  # RE1
  set idx [expr $i+(3*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file re1.max.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  redirect -append -file re1.min.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min}
  # RW2
  set idx [expr $i+(4*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file rw2.max.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  redirect -append -file rw2.min.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min}
  # RE2
  set idx [expr $i+(5*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file re2.max.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
  redirect -append -file re2.min.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit -delay_type min}
}

