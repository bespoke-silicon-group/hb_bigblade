
### bsg_router_tile constraints ################################################

if { $DESIGN_NAME == "bsg_router_tile" } {

  set clk_period    700.0
  set clk_uncert    20.0

  set max_idly      550.0
  set min_idly      20.0

  set max_odly      150.0
  set min_odly      20.0

  create_clock -period $clk_period -name "core_clk" [get_ports "clk_i"]
  set_clock_uncertainty $clk_uncert [get_clocks "core_clk"]

  set_input_delay -max $max_idly -clock "core_clk" [remove_from_collection [all_inputs] [get_ports "clk_i"]]
  set_input_delay -min $min_idly -clock "core_clk" [remove_from_collection [all_inputs] [get_ports "clk_i"]]

  set_output_delay -max $max_odly -clock "core_clk" [all_outputs]
  set_output_delay -min $min_odly -clock "core_clk" [all_outputs]

  set_case_analysis 0 [get_ports "my_*"]

  set_driving_cell -no_design_rule -lib_cell "$LIB_CELLS(invx2)" [all_inputs]
  set_load [load_of [get_lib_pin "*/$LIB_CELLS(invx8,load_pin)"]] [all_outputs]

### undefined design constraints ###############################################

} else {

  puts "BSG-error: no constraints specified for design ${DESIGN_NAME}"

}

