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
export BSG_PACKAGING_FOUNDRY ?=portable
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
VCS_OPTIONS += +define+den2048Mb+sg5+x16+FULL_MEM

########################################
## Chip and Testing Filelists and Liblists
########################################

BSG_TOP_SIM_MODULE = bsg_bigblade_pcb
BSG_CHIP_INSTANCE_PATH = $(BSG_TOP_SIM_MODULE).IC.ASIC

# $1 = pod_x
# $2 = pod_y
# $3 = tile_x
# $4 = tile_y
BSG_TILE_INSTANCE_PATH = $(BSG_TOP_SIM_MODULE).IC.ASIC.block.core_complex.core[$2].podrow.podrow.px[$1].pod.mc_y[$(shell echo $4/2 | bc)].mc_x[0].mc.y_$(shell echo $4 % 2 | bc)__x_$3__tile
# change these to select which tile in which pod is swapped with its synthesized netlist
BSG_TILE_X ?= 0
BSG_TILE_Y ?= 0
BSG_POD_X  ?= 0
BSG_POD_Y  ?= 0

# $1 = pod_x
# $2 = pod_y
# $3 = subarray_x
# $4 = subarray_y
BSG_SUBARRAY_INSTANCE_PATH = $(BSG_TOP_SIM_MODULE).IC.ASIC.block.core_complex.core[$2].podrow.podrow.px[$1].pod.mc_y[$3].mc_x[0].mc

# change these to select first subarray in which pod is swapped with its synthesized netlist
BSG_SUBARRAY_Y ?= 0
BSG_SUBARRAY_POD_X      ?= 0
BSG_SUBARRAY_POD_Y      ?= 0

VCS_OPTIONS += +define+BSG_TOP_SIM_MODULE=$(BSG_TOP_SIM_MODULE)
VCS_OPTIONS += +define+BSG_CHIP_INSTANCE_PATH=$(BSG_CHIP_INSTANCE_PATH)
VCS_OPTIONS += +define+BSG_TILE_PATH=$(call BSG_TILE_INSTANCE_PATH,$(BSG_POD_X),$(BSG_POD_Y),$(BSG_TILE_X),$(BSG_TILE_Y))
VCS_OPTIONS += +define+BSG_SUBARRAY_PATH=$(call BSG_SUBARRAY_INSTANCE_PATH,$(BSG_SUBARRAY_POD_X),$(BSG_SUBARRAY_POD_Y),$(BSG_SUBARRAY_Y))

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

###################################
# BSG manycore tile compute array #
###################################
export BSG_MANYCORE_TILE_COMPUTE_ARRAY_LIBRARY_NAME = bsg_manycore_tile_compute_array_ruche
export BSG_MANYCORE_TILE_COMPUTE_ARRAY_FILELIST = $(BSG_OUT_DIR)/$(BSG_MANYCORE_TILE_COMPUTE_ARRAY_LIBRARY_NAME).filelist
export BSG_MANYCORE_TILE_COMPUTE_ARRAY_LIBRARY  = $(BSG_OUT_DIR)/$(BSG_MANYCORE_TILE_COMPUTE_ARRAY_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_MANYCORE_TILE_COMPUTE_ARRAY_LIBRARY_NAME=$(BSG_MANYCORE_TILE_COMPUTE_ARRAY_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_MANYCORE_TILE_COMPUTE_ARRAY_FILELIST)
VCS_OPTIONS += -libmap $(BSG_MANYCORE_TILE_COMPUTE_ARRAY_LIBRARY)

# range function
range  = $(shell echo {0..$(shell echo $1-1|bc)})
window = $(shell echo {$1..$(shell echo $2-1|bc)})

# call this function to set the parameters for a tile
define tile_set_parameters
$(eval include $(BSG_DESIGNS_TARGET_DIR)/testing/machine/Makefile.machine.include)
$(eval POD_X_CORD_WIDTH=$(echo $(BSG_MACHINE_X_CORD_WIDTH)-$(BSG_MACHINE_X_CORD_WIDTH)|bc))
$(eval POD_Y_CORD_WIDTH=$(echo $(BSG_MACHINE_Y_CORD_WIDTH)-$(BSG_MACHINE_Y_CORD_WIDTH)|bc))
$(eval POD_X=$1)
$(eval POD_Y=$2)
$(eval TILE_X=$3)
$(eval TILE_Y=$4)
$(eval TILE_PATH=$(call BSG_TILE_INSTANCE_PATH,$(POD_X),$(POD_Y),$(TILE_X),$(TILE_Y)))
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).dmem_size_p=1024)
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).vcache_size_p=$(echo $(BSG_MACHINE_VCACHE_WAY)*$(BSG_MACHINE_VCACHE_SET)*$(BSG_MACHINE_VCACHE_LINE_WORDS)))
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).icache_entries_p=1024)
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).icache_tag_width_p=12)
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).x_cord_width_p=7)
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).y_cord_width_p=7)
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).pod_x_cord_width_p=3)
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).pod_y_cord_width_p=4)
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).num_tiles_x_p=$(BSG_MACHINE_POD_TILES_X))
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).num_tiles_y_p=$(BSG_MACHINE_POD_TILES_Y))
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).data_width_p=$(BSG_MACHINE_DATA_WIDTH))
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).addr_width_p=$(BSG_MACHINE_MAX_EPA_WIDTH))
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).num_vcache_rows_p=1)
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).vcache_block_size_in_words_p=$(BSG_MACHINE_VCACHE_LINE_WORDS))
$(eval VCS_PVALUES += -pvalue+$(TILE_PATH).vcache_sets_p=$(BSG_MACHINE_VCACHE_SET))
endef

