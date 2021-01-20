
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

