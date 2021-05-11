.DEFAULT_GOAL=run
.SECONDARY:

# Note: most variables that are file/dir paths are ?= because they can be
# overriden by the chip repo if this makefile is called from the chip
# infrastructure.

export BSG_DESIGNS_DIR        ?= $(abspath ../../../../)
export BSG_DESIGNS_TARGET_DIR ?= $(abspath ../../)

BSG_WORK_DIR := $(abspath ./)
BSG_OUT_DIR  := $(BSG_WORK_DIR)/out
BSG_OUT_SIM  := $(BSG_OUT_DIR)/simv

include $(BSG_DESIGNS_TARGET_DIR)/bsg_cadenv/cadenv.mk

# Repository setup
export BASEJUMP_STL_DIR       ?= $(BSG_DESIGNS_TARGET_DIR)/basejump_stl
export BSG_PACKAGING_DIR      ?= $(BSG_DESIGNS_TARGET_DIR)/bsg_packaging
export BLACKPARROT_DIR        ?= $(BSG_DESIGNS_TARGET_DIR)/black-parrot
export BSG_MANYCORE_DIR       ?= $(BSG_DESIGNS_TARGET_DIR)/bsg_manycore
export BOARD_DIR              ?= $(BSG_DESIGNS_TARGET_DIR)/board

export BSG_PACKAGE           ?=uw_bga
export BSG_PINOUT            ?=bsg_asic_cloud
export BSG_PACKAGING_FOUNDRY ?=gf_14_invecas_1p8v
export BSG_PADMAPPING        ?=default

export BLACKPARROT_COMMON_DIR ?= $(BLACKPARROT_DIR)/bp_common
export BLACKPARROT_TOP_DIR    ?= $(BLACKPARROT_DIR)/bp_top
export BLACKPARROT_FE_DIR     ?= $(BLACKPARROT_DIR)/bp_fe
export BLACKPARROT_BE_DIR     ?= $(BLACKPARROT_DIR)/bp_be
export BLACKPARROT_ME_DIR     ?= $(BLACKPARROT_DIR)/bp_me

# Additional setup for RTL-Hard
export BSG_CHIP_DIR             ?= $(BSG_DESIGNS_TARGET_DIR)/bsg_14
export PREP_MEMGEN_RUN_DIR      ?= $(BSG_CHIP_DIR)/.pdk_prep/memgen
export BSG_TOPLEVEL_DESIGN_TYPE ?=chip_3x3
export BSG_TARGET_PROCESS       ?=gf_14

include $(BSG_DESIGNS_TARGET_DIR)/mk/bsg_14.config.mk
include $(BSG_CHIP_DIR)/cad/setup/Makefile.include

########################################
## VCS OPTIONS
########################################

# Common VCS Options (will be used most of the time by all corners)
VCS_OPTIONS := -full64
VCS_OPTIONS += -notice
VCS_OPTIONS += -debug_pp
VCS_OPTIONS += -V
VCS_OPTIONS += +v2k
VCS_OPTIONS += -sverilog -assert svaext
VCS_OPTIONS += +noportcoerce
VCS_OPTIONS += +vc
VCS_OPTIONS += +vcs+loopreport
VCS_OPTIONS += -timescale=1ps/1ps
VCS_OPTIONS += -diag timescale 
VCS_OPTIONS += -o $(BSG_OUT_SIM)
VCS_OPTIONS += -Mdir=$(BSG_OUT_DIR)
VCS_OPTIONS += -top bsg_config bsg_config.v
VCS_OPTIONS += +warn=all,noOPD,noTMR,noTFIPC
VCS_OPTIONS += +define+den2048Mb+sg5+x16+FULL_MEM
VCS_OPTIONS += +vcs+lic+wait

# Additional options for Post-Synth
VCS_OPTIONS += +notimingcheck
VCS_OPTIONS += +nospecify

########################################
## Chip and Testing Filelists and Liblists
########################################

BSG_TOP_SIM_MODULE = bsg_gateway_chip
BSG_CHIP_INSTANCE_PATH = bsg_gateway_chip.DUT

VCS_OPTIONS += +define+BSG_TOP_SIM_MODULE=$(BSG_TOP_SIM_MODULE)
VCS_OPTIONS += +define+BSG_CHIP_INSTANCE_PATH=$(BSG_CHIP_INSTANCE_PATH)

