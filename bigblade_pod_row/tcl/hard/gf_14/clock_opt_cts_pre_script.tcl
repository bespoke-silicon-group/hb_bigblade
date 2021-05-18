puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

set_app_options -name clock_opt.flow.enable_clock_power_recovery -value none
set_app_options -name route_opt.flow.enable_clock_power_recovery -value none
set_app_options -name clock_opt.flow.enable_ccd -value false
set_app_options -name cts.common.enable_auto_skew_target_for_local_skew -value false

set REPORT_QOR_REPORT_CONGESTION 0

create_routing_rule "bsg_cts_2w2s"  \
  -default_reference_rule       \
  -widths {M2 0.064 M3 0.064 C4 0.12 C5 0.12 K1 0.128 K2 0.128 K3 0.128 K4 0.128 H1 0.18 H2 0.18} \
  -multiplier_spacing 2         \
  -cuts {                       \
    {V2 {VxLRG 2}}              \
    {J3 {JyLRG 2}}              \
    {A4 {AxLRG 2}}              \
    {CK {CK    4}}              \
    {U1 {Ux    4}}              \
    {U2 {Ux    4}}              \
    {U3 {Ux    4}}              \
    {KH {KH    1}}              \
    {N1 {Nx    1}}              \
  }

set_clock_routing_rules         \
  -net_type root                \
  -rule "bsg_cts_2w2s"          \
  -min_routing_layer "K1"       \
  -max_routing_layer "K4"

set_clock_routing_rules         \
  -net_type internal            \
  -rule "bsg_cts_2w2s"          \
  -min_routing_layer "K1"       \
  -max_routing_layer "K4"

set_clock_routing_rules         \
  -net_type sink                \
  -rule "bsg_cts_2w2s"          \
  -min_routing_layer "K1"       \
  -max_routing_layer "K4"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14/create_clock_tree4.tcl


puts "BSG-info: Completed script [info script]\n"
