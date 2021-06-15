.DEFAULT_GOAL=build

# Note: most variables that are file/dir paths are ?= because they can be
# overriden by the chip repo if this makefile is called from the chip
# infrastructure.

#######################################
# Simulation run-time flags
########################################

TOP_DIR            ?= $(shell git rev-parse --show-toplevel)
ROOT_DIR           ?= $(abspath $(TOP_DIR)/../)
export BSG_DESIGNS_TARGET ?= $(notdir $(abspath ../../))

BSG_WORK_DIR := $(abspath ./)
BSG_OUT_DIR  := $(BSG_WORK_DIR)/out

BSG_CUDA_PATH := $(BSG_OUT_DIR)/cuda
BSG_CUDA_SIM  := $(BSG_CUDA_PATH)/simv
BSG_CUDA_DBG  := $(BSG_CUDA_PATH)/simv-debug

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
VCS_OPTIONS += -V
VCS_OPTIONS += +v2k
VCS_OPTIONS += -sverilog -assert svaext
VCS_OPTIONS += +noportcoerce
VCS_OPTIONS += +vc
#VCS_OPTIONS += +vcs+loopreport
VCS_OPTIONS += -timescale=1ps/1ps
#VCS_OPTIONS += -diag timescale 
VCS_OPTIONS += -top bsg_config bsg_config.v
VCS_OPTIONS += -licqueue -reportstats
VCS_OPTIONS += +warn=all,noOPD,noTMR,noTFIPC,noIWNF,noSDFCOM_SWC,noSDFCOM_ANICD,noSDFCOM_IWSBA,noSDFCOM_NICD,noSDFCOM_INF

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
BSG_TRACE_PY    := $(BSG_WORK_DIR)/../py/bsg_tag_boot.py
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

#########################################
POD_Y := 0 1 2 3
POD_X := 0 1 2 3
TILE_Y := 0 1 2 3 4 5 6 7
TILE_X := 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
MEM_IDX := 0 1 2 3 4 5 6 7

CHIP_BLOCK_INSTANCE_PATH:=${BSG_CHIP_INSTANCE_PATH}.block

