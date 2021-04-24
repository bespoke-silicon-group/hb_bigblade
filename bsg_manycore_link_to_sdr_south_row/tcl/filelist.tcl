
set  basejump_stl_dir        $::env(BASEJUMP_STL_DIR)
set  bsg_manycore_dir        $::env(BSG_MANYCORE_DIR)
set  bsg_designs_target_dir  $::env(BSG_DESIGNS_TARGET_DIR)
set  bsg_packaging_dir       $::env(BSG_PACKAGING_DIR)
set  bsg_package             $::env(BSG_PACKAGE)
set  bsg_pinout              $::env(BSG_PINOUT)
set  bsg_padmapping          $::env(BSG_PADMAPPING)

set SVERILOG_INCLUDE_PATHS [join "
  $basejump_stl_dir/bsg_cache
  $basejump_stl_dir/bsg_clk_gen
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_noc
  $basejump_stl_dir/bsg_tag
  $bsg_designs_target_dir/v
  $bsg_manycore_dir/imports/HardFloat/source
  $bsg_manycore_dir/imports/HardFloat/source/RISCV
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/portable/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/portable/verilog/padmappings/$bsg_padmapping
  $bsg_packaging_dir/common/foundry/portable/verilog
  $bsg_packaging_dir/common/verilog
"]

set SVERILOG_SOURCE_FILES [join "
  $bsg_manycore_dir/v/bsg_manycore_pkg.v

  $bsg_designs_target_dir/v/bsg_manycore_link_to_sdr_south_row.v
"]
