all: | bsg_cadenv bsg_manycore basejump_stl bsg_14 bsg_replicant hb_bigblade_netlists

bsg_cadenv:    commit=master
basejump_stl:  commit=master
bsg_14:        commit=master
bsg_manycore:  commit=ci_bigblade
bsg_replicant: commit=bigblade-tapeout
hb_bigblade_netlists: commit=main

bsg_cadenv:
	git clone git@github.com:bespoke-silicon-group/bsg_cadenv.git $@
	cd $@ ; git checkout $(commit) ;

basejump_stl:
	git clone git@github.com:bespoke-silicon-group/basejump_stl.git $@
	cd $@ ; git checkout $(commit) ;

bsg_14:
	git clone git@github.com:bespoke-silicon-group/bsg_14.git $@
	cd $@ ; git checkout $(commit) ;
bsg_manycore:
	git clone git@github.com:bespoke-silicon-group/bsg_manycore.git $@
	cd $@ ; git checkout $(commit) ;
	cd $@ ; git submodule update --init imports/HardFloat;

bsg_replicant:
	git clone git@github.com:bespoke-silicon-group/bsg_replicant.git $@
	cd $@ ; git checkout $(commit) ;

hb_bigblade_netlists:
	git clone git@github.com:bespoke-silicon-group/hb_bigblade_netlists.git $@
	cd $@ ; git checkout $(commit); $(MAKE)

include ../common/exporter/Makefile.include

