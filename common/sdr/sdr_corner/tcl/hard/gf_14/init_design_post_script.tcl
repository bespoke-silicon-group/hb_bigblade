# Source common scripts
source -echo -verbose $::env(BASEJUMP_STL_DIR)/hard/gf_14/bsg_link/tcl/bsg_link_sdr.constraints.tcl

# set dont touch
bsg_link_sdr_dont_touch_constraints [get_ports { \
    io_fwd_link_data_i[*]   io_fwd_link_v_i      \
    io_rev_link_data_i[*]   io_rev_link_v_i      \
    io_wh_link_data_i[*][*] io_wh_link_v_i[*]    \
}]

set_dont_touch [get_cells -hier -filter "name=~*hard_inv*"] true
