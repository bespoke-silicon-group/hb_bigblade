
all: | bsg_14 bsg_cadenv basejump_stl

bsg_cadenv:    commit=master
bsg_14:        commit=90aa2e637760e9491a32119fd55b7b591bfea758
basejump_stl:  commit=9768a87c5acf9a5d0930ff022748455c4426e5f6

bsg_cadenv:
	git clone git@github.com:bespoke-silicon-group/bsg_cadenv.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

bsg_14:
	git clone git@github.com:bespoke-silicon-group/bsg_14.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

basejump_stl:
	git clone git@github.com:bespoke-silicon-group/basejump_stl.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

include benchmark.mk

