# Source common scripts
source -echo -verbose $::env(BASEJUMP_STL_DIR)/hard/gf_14/bsg_link/tcl/bsg_link_sdr.constraints.tcl

bsg_link_sdr_dont_touch_constraints [get_ports {io_*_link_data_i[*] io_*_link_v_i}]
