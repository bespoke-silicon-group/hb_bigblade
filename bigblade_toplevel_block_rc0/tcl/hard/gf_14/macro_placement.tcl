
# All macros are placed using bsg_move_object. These variables are a global
# offset for the bsg_move_object function that allows the use to set the
# relative point.
set __bsg_move_object_x_offset [core_llx]
set __bsg_move_object_y_offset [core_lly]

# move_object relative to core llx,lly and make sure we are on grid (can flip too)
proc bsg_move_object { obj x y } {
  move_object $obj -x [expr $x + $::__bsg_move_object_x_offset] -y [expr $y + $::__bsg_move_object_y_offset]
}

# Create placement blockages to mimic BP and CGRA tiles
create_placement_blockage -name BP0   -boundary {{0 0} {282.576 567.360}}
create_placement_blockage -name BP1   -boundary {{0 0} {282.576 567.360}}
create_placement_blockage -name BP2   -boundary {{0 0} {282.576 567.360}}
create_placement_blockage -name BP3   -boundary {{0 0} {282.576 567.360}}
create_placement_blockage -name BP4   -boundary {{0 0} {282.576 567.360}}
create_placement_blockage -name BP5   -boundary {{0 0} {282.576 567.360}}
create_placement_blockage -name BP6   -boundary {{0 0} {282.576 567.360}}
create_placement_blockage -name BP7   -boundary {{0 0} {282.576 567.360}}
create_placement_blockage -name CGRA0 -boundary {{0 0} {500.136 757.440}}
create_placement_blockage -name CGRA1 -boundary {{0 0} {500.136 757.440}}
create_placement_blockage -name CGRA2 -boundary {{0 0} {500.136 757.440}}
create_placement_blockage -name CGRA3 -boundary {{0 0} {500.136 757.440}}
create_placement_blockage -name CGRA4 -boundary {{0 0} {500.136 757.440}}
create_placement_blockage -name CGRA5 -boundary {{0 0} {500.136 757.440}}
create_placement_blockage -name CGRA6 -boundary {{0 0} {500.136 757.440}}
create_placement_blockage -name CGRA7 -boundary {{0 0} {500.136 757.440}}

# ===============================================
# Create ESD and CDMM cells
# ===============================================

remove_objects [get_cells bsg_esd_*]
remove_objects [get_cells bsg_cdmm_*]
for {set j 0} {$j < 5} {incr j} {
  for {set i 0} {$i < 62} {incr i} {
    create_keepout_margin [create_cell bsg_esd_row_${j}_col_${i} IN12LP_GPIO18_13M9S30P/IN12LP_GPIO18_13M9S30P_CORE_ESDCELL] -outer {0.512 0.512 0.512 0.512}
  }

  for {set i 0} {$i < 5} {incr i} {
    create_keepout_margin [create_cell bsg_cdmm_row_${j}_col_${i} */CDMMTYPE2_32422] -outer {0.2 0.2 0.2 0.2}
  }
}

# ===============================================
# place the quad pod rows
# ===============================================

set pod_row_cells [sort_collection -desc [get_cells hbmc_row*] name]

set pod_x        [round_to_nearest 349.44 13.44]     ;# NOTE: THE CLKGEN, BP, CGRA, ESD AND CDMM CELLS ARE RELATIVE TO THIS, CAN USE THIS TO SHIFT THE WHOLE THING
set pod_start_y  [round_to_nearest 328.32  5.76]     ;# NOTE: THE CLKGEN, BP, CGRA, ESD AND CDMM CELLS ARE RELATIVE TO THIS, CAN USE THIS TO SHIFT THE WHOLE THING
set pod_step_y   [round_to_nearest 1929.6  5.76]

set pod_curr_y $pod_start_y
foreach_in_collection c $pod_row_cells {
  bsg_move_object $c $pod_x $pod_curr_y
  set pod_curr_y [expr $pod_curr_y + $pod_step_y]
}

# ===============================================
# place the clock generators
# ===============================================

set clk_gen_cells [sort_collection -desc [get_cells clk_gen*] name]

