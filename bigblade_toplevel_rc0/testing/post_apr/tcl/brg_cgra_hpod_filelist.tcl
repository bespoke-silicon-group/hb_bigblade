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
source $::env(HB_BIGBLADE_NETLISTS_DIR)/bigblade_brg_cgra_excel-post-apr_filelist.tcl
