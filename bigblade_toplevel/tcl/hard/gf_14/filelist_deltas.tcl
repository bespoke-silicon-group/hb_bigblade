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
set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)

set HARD_INCLUDE_PATHS [join "
  $basejump_stl_dir/hard/gf_14/bsg_mem/
"]

# bsg_manycore_tile
set HARD_SWAP_FILELIST [join "
  $bsg_designs_target_dir/v/hard/gf_14/bsg_mem_1r1w_sync.v
  $bsg_designs_target_dir/v/hard/gf_14/bsg_mem_1rw_sync_mask_write_bit.v
  $bsg_designs_target_dir/v/hard/gf_14/bsg_mem_1rw_sync_mask_write_byte.v
  $bsg_designs_target_dir/v/hard/gf_14/bsg_mem_1rw_sync.v
  $bsg_designs_target_dir/v/hard/gf_14/bsg_mem_2rw_sync.v
  $bsg_designs_target_dir/v/hard/gf_14/bsg_mem_3rw_sync.v

  $basejump_stl_dir/hard/gf_14/bsg_misc/bsg_mux.v
  $basejump_stl_dir/hard/gf_14/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_async/bsg_launch_sync_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_clk_gen_osc.v

  $bsg_designs_target_dir/../common/v/hard/gf_14/bsg_link_delay_line.v
  $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_osdr_phy.v
  $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_isdr_phy.v
"]

set NETLIST_SOURCE_FILES [join "
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]
