# Release Candidate Makefiles

This folder contains release candidate directories. Each directory
contains the Makefile that was used for that release candidate version
(and the output from Make summaries). Each Makefile can be copied into
bigblade-toplevel (i.e. the parent directory) and replace the Makefile
there to resurect a specific version of the chip.

These makefiles contain pointers to commits of the submodules for
bsg_manycore, bsg_cadenv, bsg_packaging, board, basejump_stl, and
bsg_replicant. These commits are tagged as well.

The release candidates are described below:

* RC ALPHA RTLFREEZE 0: RTL Freeze for RC ALPHA on May 23 2021. 