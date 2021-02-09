include ../../bsg_cadenv/cadenv.mk
export basejump_stl_dir = $(abspath ../../basejump_stl)
export bsg_manycore_dir = $(abspath ../../bsg_manycore)
export bsg_designs_target_dir = $(abspath ../..)

INCDIR =   +incdir+$(basejump_stl_dir)/bsg_noc
INCDIR +=  +incdir+$(basejump_stl_dir)/bsg_misc
INCDIR +=  +incdir+$(bsg_manycore_dir)/imports/HardFloat/source
INCDIR +=  +incdir+$(bsg_manycore_dir)/imports/HardFloat/source/RISCV

build: simv simv-debug

simv:
	$(VCS) -full64 +v2k -sverilog -timescale=1ps/1ps -top testbench \
		+lint=all,noSVA-UA,noSVA-NSVU,noVCDE,noNS \
		-reportstats $(INCDIR) -f sv.include \
		-o $@ -l vcs.log -Mdir=csrc

simv-debug:
	$(VCS) -full64 +v2k -sverilog -timescale=1ps/1ps -top testbench \
		-debug_pp +vcs+vcdpluson \
		+lint=all,noSVA-UA,noSVA-NSVU,noVCDE,noNS \
		-reportstats $(INCDIR) -f sv.include \
		-o $@ -l vcs-debug.log -Mdir=csrc-debug
	

clean:
	rm -rf *.daidir csrc csrc*
	rm -f *.log simv simv-debug
