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
VCS_OPTIONS += -licqueue
VCS_OPTIONS += +lint=all,noSVA-UA,noSVA-NSVU,noVCDE,noNS
VCS_OPTIONS += +define+den2048Mb+sg5+x16+FULL_MEM

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

###################################
# Manycore Filelists and Liblists #
###################################

export BSG_MANYCORE_TILE_LIBRARY_NAME = bigblade_manycore_tile
export BSG_MANYCORE_TILE_FILELIST = $(BSG_OUT_DIR)/$(BSG_MANYCORE_TILE_LIBRARY_NAME).filelist
export BSG_MANYCORE_TILE_LIBRARY = $(BSG_OUT_DIR)/$(BSG_MANYCORE_TILE_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_MANYCORE_TILE_LIBRARY_NAME=$(BSG_MANYCORE_TILE_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_MANYCORE_TILE_FILELIST)
VCS_OPTIONS += -libmap $(BSG_MANYCORE_TILE_LIBRARY)

###########################################
# Bigblade clk_gen filelists and liblists #
###########################################
export BIGBLADE_CLK_GEN_LIBRARY_NAME = bigblade_clk_gen
export BIGBLADE_CLK_GEN_FILELIST = $(BSG_OUT_DIR)/$(BIGBLADE_CLK_GEN_LIBRARY_NAME).filelist
export BIGBLADE_CLK_GEN_LIBRARY = $(BSG_OUT_DIR)/$(BIGBLADE_CLK_GEN_LIBRARY_NAME).library

VCS_OPTIONS += +define+BIGBLADE_CLK_GEN_LIBRARY_NAME=$(BIGBLADE_CLK_GEN_LIBRARY_NAME)
VCS_OPTIONS += -f $(BIGBLADE_CLK_GEN_FILELIST)
VCS_OPTIONS += -libmap $(BIGBLADE_CLK_GEN_LIBRARY)

#################################################
# Bigblade IO link DDR filelists and liblists # #
#################################################

export BIGBLADE_IO_LINK_DDR_LIBRARY_NAME = bigblade_io_link_ddr
export BIGBLADE_IO_LINK_DDR_FILELIST = $(BSG_OUT_DIR)/$(BIGBLADE_IO_LINK_DDR_LIBRARY_NAME).filelist
export BIGBLADE_IO_LINK_DDR_LIBRARY = $(BSG_OUT_DIR)/$(BIGBLADE_IO_LINK_DDR_LIBRARY_NAME).library

VCS_OPTIONS += +define+BIGBLADE_IO_LINK_DDR_LIBRARY_NAME=$(BIGBLADE_IO_LINK_DDR_LIBRARY_NAME)
VCS_OPTIONS += -f $(BIGBLADE_IO_LINK_DDR_FILELIST)
VCS_OPTIONS += -libmap $(BIGBLADE_IO_LINK_DDR_LIBRARY)


###############################################
# Bigblade NOC IO link filelists and liblists #
###############################################

export BIGBLADE_NOC_IO_LINK_LIBRARY_NAME = bigblade_noc_io_link
export BIGBLADE_NOC_IO_LINK_FILELIST = $(BSG_OUT_DIR)/$(BIGBLADE_NOC_IO_LINK_LIBRARY_NAME).filelist
export BIGBLADE_NOC_IO_LINK_LIBRARY = $(BSG_OUT_DIR)/$(BIGBLADE_NOC_IO_LINK_LIBRARY_NAME).library

VCS_OPTIONS += +define+BIGBLADE_NOC_IO_LINK_LIBRARY_NAME=$(BIGBLADE_NOC_IO_LINK_LIBRARY_NAME)
VCS_OPTIONS += -f $(BIGBLADE_NOC_IO_LINK_FILELIST)
VCS_OPTIONS += -libmap $(BIGBLADE_NOC_IO_LINK_LIBRARY)

################################################
# Bigblade NOC MEM link filelists and liblists #
################################################

export BIGBLADE_NOC_MEM_LINK_LIBRARY_NAME = bigblade_noc_mem_link
export BIGBLADE_NOC_MEM_LINK_FILELIST = $(BSG_OUT_DIR)/$(BIGBLADE_NOC_MEM_LINK_LIBRARY_NAME).filelist
export BIGBLADE_NOC_MEM_LINK_LIBRARY = $(BSG_OUT_DIR)/$(BIGBLADE_NOC_MEM_LINK_LIBRARY_NAME).library

VCS_OPTIONS += +define+BIGBLADE_NOC_MEM_LINK_LIBRARY_NAME=$(BIGBLADE_NOC_MEM_LINK_LIBRARY_NAME)
VCS_OPTIONS += -f $(BIGBLADE_NOC_MEM_LINK_FILELIST)
VCS_OPTIONS += -libmap $(BIGBLADE_NOC_MEM_LINK_LIBRARY)


#################################################
# BSG Manycore SDR links filelists and liblists #
#################################################
export BSG_MANYCORE_LINK_SDR_LIBRARY_NAME = bsg_manycore_link_sdr
export BSG_MANYCORE_LINK_SDR_FILELIST = $(BSG_OUT_DIR)/$(BSG_MANYCORE_LINK_SDR_LIBRARY_NAME).filelist
export BSG_MANYCORE_LINK_SDR_LIBRARY = $(BSG_OUT_DIR)/$(BSG_MANYCORE_LINK_SDR_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_MANYCORE_LINK_SDR_LIBRARY_NAME=$(BSG_MANYCORE_LINK_SDR_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_MANYCORE_LINK_SDR_FILELIST)
VCS_OPTIONS += -libmap $(BSG_MANYCORE_LINK_SDR_LIBRARY)


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
BSG_TRACE_PY    := $(BSG_WORK_DIR)/../py/$(BSG_TRACE_NAME).py
BSG_TRACE_FILES := $(BSG_OUT_DIR)/$(BSG_TRACE_NAME).tr
BSG_TRACE_ROMS  := $(BSG_OUT_DIR)/$(BSG_TRACE_NAME)_rom.v

ifeq ($(USE_CLK_GEN),1)
  BSG_TRACE_PY_OPTION := use_clk_gen
else
  BSG_TRACE_PY_OPTION := use_ext_clk
endif

$(BSG_TRACE_FILES): $(BSG_TRACE_PY) | $(BSG_OUT_DIR)
	python $< $(BSG_TRACE_PY_OPTION) > $@

$(BSG_TRACE_ROMS): $(BSG_TRACE_FILES) | $(BSG_OUT_DIR)
	$(BASEJUMP_STL_DIR)/bsg_mem/bsg_ascii_to_rom.py $< $(BSG_TRACE_NAME)_rom > $@

VCS_OPTIONS += $(addprefix -v ,$(BSG_TRACE_ROMS))

###############################################
# Bladerunner generated libraries and sources #
###############################################
BSG_BLADERUNNER_GENERATED_SOURCES   := $(BSG_OUT_DIR)/bsg_bladerunner_pkg.v
BSG_BLADERUNNER_GENERATED_SOURCES   += $(BSG_OUT_DIR)/bsg_manycore_machine.h
BSG_BLADERUNNER_GENERATED_LIBRARIES := $(BSG_OUT_DIR)/libbsg_manycore_runtime.so
BSG_BLADERUNNER_GENERATED_LIBRARIES += $(BSG_OUT_DIR)/libbsg_manycore_regression.so
BSG_BLADERUNNER_GENERATED_LIBRARIES += $(BSG_OUT_DIR)/libbsgmc_cuda_legacy_pod_repl.so
BSG_BLADERUNNER_GENERATED_LIBRARIES += $(BSG_OUT_DIR)/libdmamem.so
BSG_BLADERUNNER_GENERATED           := $(BSG_BLADERUNNER_GENERATED_SOURCES)
BSG_BLADERUNNER_GENERATED           += $(BSG_BLADERUNNER_GENERATED_LIBRARIES)

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

#########################################
POD_Y := 0
POD_X := 0 1 2 3
TILE_Y := 0 1 2 3 4 5 6 7
TILE_X := 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15

POD_ROW_INSTANCE_PATH := $(foreach PY, $(POD_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex.core[${PY}].podrow)

BSG_SDR_NE_INSTANCE_PATHS := $(foreach PY, $(POD_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex.core[${PY}].podrow.sdr_ne)
BSG_SDR_NW_INSTANCE_PATHS := $(foreach PY, $(POD_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex.core[${PY}].podrow.sdr_nw)
BSG_SDR_SE_INSTANCE_PATHS := $(foreach PY, $(POD_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex.core[${PY}].podrow.sdr_se)
BSG_SDR_SW_INSTANCE_PATHS := $(foreach PY, $(POD_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex.core[${PY}].podrow.sdr_sw)

BSG_SDR_WEST_INSTANCE_PATHS := $(foreach PY, $(POD_Y), $(foreach TY, $(TILE_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex.core[${PY}].podrow.sdr_w_y_${TY}__sdr_w))
BSG_SDR_EAST_INSTANCE_PATHS := $(foreach PY, $(POD_Y), $(foreach TY, $(TILE_Y), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex.core[${PY}].podrow.sdr_e_y_${TY}__sdr_e))

BSG_SDR_NORTH_INSTANCE_PATHS := $(foreach PY, $(POD_Y), $(foreach PX, $(POD_X), $(foreach TX, ${TILE_X}, ${BSG_CHIP_INSTANCE_PATH}.block.core_complex.core[${PY}].podrow.sdr_n_x_${PX}__sdr_n.sdr_x_${TX}__sdr_n)))
BSG_SDR_SOUTH_INSTANCE_PATHS := $(foreach PY, $(POD_Y), $(foreach PX, $(POD_X), $(foreach TX, ${TILE_X}, ${BSG_CHIP_INSTANCE_PATH}.block.core_complex.core[${PY}].podrow.sdr_s_x_${PX}__sdr_s.sdr_x_${TX}__sdr_n)))

BSG_SDR_NORTH_ROW_INSTANCE_PATHS := $(foreach PY, $(POD_Y), $(foreach PX, $(POD_X), ${BSG_CHIP_INSTANCE_PATH}.block.core_complex.core[${PY}].podrow.sdr_n_x_${PX}__sdr_n))



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

EXPAND_VERILOG_PY = ${TOP_DIR}/util/expand_verilog_hierarchy.py
CDC_INSTANCE_LIST_V = $(abspath ./out/cdc_instance_list.v)

BSG_SDR_NE_V_GZ       = $(TOP_DIR)/bsg_manycore_link_wh_to_sdr_ne/bsg_14/current_build/pnr/bsg_manycore_link_wh_to_sdr_ne/results/bsg_manycore_link_wh_to_sdr_ne_chip_finish.v.gz
BSG_SDR_NW_V_GZ       = $(TOP_DIR)/bsg_manycore_link_wh_to_sdr_nw/bsg_14/current_build/pnr/bsg_manycore_link_wh_to_sdr_nw/results/bsg_manycore_link_wh_to_sdr_nw_chip_finish.v.gz
BSG_SDR_SE_V_GZ       = $(TOP_DIR)/bsg_manycore_link_wh_to_sdr_se/bsg_14/current_build/pnr/bsg_manycore_link_wh_to_sdr_se/results/bsg_manycore_link_wh_to_sdr_se_chip_finish.v.gz
BSG_SDR_SW_V_GZ       = $(TOP_DIR)/bsg_manycore_link_wh_to_sdr_sw/bsg_14/current_build/pnr/bsg_manycore_link_wh_to_sdr_sw/results/bsg_manycore_link_wh_to_sdr_sw_chip_finish.v.gz
BSG_SDR_EAST_V_GZ     = $(TOP_DIR)/bsg_manycore_link_ruche_to_sdr_east/bsg_14/current_build/pnr/bsg_manycore_link_ruche_to_sdr_east/results/bsg_manycore_link_ruche_to_sdr_east_chip_finish.v.gz
BSG_SDR_WEST_V_GZ     = $(TOP_DIR)/bsg_manycore_link_ruche_to_sdr_west/bsg_14/current_build/pnr/bsg_manycore_link_ruche_to_sdr_west/results/bsg_manycore_link_ruche_to_sdr_west_chip_finish.v.gz
BSG_SDR_NORTH_V_GZ    = $(TOP_DIR)/bsg_manycore_link_to_sdr_north/bsg_14/current_build/pnr/bsg_manycore_link_to_sdr_north/results/bsg_manycore_link_to_sdr_north_chip_finish.v.gz
BSG_SDR_SOUTH_V_GZ    = $(TOP_DIR)/bsg_manycore_link_to_sdr_south/bsg_14/current_build/pnr/bsg_manycore_link_to_sdr_south/results/bsg_manycore_link_to_sdr_south_chip_finish.v.gz
BSG_SDR_NORTH_ROW_V_GZ    = $(TOP_DIR)/bsg_manycore_link_to_sdr_north_row/bsg_14/current_build/pnr/bsg_manycore_link_to_sdr_north_row/results/bsg_manycore_link_to_sdr_north_row_chip_finish.v.gz
#BSG_SDR_SOUTH_ROW_V_GZ    = $(TOP_DIR)/bsg_manycore_link_to_sdr_south_row/bsg_14/current_build/pnr/bsg_manycore_link_to_sdr_south_row/results/bsg_manycore_link_to_sdr_south_row_chip_finish.v.gz

BSG_SDR_NE_V          = out/bsg_manycore_link_wh_to_sdr_ne_chip_finish.v
BSG_SDR_NW_V          = out/bsg_manycore_link_wh_to_sdr_nw_chip_finish.v
BSG_SDR_SE_V          = out/bsg_manycore_link_wh_to_sdr_se_chip_finish.v
BSG_SDR_SW_V          = out/bsg_manycore_link_wh_to_sdr_sw_chip_finish.v
BSG_SDR_EAST_V        = out/bsg_manycore_link_ruche_to_sdr_east_chip_finish.v
BSG_SDR_WEST_V        = out/bsg_manycore_link_ruche_to_sdr_west_chip_finish.v
BSG_SDR_NORTH_V       = out/bsg_manycore_link_to_sdr_north_chip_finish.v
BSG_SDR_SOUTH_V       = out/bsg_manycore_link_to_sdr_south_chip_finish.v
#BSG_SDR_NORTH_ROW_V   = out/bsg_manycore_link_to_sdr_north_row_chip_finish.v
#BSG_SDR_SOUTH_ROW_V   = out/bsg_manycore_link_to_sdr_south_row_chip_finish.v

VCS_OPTIONS += +sdfverbose +neg_tchk +overlap +multisource_int_delays +sdfretain
VCS_OPTIONS += -negdelay
VCS_OPTIONS += +optconfigfile+$(CDC_INSTANCE_LIST_V)


MIN_SIMV = $(addprefix out/, $(addsuffix _min/simv, $(SDF_CORNERS)))
MAX_SIMV = $(addprefix out/, $(addsuffix _max/simv, $(SDF_CORNERS)))
MIN_SIMV_DEBUG = $(addprefix out/, $(addsuffix _min/simv-debug, $(SDF_CORNERS)))
MAX_SIMV_DEBUG = $(addprefix out/, $(addsuffix _max/simv-debug, $(SDF_CORNERS)))

$(CDC_INSTANCE_LIST_V):
	mkdir -p out/
	gzip -cd $(BSG_SDR_NE_V_GZ) > $(BSG_SDR_NE_V)
	gzip -cd $(BSG_SDR_NW_V_GZ) > $(BSG_SDR_NW_V)
	gzip -cd $(BSG_SDR_SE_V_GZ) > $(BSG_SDR_SE_V)
	gzip -cd $(BSG_SDR_SW_V_GZ) > $(BSG_SDR_SW_V)
	gzip -cd $(BSG_SDR_EAST_V_GZ) > $(BSG_SDR_EAST_V)
	gzip -cd $(BSG_SDR_WEST_V_GZ) > $(BSG_SDR_WEST_V)
	gzip -cd $(BSG_SDR_NORTH_V_GZ) > $(BSG_SDR_NORTH_V)
	gzip -cd $(BSG_SDR_SOUTH_V_GZ) > $(BSG_SDR_SOUTH_V)
#	gzip -cd $(BSG_SDR_NORTH_ROW_V_GZ) > $(BSG_SDR_NORTH_ROW_V)
#	gzip -cd $(BSG_SDR_SOUTH_ROW_V_GZ) > $(BSG_SDR_SOUTH_ROW_V)
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
	$(foreach path, ${BSG_SDR_NORTH_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_NORTH_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
	$(foreach path, ${BSG_SDR_SOUTH_INSTANCE_PATHS}, \
    python $(EXPAND_VERILOG_PY) $(BSG_SDR_SOUTH_V) \
      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
#	$(foreach path, ${BSG_SDR_NORTH_ROW_INSTANCE_PATHS}, \
#    python $(EXPAND_VERILOG_PY) $(BSG_SDR_NORTH_ROW_V) \
#      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)
#	$(foreach path, ${BSG_SDR_SOUTH_ROW_INSTANCE_PATHS}, \
#    python $(EXPAND_VERILOG_PY) $(BSG_SDR_SOUTH_ROW_V) \
#      | grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)

# To build simv for all 32 corners, "make build -j32"
.PRECIOUS: $(MIN_SIMV) $(MAX_SIMV) $(MIN_SIMV_DEBUG) $(MAX_SIMV_DEBUG)
build:       $(MIN_SIMV) $(MAX_SIMV)
build-debug: $(MIN_SIMV_DEBUG) $(MAX_SIMV_DEBUG)

SDF_PATH = $(TOP_DIR)/bigblade_pod_row/bsg_14/current_build/ptsi_xray/bsg_manycore_pod_row_sdr

out/%_min/simv: $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(CDC_INSTANCE_LIST_V) ${IP_ROOT_DIRS} $(BSG_OUT_DIR)/bsg_bladerunner_pkg.v
	mkdir -p out/$*_min/
	$(VCS) $(VCS_OPTIONS) -o $@ -Mdir=out/$*_min/csrc   \
    -sdf min:$(POD_ROW_INSTANCE_PATH):out/$(SDF_PATH)/$*/results/bsg_manycore_pod_row_sdr.sdf.gz \
    -l out/$*_min/vcs.log

out/%_min/simv-debug: $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(CDC_INSTANCE_LIST_V) ${IP_ROOT_DIRS} $(BSG_OUT_DIR)/bsg_bladerunner_pkg.v
	mkdir -p out/$*_min/
	$(VCS) $(VCS_OPTIONS) -o $@ -Mdir=out/$*_min/csrc-debug   \
    -sdf min:$(POD_ROW_INSTANCE_PATH):out/$(SDF_PATH)/$*/results/bsg_manycore_pod_row_sdr.sdf.gz \
    -debug_pp +vcs+vcdpluson \
    -l out/$*_min/vcs-debug.log

out/%_max/simv: $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(CDC_INSTANCE_LIST_V) ${IP_ROOT_DIRS} $(BSG_OUT_DIR)/bsg_bladerunner_pkg.v
	mkdir -p out/$*_max/
	$(VCS) $(VCS_OPTIONS) -o $@ -Mdir=out/$*_max/csrc   \
    -sdf max:$(POD_ROW_INSTANCE_PATH):out/$(SDF_PATH)/$*/results/bsg_manycore_pod_row_sdr.sdf.gz \
    -l out/$*_max/vcs.log


out/%_max/simv-debug: $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(CDC_INSTANCE_LIST_V) ${IP_ROOT_DIRS} $(BSG_OUT_DIR)/bsg_bladerunner_pkg.v
	mkdir -p out/$*_max/
	$(VCS) $(VCS_OPTIONS) -o $@ -Mdir=out/$*_max/csrc-debug   \
    -sdf max:$(POD_ROW_INSTANCE_PATH):out/$(SDF_PATH)/$*/results/bsg_manycore_pod_row_sdr.sdf.gz \
    -debug_pp +vcs+vcdpluson \
    -l out/$*_max/vcs-debug.log


# RUN COMMANDS
SPMD ?= finish_asm
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



#########################################
#build: $(BSG_SPMD_SIM) $(BSG_CUDA_SIM)
#debug: $(BSG_CUDA_DBG)
#$(BSG_SPMD_SIM): VCS_OPTIONS += -Mdir=$(BSG_OUT_DIR)/spmd
#$(BSG_SPMD_SIM): $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(IP_ROOT_DIRS) $(BSG_OUT_DIR)/bsg_bladerunner_pkg.v
#	$(VCS) $(VCS_OPTIONS) -o $@ | tee -i $(BSG_OUT_DIR)/build.log

#$(BSG_CUDA_SIM): VCS_OPTIONS += -Mdir=$(BSG_CUDA_PATH)/exec
#$(BSG_CUDA_DBG): VCS_OPTIONS += -Mdir=$(BSG_CUDA_PATH)/debug

#$(BSG_CUDA_DBG): VCS_OPTIONS += -debug_pp +vcs+vcdpluson

#$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += -LDFLAGS -L$(BSG_F1_DIR)/libraries/platforms/tapeout-vcs
#$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += -LDFLAGS -Wl,-rpath=$(BSG_F1_DIR)/libraries/platforms/tapeout-vcs
#$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += -LDFLAGS -lbsg_manycore_regression
#$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += -LDFLAGS -lbsg_manycore_runtime
#$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += -LDFLAGS -lm
#$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += +define+REPLICANT=1
#
#$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(BSG_BLADERUNNER_GENERATED) $(IP_ROOT_DIRS) | $(BSG_CUDA_PATH)
#	$(VCS) $(VCS_OPTIONS) -o $@ | tee -i $(BSG_OUT_DIR)/build.log

$(BSG_OUT_DIR)/root: | $(BSG_OUT_DIR)
	ln -nsf $(ROOT_DIR) $@

$(BSG_OUT_DIR)/Makefile.machine.include: $(BSG_WORK_DIR)/../machine/Makefile.machine.include | $(BSG_OUT_DIR)
	@cp $(BSG_WORK_DIR)/../machine/Makefile.machine.include $(BSG_OUT_DIR)

$(BSG_OUT_DIR) $(BSG_CUDA_PATH):
	@mkdir -p $@

BSG_MACHINE_PATH := $(BSG_OUT_DIR)
$(BSG_BLADERUNNER_GENERATED): $(BSG_OUT_DIR)/Makefile.machine.include
	$(MAKE) -f bladerunner.mk $@ BSG_MACHINE_PATH=$(BSG_OUT_DIR)

clean:
	$(MAKE) -f bladerunner.mk libraries.clean BSG_MACHINE_PATH=$(BSG_WORK_DIR)/../machine/
	rm -rf $(BSG_OUT_DIR)
	rm -rf DVEfiles
	rm -rf stack.info.*
	rm -f  vc_hdrs.h
	rm -f  vcdplus.vpd
	rm -f  inter.vpd
	rm -f  ucli.key
