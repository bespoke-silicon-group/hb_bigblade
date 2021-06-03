# Clear out power grid from between D$ channels
set split_bound {{83.544 0.512} {84.552 165.600}}
#remove_objects [split_objects -rect $channel_bound [get_shapes -intersect $channel_bound -filter "layer.name==C5 && (net.name==VDD||net.name==VSS)"]]
split_objects -rect $split_bound [get_shapes -intersect $split_bound -filter "layer.name==C5 && (net.name==VDD||net.name==VSS)"]

set surround_bound {{82.544 -0.512} {85.552 166.600}}
remove_objects [get_shapes -within $surround_bound -filter "(net.name==VDD||net.name==VSS)"]
remove_objects [get_vias -within $surround_bound]

