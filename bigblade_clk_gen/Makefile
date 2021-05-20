
all: | bsg_cadenv basejump_stl bsg_14

bsg_cadenv:    commit=7860120e1a2f4c7dcebeb730a4fabcc53f40777b
basejump_stl:  commit=e9a502b30da83457fcee0af7b2ce147b7899012f
bsg_14:        commit=19acadff099921f6bbd01c4bb847dcd41c27b3d9

bsg_cadenv:
	git clone git@github.com:bespoke-silicon-group/bsg_cadenv.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

basejump_stl:
	git clone git@github.com:bespoke-silicon-group/basejump_stl.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

bsg_14:
	git clone git@github.com:bespoke-silicon-group/bsg_14.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

