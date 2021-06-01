
# Run this to remove the new PG shapes
if { 0 } {
  remove_objects [get_shapes -filter "tag==bsg_pg_patch"]
  remove_objects [get_vias   -filter "tag==bsg_pg_patch"]
}

# PG vias for the patch strapes (same as the normal PG)
set_pg_via_master_rule V1_pg_stack_via_rule -contact_code V1_HH_0_15_0_25_Vx       -via_array_dimension {4 1}                            -offset_start center -orient R0  ;# M1 / M2
set_pg_via_master_rule V2_pg_stack_via_rule -contact_code V2BAR_H_0_20_0_20_VxBAR  -via_array_dimension {2 1}                            -offset_start center -orient R0  ;# M2 / M3
set_pg_via_master_rule J3_pg_stack_via_rule -contact_code J3BAR_H_0_25_4_25_JyBAR  -via_array_dimension {2 1}                            -offset_start center -orient R0  ;# M3 / C4
set_pg_via_master_rule A4_pg_stack_via_rule -contact_code A4BAR_H_0_20_20_0_AxBAR  -via_array_dimension {4 1}                            -offset_start center -orient R0  ;# C4 / C5
set_pg_via_master_rule CK_pg_stack_via_rule -contact_code CK_VH_28_23_0_26_CK      -via_array_dimension {4 4} -cut_spacing {0.092 0.064} -offset_start center -orient R0  ;# C5 / K1
set_pg_via_master_rule U1_pg_stack_via_rule -contact_code U1_HV_0_26_26_0_Ux       -via_array_dimension {4 4} -cut_spacing {0.092 0.064} -offset_start center -orient R0  ;# K1 / K2
set_pg_via_master_rule U2_pg_stack_via_rule -contact_code U2_VH_26_0_0_26_Ux       -via_array_dimension {4 4} -cut_spacing {0.092 0.064} -offset_start center -orient R0  ;# K2 / K3
set_pg_via_master_rule U3_pg_stack_via_rule -contact_code U3_HV_0_26_26_0_Ux       -via_array_dimension {4 4} -cut_spacing {0.092 0.064} -offset_start center -orient R0  ;# K3 / K4
set_pg_via_master_rule KH_pg_stack_via_rule -contact_code KH_VH_45_18_0_45_KH      -via_array_dimension {2 2} -cut_spacing {0.180 0.180} -offset_start center -orient R0  ;# K4 / H1

set c5_starting_x 146.40   ;# the offset for the center of the first patch strap
set c5_pitch_x    147.84   ;# the distance between patch straps in the x direction

set c5_low_end    104.56
set c5_high_end   111.44
set c5_pitch_y    190.08

# We only need this for the 15 channels between blocks, we have a VDD and VSS power strap on the right side of the file vcache block.
for {set i 0} {$i < 15} {incr i} {
  for {set j 0} {$j < 2} {incr j} {

    set strap_loc_x    [expr $c5_starting_x + ($i * $c5_pitch_x)]
    set strap_low_end  [expr $c5_low_end    + ($j * $c5_pitch_y)]
    set strap_high_end [expr $c5_high_end   + ($j * $c5_pitch_y)]

    create_pg_strap -tag bsg_pg_patch -direction vertical -net VDD -layer C5 -width 0.700 -low_end $strap_low_end -high_end $strap_high_end -start $strap_loc_x -via_rule {
      {
        {existing: std_conn}
        {via_master: {A4_pg_stack_via_rule J3_pg_stack_via_rule V2_pg_stack_via_rule V1_pg_stack_via_rule}}
      }{
        {{existing: strap} {layers: H1}}
        {via_master: {CK_pg_stack_via_rule U1_pg_stack_via_rule U2_pg_stack_via_rule U3_pg_stack_via_rule KH_pg_stack_via_rule}}
      }{
        {intersection: undefined}
        {via_master: nil}
      }
    }
  }
}

