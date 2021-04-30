puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_TARGET_TCL_HARD_DIR)/fp_common.tcl

# ==============================================================================
# Surround the block with DECAP
# ==============================================================================

create_boundary_cells \
  -left_boundary_cell               $decap_boundary_cell \
  -right_boundary_cell              $decap_boundary_cell \
  -top_boundary_cells               [list $decap_boundary_cell $filler_x3_cell $filler_x2_cell] \
  -bottom_boundary_cells            [list $decap_boundary_cell $filler_x3_cell $filler_x2_cell] \
  -top_right_outside_corner_cell    $decap_boundary_cell \
  -top_left_outside_corner_cell     $decap_boundary_cell \
  -bottom_right_outside_corner_cell $decap_boundary_cell \
  -bottom_left_outside_corner_cell  $decap_boundary_cell \
  -no_1x

# ==============================================================================
# ADT RP Groups
# ==============================================================================

create_rp_group  -name  adt_inv_group_1       -row  1  -col  3
create_rp_group  -name  adt_inv_group_2       -row  1  -col  3
create_rp_group  -name  adt_inv_group_3       -row  1  -col  3
create_rp_group  -name  adt_inv_group_4       -row  1  -col  3
create_rp_group  -name  adt_right_group       -row  3  -col  4
create_rp_group  -name  adt_left_group_row_0  -row  1  -col  5
create_rp_group  -name  adt_left_group_row_1  -row  1  -col  3
create_rp_group  -name  adt_left_group        -row  3  -col  1
create_rp_group  -name  adt                   -row  1  -col  2

add_to_rp_group  adt_inv_group_1       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I12           -row  0  -col  0
add_to_rp_group  adt_inv_group_1       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I11           -row  0  -col  1

add_to_rp_group  adt_inv_group_2       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I22           -row  0  -col  0
add_to_rp_group  adt_inv_group_2       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I21           -row  0  -col  1

add_to_rp_group  adt_inv_group_3       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I32           -row  0  -col  0
add_to_rp_group  adt_inv_group_3       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I31           -row  0  -col  1

add_to_rp_group  adt_inv_group_4       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/ZB            -row  0  -col  0
add_to_rp_group  adt_inv_group_4       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I42           -row  0  -col  1
add_to_rp_group  adt_inv_group_4       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I41           -row  0  -col  2

add_to_rp_group  adt_right_group       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I42b          -row  0  -col  0
add_to_rp_group  adt_right_group       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I32b          -row  0  -col  1
add_to_rp_group  adt_right_group       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I22b          -row  0  -col  2
add_to_rp_group  adt_right_group       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I12b          -row  0  -col  3
add_to_rp_group  adt_right_group       -rp_group  adt_inv_group_4                                            -row  1  -col  0
add_to_rp_group  adt_right_group       -rp_group  adt_inv_group_3                                            -row  1  -col  1
add_to_rp_group  adt_right_group       -rp_group  adt_inv_group_2                                            -row  1  -col  2
add_to_rp_group  adt_right_group       -rp_group  adt_inv_group_1                                            -row  1  -col  3
add_to_rp_group  adt_right_group       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I42a          -row  2  -col  0
add_to_rp_group  adt_right_group       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I32a          -row  2  -col  1
add_to_rp_group  adt_right_group       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I22a          -row  2  -col  2
add_to_rp_group  adt_right_group       -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/I12a          -row  2  -col  3

add_to_rp_group  adt_left_group_row_0  -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/we_o_buf      -row  0  -col  0
add_to_rp_group  adt_left_group_row_0  -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/we_o_pre      -row  0  -col  1
add_to_rp_group  adt_left_group_row_0  -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/bsg_we_nand   -row  0  -col  2
add_to_rp_group  adt_left_group_row_0  -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/bsg_SYNC_2_r  -row  0  -col  3
add_to_rp_group  adt_left_group_row_0  -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/bsg_SYNC_1_r  -row  0  -col  4

add_to_rp_group  adt_left_group_row_1  -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/MX1           -row  0  -col  0
add_to_rp_group  adt_left_group_row_1  -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/NB            -row  0  -col  1
add_to_rp_group  adt_left_group_row_1  -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/sel_r_reg_0   -row  0  -col  2

