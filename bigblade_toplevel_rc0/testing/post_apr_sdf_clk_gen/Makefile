  
.DEFAULT_GOAL=run

export BSG_DESIGNS_DIR        := $(abspath ../../../)
export BSG_DESIGNS_TARGET_DIR := $(abspath ../../)

TRACE_NAME        ?= bsg_tag_boot_clk_gen_bp0
CLK_GEN_SWEEP_DIR := $(abspath ./)
SWEEP_RUNS_DIR    := $(CLK_GEN_SWEEP_DIR)/runs-$(TRACE_NAME)
PYTHON            := python

TRACE_PY_PATH     := $(CLK_GEN_SWEEP_DIR)/py/$(TRACE_NAME).py
TRACE_PATH        := $(SWEEP_RUNS_DIR)/$(TRACE_NAME).tr
NBF_PATH          := $(CLK_GEN_SWEEP_DIR)/nbf/dummy.nbf
BUILD_DIR         := $(BSG_DESIGNS_TARGET_DIR)/testing/post_sdf_block_io_mem_qp0_else_rtl/out

include $(BSG_DESIGNS_TARGET_DIR)/bsg_cadenv/cadenv.mk

PROCESSES   := ffpg_0p88v sspg_0p72v
TEMPS       := 125c m40c
RC_CORNERS  := sigcmax sigcmin sigrcmax sigrcmin
SDF_CORNERS := max min

CORNERS := $(foreach PROCESS_P, $(PROCESSES),                                \
             $(foreach TEMP_P, $(TEMPS),                                     \
               $(foreach RC_CORNER_P, $(RC_CORNERS),                         \
                 $(foreach SDF_CORNER_P, $(SDF_CORNERS),                     \
                   $(PROCESS_P)_$(TEMP_P)_$(RC_CORNER_P)_$(SDF_CORNER_P)))))

RUNS := $(foreach obj, $(CORNERS), run-$(obj))

run: $(RUNS)

run-%: $(SWEEP_RUNS_DIR) $(TRACE_PATH) $(NBF_PATH)
	mkdir $(SWEEP_RUNS_DIR)/$*
	cd $(SWEEP_RUNS_DIR)/$*               \
	&& $(BUILD_DIR)/$*/simv-debug         \
	            +nbf_file=$(NBF_PATH)     \
	            +trace_file=$(TRACE_PATH) \
	            +max_cycle=10             \
	            -l run.log

view-%:
	cd $(SWEEP_RUNS_DIR)/$*; $(VCS_BIN)/dve -full64 -vpd vcdplus.vpd

$(SWEEP_RUNS_DIR):
	mkdir -p $@

$(TRACE_PATH): $(SWEEP_RUNS_DIR)
	$(PYTHON) $(TRACE_PY_PATH) > $(TRACE_PATH)

clean:
	rm -rf $(SWEEP_RUNS_DIR)
