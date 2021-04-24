

set_app_options -name plan.place.auto_generate_blockages -value false

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

for {set x 0} {$x < $HB_NUM_TILES_X_P} {incr x} {
  set sdr_cell [get_cells "sdr_x_${x}__sdr_n"]
  set llx [expr $x*11*$grid_width]
  set lly 0
  move_objects $sdr_cell -x $llx -y $lly
  set_fixed_objects $sdr_cell

}
