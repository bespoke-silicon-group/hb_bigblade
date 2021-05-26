
all: | bsg_cadenv basejump_stl bsg_14

bsg_cadenv:    commit=7860120e1a2f4c7dcebeb730a4fabcc53f40777b
basejump_stl:  commit=bigblade-rc-alpha-rtlfreeze
bsg_14:        commit=11ad2d5cbaecb76083d20098007ea7b0777c0bb6

bsg_cadenv:
	git clone git@github.com:bespoke-silicon-group/bsg_cadenv.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

basejump_stl:
	git clone git@github.com:bespoke-silicon-group/basejump_stl.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

bsg_14:
	git clone git@github.com:bespoke-silicon-group/bsg_14.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

include ../common/exporter/Makefile.include

