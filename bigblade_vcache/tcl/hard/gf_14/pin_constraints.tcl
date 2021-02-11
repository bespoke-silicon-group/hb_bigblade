puts "BSG-info: Running script [info script]\n"


remove_individual_pin_constraints
remove_block_pin_constraints
set_block_pin_constraints -allowed_layers {C4 C5 K1 K2 K3 K4}


## common proc #########################################
proc place_pins_k2_k4 {pins start_x y} {
  set curr_x $start_x
  set i 0

  while {$i < [sizeof_collection $pins]} {
    set pin [index_collection $pins $i]

    set layer ""
    if {$i % 2 == 0} {
      set layer "K2"
    } else {
      set layer "K4"
    }

    if { [bsg_pins_check_location $curr_x $y $layer] == 1 } {
      set_individual_pin_constraints -pins $pin -allowed_layers $layer -location "$curr_x $y"
      incr i
    }

    set curr_x [expr $curr_x + 0.128]
  }
}

########################################################




source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/pin_constraints_tile.tcl
source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/pin_constraints_vcache.tcl
source $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/pin_constraints_top.tcl




puts "BSG-info: Completed script [info script]\n"
