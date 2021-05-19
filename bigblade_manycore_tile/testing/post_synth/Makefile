.DEFAULT_GOAL = all

export BSG_MANYCORE_DIR := $(abspath ../../bsg_manycore)
# By convention, basejump_stl is in the same directory as $(BSG_MANYCORE_DIR)
export BASEJUMP_STL_DIR := $(abspath ../../basejump_stl)
export BSG_F1_DIR       := $(abspath ../../bsg_replicant)
export BSG_REPLICANT_DIR := $(BSG_F1_DIR)
export HB_BIGBLADE_DIR := $(abspath ../../../)

# Sets "VCS" variable
include ../../bsg_cadenv/cadenv.mk

hb_bigblade_netlists_dir = $(abspath ../../hb_bigblade_netlists)
include $(hb_bigblade_netlists_dir)/interface.mk

# Include source lists
include arch_filelist.mk
include sim_filelist.mk
#include rtl_filelist.mk

VSOURCES += $(bsg_manycore_tile-post-synth-filelist)
#VSOURCES += $(bigblade_io_link_ddr-post-synth-filelist)
#VSOURCES += $(bigblade_noc_io_link-post-synth-filelist)
#VSOURCES += $(bigblade_noc_mem_link-post-synth-filelist)

VCS_INCLUDES += $(foreach inc,$(VINCLUDES),+incdir+"$(inc)")
VCS_DEFINES  += $(foreach def,$(VDEFINES),+define+"$(def)")
VCS_SOURCES  += $(VHEADERS) $(VSOURCES) 
VCS_FLAGS    += +v2k -sverilog -full64 -timescale=1ps/1ps \
    +lint=all,noSVA-UA,noSVA-NSVU,noVCDE,noNS
VCS_FLAGS    += -licqueue
VCS_FLAGS    += -reportstats +notimingcheck +nospecify
VCS_FLAGS    += -assert svaext  # needed for "assert final"
#VCS_FLAGS    += +vcs+loopreport


.PHONY: clean

###############################################
# Bladerunner generated libraries and sources #
###############################################
BSG_CUDA_OUT_DIR = $(abspath .)/out
BSG_BLADERUNNER_GENERATED_SOURCES   := $(BSG_CUDA_OUT_DIR)/bsg_bladerunner_pkg.v
BSG_BLADERUNNER_GENERATED_SOURCES   += $(BSG_CUDA_OUT_DIR)/bsg_manycore_machine.h
BSG_BLADERUNNER_GENERATED_LIBRARIES := $(BSG_CUDA_OUT_DIR)/libbsg_manycore_runtime.so
BSG_BLADERUNNER_GENERATED_LIBRARIES += $(BSG_CUDA_OUT_DIR)/libbsg_manycore_regression.so
BSG_BLADERUNNER_GENERATED_LIBRARIES += $(BSG_CUDA_OUT_DIR)/libbsgmc_cuda_legacy_pod_repl.so
#BSG_BLADERUNNER_GENERATED_LIBRARIES += $(BSG_CUDA_OUT_DIR)/libdmamem.so
BSG_BLADERUNNER_GENERATED           := $(BSG_BLADERUNNER_GENERATED_SOURCES)
BSG_BLADERUNNER_GENERATED           += $(BSG_BLADERUNNER_GENERATED_LIBRARIES)
BSG_MACHINE_PATH := $(BSG_CUDA_OUT_DIR)

$(BSG_CUDA_OUT_DIR)/Makefile.machine.include: Makefile.machine.include
	mkdir -p $(dir $@)
	cp $< $@

$(BSG_BLADERUNNER_GENERATED): $(BSG_CUDA_OUT_DIR)/Makefile.machine.include
	mkdir -p $(BSG_CUDA_OUT_DIR)
	$(MAKE) -f bladerunner.mk $@ BSG_MACHINE_PATH=$(BSG_CUDA_OUT_DIR)