export BSG_DESIGNS_TESTING_LIBRARY_NAME = bsg_design_testing
export BSG_DESIGNS_TESTING_FILELIST = $(BSG_OUT_DIR)/$(BSG_DESIGNS_TESTING_LIBRARY_NAME).filelist
export BSG_DESIGNS_TESTING_LIBRARY = $(BSG_OUT_DIR)/$(BSG_DESIGNS_TESTING_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_DESIGNS_TESTING_LIBRARY_NAME=$(BSG_DESIGNS_TESTING_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_DESIGNS_TESTING_FILELIST)
VCS_OPTIONS += -libmap $(BSG_DESIGNS_TESTING_LIBRARY)

export NETLIST_LIBRARY_NAME = netlist
export NETLIST_FILELIST = $(BSG_OUT_DIR)/$(NETLIST_LIBRARY_NAME).filelist
export NETLIST_LIBRARY = $(BSG_OUT_DIR)/$(NETLIST_LIBRARY_NAME).library

VCS_OPTIONS += +define+NETLIST_LIBRARY_NAME=$(NETLIST_LIBRARY_NAME)
VCS_OPTIONS += -f $(NETLIST_FILELIST)
VCS_OPTIONS += -libmap $(NETLIST_LIBRARY)

$(BSG_DESIGNS_TESTING_FILELIST): $(BSG_DESIGNS_TESTING_LIBRARY)
$(BSG_DESIGNS_TESTING_LIBRARY): $(BSG_OUT_DIR)
	/usr/bin/tclsh bsg_config.tcl

########################################
## Testbench options
########################################
NO_BIND_P ?= 1
CMT_TRACE_P ?= 0
BRIDGE_TRACE_P ?= 0
COSIM_P ?= 0
USE_BIN_P ?= 0

TB_PARAMS = -pvalue+commit_trace_p=$(CMT_TRACE_P) \
                        -pvalue+bridge_trace_p=$(BRIDGE_TRACE_P) \
                        -pvalue+cosim_p=$(COSIM_P) \
                        -pvalue+no_bind_p=$(NO_BIND_P)

VCS_OPTIONS += -CFLAGS "-I$(BLACKPARROT_DIR)/external/include -std=c++14"
VCS_OPTIONS += $(BLACKPARROT_DIR)/external/lib/libdromajo_cosim.a

########################################
## BlackParrot test junk
########################################
## TODO: Port to blackparrot itself

RISCV_GCC ?= $(BLACKPARROT_DIR)/external/bin/riscv64-unknown-elf-dramfs-gcc -mcmodel=medany
RISCV_OBJDUMP ?= $(BLACKPARROT_DIR)/external/bin/riscv64-unknown-elf-dramfs-objdump -D
RISCV_OBJCOPY ?= $(BLACKPARROT_DIR)/external/bin/riscv64-unknown-elf-dramfs-objcopy -O verilog --verilog-data-width 4

PROGS_DIR = $(abspath ../progs/)
SRC_DIR = $(PROGS_DIR)/src
INC_DIR = $(PROGS_DIR)/include
BIN_DIR = $(PROGS_DIR)/bin
PROG ?= manycore_poke_fifo
CRT ?= $(SRC_DIR)/start.S
BP_UTILS ?= $(SRC_DIR)/bp_utils.c
LINKER ?= $(SRC_DIR)/riscv.ld

PYTHON ?= python
PYTHONPATH +=:../../bsg_manycore/testbenches/py
TRACE_GEN ?= $(abspath ../py/blackparrot_trace_gen.py)
NBF_GEN ?= $(abspath ../py/blackparrot_nbf_gen.py)

%/trace.tr:
	mkdir -p $(@D)
	$(PYTHON) $(TRACE_GEN) > $@

%/prog.riscv:
	mkdir -p $(@D)
ifneq ($(USE_BIN_P), 0)
	cp $(BIN_DIR)/$(PROG).riscv $@
else
	$(RISCV_GCC) $(RISCV_LINK) -I$(INC_DIR) -T$(LINKER) -nostartfiles -nostdlib $(CRT) $(BP_UTILS) $(SRC_DIR)/$(PROG).c -o $@
endif

%/prog.elf: %/prog.riscv
	cp $*/prog.riscv $@

%/prog.dump: %/prog.riscv
	mkdir -p $(@D)
	$(RISCV_OBJDUMP) $< > $@

%/prog.mem: %/prog.riscv
	mkdir -p $(@D)
	$(RISCV_OBJCOPY) $< $@

%/prog.nbf: %/prog.mem %/prog.dump %/prog.elf
	mkdir -p $(@D)
	$(PYTHON) $(NBF_GEN) $< > $@

PLUSARGS ?= +nbf_file=prog.nbf
PLUSARGS += +max_cycle=1000000
PLUSARGS += +num_finish=1

########################################
## Run Targets
########################################

run: $(BSG_OUT_SIM) $(BSG_OUT_DIR)/prog.nbf $(BSG_OUT_DIR)/trace.tr
	cd $(BSG_OUT_DIR); $(BSG_OUT_SIM) $(PLUSARGS) | tee -i $(@D)/run.log

run-no-tee: $(BSG_OUT_SIM) $(BSG_OUT_DIR)/prog.nbf $(BSG_OUT_DIR)/trace.tr
	cd $(BSG_OUT_DIR); $(BSG_OUT_SIM) $(PLUSARGS)

rerun: $(BSG_OUT_SIM) $(BSG_OUT_DIR)/prog.nbf $(BSG_OUT_DIR)/trace.tr
	cd $(BSG_OUT_DIR); $(BSG_OUT_SIM) $(PLUSARGS) | tee -i $(@D)/run.log

rerun-no-tee: $(BSG_OUT_SIM) $(BSG_OUT_DIR)/prog.nbf $(BSG_OUT_DIR)/trace.tr
	cd $(BSG_OUT_DIR); $(BSG_OUT_SIM) $(PLUSARGS)

view:
	$(VCS_BIN)/dve -full64 -vpd $(BSG_OUT_DIR)/vcdplus.vpd

build: $(BSG_OUT_SIM)
$(BSG_OUT_SIM): $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY)
	$(VCS) $(VCS_OPTIONS) $(TB_PARAMS) | tee -i $(BSG_OUT_DIR)/build.log

$(BSG_OUT_DIR):
	mkdir -p $@

clean:
	rm -rf $(BSG_OUT_DIR)
	rm -rf DVEFiles/
