.DEFAULT_GOAL=run

BSG_DESIGNS_TARGET_DIR := $(abspath ../)
BSG_CHIP_PTSI_DIR := $(BSG_DESIGNS_TARGET_DIR)/bsg_14/current_build/ptsi

# cadenv setup
include $(BSG_DESIGNS_TARGET_DIR)/bsg_cadenv/cadenv.mk
# design setup
include $(BSG_DESIGNS_TARGET_DIR)/mk/hier.mk

BSG_WORK_DIR   := $(abspath ./)
BSG_OUT_DIR    := $(BSG_WORK_DIR)/out
DESIGN_OUT_DIR := $(BSG_OUT_DIR)/$(TOP_HIER_BLOCK)

PTSI_RUN_TCL   := $(BSG_WORK_DIR)/tcl/ptsi_run.tcl
OUTPUT_CSV_PY  := $(BSG_WORK_DIR)/py/output_csv.py
RESULT_CSV     := $(DESIGN_OUT_DIR)/result.csv
PYTHON         := python3

CORNERS := ffpg_0p88v_125c_sigcmax \
           ffpg_0p88v_125c_sigcmin \
           ffpg_0p88v_125c_sigrcmax \
           ffpg_0p88v_125c_sigrcmin \
           ffpg_0p88v_m40c_sigcmax \
           ffpg_0p88v_m40c_sigcmin \
           ffpg_0p88v_m40c_sigrcmax \
           ffpg_0p88v_m40c_sigrcmin \
           sspg_0p72v_125c_sigcmax \
           sspg_0p72v_125c_sigcmin \
           sspg_0p72v_125c_sigrcmax \
           sspg_0p72v_125c_sigrcmin \
           sspg_0p72v_m40c_sigcmax \
           sspg_0p72v_m40c_sigcmin \
           sspg_0p72v_m40c_sigrcmax \
           sspg_0p72v_m40c_sigrcmin \
           tt_0p80v_25c_nominal

RUNS := $(foreach obj, $(CORNERS), run-$(obj))

run: $(RUNS)
	$(PYTHON) $(OUTPUT_CSV_PY) $(DESIGN_OUT_DIR) > $(RESULT_CSV)

run-%: $(DESIGN_OUT_DIR)
	$(eval export PTSI_LOG_FILE:=$(DESIGN_OUT_DIR)/$*.log)
	cd $(BSG_CHIP_PTSI_DIR)/$(TOP_HIER_BLOCK)/$* && $(PT_SHELL) -f $(PTSI_RUN_TCL)

csv:
	$(PYTHON) $(OUTPUT_CSV_PY) $(DESIGN_OUT_DIR) > $(RESULT_CSV)

$(DESIGN_OUT_DIR):
	mkdir -p $@

clean:
	rm -rf $(BSG_OUT_DIR)
