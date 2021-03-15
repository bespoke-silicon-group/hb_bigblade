all: | bsg_cadenv bsg_manycore basejump_stl bsg_14

bsg_cadenv:    commit=master
basejump_stl:  commit=master
bsg_14:        commit=master
bsg_manycore:        commit=ci_bigblade

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
