# get_track_overlap_shapes
proc get_track_overlap_shapes {y layer {xmin {}} {xmax {}}} {

  set buffer_v $::__bsg_pins_default_core_buffer(${layer}_v)

  # core dimension
  set core_llx [get_attribute [get_core_area] bounding_box.ll_x]
  set core_urx [get_attribute [get_core_area] bounding_box.ur_x]

  set llx 0
  set urx 0
  if {$xmin == {}} {
    set llx $core_llx
  } else {
    set llx $xmin
  }

  if {$xmax == {}} {
    set urx $core_urx
  } else {
    set urx $xmax
  }
  
  set search_bbox [bsg_expand_bbox "{$llx $y} {$urx $y}" 0.14 $buffer_v]
  set overlap_shapes [get_shapes -quiet -hier -intersect $search_bbox -filter "layer.name==$layer && net_type!=signal"]
  set overlap_shapes [sort_collection $overlap_shapes bounding_box.ll_x]
  return $overlap_shapes
}



# is_track_clear
proc is_track_clear {y layer} {
  set overlap_shapes [get_track_overlap_shapes $y $layer]
  return [expr [sizeof_collection $overlap_shapes] == 0 ? true : false]
}


# draw horizontal wire
proc draw_horizontal_wire {net layer xmin xmax y} {

  # check if straight line can be drawn on this track
  if {[is_track_clear $y $layer]} {
    set paths [list [list $xmin $y] [list $xmax $y]]
    set curr_shape [create_shape -shape_type path -layer $layer -net $net -path $paths -width 0.064]
    set_attribute -object $curr_shape -name physical_status -value locked 
  } else {
    
    set y_offset 0
    if { [is_track_clear [expr $y+0.128] $layer] } {
      set y_offset 0.128
    } elseif { [is_track_clear [expr $y-0.128] $layer] } {
      set y_offset -0.128
    } else {
      puts "BSG-Error: both track above and below not clear."
      return
    }

    # build paths
    set paths [list]
    set overlap_shapes [get_track_overlap_shapes $y $layer $xmin $xmax]

    set first_shape [index_collection $overlap_shapes 0]
    set first_shape_llx [get_attribute $first_shape bounding_box.ll_x]
    if {$first_shape_llx  > $xmin} {
      set px $xmin
      set py $y
      lappend paths [list $px $py]
    }

    foreach_in_collection overlap_shape $overlap_shapes {
      set shape_llx [get_attribute $overlap_shape bounding_box.ll_x]
      set shape_urx [get_attribute $overlap_shape bounding_box.ur_x]
      if {$shape_llx < $xmin && $shape_urx > $xmin} {
        set px [expr $shape_urx + 0.14]
        set py $y 
        lappend paths [list $px $py]
      } elseif {$shape_llx > $xmin && $shape_urx < $xmax} {
        set px [expr $shape_llx - 0.14]
        set py [expr $y]
        lappend paths [list $px $py]

        set px [expr $shape_llx - 0.14]
        set py [expr $y + $y_offset]
        lappend paths [list $px $py]

        set px [expr $shape_urx + 0.14]
        set py [expr $y + $y_offset]
        lappend paths [list $px $py]

        set px [expr $shape_urx + 0.14]
        set py [expr $y]
        lappend paths [list $px $py]
      } elseif {$shape_llx < $xmax && $shape_urx > $xmax} {
        set px [expr $shape_llx - 0.14]
        set py $y 
        lappend paths [list $px $py]
      }
    }

    set last_shape [index_collection $overlap_shapes  end]
    set last_shape_urx [get_attribute $last_shape bounding_box.ur_x]
    if {$last_shape_urx < $xmax} {
      set px $xmax
      set py $y
      lappend paths [list $px $py]
    }

    set curr_shape [create_shape -shape_type path -layer $layer -net $net -path $paths -width 0.064]

    set_attribute -object $curr_shape -name physical_status -value locked

  }
}
