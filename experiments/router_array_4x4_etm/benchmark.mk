DATE := $(shell date "+%Y_%m_%d_%H_%M_%S")

8-core:
	$(eval export DC_NUM_CORES=8)
	$(eval export ICC2_NUM_CORES=8)
	$(MAKE) -C bsg_14/ new_build
	$(MAKE) -C bsg_14/ rename_build.$@-$(DATE)
	$(MAKE) -C bsg_14/ prof.pnr.export.bsg_chip
	$(MAKE) -C bsg_14/ $@.notify

16-core:
	$(eval export DC_NUM_CORES=16)
	$(eval export ICC2_NUM_CORES=16)
	$(MAKE) -C bsg_14/ new_build
	$(MAKE) -C bsg_14/ rename_build.$@-$(DATE)
	$(MAKE) -C bsg_14/ prof.pnr.export.bsg_chip
	$(MAKE) -C bsg_14/ $@.notify

32-core:
	$(eval export DC_NUM_CORES=16)
	$(eval export ICC2_NUM_CORES=32)
	$(MAKE) -C bsg_14/ new_build
	$(MAKE) -C bsg_14/ rename_build.$@-$(DATE)
	$(MAKE) -C bsg_14/ prof.pnr.export.bsg_chip
	$(MAKE) -C bsg_14/ $@.notify

2x8-core:
	$(eval export DC_NUM_CORES=8)
	$(eval export ICC2_NUM_CORES=8)
	$(MAKE) -C bsg_14/ BUILD_DIR=$(CURDIR)/bsg_14/build.run1 build_setup
	$(MAKE) -C bsg_14/ BUILD_DIR=$(CURDIR)/bsg_14/build.run1 rename_build.$@-$(DATE)-run1
	$(MAKE) -C bsg_14/ BUILD_DIR=$(CURDIR)/bsg_14/build.run1 prof.pnr.export.bsg_chip &
	$(MAKE) -C bsg_14/ BUILD_DIR=$(CURDIR)/bsg_14/build.run2 build_setup
	$(MAKE) -C bsg_14/ BUILD_DIR=$(CURDIR)/bsg_14/build.run2 rename_build.$@-$(DATE)-run2
	$(MAKE) -C bsg_14/ BUILD_DIR=$(CURDIR)/bsg_14/build.run2 prof.pnr.export.bsg_chip
	$(MAKE) -C bsg_14/ $@.notify

