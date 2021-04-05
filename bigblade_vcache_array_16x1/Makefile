all: | bsg_cadenv basejump_stl bsg_14 bsg_manycore

bsg_cadenv:    commit=master
basejump_stl:  commit=7556378810412be47e118b08910c02883936a64c
bsg_14:        commit=etm_mid_level_dev
bsg_manycore:  commit=500c948606799ebb1ee774538aae3ed7ea1d3cdf

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

