.DEFAULT_GOAL=spmd

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

# SDF_CORNERS += sspg_0p72v_125c_sigcmax
# SDF_CORNERS += sspg_0p72v_125c_sigcmin
SDF_CORNERS += sspg_0p72v_125c_sigrcmax
# SDF_CORNERS += sspg_0p72v_125c_sigrcmin
# SDF_CORNERS += sspg_0p72v_m40c_sigcmax
# SDF_CORNERS += sspg_0p72v_m40c_sigcmin
# SDF_CORNERS += sspg_0p72v_m40c_sigrcmin
# SDF_CORNERS += sspg_0p72v_m40c_sigrcmax
SDF_CORNERS += ffpg_0p88v_125c_sigcmax
# SDF_CORNERS += ffpg_0p88v_125c_sigcmin
SDF_CORNERS += ffpg_0p88v_125c_sigrcmax
# SDF_CORNERS += ffpg_0p88v_125c_sigrcmin
# SDF_CORNERS += ffpg_0p88v_m40c_sigrcmax
# SDF_CORNERS += ffpg_0p88v_m40c_sigrcmin
# SDF_CORNERS += ffpg_0p88v_m40c_sigcmax
# SDF_CORNERS += ffpg_0p88v_m40c_sigcmin
# SDF_CORNERS += tt_0p80v_25c_nominal

BSG_WORK_DIR := $(abspath ./)
BSG_OUT_DIR  := $(BSG_WORK_DIR)/out

BSG_SPMD_MIN_SIMS = $(addprefix out/, $(addsuffix _min/simv, $(SDF_CORNERS)))
BSG_SPMD_MAX_SIMS = $(addprefix out/, $(addsuffix _max/simv, $(SDF_CORNERS)))
BSG_SPMD_MIN_SIMS_DEBUG = $(addprefix out/, $(addsuffix _min/simv-debug, $(SDF_CORNERS)))
BSG_SPMD_MAX_SIMS_DEBUG = $(addprefix out/, $(addsuffix _max/simv-debug, $(SDF_CORNERS)))
BSG_SPMD_SIMS := $(BSG_SPMD_MIN_SIMS_DEBUG)
BSG_SPMD_SIMS += $(BSG_SPMD_MAX_SIMS_DEBUG)
BSG_SPMD_SIMS += $(BSG_SPMD_MIN_SIMS)
BSG_SPMD_SIMS += $(BSG_SPMD_MAX_SIMS)

BSG_CUDA_MIN_SIMS = $(addprefix out/, $(addsuffix _min/cuda/simv, $(SDF_CORNERS)))
BSG_CUDA_MAX_SIMS = $(addprefix out/, $(addsuffix _max/cuda/simv, $(SDF_CORNERS)))
BSG_CUDA_MIN_SIMS_DEBUG = $(addprefix out/, $(addsuffix _min/cuda/simv-debug, $(SDF_CORNERS)))
BSG_CUDA_MAX_SIMS_DEBUG = $(addprefix out/, $(addsuffix _max/cuda/simv-debug, $(SDF_CORNERS)))
BSG_CUDA_SIMS += $(BSG_CUDA_MIN_SIMS)
BSG_CUDA_SIMS += $(BSG_CUDA_MAX_SIMS)
BSG_CUDA_SIMS += $(BSG_CUDA_MIN_SIMS_DEBUG)
BSG_CUDA_SIMS += $(BSG_CUDA_MAX_SIMS_DEBUG)

BSG_SPMD_MACHINES := $(foreach simv,$(BSG_SPMD_SIMS),$(dir $(simv))/Makefile.machine.include)
BSG_CUDA_MACHINES := $(foreach simv,$(BSG_CUDA_SIMS),$(dir $(simv))/Makefile.machine.include)
BSG_MACHINES := $(BSG_SPMD_MACHINES) $(BSG_CUDA_MACHINES) $(BSG_OUT_DIR)/Makefile.machine.include

