.DEFAULT_GOAL=run

# Note: most variables that are file/dir paths are ?= because they can be
# overriden by the chip repo if this makefile is called from the chip
# infrastructure.

TOP_DIR            ?= $(shell git rev-parse --show-toplevel)
ROOT_DIR           ?= $(abspath $(TOP_DIR)/../)
BSG_DESIGNS_TARGET ?= $(notdir $(abspath ../../))

BSG_WORK_DIR := $(abspath ./)
BSG_OUT_DIR  := $(BSG_WORK_DIR)/out
BSG_OUT_SIM  := $(BSG_OUT_DIR)/simv

include $(ROOT_DIR)/bsg_cadenv/cadenv.mk

# Repository setup
export BSG_DESIGNS_DIR        ?= $(ROOT_DIR)/hb_bigblade
export BSG_DESIGNS_TARGET_DIR ?= $(BSG_DESIGNS_DIR)/$(BSG_DESIGNS_TARGET)
export BASEJUMP_STL_DIR       ?= $(ROOT_DIR)/basejump_stl
export BSG_PACKAGING_DIR      ?= $(ROOT_DIR)/bsg_packaging
export BOARD_DIR              ?= $(ROOT_DIR)/board

export TESTING_BSG_DESIGNS_DIR        ?= $(BSG_OUT_DIR)/root/hb_bigblade
export TESTING_BSG_DESIGNS_TARGET_DIR ?= $(TESTING_BSG_DESIGNS_DIR)/$(BSG_DESIGNS_TARGET)
export TESTING_BASEJUMP_STL_DIR       ?= $(BSG_OUT_DIR)/root/basejump_stl
export TESTING_BSG_PACKAGING_DIR      ?= $(BSG_OUT_DIR)/root/bsg_packaging
export TESTING_BOARD_DIR              ?= $(BSG_OUT_DIR)/root/board

export BSG_PACKAGE           ?=uw_bga
export BSG_PINOUT            ?=bsg_asic_cloud
export BSG_PACKAGING_FOUNDRY ?=gf_14_invecas_1p8v
export BSG_PADMAPPING        ?=default

########################################
## VCS OPTIONS
########################################

# Common VCS Options (will be used most of the time by all corners)
VCS_OPTIONS := -full64
VCS_OPTIONS += -notice
VCS_OPTIONS += -debug_pp +vcs+vcdpluson
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

########################################
## Chip and Testing Filelists and Liblists
########################################

BSG_TOP_SIM_MODULE = bsg_hb_pcb
BSG_CHIP_INSTANCE_PATH = bsg_hb_pcb.IC.ASIC

VCS_OPTIONS += +define+BSG_TOP_SIM_MODULE=$(BSG_TOP_SIM_MODULE)
VCS_OPTIONS += +define+BSG_CHIP_INSTANCE_PATH=$(BSG_CHIP_INSTANCE_PATH)

export BSG_CHIP_LIBRARY_NAME = bsg_chip
export BSG_CHIP_FILELIST = $(BSG_OUT_DIR)/$(BSG_CHIP_LIBRARY_NAME).filelist
export BSG_CHIP_LIBRARY = $(BSG_OUT_DIR)/$(BSG_CHIP_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_CHIP_LIBRARY_NAME=$(BSG_CHIP_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_CHIP_FILELIST)
VCS_OPTIONS += -libmap $(BSG_CHIP_LIBRARY)

export BSG_DESIGNS_TESTING_LIBRARY_NAME = bsg_design_testing
export BSG_DESIGNS_TESTING_FILELIST = $(BSG_OUT_DIR)/$(BSG_DESIGNS_TESTING_LIBRARY_NAME).filelist
export BSG_DESIGNS_TESTING_LIBRARY = $(BSG_OUT_DIR)/$(BSG_DESIGNS_TESTING_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_DESIGNS_TESTING_LIBRARY_NAME=$(BSG_DESIGNS_TESTING_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_DESIGNS_TESTING_FILELIST)
VCS_OPTIONS += -libmap $(BSG_DESIGNS_TESTING_LIBRARY)

$(BSG_CHIP_FILELIST): $(BSG_DESIGNS_TESTING_LIBRARY)
$(BSG_CHIP_LIBRARY): $(BSG_DESIGNS_TESTING_LIBRARY)
$(BSG_DESIGNS_TESTING_FILELIST): $(BSG_DESIGNS_TESTING_LIBRARY)
$(BSG_DESIGNS_TESTING_LIBRARY): $(BSG_OUT_DIR)/root
	/usr/bin/tclsh bsg_config.tcl

########################################
## Trace Replay Roms
########################################
  
BSG_TRACE_FILES := $(notdir $(wildcard $(BSG_WORK_DIR)/../traces/*.tr))
BSG_TRACE_ROMS  := $(addprefix $(BSG_OUT_DIR)/,${BSG_TRACE_FILES:.tr=_rom.v})

$(BSG_OUT_DIR)/%_rom.v: $(BSG_WORK_DIR)/../traces/%.tr | $(BSG_OUT_DIR)
	$(BASEJUMP_STL_DIR)/bsg_mem/bsg_ascii_to_rom.py $< $*_rom > $@


VCS_OPTIONS += $(addprefix -v ,$(BSG_TRACE_ROMS))


########################################
## DRAM Definitions
########################################

#VCS_OPTIONS += +define+den2048Mb+sg5+x16+FULL_MEM

########################################
## Run Targets
########################################

run: clean $(BSG_OUT_SIM)
	$(BSG_OUT_SIM) | tee -i $(BSG_OUT_DIR)/run.log

run-no-tee: clean $(BSG_OUT_SIM)
	$(BSG_OUT_SIM)

rerun: $(BSG_OUT_SIM)
	$(BSG_OUT_SIM) | tee -i $(BSG_OUT_DIR)/run.log

rerun-no-tee: $(BSG_OUT_SIM)
	$(BSG_OUT_SIM)

view:
	$(VCS_BIN)/dve -full64 -vpd vcdplus.vpd

build: $(BSG_OUT_SIM)
$(BSG_OUT_SIM): $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS)
	$(VCS) $(VCS_OPTIONS) -o $(BSG_OUT_SIM) | tee -i $(BSG_OUT_DIR)/build.log

$(BSG_OUT_DIR)/root: | $(BSG_OUT_DIR)
	ln -nsf $(ROOT_DIR) $@

$(BSG_OUT_DIR):
	mkdir -p $@

clean:
	rm -rf $(BSG_OUT_DIR)
	rm -rf DVEfiles
	rm -rf stack.info.*
	rm -f  vc_hdrs.h
	rm -f  vcdplus.vpd
	rm -f  inter.vpd
	rm -f  ucli.key