add_to_rp_group  adt_left_group        -rp_group  adt_left_group_row_1                                       -row  0  -col  0
add_to_rp_group  adt_left_group        -cells     clk_gen_inst/clk_gen_osc_inst/adt_BSG_DONT_TOUCH/M1            -row  1  -col  0
add_to_rp_group  adt_left_group        -rp_group  adt_left_group_row_0                                       -row  2  -col  0

add_to_rp_group  adt                   -rp_group  adt_left_group                                             -row  0  -col  0
add_to_rp_group  adt                   -rp_group  adt_right_group                                            -row  0  -col  1

# ==============================================================================
# CDT RP Groups
# ==============================================================================

create_rp_group -name cdt_inv_row -rows 1 -columns 11
add_to_rp_group cdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/I1 -row 0 -column 0
add_to_rp_group cdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/I2 -row 0 -column 1
add_to_rp_group cdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/I2a -row 0 -column 2
add_to_rp_group cdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/I3 -row 0 -column 3
add_to_rp_group cdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/I4 -row 0 -column 4
add_to_rp_group cdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/I4a -row 0 -column 5
add_to_rp_group cdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/I5 -row 0 -column 6
add_to_rp_group cdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/I6 -row 0 -column 7
add_to_rp_group cdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/I6a -row 0 -column 8
add_to_rp_group cdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/I7 -row 0 -column 9
add_to_rp_group cdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/I8 -row 0 -column 10

create_rp_group -name cdt_buf_mux_row -rows 1 -columns 2
add_to_rp_group cdt_buf_mux_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/we_o_buf -row 0 -column 0
add_to_rp_group cdt_buf_mux_row -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/M1 -row 0 -column 1

create_rp_group -name cdt_sel_mux_reg -rows 2 -columns 2
add_to_rp_group cdt_sel_mux_reg -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/MX2 -row 0 -column 0
add_to_rp_group cdt_sel_mux_reg -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/sel_r_reg_1 -row 0 -column 1
add_to_rp_group cdt_sel_mux_reg -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/MX1 -row 1 -column 0
add_to_rp_group cdt_sel_mux_reg -cells clk_gen_inst/clk_gen_osc_inst/cdt_BSG_DONT_TOUCH/sel_r_reg_0 -row 1 -column 1

create_rp_group -name cdt -rows 3 -columns 1
add_to_rp_group cdt -rp_group cdt_inv_row -row 0 -column 0
add_to_rp_group cdt -rp_group cdt_buf_mux_row -row 1 -column 0
add_to_rp_group cdt -rp_group cdt_sel_mux_reg -row 2 -column 0

# ==============================================================================
# FDT RP Groups
# ==============================================================================

create_rp_group -name fdt_inv_row -rows 1 -columns 11
add_to_rp_group fdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/I0 -row 0 -column 0
add_to_rp_group fdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/I1 -row 0 -column 1
add_to_rp_group fdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/I2 -row 0 -column 2
add_to_rp_group fdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/I2_1 -row 0 -column 3
add_to_rp_group fdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/I3 -row 0 -column 4
add_to_rp_group fdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/I3_1 -row 0 -column 5
add_to_rp_group fdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/I3_2 -row 0 -column 6
add_to_rp_group fdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/I4 -row 0 -column 7
add_to_rp_group fdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/I4_1 -row 0 -column 8
add_to_rp_group fdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/I4_2 -row 0 -column 9
add_to_rp_group fdt_inv_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/I4_3 -row 0 -column 10

create_rp_group -name fdt_buf_mux_row -rows 1 -columns 2
add_to_rp_group fdt_buf_mux_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/M2 -row 0 -column 0
add_to_rp_group fdt_buf_mux_row -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/ICLK -row 0 -column 1


create_rp_group -name fdt_sel_mux_reg -rows 2 -columns 2
add_to_rp_group fdt_sel_mux_reg -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/X1 -row 0 -column 0
add_to_rp_group fdt_sel_mux_reg -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/DFFR1 -row 0 -column 1
add_to_rp_group fdt_sel_mux_reg -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/MX2 -row 1 -column 0
add_to_rp_group fdt_sel_mux_reg -cells clk_gen_inst/clk_gen_osc_inst/fdt_BSG_DONT_TOUCH/DFFR2 -row 1 -column 1

