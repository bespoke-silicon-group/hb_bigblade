puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

proc bsg_dont_touch_regexp {arg1} {
  set pattern "full_name=~$arg1";
  set mycells [get_cells -hier -filter $pattern]
  puts [concat "BSG: set dont_touch'ing " $pattern "=" [collection_to_list $mycells]]
  set_dont_touch $mycells
}

proc bsg_dont_touch_regexp_type {arg1} {
  set pattern "ref_name=~$arg1";
  set mycells [get_cells -hier -filter $pattern]
  puts [concat "BSG: set dont_touch'ing " $pattern "=" [collection_to_list $mycells]]
  set_dont_touch $mycells
}

#bsg_dont_touch_regexp *DONT_TOUCH*
#bsg_dont_touch_regexp_type *SYNC*SDFF*

set_dont_touch [get_cells -hier -filter "name=~*hard_inv*"] true
set_dont_touch [get_cells -hier -filter "name=~*hard_buf*"] true

set_dont_touch [get_nets -of [get_pins y_*__x_*__tile/ruche_link_*]] true

puts "BSG-info: Completed script [info script]\n"
