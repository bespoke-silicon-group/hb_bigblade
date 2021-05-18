
all: | bsg_cadenv basejump_stl bsg_14

bsg_cadenv:    commit=master
basejump_stl:  commit=8710085d1a06a612a32d5eba9521798a739a60ab
bsg_14:        commit=4dc00f21abb5c16a69e530f3095f11918c9348f8

bsg_cadenv:
	git clone git@github.com:bespoke-silicon-group/bsg_cadenv.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

basejump_stl:
	git clone git@github.com:bespoke-silicon-group/basejump_stl.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

bsg_14:
	git clone git@github.com:bespoke-silicon-group/bsg_14.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

