set_app_options -name route.global.timing_driven -value false
set_app_options -name route.track.timing_driven -value false
set_app_options -name route.detail.timing_driven -value false

set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.crosstalk_driven -value true

set_app_options -name time.enable_si_timing_windows -value true
set_app_options -name route.common.threshold_noise_ratio -value 0.25
set_app_options -name route_opt.flow.xtalk_reduction -value true
set_app_options -name route_opt.flow.enable_cto -value true
set_app_options -name route_opt.flow.enable_ccd -value true

set CLOCK_OPT_GLOBAL_ROUTE_OPT    false
remove_route_aware_estimation
