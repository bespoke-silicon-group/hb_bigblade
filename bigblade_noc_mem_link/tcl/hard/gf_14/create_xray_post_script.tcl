
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl


remove_clocks [get_clocks {ext_io_clk ext_noc_clk}]

set io_clk_period_ps              800.0 ;# 1.25 GHz
set io_clk_uncertainty_ps         20
for {set i 0} {$i < 2} {incr i} {
  set io_clk_name   "io_link_${i}_io_clk"
  create_clock -period $io_clk_period_ps -name $io_clk_name [get_pins "ddr_link*${i}*link/clk_gen_io/clk_gen_inst/mux_inst/*/Z"]
  set_clock_uncertainty $io_clk_uncertainty_ps  [get_clocks $io_clk_name]
  set_propagated_clock [get_clocks $io_clk_name]
}

bsg_chip_derate_cells
bsg_chip_derate_mems

foreach_in_collection cell [get_cells -quiet -hier -filter "(ref_name=~gf14_*)&&(full_name=~*downstream*harden*fifo*)"] {
  set_disable_timing $cell -from CLKA -to CLKB
  set_disable_timing $cell -from CLKB -to CLKA
}