set clk_gen_x        [expr $pod_x + 4771.20]
set clk_gen_start_y  [expr $pod_start_y + 1883.52]
set clk_gen_step_y   $pod_step_y

set clk_gen_curr_y $clk_gen_start_y
foreach_in_collection c $clk_gen_cells {
  bsg_move_object $c $clk_gen_x $clk_gen_curr_y
  set clk_gen_curr_y [expr $clk_gen_curr_y + $clk_gen_step_y]
}

# ===============================================
# place BP/CGGA "cells"
# ===============================================

set cgra_cells [sort_collection -desc [get_placement_blockages CGRA*] name]
set bp_cells   [sort_collection -desc [get_placement_blockages BP*]   name]

set acc_slot1_offset_y 172.80
set acc_slot2_offset_y 933.12
set acc_start_y        $pod_start_y
set acc_step_y         $pod_step_y

set bp_x               [expr $pod_x + -295.68]
set cgra_x             [expr $pod_x + 9623.04]

set acc_curr_y $acc_start_y
for {set i 0} {$i < 8} {incr i 2} {
  bsg_move_object [index_collection $cgra_cells [expr $i+0]] $cgra_x [expr $acc_curr_y + $acc_slot1_offset_y]
  bsg_move_object [index_collection $cgra_cells [expr $i+1]] $cgra_x [expr $acc_curr_y + $acc_slot2_offset_y]
  bsg_move_object [index_collection $bp_cells   [expr $i+0]] $bp_x   [expr $acc_curr_y + $acc_slot1_offset_y]
  bsg_move_object [index_collection $bp_cells   [expr $i+1]] $bp_x   [expr $acc_curr_y + $acc_slot2_offset_y]
  set acc_curr_y [expr $acc_curr_y + $acc_step_y]
}

# ===============================================
# place the esd cells
# ===============================================

set esd_start_x    [expr $pod_x + 162.3]
set esd_step_x     147.84
set esd_start_y    [expr $pod_start_y - 56.74]
set esd_step_y     $pod_step_y

set esd_curr_y $esd_start_y
for {set j 0} {$j < 5} {incr j} {
  set esd_curr_x $esd_start_x
  for {set i 0} {$i < 62} {incr i} {
    bsg_move_object [get_cell bsg_esd_row_${j}_col_${i}] $esd_curr_x $esd_curr_y
    set esd_curr_x [expr $esd_curr_x + $esd_step_x]
    if {$i == 14 || $i == 15 || $i == 45 || $i == 46} {
      set esd_curr_x [expr $esd_curr_x + 6.72]
    }
    if {$i == 30} {
      set esd_curr_x [expr $esd_curr_x + $esd_x_step + 13.44]
    }
  }
  set esd_curr_y [expr $esd_curr_y + $esd_step_y]
}

# ===============================================
# place the cdmm cells
# ===============================================

set cdmm_start_x   $pod_x
set cdmm_start_y   [expr $pod_start_y - 30.94]
set cdmm_step_y    $pod_step_y

set cdmm_curr_y $cdmm_start_y
for {set j 0} {$j < 5} {incr j} {
  bsg_move_object [get_cell bsg_cdmm_row_${j}_col_0] [expr $cdmm_start_x + 62.05]    $cdmm_curr_y
  bsg_move_object [get_cell bsg_cdmm_row_${j}_col_1] [expr $cdmm_start_x + 2342.84]  $cdmm_curr_y
  bsg_move_object [get_cell bsg_cdmm_row_${j}_col_2] [expr $cdmm_start_x + 4805.66]  $cdmm_curr_y
  bsg_move_object [get_cell bsg_cdmm_row_${j}_col_3] [expr $cdmm_start_x + 7255.16]  $cdmm_curr_y
  bsg_move_object [get_cell bsg_cdmm_row_${j}_col_4] [expr $cdmm_start_x + 9549.27]  $cdmm_curr_y
  set cdmm_curr_y [expr $cdmm_curr_y + $cdmm_step_y]
}

set_fixed_object [get_cells -hier -filter is_hard_macro]

