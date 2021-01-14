BSG_CADENV_DIR 				 = $(abspath ../../bsg_cadenv)
BSG_OUT_DIR            = $(abspath ./out)
SIMV  	   		         = $(abspath ./out/simv)
SIMV_DEBUG  	   		   = $(abspath ./out/simv-debug)

include $(BSG_CADENV_DIR)/cadenv.mk

# repository setup
export BSG_DESIGNS_DIR = $(abspath ../../../../)
export BSG_DESIGNS_TARGET_DIR = $(abspath ../../)
export BSG_DESIGNS_TARGET_TCL_HARD_DIR = $(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14
export BASEJUMP_STL_DIR  = $(BSG_DESIGNS_TARGET_DIR)/basejump_stl
export BSG_CHIP_DIR      = $(BSG_DESIGNS_TARGET_DIR)/bsg_14
export BOARD_DIR         = $(BSG_DESIGNS_TARGET_DIR)/board
export BSG_MANYCORE_DIR  = $(BSG_DESIGNS_TARGET_DIR)/bsg_manycore
export BSG_PACKAGING_DIR = $(BSG_DESIGNS_TARGET_DIR)/bsg_packaging

export PREP_MEMGEN_RUN_DIR    = $(BSG_CHIP_DIR)/.pdk_prep/memgen

export TESTING_BSG_DESIGNS_DIR        = $(BSG_OUT_DIR)/bsg_design_hb_one
export TESTING_BSG_DESIGNS_TARGET_DIR = $(BSG_OUT_DIR)/hb_manycore
export TESTING_BSG_PACKAGING_DIR 			= $(BSG_OUT_DIR)/bsg_packaging
export TESTING_BASEJUMP_STL_DIR 			= $(BSG_OUT_DIR)/basejump_stl
export TESTING_BSG_MANYCORE_DIR				= $(BSG_OUT_DIR)/bsg_manycore
export TESTING_BOARD_DIR              = $(BSG_OUT_DIR)/board


# packaging options
export BSG_PACKAGE                     ?=uw_bga
export BSG_PINOUT                      ?=bsg_asic_cloud
export BSG_PACKAGING_FOUNDRY           ?=gf_14_invecas_1p8v
export BSG_PADMAPPING                  ?=default
export BSG_TOPLEVEL_DESIGN_TYPE ?=chip_3x3
export BSG_TARGET_PROCESS       ?=gf_14




# VCS options
VCS_OPTIONS := -full64
VCS_OPTIONS += -notice
VCS_OPTIONS += -V
VCS_OPTIONS += +v2k
VCS_OPTIONS += -sverilog -assert svaext
VCS_OPTIONS += +noportcoerce
VCS_OPTIONS += +vc
VCS_OPTIONS += +vcs+loopreport
VCS_OPTIONS += -timescale=1ps/1ps
VCS_OPTIONS += -diag timescale
VCS_OPTIONS += -Mdir=$(BSG_OUT_DIR)
VCS_OPTIONS += -top bsg_config bsg_config.v
VCS_OPTIONS += +warn=all,noOPD,noTMR
VCS_OPTIONS += -l out/vcs.log
VCS_OPTIONS += +lint=all,noSVA-UA,noSVA-NSVU,noVCDE,noNS
VCS_OPTIONS += -licqueue

VCS_OPTIONS += +notimingcheck
VCS_OPTIONS += +nospecify

# bsg_config setup
BSG_TOP_SIM_MODULE = testbench
BSG_CHIP_IC0_INSTANCE_PATH = testbench.DUT

VCS_OPTIONS += +define+BSG_TOP_SIM_MODULE=$(BSG_TOP_SIM_MODULE)
VCS_OPTIONS += +define+BSG_CHIP_IC0_INSTANCE_PATH=$(BSG_CHIP_IC0_INSTANCE_PATH)

export BSG_CHIP_LIBRARY_NAME = bsg_chip
export BSG_CHIP_FILELIST = $(BSG_OUT_DIR)/$(BSG_CHIP_LIBRARY_NAME).filelist
export BSG_CHIP_LIBRARY  = $(BSG_OUT_DIR)/$(BSG_CHIP_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_CHIP_LIBRARY_NAME=$(BSG_CHIP_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_CHIP_FILELIST)
VCS_OPTIONS += -libmap $(BSG_CHIP_LIBRARY)

export BSG_DESIGNS_TESTING_LIBRARY_NAME = bsg_design_testing
export BSG_DESIGNS_TESTING_FILELIST = $(BSG_OUT_DIR)/$(BSG_DESIGNS_TESTING_LIBRARY_NAME).filelist
export BSG_DESIGNS_TESTING_LIBRARY  = $(BSG_OUT_DIR)/$(BSG_DESIGNS_TESTING_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_DESIGNS_TESTING_LIBRARY_NAME=$(BSG_DESIGNS_TESTING_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_DESIGNS_TESTING_FILELIST)
VCS_OPTIONS += -libmap $(BSG_DESIGNS_TESTING_LIBRARY)


# BUILD DEFS
build: $(SIMV) $(SIMV_DEBUG)
#build: $(SIMV_DEBUG)

$(SIMV): filelist copy_machine trace_rom
	$(VCS) $(VCS_OPTIONS) -o $@ -l out/vcs.log -Mdir=out/csrc

$(SIMV_DEBUG): filelist copy_machine trace_rom
	$(VCS) $(VCS_OPTIONS) -debug_pp +vcs+vcdpluson -o $@ -l out/vcs-debug.log -Mdir=out/csrc-debug
	

# POD TAG TRACE GEN
POD_TRACE_GEN_PY = $(BSG_MANYCORE_DIR)/testbenches/py/pod_trace_gen.py
ASCII_TO_ROM_PY = $(BASEJUMP_STL_DIR)/bsg_mem/bsg_ascii_to_rom.py
trace_rom:
	python $(POD_TRACE_GEN_PY) 1 1 7 > ../pod_trace.tr
	python $(ASCII_TO_ROM_PY) ../pod_trace.tr bsg_tag_boot_rom > ../bsg_tag_boot_rom.v

copy_machine:
	mkdir -p out/
	cp ../Makefile.machine.include out/

filelist: test_repo
	mkdir -p out/
	/usr/bin/tclsh bsg_config.tcl

	
test_repo:
	mkdir -p out/
	ln -nsf $(BASEJUMP_STL_DIR) $(TESTING_BASEJUMP_STL_DIR)
	ln -nsf $(BSG_MANYCORE_DIR) $(TESTING_BSG_MANYCORE_DIR)
	ln -nsf $(BSG_DESIGNS_TARGET_DIR) $(TESTING_BSG_DESIGNS_TARGET_DIR)
	ln -nsf $(BSG_DESIGNS_DIR) $(TESTING_BSG_DESIGNS_DIR)

dve:
	$(DVE) -full64 -vpd out/vcdplus.vpd

clean:
	rm -rf out/
	rm -rf DVEfiles vc_hdrs.h
