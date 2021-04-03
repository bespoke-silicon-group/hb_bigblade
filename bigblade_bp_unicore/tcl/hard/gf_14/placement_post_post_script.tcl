
# Remove placements blockages inside of ISDR bound, within 5 units
set bbox_llx [get_attribute [get_bounds "isdr"] -name bounding_box.ll_x]
set bbox_lly [get_attribute [get_bounds "isdr"] -name bounding_box.ll_y]
set bbox_urx [get_attribute [get_bounds "isdr"] -name bounding_box.ur_x]
set bbox_ury [get_attribute [get_bounds "isdr"] -name bounding_box.ur_y]
set bbox [list [list [expr $bbox_llx-5] [expr $bbox_lly-5]] [list [expr $bbox_urx+5] [expr $bbox_ury+5]]]

remove_placement_blockages [get_placement_blockages -within $bbox]
