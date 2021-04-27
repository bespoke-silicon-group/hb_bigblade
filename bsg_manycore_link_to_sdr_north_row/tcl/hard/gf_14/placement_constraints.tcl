

set_app_options -name plan.place.auto_generate_blockages -value false

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

for {set x 0} {$x < $HB_NUM_TILES_X_P} {incr x} {
  set sdr_cell [get_cells "sdr_x_${x}__sdr_n"]
  set llx [expr $x*11*$grid_width]
  set lly 0
  move_objects $sdr_cell -x $llx -y $lly
  set_fixed_objects $sdr_cell

}



# bsg tag
set llx [expr [die_urx] - 12]
set lly [expr [die_ury] - 4.5]
set urx [die_urx]
set ury [die_ury]
create_bound -name "btc_bound" -boundary [list [list $llx $lly] [list $urx $ury]] -type hard
add_to_bound "btc_bound" [get_flat_cells "btc*"]
