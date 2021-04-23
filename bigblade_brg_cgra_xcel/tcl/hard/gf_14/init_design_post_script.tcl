
# These constraints are dropped between DC and ICC2
# set_dont_touch
# inputs
set_dont_touch_network -no_propagate [get_ports io_*_link_data_i[*]]
set_dont_touch_network -no_propagate [get_ports io_*_link_v_i]
# outputs
set_dont_touch_network -no_propagate [get_flat_pins -filter "full_name=~*BSG_OSDR_BUF_DONT_TOUCH/Z"]
set_dont_touch_network -no_propagate [get_flat_pins -filter "full_name=~*BSG_OSDR_CKBUF_DONT_TOUCH/Z"]

