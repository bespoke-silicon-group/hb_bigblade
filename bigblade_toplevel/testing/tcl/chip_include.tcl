
set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set bsg_manycore_dir       $::env(BSG_MANYCORE_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)

set bsg_packaging_dir $::env(BSG_PACKAGING_DIR)
set bsg_package       $::env(BSG_PACKAGE)
set bsg_pinout        $::env(BSG_PINOUT)
set bsg_padmapping    $::env(BSG_PADMAPPING)

set bsg_packaging_foundary $::env(BSG_PACKAGING_FOUNDRY)

set bp_dir        $::env(BLACKPARROT_DIR)
set bp_common_dir ${bp_dir}/bp_common
set bp_top_dir    ${bp_dir}/bp_top
set bp_fe_dir     ${bp_dir}/bp_fe
set bp_be_dir     ${bp_dir}/bp_be
set bp_me_dir     ${bp_dir}/bp_me

set SVERILOG_INCLUDE_PATHS [join "
  $bsg_packaging_dir/common/verilog
  $bsg_packaging_dir/common/foundry/$bsg_packaging_foundary/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/$bsg_packaging_foundary/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/$bsg_packaging_foundary/verilog/padmappings/$bsg_padmapping
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_cache
  $basejump_stl_dir/bsg_clk_gen
  $basejump_stl_dir/bsg_noc
  $basejump_stl_dir/bsg_tag
  $bsg_manycore_dir/imports/HardFloat/source
  $bsg_manycore_dir/imports/HardFloat/source/RISCV
  $bp_common_dir/src/include
  $bp_fe_dir/src/include
  $bp_be_dir/src/include
  $bp_be_dir/src/include/bp_be_dcache
  $bp_me_dir/src/include
  $bp_top_dir/src/include
  $bp_dir/external/HardFloat/source
  $bp_dir/external/HardFloat/source/RISCV

  $bsg_designs_target_dir/../common/v
  $bsg_designs_target_dir/../common/sdr/sdr_horizontal/v
  $bsg_designs_target_dir/../common/sdr/sdr_vertical/v
  $bsg_designs_target_dir/../common/sdr/sdr_corner/v
"]