BSG_SDR_NE_INSTANCE_PATHS := $(foreach PY, $(POD_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_${PY}__podrow.sdr_ne)
BSG_SDR_NW_INSTANCE_PATHS := $(foreach PY, $(POD_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_${PY}__podrow.sdr_nw)
BSG_SDR_SE_INSTANCE_PATHS := $(foreach PY, $(POD_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_${PY}__podrow.sdr_se)
BSG_SDR_SW_INSTANCE_PATHS := $(foreach PY, $(POD_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_${PY}__podrow.sdr_sw)

BSG_SDR_WEST_INSTANCE_PATHS := $(foreach PY, $(POD_Y), $(foreach TY, $(TILE_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_${PY}__podrow.sdr_w_y_${TY}__sdr_w))
BSG_SDR_EAST_INSTANCE_PATHS := $(foreach PY, $(POD_Y), $(foreach TY, $(TILE_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_${PY}__podrow.sdr_e_y_${TY}__sdr_e))

BSG_SDR_NORTH0_INSTANCE_PATHS := $(foreach PX, $(POD_X), $(foreach TX, ${TILE_X}, ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_0__podrow.sdr_n_x_${PX}__sdr_n.sdr_x_${TX}__sdr_n))
BSG_SDR_NORTH1_INSTANCE_PATHS := $(foreach PX, $(POD_X), $(foreach TX, ${TILE_X}, ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_1__podrow.sdr_n_x_${PX}__sdr_n.sdr_x_${TX}__sdr_n))
BSG_SDR_NORTH2_INSTANCE_PATHS := $(foreach PX, $(POD_X), $(foreach TX, ${TILE_X}, ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_2__podrow.sdr_n_x_${PX}__sdr_n.sdr_x_${TX}__sdr_n))
BSG_SDR_NORTH3_INSTANCE_PATHS := $(foreach PX, $(POD_X), $(foreach TX, ${TILE_X}, ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_3__podrow.sdr_n_x_${PX}__sdr_n.sdr_x_${TX}__sdr_n))
BSG_SDR_SOUTH0_INSTANCE_PATHS := $(foreach PX, $(POD_X), $(foreach TX, ${TILE_X}, ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_0__podrow.sdr_s_x_${PX}__sdr_s.sdr_x_${TX}__sdr_n))
BSG_SDR_SOUTH1_INSTANCE_PATHS := $(foreach PX, $(POD_X), $(foreach TX, ${TILE_X}, ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_1__podrow.sdr_s_x_${PX}__sdr_s.sdr_x_${TX}__sdr_n))
BSG_SDR_SOUTH2_INSTANCE_PATHS := $(foreach PX, $(POD_X), $(foreach TX, ${TILE_X}, ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_2__podrow.sdr_s_x_${PX}__sdr_s.sdr_x_${TX}__sdr_n))
BSG_SDR_SOUTH3_INSTANCE_PATHS := $(foreach PX, $(POD_X), $(foreach TX, ${TILE_X}, ${BSG_CHIP_INSTANCE_PATH}.block.core_complex_core_3__podrow.sdr_s_x_${PX}__sdr_s.sdr_x_${TX}__sdr_n))


NOC_IO_LINK_PATHS 			:= $(BSG_CHIP_INSTANCE_PATH).block.io_link
NOC_MEM_LINK_PATHS 			:= $(foreach M, $(MEM_IDX), $(BSG_CHIP_INSTANCE_PATH).block.mem_link_${M}__link)
BIGBLADE_CLK_GEN_PATHS 	:= $(foreach PY, $(POD_Y), $(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_${PY}__clk_gen)
BP_CLK_GEN_PATHS        := $(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_0__bp_0__clk_gen \
													 $(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_1__bp_0__clk_gen \
													 $(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_2__bp_0__clk_gen \
													 $(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_3__bp_0__clk_gen \
													 $(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_0__bp_1__clk_gen \
													 $(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_1__bp_1__clk_gen \
													 $(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_2__bp_1__clk_gen \
													 $(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_3__bp_1__clk_gen

BP_HALFPOD_PATHS 	:= \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_0__bp_0__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_1__bp_0__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_2__bp_0__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_3__bp_0__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_0__bp_1__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_1__bp_1__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_2__bp_1__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_3__bp_1__halfpod

CGRA_CLK_GEN_PATHS := \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_0__cgra_0__clk_gen \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_1__cgra_0__clk_gen \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_2__cgra_0__clk_gen \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_3__cgra_0__clk_gen \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_0__cgra_1__clk_gen \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_1__cgra_1__clk_gen \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_2__cgra_1__clk_gen \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_3__cgra_1__clk_gen


CGRA_HALFPOD_PATHS := \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_0__cgra_0__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_1__cgra_0__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_2__cgra_0__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_3__cgra_0__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_0__cgra_1__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_1__cgra_1__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_2__cgra_1__halfpod \
	$(BSG_CHIP_INSTANCE_PATH).block.core_complex_core_3__cgra_1__halfpod
	

IO_LINK_DDR_PATHS 			:= $(BSG_CHIP_INSTANCE_PATH).block.io_link.ddr_link_0__link
IO_LINK_DDR_PATHS 			+= $(BSG_CHIP_INSTANCE_PATH).block.io_link.ddr_link_1__link
IO_LINK_DDR_PATHS 			+= $(foreach M, $(MEM_IDX), $(BSG_CHIP_INSTANCE_PATH).block.mem_link_${M}__link.ddr_link_0__link)
IO_LINK_DDR_PATHS 			+= $(foreach M, $(MEM_IDX), $(BSG_CHIP_INSTANCE_PATH).block.mem_link_${M}__link.ddr_link_1__link)


EXPAND_VERILOG_PY = ${TOP_DIR}/util/expand_verilog_hierarchy.py
CDC_INSTANCE_LIST_V = $(abspath ./out/cdc_instance_list.v)

BIGBLADE_CLK_GEN_V 	  = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-2/post-apr/bigblade_clk_gen/bigblade_clk_gen_chip_finish.v

IO_LINK_DDR_V 			  = $(HB_BIGBLADE_NETLISTS_DIR)/rc-0-0/post-apr/bigblade_io_link_ddr/bsg_chip_io_link_ddr_chip_finish.v
NOC_IO_LINK_V					= $(HB_BIGBLADE_NETLISTS_DIR)/rc-0-0/post-apr/bigblade_noc_io_link/bsg_chip_noc_io_link_chip_finish.v
NOC_MEM_LINK_V				= $(HB_BIGBLADE_NETLISTS_DIR)/rc-0-0/post-apr/bigblade_noc_mem_link/bsg_chip_noc_mem_link_chip_finish.v

BSG_SDR_NE_V          = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_wh_to_sdr_ne/bsg_manycore_link_wh_to_sdr_ne_chip_finish.v
BSG_SDR_NW_V          = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_wh_to_sdr_nw/bsg_manycore_link_wh_to_sdr_nw_chip_finish.v
BSG_SDR_SE_V          = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_wh_to_sdr_se/bsg_manycore_link_wh_to_sdr_se_chip_finish.v
BSG_SDR_SW_V          = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_wh_to_sdr_sw/bsg_manycore_link_wh_to_sdr_sw_chip_finish.v
BSG_SDR_EAST_V        = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_ruche_to_sdr_east/bsg_manycore_link_ruche_to_sdr_east_chip_finish.v
BSG_SDR_WEST_V        = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_ruche_to_sdr_west/bsg_manycore_link_ruche_to_sdr_west_chip_finish.v
BSG_SDR_NORTH_V       = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_to_sdr_north/bsg_manycore_link_to_sdr_north_chip_finish.v
BSG_SDR_SOUTH_V       = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_to_sdr_south/bsg_manycore_link_to_sdr_south_chip_finish.v

BP_HALFPOD_V				  = $(HB_BIGBLADE_NETLISTS_DIR)/rc-0-1/post-apr/bigblade_bp_unicore/bsg_blackparrot_halfpod_chip_finish.v


# Gate-level Sim options
VCS_OPTIONS += +sdfverbose +neg_tchk +overlap +multisource_int_delays -sdfretain
VCS_OPTIONS += -negdelay
VCS_OPTIONS += +optconfigfile+$(CDC_INSTANCE_LIST_V)
VCS_OPTIONS += -diag=sdf


####################################
SDF_CORNERS = \
	sspg_0p72v_125c_sigcmax \
	sspg_0p72v_125c_sigcmin \
	sspg_0p72v_125c_sigrcmax \
	sspg_0p72v_125c_sigrcmin \
	sspg_0p72v_m40c_sigcmax \
	sspg_0p72v_m40c_sigcmin \
	sspg_0p72v_m40c_sigrcmin \
	sspg_0p72v_m40c_sigrcmax \
	ffpg_0p88v_125c_sigcmax \
  ffpg_0p88v_125c_sigcmin \
  ffpg_0p88v_125c_sigrcmax \
  ffpg_0p88v_125c_sigrcmin \
  ffpg_0p88v_m40c_sigrcmax \
  ffpg_0p88v_m40c_sigrcmin \
  ffpg_0p88v_m40c_sigcmax \
  ffpg_0p88v_m40c_sigcmin


MIN_SIMV = $(addprefix out/, $(addsuffix _min/simv, $(SDF_CORNERS)))
MAX_SIMV = $(addprefix out/, $(addsuffix _max/simv, $(SDF_CORNERS)))
MIN_SIMV_DEBUG = $(addprefix out/, $(addsuffix _min/simv-debug, $(SDF_CORNERS)))
MAX_SIMV_DEBUG = $(addprefix out/, $(addsuffix _max/simv-debug, $(SDF_CORNERS)))

$(CDC_INSTANCE_LIST_V):
	mkdir -p out/
	$(foreach path, ${BSG_SDR_NE_INSTANCE_PATHS}, \
		python $(EXPAND_VERILOG_PY) $(BSG_SDR_NE_V) \
			| grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_NW_INSTANCE_PATHS}, \
		python $(EXPAND_VERILOG_PY) $(BSG_SDR_NW_V) \
			| grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_SE_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_SE_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_SW_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_SW_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_EAST_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_EAST_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_WEST_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_WEST_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_NORTH0_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_NORTH_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_NORTH1_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_NORTH_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_NORTH2_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_NORTH_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_NORTH3_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_NORTH_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_SOUTH0_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_SOUTH_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_SOUTH1_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_SOUTH_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_SOUTH2_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_SOUTH_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_SOUTH3_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_SOUTH_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BIGBLADE_CLK_GEN_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BIGBLADE_CLK_GEN_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${NOC_IO_LINK_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(NOC_IO_LINK_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${NOC_MEM_LINK_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(NOC_MEM_LINK_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${IO_LINK_DDR_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(IO_LINK_DDR_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BP_HALFPOD_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BP_HALFPOD_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BP_CLK_GEN_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BIGBLADE_CLK_GEN_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${CGRA_CLK_GEN_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BIGBLADE_CLK_GEN_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)




# To build simv for all 32 corners, "make build -j32"
.PRECIOUS: $(MIN_SIMV) $(MAX_SIMV) $(MIN_SIMV_DEBUG) $(MAX_SIMV_DEBUG)
build:       $(MIN_SIMV) $(MAX_SIMV)
build-debug: $(MIN_SIMV_DEBUG) $(MAX_SIMV_DEBUG)

SDF_PATH = /nbu/spin_extra/gaozihou/rc0-final/ptsi_xray/bsg_chip

out/%_min/simv: $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(CDC_INSTANCE_LIST_V) ${IP_ROOT_DIRS}
	mkdir -p out/$*_min/
	$(VCS) $(VCS_OPTIONS) -o $@ -Mdir=out/$*_min/csrc   \
		-sdf min:$(BSG_CHIP_INSTANCE_PATH):$(SDF_PATH)/$*/results/bsg_chip.sdf.gz \
		-l out/$*_min/vcs.log

out/%_min/simv-debug: $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(CDC_INSTANCE_LIST_V) ${IP_ROOT_DIRS}
	mkdir -p out/$*_min/
	$(VCS) $(VCS_OPTIONS) -o $@ -Mdir=out/$*_min/csrc-debug   \
    -sdf min:$(BSG_CHIP_INSTANCE_PATH):$(SDF_PATH)/$*/results/bsg_chip.sdf.gz \
    -debug_pp +vcs+vcdpluson \
    -l out/$*_min/vcs-debug.log

out/%_max/simv: $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(CDC_INSTANCE_LIST_V) ${IP_ROOT_DIRS}
	mkdir -p out/$*_max/
	$(VCS) $(VCS_OPTIONS) -o $@ -Mdir=out/$*_max/csrc   \
    -sdf max:$(BSG_CHIP_INSTANCE_PATH):$(SDF_PATH)/$*/results/bsg_chip.sdf.gz \
    -l out/$*_max/vcs.log


out/%_max/simv-debug: $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(CDC_INSTANCE_LIST_V) ${IP_ROOT_DIRS}
	mkdir -p out/$*_max/
	$(VCS) $(VCS_OPTIONS) -o $@ -Mdir=out/$*_max/csrc-debug   \
    -sdf max:$(BSG_CHIP_INSTANCE_PATH):$(SDF_PATH)/$*/results/bsg_chip.sdf.gz \
    -debug_pp +vcs+vcdpluson \
    -l out/$*_max/vcs-debug.log


# RUN COMMANDS
SPMD ?= test_global_pod_ptr_lite
MAX_CYCLES ?= 100000000
NBF_FILE = $(BSG_MANYCORE_DIR)/software/spmd/$(SPMD)/main.nbf
MIN_RUN = $(addsuffix .min.run, $(SDF_CORNERS))
MAX_RUN = $(addsuffix .max.run, $(SDF_CORNERS))
bsg_pods_X ?= 1
bsg_pods_Y ?= 1
NUM_FINISH ?= $(shell env expr $(bsg_pods_X) \* $(bsg_pods_Y))
SIMV_COMMON_OPT = +nbf_file=$(NBF_FILE) \
                  +max_cycle=$(MAX_CYCLES) \
                  +num_finish=${NUM_FINISH} \
                  -reportstats
out/Makefile.machine.include:
	mkdir -p out/
	cp ../machine/Makefile.machine.include out/

$(NBF_FILE): out/Makefile.machine.include
	(cd $(BSG_MANYCORE_DIR)/software/spmd/$(SPMD); make main.nbf)


%.min.run: out/%_min/simv $(NBF_FILE)
	mkdir -p out/$*_min
	mkdir -p out/$*_min/$(SPMD)/
	(cd out/$*_min/$(SPMD)/; ../simv $(SIMV_COMMON_OPT) -l run.log)

%.min.debug: out/%_min/simv-debug $(NBF_FILE)
	mkdir -p out/$*_min
	mkdir -p out/$*_min/$(SPMD)-debug/
	(cd out/$*_min/$(SPMD)-debug/; ../simv-debug $(SIMV_COMMON_OPT) -l run.log)

%.max.run: out/%_max/simv $(NBF_FILE)
	mkdir -p out/$*_max
	mkdir -p out/$*_max/$(SPMD)/
	(cd out/$*_max/$(SPMD)/; ../simv $(SIMV_COMMON_OPT) -l run.log)

%.max.debug: out/%_max/simv-debug $(NBF_FILE)
	mkdir -p out/$*_max
	mkdir -p out/$*_max/$(SPMD)-debug/
	(cd out/$*_max/$(SPMD)-debug/; ../simv-debug $(SIMV_COMMON_OPT) -l run.log)

run: $(MIN_RUN) $(MAX_RUN)
min_run: $(MIN_RUN)
max_run: $(MAX_RUN)

%.min.dve:
	$(DVE) -full64 -vpd out/$*_min/$(SPMD)-debug/vcdplus.vpd &
%.max.dve:
	$(DVE) -full64 -vpd out/$*_max/$(SPMD)-debug/vcdplus.vpd &


$(BSG_OUT_DIR)/root: | $(BSG_OUT_DIR)
	ln -nsf $(ROOT_DIR) $@

$(BSG_OUT_DIR)/Makefile.machine.include: $(BSG_WORK_DIR)/../machine/Makefile.machine.include | $(BSG_OUT_DIR)
	@cp $(BSG_WORK_DIR)/../machine/Makefile.machine.include $(BSG_OUT_DIR)

$(BSG_OUT_DIR):
	@mkdir -p $@

export BSG_MACHINE_PATH := $(BSG_OUT_DIR)

summary:
	grep -R out/*/$(SPMD)/run.log --color -e "BSG_FINISH" -e "BSG_FAIL" -e "BSG_TIMEOUT" -e "Error"

clean:
	rm -rf $(BSG_OUT_DIR) sdfAnnotateInfo
	rm -rf DVEfiles
	rm -rf stack.info.*
	rm -f  vc_hdrs.h
	rm -f  vcdplus.vpd
	rm -f  inter.vpd
	rm -f  ucli.key
