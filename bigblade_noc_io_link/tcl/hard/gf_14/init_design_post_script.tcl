# Source common scripts
source -echo -verbose $::env(BASEJUMP_STL_DIR)/hard/gf_14/bsg_link/tcl/bsg_link_ddr.constraints.tcl

proc bsg_dont_touch_regexp {arg1} {
    set pattern "full_name=~$arg1";
    set mycells [get_cells -hier -filter $pattern]
    puts [concat "BSG: set dont_touch'ing " $pattern "=" [collection_to_list $mycells]]
    set_dont_touch $mycells
}

proc bsg_dont_touch_regexp_type {arg1} {
    set pattern "ref_name=~$arg1";
    set mycells [get_cells -hier -filter $pattern]
    puts [concat "BSG: set dont_touch'ing " $pattern "=" [collection_to_list $mycells]]
    set_dont_touch $mycells
}


#bsg_dont_touch_regexp */adt_DONT_TOUCH/*
#bsg_dont_touch_regexp */cdt_DONT_TOUCH/*
#bsg_dont_touch_regexp */fdt_DONT_TOUCH/*
#bsg_dont_touch_regexp *BSG_BAL41MUX*

bsg_dont_touch_regexp_type *SYNC*SDFF*

# set dont touch on all delay lines
set_dont_touch_network [get_pins "ddr_link*link/io_link_clk_o*"]
set_dont_touch_network [get_pins "ddr_link*link/io_link_v_o*"]
set_dont_touch_network [get_pins "ddr_link*link/io_link_data_o*"]
set_dont_touch_network [get_ports "io_link_clk_i*"]
set_dont_touch_network [get_ports "io_link_v_i*"]
set_dont_touch_network [get_ports "io_link_data_i*"]
