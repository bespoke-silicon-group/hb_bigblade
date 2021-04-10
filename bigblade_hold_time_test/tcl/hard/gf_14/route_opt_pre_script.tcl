set_app_options -name route.global.timing_driven -value false
set_app_options -name route.track.timing_driven -value false
set_app_options -name route.detail.timing_driven -value false

set_app_options -name time.enable_si_timing_windows -value true
set_app_options -name route.common.threshold_noise_ratio -value 0.25
set_app_options -name route_opt.flow.xtalk_reduction -value true

set_scenario_status tt_0p80v_25c_nominal -leakage_power true -dynamic_power true