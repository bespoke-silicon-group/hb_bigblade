foreach_in_collection bound [get_bounds *] {
  puts "create_bound -name [get_object_name $bound] -type [get_attribute $bound type] -boundary {[get_attribute [get_bound_shapes -of_object $bound] boundary]}"
}
