puts "BSG-info running [info script]"

#create_placement -timing_driven
#legalize_placement -incremental
add_tie_cells
legalize_placement
check_legality

puts "BSG-info finished [info script]"
