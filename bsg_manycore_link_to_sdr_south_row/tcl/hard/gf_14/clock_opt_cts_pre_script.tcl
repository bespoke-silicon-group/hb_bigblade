
set_app_options -name clock_opt.flow.enable_clock_power_recovery -value none
set_app_options -name route_opt.flow.enable_clock_power_recovery -value none
set_app_options -name clock_opt.flow.enable_ccd -value false
set_app_options -name cts.common.enable_auto_skew_target_for_local_skew -value false

set_max_transition -scenarios [all_scenarios] -clock_path 25 [all_clocks]
set_clock_tree_options -corners [get_corners *] -clocks [get_clocks -filter "!is_generated"] -target_latency 100



create_routing_rule "bsg_cts_2w2s"  \
  -default_reference_rule       \
  -widths {M2 0.064 M3 0.064 C4 0.12 C5 0.12 K1 0.128 K2 0.128 K3 0.128 K4 0.128 H1 0.18} \
  -multiplier_spacing 2         \
  -cuts {                       \
    {V2 {Vx 2}}              \
    {J3 {Jy 2}}              \
    {A4 {AxLRG 2}}              \
    {CK {CK    4}}              \
    {U1 {Ux    4}}              \
    {U2 {Ux    4}}              \
    {U3 {Ux    4}}              \
    {KH {KH    1}}              \
  }

set_clock_routing_rules         \
  -net_type root                \
  -rule "bsg_cts_2w2s"          \
  -min_routing_layer "M2"       \
  -max_routing_layer "K4"

set_clock_routing_rules         \
  -net_type internal            \
  -rule "bsg_cts_2w2s"          \
  -min_routing_layer "M2"       \
  -max_routing_layer "K4"

set_clock_routing_rules         \
  -net_type sink                \
  -rule "bsg_cts_2w2s"          \
  -min_routing_layer "M2"       \
  -max_routing_layer "K4"


foreach_in_collection m [get_modes] {
  current_mode $m
  create_clock_skew_group -name sg1 -objects [get_pins "sdr_x_*__sdr_n/core_clk_i"]
}

