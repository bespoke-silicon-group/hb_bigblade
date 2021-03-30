set clk_gen_bound [create_bound -name "clk_gen" -type soft -boundary {{0 83.00} {13 96.00}}]
add_to_bound ${clk_gen_bound} [get_cells -hier -filter "full_name=~clk_gen/*"]