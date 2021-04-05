all: | bsg_cadenv basejump_stl bsg_14 bsg_manycore

bsg_cadenv:    commit=master
basejump_stl:  commit=6446895be918bf14818f120464561354d1c5a52b
bsg_14:        commit=etm_mid_level_dev
bsg_manycore:  commit=82b52eff5ed9bf8bbc04bef972779a242196d9b4

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
	cd $@ ; git submodule update --init imports/HardFloat

