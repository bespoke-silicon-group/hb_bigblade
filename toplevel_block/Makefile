
all: | bsg_cadenv basejump_stl bsg_14

bsg_cadenv:    commit=master
basejump_stl:  commit=bdc199bd022e1a76cae51edbae9ade6bc8bcedb5
bsg_14:        commit=61262bdbcc74e6d91fa42cd99e4a8e0e3094f14b

bsg_cadenv:
	git clone git@github.com:bespoke-silicon-group/bsg_cadenv.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

basejump_stl:
	git clone git@github.com:bespoke-silicon-group/basejump_stl.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

bsg_14:
	git clone git@github.com:bespoke-silicon-group/bsg_14.git $@
	cd $@ ; git checkout $(commit) ; git checkout -b dev_$(commit)

