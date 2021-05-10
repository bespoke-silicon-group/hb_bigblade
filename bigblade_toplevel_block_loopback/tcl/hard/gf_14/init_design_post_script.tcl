
report_clock_skew_groups

for {set i 0} {$i < 8} {incr i} {
  create_clock_skew_group -name "tag_mem_${i}"    -objects [get_pins "mem_link*${i}*link/tag_clk_i"]
  create_clock_skew_group -name "extio_mem_${i}"  -objects [get_pins "mem_link*${i}*link/ext_io_clk_i"]
  create_clock_skew_group -name "extnoc_mem_${i}" -objects [get_pins "mem_link*${i}*link/ext_noc_clk_i"]
}

create_clock_skew_group -name "tag_io"    -objects [get_pins "io_link/tag_clk_i"]
create_clock_skew_group -name "extio_io"  -objects [get_pins "io_link/ext_io_clk_i"]
create_clock_skew_group -name "extnoc_io" -objects [get_pins "io_link/ext_noc_clk_i"]

report_clock_skew_groups
