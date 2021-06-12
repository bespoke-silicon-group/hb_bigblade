puts "BSG-info: Running script [info script]\n"

set ROUTE_OPT_RESHIELD "none"
set_app_options -name route.common.threshold_noise_ratio -value 0.25
set_app_options -name route_opt.flow.xtalk_reduction -value true

puts "BSG-info: Completed script [info script]\n"
