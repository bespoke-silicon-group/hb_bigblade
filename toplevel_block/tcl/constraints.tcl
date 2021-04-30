### constraints.tcl
set_driving_cell -no_design_rule -lib_cell "IN12LP_GPIO18_13M9S30P_IO_H" [all_inputs]
set_load [load_of [get_lib_pin "*/IN12LP_GPIO18_13M9S30P_IO_H/DATA"]] [all_outputs]