# set parameters foreach tile
define tiles_set_parameters
$(eval include $(BSG_DESIGNS_TARGET_DIR)/testing/machine/Makefile.machine.include)
$(foreach tx,$(call range,16),\
$(foreach ty,$(call window,$(shell echo "2*$(BSG_SUBARRAY_Y)"|bc),$(shell echo "2*($(BSG_SUBARRAY_Y)+1)"|bc)),\
$(eval $(call tile_set_parameters,$(BSG_SUBARRAY_POD_X),$(BSG_SUBARRAY_POD_Y),$(tx),$(ty)))))
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
OVERRIDE_PODS_Y ?= 4

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
IP_BLOCKS += bsg_tiehilo

IP_ROOT_DIRS = $(foreach block,$(IP_BLOCKS),$(BSG_OUT_DIR)/$(block))
$(IP_ROOT_DIRS): | $(BSG_OUT_DIR)
	ln -s $(BSG_DESIGNS_DIR) $@

$(eval $(call tiles_set_parameters))


VCS_OPTIONS += $(VCS_PVALUES)
VCS_OPTIONS += -parameters $(BSG_OUT_DIR)/../parameters.txt

build: $(BSG_SPMD_SIM) $(BSG_CUDA_SIM)
debug: $(BSG_CUDA_DBG)
$(BSG_SPMD_SIM): VCS_OPTIONS += -Mdir=$(BSG_OUT_DIR)/spmd
$(BSG_SPMD_SIM): $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(IP_ROOT_DIRS) $(BSG_OUT_DIR)/bsg_bladerunner_pkg.v
	$(VCS) $(VCS_OPTIONS) -o $@ | tee -i $(BSG_OUT_DIR)/build.log

$(BSG_CUDA_SIM): VCS_OPTIONS += -Mdir=$(BSG_CUDA_PATH)/exec
$(BSG_CUDA_DBG): VCS_OPTIONS += -Mdir=$(BSG_CUDA_PATH)/debug

$(BSG_CUDA_DBG): VCS_OPTIONS += -debug_pp +vcs+vcdpluson

$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += -LDFLAGS -L$(BSG_F1_DIR)/libraries/platforms/tapeout-vcs
$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += -LDFLAGS -Wl,-rpath=$(BSG_F1_DIR)/libraries/platforms/tapeout-vcs
$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += -LDFLAGS -lbsg_manycore_regression
$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += -LDFLAGS -lbsg_manycore_runtime
$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += -LDFLAGS -lm
$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): VCS_OPTIONS += +define+REPLICANT=1

$(BSG_CUDA_DBG) $(BSG_CUDA_SIM): $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) $(BSG_BLADERUNNER_GENERATED) $(IP_ROOT_DIRS) | $(BSG_CUDA_PATH)
	echo $(VCS_OPTIONS) > $(BSG_OUT_DIR)/vcs_options.log
	echo $(VCS_PVALUES) > $(BSG_OUT_DIR)/vcs_pvalues.log
	$(VCS) $(VCS_OPTIONS) -o $@ | tee -i $(BSG_OUT_DIR)/build.log

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
