.DEFAULT_GOAL=build

# Note: most variables that are file/dir paths are ?= because they can be
# overriden by the chip repo if this makefile is called from the chip
# infrastructure.

#######################################
# Simulation run-time flags
########################################
WAVE       ?= 0

TOP_DIR            ?= $(shell git rev-parse --show-toplevel)
ROOT_DIR           ?= $(abspath $(TOP_DIR)/../)
export BSG_DESIGNS_TARGET ?= $(notdir $(abspath ../../))

BSG_WORK_DIR := $(abspath ./)
BSG_OUT_DIR  := $(BSG_WORK_DIR)/out
ifeq ($(WAVE),1)
  BSG_SPMD_SIM  := $(BSG_OUT_DIR)/simv-debug
else
  BSG_SPMD_SIM  := $(BSG_OUT_DIR)/simv
endif


# Repository setup
export BSG_DESIGNS_DIR        ?= $(abspath ../../../)
export BSG_DESIGNS_TARGET_DIR ?= $(BSG_DESIGNS_DIR)/$(BSG_DESIGNS_TARGET)
export BSG_DESIGNS_TARGET_TCL_HARD_DIR ?= $(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14

# Additional setup for RTL-Hard
export BSG_CHIP_DIR             ?= $(BSG_DESIGNS_TARGET_DIR)/bsg_14
export PREP_MEMGEN_RUN_DIR      ?= $(BSG_CHIP_DIR)/.pdk_prep/memgen
export BSG_TOPLEVEL_DESIGN_TYPE ?=chip_3x3
export BSG_TARGET_PROCESS       ?=gf_14

export BASEJUMP_STL_DIR       ?= $(BSG_DESIGNS_TARGET_DIR)/basejump_stl
export BSG_MANYCORE_DIR       ?= $(BSG_DESIGNS_TARGET_DIR)/bsg_manycore
export BSG_REPLICANT_DIR      ?= $(BSG_DESIGNS_TARGET_DIR)/bsg_replicant
export BSG_F1_DIR             ?= $(BSG_REPLICANT_DIR)
export BSG_PACKAGING_DIR      ?= $(BSG_DESIGNS_TARGET_DIR)/bsg_packaging
export BOARD_DIR              ?= $(BSG_DESIGNS_TARGET_DIR)/board
export HB_BIGBLADE_NETLISTS_DIR ?= $(BSG_DESIGNS_TARGET_DIR)/hb_bigblade_netlists

export TESTING_BSG_DESIGNS_DIR        ?= $(BSG_OUT_DIR)/root/$(notdir $(BSG_DESIGNS_DIR))
export TESTING_BSG_DESIGNS_TARGET_DIR ?= $(TESTING_BSG_DESIGNS_DIR)/$(BSG_DESIGNS_TARGET)
export TESTING_BASEJUMP_STL_DIR       ?= $(TESTING_BSG_DESIGNS_TARGET_DIR)/basejump_stl
export TESTING_BSG_MANYCORE_DIR       ?= $(TESTING_BSG_DESIGNS_TARGET_DIR)/bsg_manycore
export TESTING_BSG_REPLICANT_DIR      ?= $(TESTING_BSG_DESIGNS_TARGET_DIR)/bsg_replicant
export TESTING_BSG_PACKAGING_DIR      ?= $(TESTING_BSG_DESIGNS_TARGET_DIR)/bsg_packaging
export TESTING_BOARD_DIR              ?= $(TESTING_BSG_DESIGNS_TARGET_DIR)/board
export TESTING_BSG_OUT_DIR            ?= $(BSG_OUT_DIR)

export BSG_PACKAGE           ?=basejump_fcbga_785
export BSG_PINOUT            ?=bsg_bigblade_v0
export BSG_PACKAGING_FOUNDRY ?=gf_14_invecas_1p8v
export BSG_PADMAPPING        ?=default

include $(BSG_DESIGNS_TARGET_DIR)/bsg_cadenv/cadenv.mk

########################################
## VCS OPTIONS
########################################

# Common VCS Options (will be used most of the time by all corners)
VCS_OPTIONS := -full64
VCS_OPTIONS += -notice
ifeq ($(WAVE),1)
  VCS_OPTIONS += -debug_pp +vcs+vcdpluson
endif
VCS_OPTIONS += -V
VCS_OPTIONS += +v2k
VCS_OPTIONS += -sverilog -assert svaext
VCS_OPTIONS += +noportcoerce
VCS_OPTIONS += +vc
#VCS_OPTIONS += +vcs+loopreport
VCS_OPTIONS += -timescale=1ps/1ps
#VCS_OPTIONS += -diag timescale 
VCS_OPTIONS += -top bsg_config bsg_config.v
VCS_OPTIONS += -licqueue
VCS_OPTIONS += +notimingcheck
VCS_OPTIONS += +nospecify
VCS_OPTIONS += +lint=all,noSVA-UA,noSVA-NSVU,noVCDE,noNS

VCS_OPTIONS += +define+SPMD_VERBOSE=1
########################################
## Chip and Testing Filelists and Liblists
########################################

BSG_TOP_SIM_MODULE = bsg_bigblade_pcb
BSG_CHIP_INSTANCE_PATH = $(BSG_TOP_SIM_MODULE).IC.ASIC

VCS_OPTIONS += +define+BSG_TOP_SIM_MODULE=$(BSG_TOP_SIM_MODULE)
VCS_OPTIONS += +define+BSG_CHIP_INSTANCE_PATH=$(BSG_CHIP_INSTANCE_PATH)

export BSG_CHIP_LIBRARY_NAME = bsg_chip
export BSG_CHIP_FILELIST = $(BSG_OUT_DIR)/$(BSG_CHIP_LIBRARY_NAME).filelist
export BSG_CHIP_LIBRARY = $(BSG_OUT_DIR)/$(BSG_CHIP_LIBRARY_NAME).library
export BSG_CHIP_DIR = $(BSG_DESIGNS_TARGET_DIR)/bsg_14

VCS_OPTIONS += +define+BSG_CHIP_LIBRARY_NAME=$(BSG_CHIP_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_CHIP_FILELIST)
VCS_OPTIONS += -libmap $(BSG_CHIP_LIBRARY)

export BSG_DESIGNS_TESTING_LIBRARY_NAME = bsg_design_testing
export BSG_DESIGNS_TESTING_FILELIST = $(BSG_OUT_DIR)/$(BSG_DESIGNS_TESTING_LIBRARY_NAME).filelist
export BSG_DESIGNS_TESTING_LIBRARY = $(BSG_OUT_DIR)/$(BSG_DESIGNS_TESTING_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_DESIGNS_TESTING_LIBRARY_NAME=$(BSG_DESIGNS_TESTING_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_DESIGNS_TESTING_FILELIST)
VCS_OPTIONS += -libmap $(BSG_DESIGNS_TESTING_LIBRARY)

###########################################


##################################
# Create filelists and libraries #
##################################
.PHONY: library
library: $(BSG_DESIGNS_TESTING_LIBRARY)

$(BSG_CHIP_FILELIST): $(BSG_DESIGNS_TESTING_LIBRARY)
$(BSG_CHIP_LIBRARY): $(BSG_DESIGNS_TESTING_LIBRARY)
$(BSG_DESIGNS_TESTING_FILELIST): $(BSG_DESIGNS_TESTING_LIBRARY)
$(BSG_DESIGNS_TESTING_LIBRARY): $(BSG_OUT_DIR)/root
	/usr/bin/tclsh bsg_config.tcl

########################################
## Trace Replay Roms
########################################

BSG_TRACE_NAME  := bsg_tag_boot
BSG_TRACE_PY    := $(BSG_WORK_DIR)/../py/bsg_tag_boot_single_pod.py
BSG_TRACE_FILES := $(BSG_OUT_DIR)/$(BSG_TRACE_NAME).tr
BSG_TRACE_ROMS  := $(BSG_OUT_DIR)/bsg_tag_boot_rom.v

ifeq ($(USE_CLK_GEN),1)
  BSG_TRACE_PY_OPTION := use_clk_gen
else
  BSG_TRACE_PY_OPTION := use_ext_clk
endif

$(BSG_TRACE_FILES): $(BSG_TRACE_PY) | $(BSG_OUT_DIR)
	python $< $(BSG_TRACE_PY_OPTION) > $@

$(BSG_TRACE_ROMS): $(BSG_TRACE_FILES) | $(BSG_OUT_DIR)
	$(BASEJUMP_STL_DIR)/bsg_mem/bsg_ascii_to_rom.py $< bsg_tag_boot_rom > $@

#VCS_OPTIONS += $(addprefix -v ,$(BSG_TRACE_ROMS))


########################################
## Toplevel Parameters
########################################

# Note: For debugging purpose only, should not modify in regular runs
OVERRIDE_PODS_X ?= 4
OVERRIDE_PODS_Y ?= 1

# Note: Overriding parameters in bsg_chip_pkg.v
VCS_OPTIONS += -pvalue+hb_num_pods_x_gp=$(OVERRIDE_PODS_X)
VCS_OPTIONS += -pvalue+hb_num_pods_y_gp=$(OVERRIDE_PODS_Y)

########################################
## DRAM Definitions
########################################

#VCS_OPTIONS += +define+den2048Mb+sg5+x16+FULL_MEM

########################################
## Run Targets
########################################

# create symlinks foreach ip block

IP_BLOCKS  = bigblade_clk_gen
IP_BLOCKS += bigblade_noc_io_link
IP_BLOCKS += bigblade_noc_mem_link
IP_BLOCKS += bsg_manycore_tile
IP_BLOCKS += bigblade_io_link_ddr
IP_BLOCKS += bsg_manycore_link_sdr

IP_ROOT_DIRS = $(foreach block,$(IP_BLOCKS),$(BSG_OUT_DIR)/$(block))
$(IP_ROOT_DIRS): | $(BSG_OUT_DIR)
	ln -s $(BSG_DESIGNS_DIR) $@

build: $(BSG_SPMD_SIM)
	
$(BSG_SPMD_SIM): VCS_OPTIONS += -Mdir=$(BSG_OUT_DIR)/spmd
$(BSG_SPMD_SIM): $(BSG_OUT_DIR)/Makefile.machine.include $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(IP_ROOT_DIRS)
	$(VCS) $(VCS_OPTIONS) -o $@ | tee -i $(BSG_OUT_DIR)/build.log


$(BSG_OUT_DIR)/root: | $(BSG_OUT_DIR)
	ln -nsf $(ROOT_DIR) $@

$(BSG_OUT_DIR)/Makefile.machine.include: $(BSG_WORK_DIR)/../machine/Makefile.machine.include | $(BSG_OUT_DIR)
	@cp $(BSG_WORK_DIR)/../machine/Makefile.machine.include $(BSG_OUT_DIR)

$(BSG_OUT_DIR):
	@mkdir -p $@


clean:
	rm -rf $(BSG_OUT_DIR)
	rm -rf DVEfiles
	rm -rf stack.info.*
	rm -f  vc_hdrs.h
	rm -f  vcdplus.vpd
	rm -f  inter.vpd
	rm -f  ucli.key