# set_machine_variables includes the Makefile.machine.include file and sets the
# VCS_DEFINES that define the architecture for a machine. This should be called
# from inside of the rule that builds the machine-specific executable for a
# machine so that the *correct* Makfile.machine.include can be included
# $1 = machine makefile
# $2 = toplevel
define set_machine_variables
	$(eval include $1)
	$(eval VCS_DEFINES := +define+BSG_MACHINE_PODS_X=${BSG_MACHINE_PODS_X})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_PODS_Y=${BSG_MACHINE_PODS_Y})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_ORIGIN_X_CORD=${BSG_MACHINE_ORIGIN_X_CORD})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_ORIGIN_Y_CORD=${BSG_MACHINE_ORIGIN_Y_CORD})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_GLOBAL_X=${BSG_MACHINE_GLOBAL_X})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_GLOBAL_Y=${BSG_MACHINE_GLOBAL_Y})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_HOST_X_CORD=${BSG_MACHINE_HOST_X_CORD})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_HOST_Y_CORD=${BSG_MACHINE_HOST_Y_CORD})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_ORIGIN_Y_CORD=${BSG_MACHINE_ORIGIN_Y_CORD})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_VCACHE_SET=${BSG_MACHINE_VCACHE_SET})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_VCACHE_WAY=${BSG_MACHINE_VCACHE_WAY})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_VCACHE_BLOCK_SIZE_WORDS=${BSG_MACHINE_VCACHE_BLOCK_SIZE_WORDS})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_VCACHE_DMA_DATA_WIDTH=${BSG_MACHINE_VCACHE_DMA_DATA_WIDTH})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_VCACHE_MISS_FIFO_ELS=${BSG_MACHINE_VCACHE_MISS_FIFO_ELS})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_DRAM_SIZE_WORDS=${BSG_MACHINE_DRAM_SIZE_WORDS})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_DRAM_INCLUDED=${BSG_MACHINE_DRAM_INCLUDED})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_MAX_EPA_WIDTH=${BSG_MACHINE_MAX_EPA_WIDTH})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_MEM_CFG=${BSG_MACHINE_MEM_CFG})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_BRANCH_TRACE_EN=${BSG_MACHINE_BRANCH_TRACE_EN})
	$(eval VCS_DEFINES += +define+BSG_MACHINE_HETERO_TYPE_VEC="${BSG_MACHINE_HETERO_TYPE_VEC}")
	$(eval VCS_DEFINES += +define+BSG_MACHINE_NETWORK_CFG="${BSG_MACHINE_NETWORK_CFG}")
	$(eval VCS_DEFINES += +define+BSG_MACHINE_RUCHE_FACTOR_X="${BSG_MACHINE_RUCHE_FACTOR_X}")
	$(eval VCS_DEFINES += +define+BSG_MACHINE_SUBARRAY_X="${BSG_MACHINE_SUBARRAY_X}")
	$(eval VCS_DEFINES += +define+BSG_MACHINE_SUBARRAY_Y="${BSG_MACHINE_SUBARRAY_Y}")
	$(eval VCS_DEFINES += +define+BSG_MACHINE_NUM_VCACHE_ROWS="${BSG_MACHINE_NUM_VCACHE_ROWS}")
	$(eval VCS_DEFINES += +define+BSG_MACHINE_NUM_VCACHES_PER_CHANNEL="${BSG_MACHINE_NUM_VCACHES_PER_CHANNEL}")
	$(eval VCS_DEFINES += +define+BSG_MACHINE_DRAMSIM3_PKG="${BSG_MACHINE_DRAMSIM3_PKG}")
	$(eval VCS_DEFINES += +define+BSG_MACHINE_DISABLE_VCORE_PROFILING=1)
	$(eval VCS_DEFINES += +define+BSG_MACHINE_DISABLE_ROUTER_PROFILING=1)
	$(eval VCS_DEFINES += +define+BSG_MACHINE_DISABLE_CACHE_PROFILING=1)
	# specify where the host module is instantiated for profiler trigger (print_stat).
	# relative to $root
	$(eval VCS_DEFINES += +define+HOST_MODULE_PATH=$2)
	$(eval VCS_FLAGS   += -top $2)
	# These define are required by mobile_ddr.v.
	# density     	= 2048 Mbit
	# speed grade 	= 5
	# organization 	= x16
	# allocation    = FULL_MEM
	$(eval VCS_DEFINES += +define+den2048Mb+sg5+x16+FULL_MEM)
endef

define set_linker_flags
	$(eval VCS_LDFLAGS += -lbsg_manycore_runtime)
	$(eval VCS_LDFLAGS += -lbsg_manycore_regression)
	$(eval VCS_LDFLAGS += -L$(BSG_REPLICANT_DIR)/libraries/platforms/bsg-designs-vcs/)
	$(eval VCS_LDFLAGS += -Wl,-rpath=$(BSG_REPLICANT_DIR)/libraries/platforms/bsg-designs-vcs/)
	$(eval VCS_FLAGS += $(foreach ldflag,$(VCS_LDFLAGS),-LDFLAGS "$(ldflag)"))
