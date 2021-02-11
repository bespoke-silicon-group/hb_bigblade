

set HB_LINK_WIDTH_P         154
set HB_RUCHE_LINK_WIDTH_P   140

# west input
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  redirect -append -file west_input.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
}

# east input
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(1*$HB_LINK_WIDTH_P)]
  redirect -append -file east_input.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
}

# north input
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(2*$HB_LINK_WIDTH_P)]
  redirect -append -file north_input.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
}


# south input
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(3*$HB_LINK_WIDTH_P)]
  redirect -append -file south_input.timing.rpt {report_timing -from [get_ports "link_i[$idx]"] -nosplit}
}


# RW input
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(0*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file rw_input.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
}

# RE input
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(1*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file re_input.timing.rpt {report_timing -from [get_ports "ruche_link_i[$idx]"] -nosplit}
}



#################

# west output
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(0*$HB_LINK_WIDTH_P)]
  redirect -append -file west_output.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
}

# east input
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(1*$HB_LINK_WIDTH_P)]
  redirect -append -file east_output.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
}

# north input
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(2*$HB_LINK_WIDTH_P)]
  redirect -append -file north_output.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
}


# south input
for {set i 0} {$i < $HB_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(3*$HB_LINK_WIDTH_P)]
  redirect -append -file south_output.timing.rpt {report_timing -to [get_ports "link_o[$idx]"] -nosplit}
}


# RW input
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(0*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file rw_output.timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit}
}

# RE input
for {set i 0} {$i < $HB_RUCHE_LINK_WIDTH_P} {incr i} {
  set idx [expr $i+(1*$HB_RUCHE_LINK_WIDTH_P)]
  redirect -append -file re_output.timing.rpt {report_timing -to [get_ports "ruche_link_o[$idx]"] -nosplit}
}
