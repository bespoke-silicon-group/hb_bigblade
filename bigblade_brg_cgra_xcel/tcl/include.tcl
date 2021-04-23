
set basejump_stl_dir        $::env(BASEJUMP_STL_DIR)
set bsg_designs_target_dir  $::env(BSG_DESIGNS_TARGET_DIR)

set hardfloat_dir     $bsg_designs_target_dir/HardFloat
set bigblade_dir      $bsg_designs_target_dir/..

set SVERILOG_INCLUDE_PATHS [join "
  $basejump_stl_dir/bsg_clk_gen
  $basejump_stl_dir/bsg_dataflow
  $basejump_stl_dir/bsg_mem
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_test
  $basejump_stl_dir/bsg_noc
  $basejump_stl_dir/bsg_tag
  $hardfloat_dir/source
  $hardfloat_dir/source/RISCV
"]