endef

# boot tag rom gen
POD_TRACE_GEN_PY = $(BSG_MANYCORE_DIR)/testbenches/py/pod_trace_gen.py
ASCII_TO_ROM_PY = $(BASEJUMP_STL_DIR)/bsg_mem/bsg_ascii_to_rom.py

# set top level
out/simv out/simv-debug: TOP_LEVEL := spmd_testbench
out/cuda/simv: TOP_LEVEL := replicant_tb_top

# build simv
# without debug option for faster simulation.
out/simv : Makefile.machine.include $(VSOURCES) $(CSOURCES) $(VINCLUDES) $(VHEADERS) 
	mkdir -p out
	cp Makefile.machine.include out/
	$(call set_machine_variables,$<,$(TOP_LEVEL))
	python $(POD_TRACE_GEN_PY) $(BSG_MACHINE_PODS_X) $(BSG_MACHINE_PODS_Y) > out/pod_trace.tr
	python $(ASCII_TO_ROM_PY) out/pod_trace.tr bsg_tag_boot_rom > out/bsg_tag_boot_rom.v
	@echo $(VCS_SOURCES)
	$(VCS) $(VCS_FLAGS) $(VCS_CFLAGS) -o $@ \
		$(VCS_INCLUDES) $(VCS_DEFINES) $(CSOURCES) $(VCS_SOURCES) out/bsg_tag_boot_rom.v \
		-l out/build.log -Mdir=out/csrc 2>&1 | tee $@.vcs.log

# build simv-debug
# with debug option for waveform generation.
out/simv-debug : Makefile.machine.include $(VSOURCES) $(CSOURCES) $(VINCLUDES) $(VHEADERS) 
	mkdir -p out
	cp Makefile.machine.include out/
	$(call set_machine_variables,$<,$(TOP_LEVEL))
	python $(POD_TRACE_GEN_PY) $(BSG_MACHINE_PODS_X) $(BSG_MACHINE_PODS_Y) > out/pod_trace.tr
	python $(ASCII_TO_ROM_PY) out/pod_trace.tr bsg_tag_boot_rom > out/bsg_tag_boot_rom.v
	$(eval VCS_FLAGS += -debug_pp +vcs+vcdpluson) # Debug adds these two variables to generate waveforms
	$(VCS) $(VCS_FLAGS) $(VCS_CFLAGS) -o $@ \
		$(VCS_INCLUDES) $(VCS_DEFINES) $(CSOURCES) $(VCS_SOURCES) out/bsg_tag_boot_rom.v \
		-l out/build-debug.log -Mdir=out/csrc-debug 2>&1 | tee $@.vcs.log

# build simv
# without debug option for faster simulation.
out/cuda/simv: $(BSG_BLADERUNNER_GENERATED)
out/cuda/simv : Makefile.machine.include $(VSOURCES) $(CSOURCES) $(VINCLUDES) $(VHEADERS) 
	mkdir -p out
	mkdir -p out/cuda
	cp $< out/Makefile.machine.include
	$(call set_machine_variables,$<,$(TOP_LEVEL))
	$(call set_linker_flags)
	@echo VCS_DEFINES: $(VCS_DEFINES) > $@.vcs_defines.log
	@echo VCS_FLAGS:  $(VCS_FLAGS)  > $@.vcs_flags.log
	python $(POD_TRACE_GEN_PY) $(BSG_MACHINE_PODS_X) $(BSG_MACHINE_PODS_Y) > out/pod_trace.tr
	python $(ASCII_TO_ROM_PY) out/pod_trace.tr bsg_tag_boot_rom > out/bsg_tag_boot_rom.v
	@echo $(VCS_SOURCES)
	$(VCS) $(VCS_FLAGS) $(VCS_CFLAGS) -o $@ \
		$(VCS_INCLUDES) $(VCS_DEFINES) $(CSOURCES) $(VHEADERS) $(VSOURCES) out/bsg_tag_boot_rom.v \
		-l out/cuda/build.log -Mdir=out/cuda/csrc 2>&1 | tee $@.vcs.log

clean:
	rm -rf */csrc* out
	rm -rf */*.log */*.daidir */simv */simv-debug */simv-profile
	rm -rf stack.info.*
	rm -f */vc_hdrs.h
	rm -f */*.tr */bsg_tag_boot_rom.v
