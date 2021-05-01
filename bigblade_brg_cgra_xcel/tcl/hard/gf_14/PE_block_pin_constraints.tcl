#=========================================================================
# floorplan.tcl
#=========================================================================
# This script is called from the Innovus init flow step. The constraitns
# below places cfg_out on the north edge, cfg_in on the south,
# val/rdy0 + msg[32:0] on the south, val/rdy1 + msg[65:33] on the north,
# val/rdy2 + msg[98:66] on the west, and val/rdy3 + msg[131:99] on the
# east. Applying constraints in this script effectively rotates the
# logical PE block by 90 degrees clockwise.
#
# Author : Yanghui Ou, Peitian Pan
# Date   : May 1, 2021

set pe_width  50.00
set pe_height 85.00

floorPlan -d $pe_width $pe_height \
             $core_margin_l $core_margin_b $core_margin_r $core_margin_t

setFlipping s

# Use automatic floorplan synthesis to pack macros (e.g., SRAMs) together

planDesign

setPinAssignMode -pinEditInBatch true

#-------------------------------------------------------------------------
# MISC pins
#-------------------------------------------------------------------------

set misc_pins [list]
foreach this_port [get_object_name [get_ports clk]] {
  lappend misc_pins $this_port
}

foreach this_port [get_object_name [get_ports reset]] {
  lappend misc_pins $this_port
}

foreach this_port [get_object_name [get_ports is_calc]] {
  lappend misc_pins $this_port
}

foreach this_port [get_object_name [get_ports is_occupied]] {
  lappend misc_pins $this_port
}

foreach this_port [get_object_name [get_ports x_cord*]] {
  lappend misc_pins $this_port
}

foreach this_port [get_object_name [get_ports y_cord*]] {
  lappend misc_pins $this_port
}

set num_misc_pins [expr [llength $misc_pins]]
set misc_spacing  [expr 4*0.16]
set start_y [expr $pe_height/2 - $misc_spacing*$num_misc_pins/2]
foreach this_port $misc_pins {
  editPin -pin $this_port -layer C4 -snap TRACK -assign 0 $start_y
  set start_y [expr $start_y+$misc_spacing]
}

#-------------------------------------------------------------------------
# Cfg pins
#-------------------------------------------------------------------------

lappend pins_cfg_in cfg_in__val[0]
for {set i 0} {$i < 38} {incr i} {
  lappend pins_cfg_in cfg_in__msg[$i]
}

lappend pins_cfg_out cfg_out__val[0]
for {set i 0} {$i < 38} {incr i} {
  lappend pins_cfg_out cfg_out__msg[$i]
}

set cfg_spacing [expr 4*0.16]
set start_x [expr $pe_width/2 - 39/2*$cfg_spacing]

for {set i 0} {$i < [expr [llength $pins_cfg_out]]} {incr i} {
  editPin -pin [lindex $pins_cfg_out $i] -layer C5 -snap TRACK -assign [expr $start_x+$i*$cfg_spacing] $pe_height
}
for {set i 0} {$i < [expr [llength $pins_cfg_in]]} {incr i} {
  editPin -pin [lindex $pins_cfg_in $i] -layer C5 -snap TRACK -assign [expr $start_x+$i*$cfg_spacing] 0
}


#-------------------------------------------------------------------------
# Msg  pins
#-------------------------------------------------------------------------

set spacing [expr 0.128*4]
set start_x [expr $pe_width/2  - 35*$spacing]
set start_y [expr $pe_height/2 - 35*$spacing]

lappend pins_south in___val[0] in___rdy[0]
for {set i 0} {$i < 33} {incr i} {
  set idx [expr $i + 33*0]
  lappend pins_south in___msg[$idx]
}

lappend pins_south out__val[0] out__rdy[0]
for {set i 0} {$i < 33} {incr i} {
  set idx [expr $i + 33*0]
  lappend pins_south out__msg[$idx]
}

lappend pins_north out__val[1] out__rdy[1]
for {set i 0} {$i < 33} {incr i} {
  set idx [expr $i + 33*1]
  lappend pins_north out__msg[$idx]
}

lappend pins_north in___val[1] in___rdy[1]
for {set i 0} {$i < 33} {incr i} {
  set idx [expr $i + 33*1]
  lappend pins_north in___msg[$idx]
}

lappend pins_west in___val[2] in___rdy[2]
for {set i 0} {$i < 33} {incr i} {
  set idx [expr $i + 33*2]
  lappend pins_west in___msg[$idx]
}

lappend pins_west out__val[2] out__rdy[2]
for {set i 0} {$i < 33} {incr i} {
  set idx [expr $i + 33*2]
  lappend pins_west out__msg[$idx]
}

lappend pins_east out__val[3] out__rdy[3]
for {set i 0} {$i < 33} {incr i} {
  set idx [expr $i + 33*3]
  lappend pins_east out__msg[$idx]
}

lappend pins_east in___val[3] in___rdy[3]
for {set i 0} {$i < 33} {incr i} {
  set idx [expr $i + 33*3]
  lappend pins_east in___msg[$idx]
}

for {set i 0} {$i < [expr [llength $pins_north]]} {incr i} {
  editPin -pin [lindex $pins_north $i] -layer K2 -snap TRACK -assign [expr $start_x + $i*$spacing] $pe_height
}

for {set i 0} {$i < [expr [llength $pins_south]]} {incr i} {
  editPin -pin [lindex $pins_south $i] -layer K1 -snap TRACK -assign [expr $start_x + $i*$spacing] 0
}

for {set i 0} {$i < [expr [llength $pins_west]]} {incr i} {
  editPin -pin [lindex $pins_west $i] -layer K1 -snap TRACK -assign 0 [expr $start_y + $i*$spacing]
}

for {set i 0} {$i < [expr [llength $pins_east]]} {incr i} {
  editPin -pin [lindex $pins_east $i] -layer K2 -snap TRACK -assign $pe_width [expr $start_y + $i*$spacing]
}


setPinAssignMode -pinEditInBatch false
