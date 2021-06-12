puts "BSG-info: Running script [info script]\n"

set ROUTE_AUTO_CREATE_SHIELDS "none"
set REDUNDANT_VIA_INSERTION false

set_app_options -name route.common.threshold_noise_ratio -value 0.25
set_app_options -name route_opt.flow.xtalk_reduction -value true

puts "BSG-info: Completed script [info script]\n"
