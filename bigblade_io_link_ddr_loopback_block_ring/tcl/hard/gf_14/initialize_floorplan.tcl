puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl

set edge_offset          237
set die_width            11000
set die_height           9000
set die_block_width      [expr $die_width-2*$edge_offset]
set die_block_height     [expr $die_height-2*$edge_offset]

# 10526 8526

#initialize_floorplan \
#  -control_type core \
#  -coincident_boundary true \
#  -shape R \
#  -side_length [list $die_block_width $die_block_height]

initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -boundary { {0 0} {0 8526} {10526 8526} {10526 0} \
              {5400 0} {5400 512.44} {10156.37 512.44} {10156.37 657.88} \
              {10438.87 657.88} {10438.87 2232.28} {10156.37 2232.28} {10156.37 2523.16} \
              {10438.87 2523.16} {10438.87 4097.56} {10156.37 4097.56} {10156.37 4388.44} \
              {10438.87 4388.44} {10438.87 5962.84} {10156.37 5962.84} {10156.37 6253.72} \
              {10438.87 6253.72} {10438.87 7828.12} {10156.37 7828.12} {10156.37 8013.56} \
              {587.13 8013.56} {587.13 7828.12} \
              {87.13 7828.12} {87.13 6253.72} {587.13 6253.72} {587.13 5962.84} \
              {87.13 5962.84} {87.13 4388.44} {587.13 4388.44} {587.13 4097.56} \
              {87.13 4097.56} {87.13 2523.16} {587.13 2523.16} {587.13 2232.28} \
              {87.13 2232.28} {87.13 657.88} {587.13 657.88} {587.13 512.44} \
              {5100 512.44} {5100 0} \
            }


puts "BSG-info: Completed script [info script]\n"
