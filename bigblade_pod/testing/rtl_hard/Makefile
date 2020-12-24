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
export BSG_PACKAGING_DIR = $(BSG_DESIGNS_TARGET_DIR)/bsg_packaging
export BSG_CHIP_DIR      = $(BSG_DESIGNS_TARGET_DIR)/bsg_14
export BSG_MANYCORE_DIR  = $(BSG_DESIGNS_TARGET_DIR)/bsg_manycore
export BOARD_DIR         = $(BSG_DESIGNS_TARGET_DIR)/board
export PREP_MEMGEN_RUN_DIR    = $(BSG_CHIP_DIR)/.pdk_prep/memgen

export TESTING_BSG_DESIGNS_DIR        = $(BSG_OUT_DIR)/bsg_design_hb_one
export TESTING_BSG_DESIGNS_TARGET_DIR = $(BSG_OUT_DIR)/hb_manycore
export TESTING_BSG_PACKAGING_DIR 			= $(BSG_OUT_DIR)/bsg_packaging
export TESTING_BASEJUMP_STL_DIR 			= $(BSG_OUT_DIR)/basejump_stl
export TESTING_BSG_MANYCORE_DIR				= $(BSG_OUT_DIR)/bsg_manycore
export TESTING_BOARD_DIR              = $(BSG_OUT_DIR)/board

TAG_TRACE_DIR=$(BSG_DESIGNS_TARGET_DIR)/testing/py/

# packaging options
export BSG_PACKAGE           		?=uw_bga
export BSG_PINOUT            		?=bsg_asic_cloud
export BSG_PACKAGING_FOUNDRY 		?=gf_14_invecas_1p8v
export BSG_PADMAPPING        		?=default
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

export BSG_CHIP_LIBRARY_NAME = bsg_manycore_bigblade_pod
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

# clock period
#VCS_OPTIONS += +define+CORE_CLK_PERIOD=1000
#VCS_OPTIONS += +define+IO_MASTER_CLK_PERIOD=1000
#VCS_OPTIONS += +define+ROUTER_CLK_PERIOD=1000

# mobile ddr
VCS_OPTIONS += +define+den2048Mb+sg5+x16+FULL_MEM

# BUILD DEFS
#build: $(SIMV) $(SIMV_DEBUG)
build: $(SIMV_DEBUG)

$(SIMV): filelist tag_trace_rom copy_machine
	$(VCS) $(VCS_OPTIONS) -o $@ -l out/vcs.log -Mdir=out/csrc

$(SIMV_DEBUG): filelist copy_machine
	$(VCS) $(VCS_OPTIONS) -debug_pp +vcs+vcdpluson -o $@ -l out/vcs-debug.log -Mdir=out/csrc-debug
	
copy_machine:
	mkdir -p out/
	cp ../Makefile.machine.include out/

filelist: test_repo
	mkdir -p out/
	/usr/bin/tclsh bsg_config.tcl

tag_trace_rom:
	python $(TAG_TRACE_DIR)/ext_clk_trace.py > $(TAG_TRACE_DIR)/ext_clk_trace.tr
	python $(BASEJUMP_STL_DIR)/bsg_mem/bsg_ascii_to_rom.py $(TAG_TRACE_DIR)/ext_clk_trace.tr bsg_tag_boot_rom > $(TAG_TRACE_DIR)/bsg_tag_boot_rom.v

	
test_repo:
	mkdir -p out/
	ln -nsf $(BASEJUMP_STL_DIR) $(TESTING_BASEJUMP_STL_DIR)
	ln -nsf $(BSG_MANYCORE_DIR) $(TESTING_BSG_MANYCORE_DIR)
	ln -nsf $(BSG_PACKAGING_DIR) $(TESTING_BSG_PACKAGING_DIR)
	ln -nsf $(BSG_DESIGNS_TARGET_DIR) $(TESTING_BSG_DESIGNS_TARGET_DIR)
	ln -nsf $(BSG_DESIGNS_DIR) $(TESTING_BSG_DESIGNS_DIR)
	ln -nsf $(BOARD_DIR) $(TESTING_BOARD_DIR)

dve:
	$(DVE) -full64 -vpd out/vcdplus.vpd

clean:
	rm -rf out/
	rm -rf DVEfiles vc_hdrs.h
