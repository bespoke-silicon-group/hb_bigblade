#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set bsg_manycore_dir       $::env(BSG_MANYCORE_DIR)
set bsg_designs_dir        $::env(BSG_DESIGNS_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)
set bsg_packaging_dir      $::env(BSG_PACKAGING_DIR)
set cgra_dir               $::env(CGRA_DIR)

set bsg_package       $::env(BSG_PACKAGE)
set bsg_pinout        $::env(BSG_PINOUT)
set bsg_padmapping    $::env(BSG_PADMAPPING)

# TODO: read netlist from HB_BIGBLADE_NETLIST
# source $::env(HB_BIGBLADE_NETLISTS_DIR)/brg_cgra_pod-post-synth_filelist.tcl

# PP: I didn't add the SRAM models here because CGRA SRAMs have the
# same spec as core DMEMs. Since we are doing full-chip RTL sim the
# hardened SRAMs are already included.
set BIGBLADE_BRG_CGRA_XCEL_SOURCE_FILES [join "
    $basejump_stl_dir/hard/gf_14/bsg_misc/bsg_mux.v
    $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_osdr_phy.v
    $basejump_stl_dir/hard/gf_14/bsg_link/bsg_link_isdr_phy.v
    $basejump_stl_dir/hard/gf_14/bsg_async/bsg_sync_sync.v
    $basejump_stl_dir/hard/gf_14/bsg_async/bsg_launch_sync_sync.v

    $cgra_dir/v/hard/gf_14/sram/SramWrapper.v
    $cgra_dir/v/hard/gf_14/HBEndpointCGRAXcel_8x8Array_4x4KBSpads__pickled.v
"]