# sdf path
SDF_PATH = /nbu/spin/share/gf14/bigblade_toplevel/rc-0-final

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
export BLACKPARROT_DIR        ?= $(BSG_DESIGNS_TARGET_DIR)/black-parrot
export CGRA_DIR               ?= $(BSG_DESIGNS_TARGET_DIR)/cgra
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
VCS_OPTIONS += -diag=sdf
VCS_OPTIONS += -top bsg_config bsg_config.v
VCS_OPTIONS += -licqueue
VCS_OPTIONS += +lint=all,noSVA-UA,noSVA-NSVU,noVCDE,noNS
VCS_OPTIONS += +define+den2048Mb+sg5+x16+FULL_MEM
VCS_OPTIONS += +warn=all,noOPD,noTMR,noTFIPC,noIWNF

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

########################################
# BSG Tie HI/LO filelists and liblists #
########################################
export BSG_TIEHILO_LIBRARY_NAME = bsg_tiehilo
export BSG_TIEHILO_FILELIST = $(BSG_OUT_DIR)/$(BSG_TIEHILO_LIBRARY_NAME).filelist
export BSG_TIEHILO_LIBRARY = $(BSG_OUT_DIR)/$(BSG_TIEHILO_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_TIEHILO_LIBRARY_NAME=$(BSG_TIEHILO_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_TIEHILO_FILELIST)
VCS_OPTIONS += -libmap $(BSG_TIEHILO_LIBRARY)

##################################################
# Bigblade Toplevel Block filelists and liblists #
#################################################
export BIGBLADE_TOPLEVEL_BLOCK_LIBRARY_NAME = bigblade_toplevel_block
export BIGBLADE_TOPLEVEL_BLOCK_FILELIST = $(BSG_OUT_DIR)/$(BIGBLADE_TOPLEVEL_BLOCK_LIBRARY_NAME).filelist
export BIGBLADE_TOPLEVEL_BLOCK_LIBRARY = $(BSG_OUT_DIR)/$(BIGBLADE_TOPLEVEL_BLOCK_LIBRARY_NAME).library

VCS_OPTIONS += +define+BIGBLADE_TOPLEVEL_BLOCK_LIBRARY_NAME=$(BIGBLADE_TOPLEVEL_BLOCK_LIBRARY_NAME)
VCS_OPTIONS += -f $(BIGBLADE_TOPLEVEL_BLOCK_FILELIST)
VCS_OPTIONS += -libmap $(BIGBLADE_TOPLEVEL_BLOCK_LIBRARY)

##################################################
# Bigblade Toplevel filelists and liblists #
#################################################
export BIGBLADE_TOPLEVEL_LIBRARY_NAME = bigblade_toplevel
export BIGBLADE_TOPLEVEL_FILELIST = $(BSG_OUT_DIR)/$(BIGBLADE_TOPLEVEL_LIBRARY_NAME).filelist
export BIGBLADE_TOPLEVEL_LIBRARY = $(BSG_OUT_DIR)/$(BIGBLADE_TOPLEVEL_LIBRARY_NAME).library

VCS_OPTIONS += +define+BIGBLADE_TOPLEVEL_LIBRARY_NAME=$(BIGBLADE_TOPLEVEL_LIBRARY_NAME)
VCS_OPTIONS += -f $(BIGBLADE_TOPLEVEL_FILELIST)
VCS_OPTIONS += -libmap $(BIGBLADE_TOPLEVEL_LIBRARY)

#################################################
# BlackParrot filelists and liblists #
#################################################
export BIGBLADE_BP_UNICORE_LIBRARY_NAME = bigblade_bp_unicore
export BIGBLADE_BP_UNICORE_FILELIST = $(BSG_OUT_DIR)/$(BIGBLADE_BP_UNICORE_LIBRARY_NAME).filelist
export BIGBLADE_BP_UNICORE_LIBRARY = $(BSG_OUT_DIR)/$(BIGBLADE_BP_UNICORE_LIBRARY_NAME).library

VCS_OPTIONS += +define+BIGBLADE_BP_UNICORE_LIBRARY_NAME=$(BIGBLADE_BP_UNICORE_LIBRARY_NAME)
VCS_OPTIONS += -f $(BIGBLADE_BP_UNICORE_FILELIST)
VCS_OPTIONS += -libmap $(BIGBLADE_BP_UNICORE_LIBRARY)

###############################
# CGRA filelists and liblists #
###############################
export BRG_CGRA_HPOD_LIBRARY_NAME = brg_cgra_hpod
export BRG_CGRA_HPOD_FILELIST = $(BSG_OUT_DIR)/$(BRG_CGRA_HPOD_LIBRARY_NAME).filelist
export BRG_CGRA_HPOD_LIBRARY = $(BSG_OUT_DIR)/$(BRG_CGRA_HPOD_LIBRARY_NAME).library

VCS_OPTIONS += +define+BRG_CGRA_HPOD_LIBRARY_NAME=$(BRG_CGRA_HPOD_LIBRARY_NAME)
VCS_OPTIONS += -f $(BRG_CGRA_HPOD_FILELIST)
VCS_OPTIONS += -libmap $(BRG_CGRA_HPOD_LIBRARY)

##############################################
# Specify which modules to swap for netlists #
##############################################
range  = $(shell echo {0..$(shell echo $1-1|bc)})
window = $(shell echo {$1..$(shell echo $2-1|bc)})

# To create swaplist.vh, we create a huge string with all of the instances to swap.
SWAPSTRING=

# $1 = root path
# $2 = tile_y
# $3 = tile_x
BSG_TILE_INSTANCE_PATH_SUB = $1.y_$2__x_$3__tile
define swap_tile
$(eval SWAPSTRING += instance $(call BSG_TILE_INSTANCE_PATH_SUB,$1,$2,$3) liblist `BSG_MANYCORE_TILE_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;)
endef

# $1 = root path
# $2 = array y
# $3 = array x
BSG_SUBARRAY_INSTANCE_PATH_SUB = $1.mc_y_$2__mc_x_$3__mc
define swap_array_tile
$(eval ARRAY_TILE_CUR_ROOT=$(call BSG_SUBARRAY_INSTANCE_PATH_SUB,$1,$2,$3))
$(eval SWAPSTRING += instance $(ARRAY_TILE_CUR_ROOT) liblist `BSG_MANYCORE_TILE_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;)
$(eval SWAPSTRING += $(foreach ty,$(call range,2),\
		       $(foreach tx,$(call range,16),\
			 instance $(call BSG_TILE_INSTANCE_PATH_SUB,$(ARRAY_TILE_CUR_ROOT),$(ty),$(tx)) liblist `BSG_MANYCORE_TILE_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;)))
endef

# $1 = root path
# $2 = cache_x
BSG_CACHE_INSTANCE_PATH_SUB = $1.vc_y_0__vc_x_$2__vc
define swap_cache
$(eval SWAPSTRING += instance $(call BSG_CACHE_INSTANCE_PATH_SUB,$1,$2) liblist `BSG_MANYCORE_TILE_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;)
endef

# $1 = root path
# $2 = north/south
BSG_CACHE_ARRAY_INSTANCE_PATH_SUB = $1.$2_vc_x_0__$2_vc_row
define swap_array_cache
$(eval ARRAY_CACHE_CUR_ROOT=$(call BSG_CACHE_ARRAY_INSTANCE_PATH_SUB,$1,$2))
$(eval SWAPSTRING += instance $(ARRAY_CACHE_CUR_ROOT) liblist `BSG_MANYCORE_TILE_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;)
$(eval SWAPSTRING += $(foreach tx,$(call range,16),\
	               instance $(call BSG_CACHE_INSTANCE_PATH_SUB,$(ARRAY_CACHE_CUR_ROOT),$(tx)) liblist `BSG_MANYCORE_TILE_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;))
endef

# $1 = root path
# $2 = pod_x
#$(eval SWAPSTRING += instance $(POD_CUR_ROOT) liblist `BSG_MANYCORE_TILE_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;)
BSG_POD_INSTANCE_PATH_SUB = $1.px_$2__pod
define swap_pod
$(eval POD_CUR_ROOT=$(call BSG_POD_INSTANCE_PATH_SUB,$1,$2))
$(eval $(call swap_array_cache,$(POD_CUR_ROOT),north))
$(eval $(foreach ay,$(call range,4),$(call swap_array_tile,$(POD_CUR_ROOT),$(ay),0)))
$(eval $(call swap_array_cache,$(POD_CUR_ROOT),south))
endef

# $1 = root path
# $2 = row
BSG_POD_ROW_INSTANCE_PATH_SUB = $1.core_complex_core_$2__podrow
BSG_CLK_GEN_INSTANCE_PATH_SUB = $1.core_complex_core_$2__clk_gen
define swap_pod_row
$(eval POD_ROW_CUR_ROOT=$(call BSG_POD_ROW_INSTANCE_PATH_SUB,$1,$2))
$(eval SWAPSTRING += instance $(POD_ROW_CUR_ROOT) liblist `BSG_MANYCORE_LINK_SDR_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;)
$(eval $(foreach pod,$(call range,4),$(call swap_pod,$(POD_ROW_CUR_ROOT).podrow,$(pod),0)))
endef

# $1 pod row
BSG_MEM_LINK_EAST_INDEX_FROM_ROW =$(shell echo $1+4 | bc)

# $1 = root path
# $2 = row
BSG_MEM_LINK_WEST_INSTANCE_PATH_SUB = $1.mem_link_$2__link
BSG_MEM_LINK_EAST_INSTANCE_PATH_SUB = $1.mem_link_$(call BSG_MEM_LINK_EAST_INDEX_FROM_ROW,$2)__link

# $1 = root path
BSG_NOC_IO_INSTANCE_PATH_SUB = $1.io_link

# $1 = root path
# $2 = row
# $3 = core
BSG_BP_UNICORE_INSTANCE_PATH = $1.core_complex_core_$2__bp_$3__halfpod
BSG_BP_UNICORE_CLK_GEN_INSTANCE_PATH = $1.core_complex_core_$2__bp_$3__clk_gen

# $1 = root path
# $2 = row
# $3 = core
BRG_CGRA_INSTANCE_PATH = $1.core_complex_core_$2__cgra_$3__halfpod
BRG_CGRA_CLK_GEN_INSTANCE_PATH = $1.core_complex_core_$2__cgra_$3__clk_gen

# Swap podrows
POD_ROWS := 0
PODS_X := $(call range, 4)
TILES_Y := $(call range, 8)
TILES_X := $(call range, 16)

BSG_CHIP_BLOCK_INSTANCE_PATH=$(BSG_CHIP_INSTANCE_PATH).block
$(eval $(foreach r,$(POD_ROWS),$(call swap_pod_row,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$r)))

swaplist.vh:
	@echo '$(SWAPSTRING)' | sed 's/; */&\n/g' > $@

###########################
# Set up CDC timing rules #
###########################

EXPAND_VERILOG_PY = $(TOP_DIR)/util/expand_verilog_hierarchy.py
CDC_INSTANCE_LIST_V = $(BSG_OUT_DIR)/cdc_instance_list.v
VCS_OPTIONS += +optconfigfile+$(CDC_INSTANCE_LIST_V)

BSG_SDR_NE_V          = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_wh_to_sdr_ne/bsg_manycore_link_wh_to_sdr_ne_chip_finish.v
BSG_SDR_NW_V          = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_wh_to_sdr_nw/bsg_manycore_link_wh_to_sdr_nw_chip_finish.v
BSG_SDR_SE_V          = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_wh_to_sdr_se/bsg_manycore_link_wh_to_sdr_se_chip_finish.v
BSG_SDR_SW_V          = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_wh_to_sdr_sw/bsg_manycore_link_wh_to_sdr_sw_chip_finish.v
BSG_SDR_EAST_V        = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_ruche_to_sdr_east/bsg_manycore_link_ruche_to_sdr_east_chip_finish.v
BSG_SDR_WEST_V        = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_ruche_to_sdr_west/bsg_manycore_link_ruche_to_sdr_west_chip_finish.v
BSG_SDR_NORTH_V       = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_to_sdr_north/bsg_manycore_link_to_sdr_north_chip_finish.v
BSG_SDR_SOUTH_V       = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_to_sdr_south/bsg_manycore_link_to_sdr_south_chip_finish.v
BSG_SDR_NORTH_ROW_V   = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_to_sdr_north_row/bsg_manycore_link_to_sdr_north_row_chip_finish.v
BSG_SDR_SOUTH_ROW_V   = $(HB_BIGBLADE_NETLISTS_DIR)/rc-alpha-rtlfreeze-3/post-apr/bsg_manycore_link_to_sdr_south_row/bsg_manycore_link_to_sdr_south_row_chip_finish.v

BRG_CGRA_V = $(HB_BIGBLADE_NETLISTS_DIR)/rc-0-0/post-apr/bigblade_brg_cgra_xcel/brg_cgra_pod_chip_finish.v

POD_ROW_INSTANCE_PATHS :=$(foreach r, $(POD_ROWS),$(call BSG_POD_ROW_INSTANCE_PATH_SUB,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$r))

BSG_SDR_NE_INSTANCE_PATHS := $(foreach PRIP, $(POD_ROW_INSTANCE_PATHS),$(PRIP).sdr_ne)
BSG_SDR_NW_INSTANCE_PATHS := $(foreach PRIP, $(POD_ROW_INSTANCE_PATHS),$(PRIP).sdr_nw)
BSG_SDR_SE_INSTANCE_PATHS := $(foreach PRIP, $(POD_ROW_INSTANCE_PATHS),$(PRIP).sdr_se)
BSG_SDR_SW_INSTANCE_PATHS := $(foreach PRIP, $(POD_ROW_INSTANCE_PATHS),$(PRIP).sdr_sw)

BSG_SDR_WEST_INSTANCE_PATHS := $(foreach PRIP, $(POD_ROW_INSTANCE_PATHS),$(foreach TY, $(TILES_Y),$(PRIP).sdr_w_y_${TY}__sdr_w))
BSG_SDR_EAST_INSTANCE_PATHS := $(foreach PRIP, $(POD_ROW_INSTANCE_PATHS),$(foreach TY, $(TILES_Y),$(PRIP).sdr_e_y_${TY}__sdr_e))

BRG_CGRA_INSTANCE_PATHS := $(foreach ROW,$(call range,4),$(call BRG_CGRA_INSTANCE_PATH,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$(ROW),0))
BRG_CGRA_INSTANCE_PATHS += $(foreach ROW,$(call range,4),$(call BRG_CGRA_INSTANCE_PATH,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$(ROW),1))

# $1 root
# $2 n/s
# $3 pod_x
BSG_POD_SDR_ROW_INSTANCE_PATH_SUB = $1.sdr_$2_x_$3__sdr_$2

# $1 root
# $2 tile_x
# NB: sdr_n is correct here. The south SDR links were misnamed
BSG_SDR_INSTANCE_PATH_SUB = $1.sdr_x_$2__sdr_n
BSG_SDR_NORTH_INSTANCE_PATHS :=$(foreach PRIP, $(POD_ROW_INSTANCE_PATHS),\
                                 $(foreach PX, $(PODS_X),\
                                   $(foreach TX, $(TILES_X),\
                                     $(call BSG_SDR_INSTANCE_PATH_SUB,\
                                       $(call BSG_POD_SDR_ROW_INSTANCE_PATH_SUB,$(PRIP),n,$(PX)),$(TX)))))

BSG_SDR_SOUTH_INSTANCE_PATHS :=$(foreach PRIP, $(POD_ROW_INSTANCE_PATHS),\
                                 $(foreach PX, $(PODS_X),\
                                   $(foreach TX, $(TILES_X),\
                                     $(call BSG_SDR_INSTANCE_PATH_SUB,\
                                       $(call BSG_POD_SDR_ROW_INSTANCE_PATH_SUB,$(PRIP),s,$(PX)),$(TX)))))

BSG_SDR_NORTH_ROW_INSTANCE_PATHS := $(foreach PRIP, $(POD_ROW_INSTANCE_PATHS),\
                                      $(foreach PX, $(PODS_X),\
                                        $(call BSG_POD_SDR_ROW_INSTANCE_PATH_SUB,$(PRIP),n,$(PX))))
BSG_SDR_SOUTH_ROW_INSTANCE_PATHS := $(foreach PRIP, $(POD_ROW_INSTANCE_PATHS),\
                                      $(foreach PX, $(PODS_X),\
                                        $(call BSG_POD_SDR_ROW_INSTANCE_PATH_SUB,$(PRIP),s,$(PX))))

# Create giant config file... I don't doubt there is a better way to
# handle this, but time is a critical factor here. The challenge seems
# to be linking the variable name above (BSG_SDR_NORTH_INSTANCE_PATHS,
# etc)
$(CDC_INSTANCE_LIST_V): $(BSG_OUT_DIR)
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

	$(foreach path, ${BSG_SDR_NORTH_ROW_INSTANCE_PATHS}, \
		python $(EXPAND_VERILOG_PY) $(BSG_SDR_NORTH_ROW_V) \
			| grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)

	$(foreach path, ${BSG_SDR_SOUTH_ROW_INSTANCE_PATHS}, \
		python $(EXPAND_VERILOG_PY) $(BSG_SDR_SOUTH_ROW_V) \
			| grep "_hard_sync_int" | awk '{ print "instance { $(path)." $$$$2 " } { noTiming };" }' | sort >> $@;)

	$(foreach path, ${BRG_CGRA_INSTANCE_PATHS}, \
		python $(EXPAND_VERILOG_PY) $(BRG_CGRA_V) \
			| grep "bsg_SYNC_1_r_reg" | awk '{print "instance { $(path)." $$$$1 " } { noTiming };" }' | sort >> $@;)

#########################
# Set up SDF annotation #
#########################

VCS_OPTIONS += +warn=noSDFCOM_SWC,noSDFCOM_ANICD,noSDFCOM_IWSBA,noSDFCOM_NICD,noSDFCOM_INF
VCS_OPTIONS += +sdfverbose +neg_tchk +overlap +multisource_int_delays -sdfretain
VCS_OPTIONS += -negdelay

# $1 pod row
# $2 corner
# $3 min/max
define pod_row_add_sdf_options
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BSG_POD_ROW_INSTANCE_PATH_SUB,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1):$(SDF_PATH)/$2/bsg_chip_podrow_$1.sdf.gz)
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BSG_CLK_GEN_INSTANCE_PATH_SUB,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1):$(SDF_PATH)/$2/bsg_chip_clk_gen_$1.sdf.gz)
endef

# $1 pod row
# $2 corner
# $3 min/max
define noc_mem_row_add_sdf_options
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BSG_MEM_LINK_WEST_INSTANCE_PATH_SUB,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1):$(SDF_PATH)/$2/bsg_chip_noc_mem_$1.sdf.gz)
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BSG_MEM_LINK_EAST_INSTANCE_PATH_SUB,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1):$(SDF_PATH)/$2/bsg_chip_noc_mem_$(call BSG_MEM_LINK_EAST_INDEX_FROM_ROW,$1).sdf.gz)
endef

# $1 bp row
# $2 corner
# $3 min/max
define bp_row_add_sdf_options
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BSG_BP_UNICORE_INSTANCE_PATH,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1,0):$(SDF_PATH)/$2/bsg_chip_core_$1__bp_0__halfpod.sdf.gz)
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BSG_BP_UNICORE_INSTANCE_PATH,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1,1):$(SDF_PATH)/$2/bsg_chip_core_$1__bp_1__halfpod.sdf.gz)
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BSG_BP_UNICORE_CLK_GEN_INSTANCE_PATH,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1,0):$(SDF_PATH)/$2/bsg_chip_core_$1__bp_0__clk_gen.sdf.gz)
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BSG_BP_UNICORE_CLK_GEN_INSTANCE_PATH,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1,1):$(SDF_PATH)/$2/bsg_chip_core_$1__bp_1__clk_gen.sdf.gz)
endef

define cgra_row_add_sdf_options
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BRG_CGRA_INSTANCE_PATH,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1,0):$(SDF_PATH)/$2/bsg_chip_core_$1__cgra_0__halfpod.sdf.gz)
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BRG_CGRA_INSTANCE_PATH,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1,1):$(SDF_PATH)/$2/bsg_chip_core_$1__cgra_1__halfpod.sdf.gz)
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BRG_CGRA_CLK_GEN_INSTANCE_PATH,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1,0):$(SDF_PATH)/$2/bsg_chip_core_$1__cgra_0__clk_gen.sdf.gz)
$(eval SDF_VCS_OPTIONS += -sdf $3:$(call BRG_CGRA_CLK_GEN_INSTANCE_PATH,$(BSG_CHIP_BLOCK_INSTANCE_PATH),$1,1):$(SDF_PATH)/$2/bsg_chip_core_$1__cgra_1__clk_gen.sdf.gz)
endef

# sets sdf options to SDF_VCS_OPTIONS
# $1 corner
# $2 min/max
define add_sdf_options
$(eval SDF_VCS_OPTIONS = )
# chip block level 1
$(eval SDF_VCS_OPTIONS += -sdf $2:$(BSG_CHIP_INSTANCE_PATH):$(SDF_PATH)/$1/bsg_chip_level_2.sdf.gz)
# chip block noc io
$(eval SDF_VCS_OPTIONS += -sdf $2:$(call BSG_NOC_IO_INSTANCE_PATH_SUB,$(BSG_CHIP_BLOCK_INSTANCE_PATH)):$(SDF_PATH)/$1/bsg_chip_noc_io.sdf.gz)
# each pod to swap
$(eval $(foreach r,$(POD_ROWS),$(call pod_row_add_sdf_options,$r,$1,$2)))
# each row (there are 4)
# noc memories e/w
$(eval $(foreach r,$(call range,4),$(call noc_mem_row_add_sdf_options,$r,$1,$2)))
# bp e/w
$(eval $(foreach r,$(call range,4),$(call bp_row_add_sdf_options,$r,$1,$2)))
# cgra e/w
$(eval $(foreach r,$(call range,4),$(call cgra_row_add_sdf_options,$r,$1,$2)))
endef

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

BSG_TRACE_NAME  := bsg_tag_boot_pods_only
BSG_TRACE_PY    := $(BSG_WORK_DIR)/../py/$(BSG_TRACE_NAME).py
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
OVERRIDE_PODS_Y ?= 4

# Note: Overriding parameters in bsg_chip_pkg.v
VCS_OPTIONS += -pvalue+hb_num_pods_x_gp=$(OVERRIDE_PODS_X)
VCS_OPTIONS += -pvalue+hb_num_pods_y_gp=$(OVERRIDE_PODS_Y)

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
IP_BLOCKS += bsg_tiehilo
IP_BLOCKS += bigblade_toplevel_block
IP_BLOCKS += bigblade_toplevel

IP_ROOT_DIRS = $(foreach block,$(IP_BLOCKS),$(BSG_OUT_DIR)/$(block))
$(IP_ROOT_DIRS): | $(BSG_OUT_DIR)
	ln -s $(BSG_DESIGNS_DIR) $@

spmd:  $(BSG_SPMD_SIMS)
build: $(BSG_SPMD_SIMS) $(BSG_CUDA_SIMS)
debug: $(BSG_CUDA_DBGS)
$(BSG_SPMD_SIMS): $(CDC_INSTANCE_LIST_V) swaplist.vh $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(IP_ROOT_DIRS) $(BSG_MACHINES) $(BSG_OUT_DIR)/bsg_bladerunner_pkg.v
	mkdir -p $(dir $@)
	$(eval EXTRA_VCS_OPTIONS = )
	$(eval DEBUG = $(findstring -debug,$@))
	$(eval EXTRA_VCS_OPTIONS += -Mdir=$(dir $@)/csrc$(DEBUG))
	$(eval MAX = $(subst _,,$(findstring _max,$@)))
	$(eval MIN = $(subst _,,$(findstring _min,$@)))
	$(eval MIN_OR_MAX = $(MIN)$(MAX))
	$(eval CORNER = $(filter $(SDF_CORNERS),$(subst _max,,$(subst _min,,$(subst /, ,$@)))))
	$(eval $(call add_sdf_options,$(CORNER),$(MIN_OR_MAX)))
	$(eval EXTRA_VCS_OPTIONS += $(SDF_VCS_OPTIONS))
	@echo $(VCS_OPTIONS) $(EXTRA_VCS_OPTIONS) > $(dir $@)/vcs_options.log
	$(VCS) $(VCS_OPTIONS) $(EXTRA_VCS_OPTIONS) -o $@ 2>&1 | tee -i $(dir $@)/build$(DEBUG).log

$(BSG_CUDA_DBGS): VCS_OPTIONS += -debug_pp +vcs+vcdpluson
$(BSG_CUDA_DBGS) $(BSG_CUDA_SIMS): VCS_OPTIONS += -LDFLAGS -L$(BSG_F1_DIR)/libraries/platforms/tapeout-vcs
$(BSG_CUDA_DBGS) $(BSG_CUDA_SIMS): VCS_OPTIONS += -LDFLAGS -Wl,-rpath=$(BSG_F1_DIR)/libraries/platforms/tapeout-vcs
$(BSG_CUDA_DBGS) $(BSG_CUDA_SIMS): VCS_OPTIONS += -LDFLAGS -lbsg_manycore_regression
$(BSG_CUDA_DBGS) $(BSG_CUDA_SIMS): VCS_OPTIONS += -LDFLAGS -lbsg_manycore_runtime
$(BSG_CUDA_DBGS) $(BSG_CUDA_SIMS): VCS_OPTIONS += -LDFLAGS -lm
$(BSG_CUDA_DBGS) $(BSG_CUDA_SIMS): VCS_OPTIONS += +define+REPLICANT=1
$(BSG_CUDA_DBGS) $(BSG_CUDA_SIMS): $(CDC_INSTANCE_LIST_V) swaplist.vh $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(BSG_BLADERUNNER_GENERATED) $(IP_ROOT_DIRS) $(BSG_MACHINES)
	mkdir -p $(dir $@)
	$(eval EXTRA_VCS_OPTIONS = )
	$(eval DEBUG = $(findstring -debug,$@))
	$(eval EXTRA_VCS_OPTIONS += -Mdir=$(dir $@)/csrc$(DEBUG))
	$(eval MAX = $(subst _,,$(findstring _max,$@)))
	$(eval MIN = $(subst _,,$(findstring _min,$@)))
	$(eval MIN_OR_MAX = $(MIN)$(MAX))
	$(eval CORNER = $(filter $(SDF_CORNERS),$(subst _max,,$(subst _min,,$(subst /, ,$@)))))
	$(eval $(call add_sdf_options,$(CORNER),$(MIN_OR_MAX)))
	$(eval EXTRA_VCS_OPTIONS += $(SDF_VCS_OPTIONS))
	@echo $(VCS_OPTIONS) $(EXTRA_VCS_OPTIONS) > $(dir $@)/vcs_options.log
	$(VCS) $(VCS_OPTIONS) $(EXTRA_VCS_OPTIONS) -o $@ 2>&1 | tee -i $(dir $@)/build$(DEBUG).log

$(BSG_OUT_DIR)/root: | $(BSG_OUT_DIR)
	ln -nsf $(ROOT_DIR) $@

$(BSG_MACHINES): $(BSG_WORK_DIR)/../machine/Makefile.machine.include | $(BSG_OUT_DIR)
	@mkdir -p $(dir $@)
	@cp $< $@

$(BSG_OUT_DIR):
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
	rm -rf swaplist.vh
	rm -f sdfAnnotateInfo
