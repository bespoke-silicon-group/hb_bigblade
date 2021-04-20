puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

set_app_options -name clock_opt.flow.enable_clock_power_recovery -value none
set_app_options -name route_opt.flow.enable_clock_power_recovery -value none

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


# set balance points
#set vcache_clk_pins [get_pins "podrow/px_*__pod/*_vc_x_*__*_vc_row/clk_i"]
#set_clock_balance_points -early -consider_for_balancing true -delay 166 -corners ffpg_0p88v_125c_sigcmin -balance_points $vcache_clk_pins
#set_clock_balance_points -late  -consider_for_balancing true -delay 192 -corners ffpg_0p88v_125c_sigcmin -balance_points $vcache_clk_pins
#set_clock_balance_points -early -consider_for_balancing true -delay 153 -corners ffpg_0p88v_m40c_sigcmin -balance_points $vcache_clk_pins
#set_clock_balance_points -late  -consider_for_balancing true -delay 177 -corners ffpg_0p88v_m40c_sigcmin -balance_points $vcache_clk_pins
#set_clock_balance_points -early -consider_for_balancing true -delay 300 -corners sspg_0p72v_125c_sigcmax -balance_points $vcache_clk_pins
#set_clock_balance_points -late  -consider_for_balancing true -delay 337 -corners sspg_0p72v_125c_sigcmax -balance_points $vcache_clk_pins
#set_clock_balance_points -clock manycore_clk -consider_for_balancing true -corners ffpg_0p88v_125c_sigcmin -balance_points $vcache_clk_pins
#set_clock_balance_points -clock manycore_clk -consider_for_balancing true -corners ffpg_0p88v_m40c_sigcmin -balance_points $vcache_clk_pins
#set_clock_balance_points -clock manycore_clk -consider_for_balancing true -corners sspg_0p72v_125c_sigcmax -balance_points $vcache_clk_pins

#set tile_clk_pins [get_pins "podrow/px_*__pod/mc_y_*__mc_x_*__mc/clk_i"]
#set_clock_balance_points -early -consider_for_balancing true -delay 209 -corners ffpg_0p88v_125c_sigcmin -balance_points $tile_clk_pins
#set_clock_balance_points -late  -consider_for_balancing true -delay 234 -corners ffpg_0p88v_125c_sigcmin -balance_points $tile_clk_pins
#set_clock_balance_points -early -consider_for_balancing true -delay 188 -corners ffpg_0p88v_m40c_sigcmin -balance_points $tile_clk_pins
#set_clock_balance_points -late  -consider_for_balancing true -delay 208 -corners ffpg_0p88v_m40c_sigcmin -balance_points $tile_clk_pins
#set_clock_balance_points -early -consider_for_balancing true -delay 379 -corners sspg_0p72v_125c_sigcmax -balance_points $tile_clk_pins
#set_clock_balance_points -late  -consider_for_balancing true -delay 417 -corners sspg_0p72v_125c_sigcmax -balance_points $tile_clk_pins
#set_clock_balance_points -clock manycore_clk -consider_for_balancing true -corners ffpg_0p88v_125c_sigcmin -balance_points $tile_clk_pins
#set_clock_balance_points -clock manycore_clk -consider_for_balancing true -corners ffpg_0p88v_m40c_sigcmin -balance_points $tile_clk_pins
#set_clock_balance_points -clock manycore_clk -consider_for_balancing true -corners sspg_0p72v_125c_sigcmax -balance_points $tile_clk_pins

# report
#report_clock_balance_points

puts "BSG-info: Completed script [info script]\n"
