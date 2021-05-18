
proc get_propagated_nets {port cell} {

  set start_net  [get_nets  -of_object $port     ]
  set start_cell [get_cells -of_object $start_net]

  set result [list]
  append_to_collection result $start_net

  set curr_net_name  [get_attribute $start_net  name]
  set curr_cell_name [get_attribute $start_cell name]
  set end_cell_name  [get_attribute $cell       name]

  while {$curr_cell_name != $end_cell_name} {
    set curr_cell [get_cells $curr_cell_name]
    set next_net  [get_nets -of_object $curr_cell -filter "(full_name!=$curr_net_name)&&(full_name!=VSS)&&(full_name!=VDD)"]
    set next_cell [get_cells -of_object $next_net -filter "(full_name!=$curr_cell_name)"]
    set curr_net_name  [get_attribute $next_net  name]
    set curr_cell_name [get_attribute $next_cell name]
    append_to_collection result $next_net
  }

  return $result
}

set ss_nets [list]

foreach {side} {"DL" "DR" "IT"} {
  set limit [expr {$side == "IT"} ? 2 : 8]
  for {set i 0} {$i < $limit} {incr i} {
    foreach {dir} {"i" "o"} {
      set num  [expr {$side == "DL"} ? {$i/2} : {$i/2+4}]
      set cell "mem_link_${num}__link"
      if {$side == "IT"} {set cell "io_link"}
      append_to_collection ss_nets [get_propagated_nets [get_ports "pad_${side}${i}_v_${dir}_int"] [get_cells $cell]]
      for {set j 0} {$j < 16} {incr j} {
        append_to_collection ss_nets [get_propagated_nets [get_ports "pad_${side}${i}_${j}_${dir}_int"] [get_cells $cell]]
      }
    }
  }
}

create_routing_rule ss_ndr   \
  -cuts {                    \
    {V2 {Vx 2}}              \
    {J3 {Jy 2}}              \
    {A4 {Ax 2}}              \
    {CK {CK 2}}              \
    {U1 {Ux 2}}              \
    {U2 {Ux 2}}              \
    {U3 {Ux 2}}              \
    {KH {KH 1}}              \
  }

set_routing_rule -rule ss_ndr -min_routing_layer M2 -max_routing_layer K4 $ss_nets
