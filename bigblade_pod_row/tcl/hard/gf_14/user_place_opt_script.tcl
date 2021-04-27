puts "BSG-info running user_place_opt_script"

create_placement -timing_driven
legalize_placement -incremental
add_tie_cells

puts "BSG-info finished user_place_opt_script"
