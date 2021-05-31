
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl


remove_clocks [get_clocks {ext_io_clk ext_noc_clk}]

bsg_chip_derate_cells
bsg_chip_derate_mems

foreach_in_collection cell [get_cells -quiet -hier -filter "(ref_name=~gf14_*)&&(full_name=~*downstream*harden*fifo*)"] {
  set_disable_timing $cell -from CLKA -to CLKB
  set_disable_timing $cell -from CLKB -to CLKA
}
