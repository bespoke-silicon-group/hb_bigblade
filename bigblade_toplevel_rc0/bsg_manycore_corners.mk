THIS_DIR :=$(realpath $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

TESTBENCH = post_sdf_block_io_mem_qp0_else_rtl
TESTBENCH_PATH = $(THIS_DIR)/testing/$(TESTBENCH)

# corners for which we should make a clone of bsg_manycore
CLONE_SDF_CORNERS += sspg_0p72v_125c_sigrcmax
CLONE_SDF_CORNERS += ffpg_0p88v_125c_sigcmax
CLONE_SDF_CORNERS += ffpg_0p88v_125c_sigrcmax
CLONE_SDF_CORNERS += ffpg_0p88v_125c_sigcmin
CLONE_SDF_CORNERS += ffpg_0p88v_125c_sigrcmin
CLONE_SDF_CORNERS += ffpg_0p88v_m40c_sigcmax
CLONE_SDF_CORNERS += ffpg_0p88v_m40c_sigcmin
CLONE_SDF_CORNERS += ffpg_0p88v_m40c_sigrcmax
CLONE_SDF_CORNERS += ffpg_0p88v_m40c_sigrcmin
CLONE_SDF_CORNERS += sspg_0p72v_125c_sigcmax
CLONE_SDF_CORNERS += sspg_0p72v_125c_sigcmin
CLONE_SDF_CORNERS += sspg_0p72v_125c_sigrcmin
CLONE_SDF_CORNERS += sspg_0p72v_m40c_sigcmax
CLONE_SDF_CORNERS += sspg_0p72v_m40c_sigcmin
CLONE_SDF_CORNERS += sspg_0p72v_m40c_sigrcmax
CLONE_SDF_CORNERS += sspg_0p72v_m40c_sigrcmin

# corners for which we should run
RUN_SDF_CORNERS := $(CLONE_SDF_CORNERS)

MC_MAX_CLONES := $(addprefix bsg_manycore_,$(addsuffix _max,$(CLONE_SDF_CORNERS)))
MC_MIN_CLONES := $(addprefix bsg_manycore_,$(addsuffix _min,$(CLONE_SDF_CORNERS)))
MC_CLONES := $(MC_MAX_CLONES) $(MC_MIN_CLONES)

clones: $(MC_CLONES)

$(MC_CLONES):
	$(eval STRIPPED = $(subst bsg_manycore_,,$@))
	$(eval CORNER = $(filter $(CLONE_SDF_CORNERS),$(subst _max,,$(subst _min,,$(STRIPPED)))))
	$(eval MIN_OR_MAX = $(subst $(CORNER)_,,$(STRIPPED)))
	git clone git@github.com:bespoke-silicon-group/bsg_manycore $@
	cd $@ && git checkout ci_bigblade && make checkout_submodules
	cd $@ && git remote add ptpan git@github.com:ptpan/bsg_manycore.git
	cd $@ && git fetch ptpan pp482-chip-plus-cgra-sim && git checkout ptpan/pp482-chip-plus-cgra-sim -- software/spmd/one_cgra_xcel_read_write
	cp $(THIS_DIR)/bsg_manycore/software/spmd/one_cgra_xcel_read_write/main.c $(THIS_DIR)/$@/software/spmd/one_cgra_xcel_read_write
	cp $(THIS_DIR)/bsg_manycore/software/spmd/one_cgra_xcel_read_write/init_file $(THIS_DIR)/$@/software/spmd/one_cgra_xcel_read_write
	ln -nsf \
	$(THIS_DIR)/bsg_manycore/software/riscv-tools/riscv-install \
	$(THIS_DIR)/$@/software/riscv-tools/riscv-install
	echo "BSG_MACHINE_PATH = $(TESTBENCH_PATH)/out/$(CORNER)_$(MIN_OR_MAX)/" >> $@/software/mk/Makefile.paths

MC_MAX_RUNS := $(addsuffix .run,$(addprefix bsg_manycore_,$(addsuffix _max,$(RUN_SDF_CORNERS))))
MC_MIN_RUNS := $(addsuffix .run,$(addprefix bsg_manycore_,$(addsuffix _min,$(RUN_SDF_CORNERS))))
MC_RUNS := $(MC_MAX_RUNS) $(MC_MIN_RUNS)

run: $(MC_RUNS)
$(MC_RUNS): %.run:
	$(MAKE) bsg_pods_X=4 bsg_pods_Y=1 TRACE_FILE=$(TESTBENCH_PATH)/out/bsg_tag_boot_pod0_cgra0.tr -C $*/software/spmd/one_cgra_xcel_read_write

MC_MAX_DEBUG := $(addsuffix .dbg,$(addprefix bsg_manycore_,$(addsuffix _max,$(RUN_SDF_CORNERS))))
MC_MIN_DEBUG := $(addsuffix .dbg,$(addprefix bsg_manycore_,$(addsuffix _min,$(RUN_SDF_CORNERS))))
MC_DEBUG := $(MC_MAX_DEBUG) $(MC_MIN_DEBUG)
debug: $(MC_DEBUG)
$(MC_DEBUG): %.dbg:
	$(MAKE) WAVE=1 bsg_pods_X=4 bsg_pods_Y=1 TRACE_FILE=$(TESTBENCH_PATH)/out/bsg_tag_boot_pod0_cgra0.tr -C $*/software/spmd/one_cgra_xcel_read_write

purge:
	rm -rf $(MC_CLONES)


