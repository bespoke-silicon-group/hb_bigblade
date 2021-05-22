
all: | bsg_cadenv basejump_stl bsg_14

bsg_cadenv:    commit=7860120e1a2f4c7dcebeb730a4fabcc53f40777b
basejump_stl:  commit=dcdf7d48f53cc587af6a50f0ca5dc4cacc5e4ed5
bsg_14:        commit=8935d97ca8f0fc4d96d45d3345f9c0b87208fe4a

bsg_cadenv:
	git clone git@github.com:bespoke-silicon-group/bsg_cadenv.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

basejump_stl:
	git clone git@github.com:bespoke-silicon-group/basejump_stl.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

bsg_14:
	git clone git@github.com:bespoke-silicon-group/bsg_14.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

