# Testing (Testbenches) directory

Each folder contains a specific configuration of the top-level chip TB.

There are four "main" testbenches:
 - rtl: Un-synthesized chip RTL
 - rtl_hard: Unsynthesized chip RTL with hardened macros swapped out on a per-module basis
 - post_synth: All modules are swappwed with their synthesized netlists
 - post_apr: All modules are swapped with their post-apr netlists

Each of the remaining testbenches are derived from these four. For
example, the io_sdr_post_synth testbench swapps the IO and SDR RTL
modules for their post-synthesis counterparts. This is done by
modifying two files:

 - bsg_config.v: This is a list of all of the modules that should be
   swapped and the library name to look in to find them. See
   post_synth and post_apr for examples. Modules that are not swapped
   should not be in bsg_config.v. bsg_config.v *DOES NOT* specify how
   the modules are swapped. An example is shown below:

```
  cell bsg_chip_io_link_ddr liblist `BIGBLADE_IO_LINK_DDR_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
```

  This specifies that all `bigblade_clk_gen` modules should use the
filelist library `BIGBLADE_CLK_GEN_LIBRARY_NAME` to find its source
files. If the file cannot be found there, fall back to
`BSG_CHIP_LIBRARY_NAME`. **IMPORTANT:** The cell name
(e.g. bigblade_clk_gen) MUST match the name of the module that needs
to be to swapped. If not, VCS will happily use the the RTL version of
the module.

 - bsg_config.tcl: This is a list of how all of the modules should be
   swapped, using file lists. Each module has an entry that looks like
   the following:

```
 # Swap the clock generator Chip RTL for RTL Hard.
 source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_io_link_ddr_filelist.tcl
 source $::env(BSG_DESIGNS_TARGET_DIR)/testing/rtl_hard/tcl/bigblade_io_link_ddr_include.tcl
```

The same declaration is made for post synth:

```
 # Swap the clock generator Chip RTL for Post-Synthesis.
 source $::env(BSG_DESIGNS_TARGET_DIR)/testing/post_synth/tcl/bigblade_io_link_ddr_filelist.tcl
 source $::env(BSG_DESIGNS_TARGET_DIR)/testing/post_synth/tcl/bigblade_io_link_ddr_include.tcl
```

There are two ways to confirm that the swap has happened correctly, AND BOTH SHOULD BE USED.

1. Search build.log for synthesized instances being compiled during the final VCS step. For example: bsg_chip_io_link_ddr_bsg_counter_clear_up_f_0_1_1
2. Run simulation, open DVE, and confirm that the synthesized netlist is being simulated in the hierarchy. This means finding the gf14 cells.



