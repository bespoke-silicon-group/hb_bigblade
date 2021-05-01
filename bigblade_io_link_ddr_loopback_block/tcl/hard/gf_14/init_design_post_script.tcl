
report_clock_skew_groups

for {set i 0} {$i < 8} {incr i} {
  create_clock_skew_group -name "tag${i}"    -objects [get_pins "mem_link*${i}*link/tag_clk_i"]
  create_clock_skew_group -name "extio${i}"  -objects [get_pins "mem_link*${i}*link/ext_io_clk_i"]
  create_clock_skew_group -name "extnoc${i}" -objects [get_pins "mem_link*${i}*link/ext_noc_clk_i"]
}

report_clock_skew_groups
