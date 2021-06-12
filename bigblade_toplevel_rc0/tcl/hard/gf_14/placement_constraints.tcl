set BLOCK        [get_flat_cells "block"]
set BLOCK_WIDTH  [get_attribute $BLOCK width ]
set BLOCK_HEIGHT [get_attribute $BLOCK height]
set BLOCK_X      [expr ([die_width]  - $BLOCK_WIDTH)  / 2.0]
set BLOCK_Y      [expr ([die_height] - $BLOCK_HEIGHT) / 2.0]

set BLOCK_FIX_X 0
set BLOCK_FIX_Y 0

set_fixed_objects -unfix $BLOCK
move_object $BLOCK -x [expr $BLOCK_X + $BLOCK_FIX_X] -y [expr $BLOCK_Y + $BLOCK_FIX_Y]
set_fixed_objects $BLOCK