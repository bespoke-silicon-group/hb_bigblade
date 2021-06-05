set DESIGN_NAME $::env(DESIGN_NAME)

open_lib $DESIGN_NAME
open_block $DESIGN_NAME/init_design
link_block

set create_frame_cmd "create_frame -block_all used_layers"
append create_frame_cmd " -remove_non_pin_shapes {"
foreach layer [get_object_name [get_layers -filter "is_default_layer"]] {
  append create_frame_cmd " {$layer all} "
}
append create_frame_cmd "}"
puts "BSG-info: create frame cmd => \"$create_frame_cmd\""
eval $create_frame_cmd

write_lef /tmp/temp_$DESIGN_NAME.lef

exit
