puts "BSG-info: Running script [info script]\n"

set_clock_jitter -clock [get_clocks "core_clk"] -duty_cycle 10.0

puts "BSG-info: Completed script [info script]\n"
