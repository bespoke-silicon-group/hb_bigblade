puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

create_routing_rule "bsg_cts_2w2s"  \
  -default_reference_rule       \
  -multiplier_width 2           \
  -multiplier_spacing 2         \
  -cuts {                       \
    {V2 {VxLRG 1}}              \
    {J3 {JyLRG 1}}              \
    {A4 {AxLRG 1}}              \
    {CK {CK    4}}              \
    {U1 {Ux    4}}              \
    {U2 {Ux    4}}              \
    {U3 {Ux    4}}              \
    {KH {KH    4}}              \
  }

set_clock_routing_rules         \
  -net_type root                \
  -rule "bsg_cts_2w2s"          \
  -min_routing_layer "K1"       \
  -max_routing_layer "H1"

set_clock_routing_rules         \
  -net_type internal            \
  -rule "bsg_cts_2w2s"          \
  -min_routing_layer "K1"       \
  -max_routing_layer "H1"

set_clock_routing_rules         \
  -net_type sink                \
  -rule "bsg_cts_2w2s"          \
  -min_routing_layer "M2"       \
  -max_routing_layer "H1"

puts "BSG-info: Completed script [info script]\n"
