
### bsg_chip constraints ################################################

if { $DESIGN_NAME == "bsg_chip" } {

  ungroup -flatten [get_cells -filter "@hdl_template==bsg_mesh_stitch"]

  set clk_period    1000.0
  set clk_uncert    20.0
  create_clock -period $clk_period -name "core_clk" [get_ports "clk_i"]
  set_clock_uncertainty $clk_uncert [get_clocks "core_clk"]

  set max_idly_perc 0.80
  set min_idly_perc 0.02
  set_input_delay -min [expr $clk_period*$min_idly_perc] -clock "core_clk" [remove_from_collection [all_inputs] [get_ports "clk_i"]]
  set_input_delay -max [expr $clk_period*$max_idly_perc] -clock "core_clk" [remove_from_collection [all_inputs] [get_ports "clk_i"]]

  set max_odly_perc 0.20
  set min_odly_perc 0.02
  set_output_delay -min [expr $clk_period*$min_odly_perc] -clock "core_clk" [all_outputs]
  set_output_delay -max [expr $clk_period*$max_odly_perc] -clock "core_clk" [all_outputs]

  set_driving_cell -no_design_rule -lib_cell "$LIB_CELLS(invx2)" [all_inputs]
  set_load [load_of [get_lib_pin "*/$LIB_CELLS(invx8,load_pin)"]] [all_outputs]

  set_false_path -from [get_ports "reset_i"]

### undefined design constraints ###############################################

} else {

  puts "BSG-error: no constraints specified for design ${DESIGN_NAME}"

}

