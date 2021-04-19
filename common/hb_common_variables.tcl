puts "BSG-info: Running script [info script]\n"


source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl

# unit height = 0.48 um
# unit width  = 0.084 um

# block grid unit
set grid_width  [expr 28*[unit_height]]
set grid_height [expr 12*[unit_height]]

# distance from core origin to pod origin
set pod_x_offset      [expr $grid_width*0]
set pod_y_offset      [expr $grid_height*1]


# shape of tiles
set tile_width        [expr ($grid_width*10.5)+0.672]
set tile_height       [expr $grid_height*32.50]
set vcache_width      [expr ($grid_width*10.5)+0.672]
set vcache_height     [expr $grid_height*25.50]


# spacing between tiles
set tile_x_space        [expr $grid_width*0.5-0.672]
set tile_y_space        [expr $grid_height*0.5]
set vcache_x_space      [expr $grid_width*0.5-0.672]
set vcache_top_y_space  [expr $grid_height*0.50]
set vcache_bot_y_space  [expr $grid_height*0.75]


# corners of each part of array
set bot_vcache_llx      [expr $pod_x_offset]
set bot_vcache_lly      [expr $pod_y_offset]
set bot_vcache_ury      [expr $bot_vcache_lly + $vcache_height]

set tile_array_llx      [expr $pod_x_offset]
set tile_array_lly      [expr $bot_vcache_lly+$vcache_height+$vcache_bot_y_space]

set top_vcache_llx      [expr $pod_x_offset]
set top_vcache_lly      [expr $tile_array_lly+($tile_height+$tile_y_space)*$HB_NUM_TILES_Y_P-$tile_y_space+$vcache_top_y_space]

# core area dimension
set core_height         [expr $top_vcache_lly + $vcache_height + (0.75*$grid_height)]
set core_width          [expr $tile_array_llx + $HB_NUM_TILES_X_P*($tile_width+$tile_x_space)]

# distance between tile and ruche buffer RP groups
set RB_RP_X_OFFSET      [expr 16*[unit_width]]

set TAPCELL_X_OFFSET    [expr 47*[unit_width]]

# pin offsets
set NORTH_INPUT_OFFSET          [expr (324*0.128)]
set NORTH_OUTPUT_OFFSET         [expr (573*0.128)]

set TILE_WEST_OUTPUT_OFFSET     [expr (0.128*22)]
set TILE_WEST_INPUT_OFFSET      [expr (0.128*747)]

set VCACHE_WEST_OUTPUT_OFFSET   [expr (302*0.128)]
set VCACHE_WEST_INPUT_OFFSET    [expr (702*0.128)]




# POD DIMENSION
set  tile_array_width         [expr $grid_width*176.5]
set  tile_array_height        [expr $grid_height*65.5]
set  vcache_array_width       [expr $grid_width*176.5]
set  vcache_array_height      [expr $grid_height*25.75]


set  sdr_horiz_east_width      [expr $grid_width*3.5]
set  sdr_horiz_west_width      [expr $grid_width*3.75]
set  sdr_horiz_height          [expr $grid_height*32.5]

set  sdr_vert_width    [expr $grid_width*10.5]
set  sdr_vert_height   [expr $grid_height*3.5]

set  sdr_corner_east_width          [expr $grid_width*3.5]
set  sdr_corner_west_width          [expr $grid_width*3.75]
set  sdr_corner_height              [expr $grid_height*25.5]

set pod_row_width   [expr $sdr_horiz_west_width + \
                          (0.25*$grid_width) + \
                          ((($grid_width*0.5)+$tile_array_width)*$HB_NUM_PODS_X_P) + \
                          $sdr_horiz_east_width]
                          


set  pod_row_height   [expr $sdr_vert_height + (0.5*$grid_height) + \
                        ($vcache_array_height+(0.5*$grid_height))*2 + \
                        ($tile_array_height+(0.5*$grid_height))*4 + \
                        $sdr_vert_height + (1*$grid_height)]


puts "BSG-info: Completed script [info script]\n"
