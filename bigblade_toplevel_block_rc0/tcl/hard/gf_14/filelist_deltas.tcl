### filelist_deltas.tcl

#-------------------------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module and macro
# definitions may be needed by the subsequent files
#-------------------------------------------------------------------------------

set bsg_designs_target_dir  $::env(BSG_DESIGNS_TARGET_DIR)
set bsg_packaging_dir       $::env(BSG_PACKAGING_DIR)
set bsg_package             $::env(BSG_PACKAGE)
set bsg_pinout              $::env(BSG_PINOUT)
set bsg_padmapping          $::env(BSG_PADMAPPING)
set bsg_packaging_foundry   $::env(BSG_PACKAGING_FOUNDRY)

set HARD_SWAP_FILELIST [join "
  $basejump_stl_dir/hard/gf_14/bsg_misc/bsg_mux.v
  $basejump_stl_dir/hard/gf_14/bsg_misc/bsg_tielo.v
  $basejump_stl_dir/hard/gf_14/bsg_misc/bsg_tiehi.v
"]

set NETLIST_SOURCE_FILES [join "
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

set HARD_INCLUDE_PATHS [join "
  $bsg_packaging_dir/common/verilog
  $bsg_packaging_dir/common/foundry/$bsg_packaging_foundry/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/$bsg_packaging_foundry/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/$bsg_packaging_foundry/verilog/padmappings/$bsg_padmapping
"]
