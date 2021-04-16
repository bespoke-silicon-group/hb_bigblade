#set_app_options -name route.global.timing_driven -value false
#set_app_options -name route.track.timing_driven -value false
#set_app_options -name route.detail.timing_driven -value false

#set_app_options -name route.global.crosstalk_driven -value true
#set_app_options -name route.track.crosstalk_driven -value true

#set_app_options -name time.enable_si_timing_windows -value true
#set_app_options -name route.common.threshold_noise_ratio -value 0.25
set_app_options -name route_opt.flow.xtalk_reduction -value true
#set_app_options -name route_opt.flow.enable_cto -value true
#set_app_options -name route_opt.flow.enable_ccd -value true

#set_app_options -name ccd.post_route_buffer_removal -value false
#set_app_options -name opt.area.effort -value low
#set_app_options -name opt.common.advanced_logic_restructuring_mode -value timing
#set_app_options -name opt.common.buffer_area_effort -value low
#set_app_options -name opt.power.effort -value low
#set_app_options -name opt.power.mode -value none
#set_app_options -name route_opt.flow.enable_power -value false

#set ROUTE_OPT_CCD_IN_SECOND_RUN   true
