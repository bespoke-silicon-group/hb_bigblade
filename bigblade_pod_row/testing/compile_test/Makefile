BSG_CADENV_DIR 				 = $(abspath ../../bsg_cadenv)
include $(BSG_CADENV_DIR)/cadenv.mk

VCS_FLAGS    += +v2k -sverilog -full64 -timescale=1ps/1ps \
    +lint=all,noSVA-UA,noSVA-NSVU,noVCDE,noNS -top bsg_manycore_pod_row_sdr
VCS_FLAGS    += -licqueue
VCS_FLAGS    += -reportstats
VCS_FLAGS    += -assert svaext 

export BSG_DESIGNS_TARGET_DIR = $(abspath ../../)
export BSG_DESIGNS_DIR = $(abspath ../../../)
export BSG_MANYCORE_DIR  = $(BSG_DESIGNS_TARGET_DIR)/bsg_manycore
export BASEJUMP_STL_DIR  = $(BSG_DESIGNS_TARGET_DIR)/basejump_stl


INCDIR += +incdir+$(BASEJUMP_STL_DIR)/bsg_misc/
INCDIR += +incdir+$(BASEJUMP_STL_DIR)/bsg_noc/
INCDIR += +incdir+$(BASEJUMP_STL_DIR)/bsg_clk_gen/
INCDIR += +incdir+$(BSG_DESIGNS_DIR)/common/sdr/sdr_corner/v/
INCDIR += +incdir+$(BSG_DESIGNS_DIR)/common/sdr/sdr_vertical/v/
INCDIR += +incdir+$(BSG_DESIGNS_DIR)/common/sdr/sdr_horizontal/v/
INCDIR += +incdir+$(BSG_MANYCORE_DIR)/imports/HardFloat/source
INCDIR += +incdir+$(BSG_MANYCORE_DIR)/imports/HardFloat/source/RISCV

simv:
	$(VCS) $(VCS_FLAGS) $(INCDIR) -f sv.include -l vcs.log

clean:
	rm -f simv vcs.log vc_hdrs.h
	rm -rf csrc simv.daidir