create_rp_group -name fdt -rows 3 -columns 1
add_to_rp_group fdt -rp_group fdt_inv_row -row 0 -column 0
add_to_rp_group fdt -rp_group fdt_buf_mux_row -row 1 -column 0
add_to_rp_group fdt -rp_group fdt_sel_mux_reg -row 2 -column 0

# ==============================================================================
# ADT/CDT/FDT Combo RP Groups
# ==============================================================================

create_rp_group -name cdt_fdt -rows 1 -column 2
add_to_rp_group cdt_fdt -rp_group cdt -row 0 -column 0
add_to_rp_group cdt_fdt -rp_group fdt -row 0 -column 1

create_rp_group -name cdt_fdt_over_adt -rows 2 -column 1
add_to_rp_group cdt_fdt_over_adt -rp_group adt     -row 0 -column 0
add_to_rp_group cdt_fdt_over_adt -rp_group cdt_fdt -row 1 -column 0

# ==============================================================================
# Create Bounds
# ==============================================================================

# Note: The placement bounds are all relative to 0,0. To move all the bounds as
# a group, we add all the bounds to the my_bounds list and then use the
# move_objects command on the list to move them all to some specified offset.

set my_bounds [list]

append_to_collection my_bounds [create_bound -name adt_cdt_fdt_bounds -type hard -boundary {{2.7720 4.3200} {2.7720 7.6800} {12.6840 7.6800} {12.6840 4.3200}}]
add_to_bound adt_cdt_fdt_bounds [get_flat_cells "*adt* *cdt* *fdt*"]

append_to_collection my_bounds [create_bound -name btc_async_reset_bounds -type hard -boundary {{0.0000 0.0000} {0.0000 1.9200} {2.7720 1.9200} {2.7720 0.0000}}]
add_to_bound btc_async_reset_bounds [get_flat_cells "*btc_async_reset*"]
add_to_bound btc_async_reset_bounds [get_cells "clk_gen_inst/clk_gen_osc_inst/*" -filter "!is_hierarchical"]

append_to_collection my_bounds [create_bound -name btc_clk_select_bounds -type hard -boundary {{8.8200 0.0000} {8.8200 1.4400} {12.6840 1.4400} {12.6840 0.0000}}]
add_to_bound btc_clk_select_bounds [get_flat_cells "*btc_clk_select*"]

append_to_collection my_bounds [create_bound -name clk_gen_ds_bounds -type hard -boundary {{12.6840 0.9600} {12.6840 7.6800} {17.7240 7.6800} {17.7240 0.9600}}]
add_to_bound clk_gen_ds_bounds [get_flat_cells "*clk_gen_ds_inst*"]

append_to_collection my_bounds [create_bound -name clk_gen_btc_bounds -type hard -boundary {{0.0000 3.3600} {0.0000 7.6800} {2.7720 7.6800} {2.7720 3.3600}}]
add_to_bound clk_gen_btc_bounds [get_flat_cells "clk_gen_inst/clk_gen_osc_inst/btc/*"]

append_to_collection my_bounds [create_bound -name clk_gen_btc_trigger_bounds -type hard -boundary {{0.0000 1.9200} {0.0000 3.3600} {2.7720 3.3600} {2.7720 1.9200}}]
add_to_bound clk_gen_btc_trigger_bounds [get_flat_cells "clk_gen_inst/clk_gen_osc_inst/btc_trigger/*"]

append_to_collection my_bounds [create_bound -name clk_gen_btc_ds_bounds -type hard -boundary {{8.8200 1.4400} {8.8200 0.0000} {2.7720 0.0000} {2.7720 4.3200} {12.6840 4.3200} {12.6840 1.4400}}]
add_to_bound clk_gen_btc_ds_bounds [get_flat_cells "clk_gen_inst/btc_ds/*"]

append_to_collection my_bounds [create_bound -name mux_out_bound -type hard -boundary {{12.6710 0.0000} {12.6710 0.9600} {17.7110 0.9600} {17.7110 0.0000}}]
add_to_bound mux_out_bound [get_flat_cells "clk_gen_inst/mux_inst/fi_rof_0__BSG_BAL41MUX_BSG_DONT_TOUCH"]
add_to_bound mux_out_bound [get_cells "*" -filter "!is_hierarchical && !is_physical_only"]

move_objects -delta "$bounds_offset_x $bounds_offset_y" $my_bounds

puts "BSG-info: Completed script [info script]\n"
