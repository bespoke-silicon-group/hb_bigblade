
all: | bsg_cadenv bsg_packaging basejump_stl bsg_14

bsg_cadenv:    commit=master
bsg_packaging: commit=basejump_fcbga_785
basejump_stl:  commit=master
bsg_14:        commit=master

bsg_cadenv:
	git clone git@github.com:bespoke-silicon-group/bsg_cadenv.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

bsg_packaging:
	git clone git@github.com:bespoke-silicon-group/bsg_packaging.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

basejump_stl:
	git clone git@github.com:bespoke-silicon-group/basejump_stl.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

bsg_14:
	git clone git@github.com:bespoke-silicon-group/bsg_14.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

