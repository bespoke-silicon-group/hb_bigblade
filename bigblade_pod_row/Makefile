all: | bsg_cadenv bsg_manycore basejump_stl bsg_14

bsg_cadenv:    commit=master
basejump_stl:  commit=6446895be918bf14818f120464561354d1c5a52b
bsg_14:        commit=etm_mid_level_dev
bsg_manycore:  commit=ee621b39d1d7f9637548b0de13de98ae8de26f9d

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
