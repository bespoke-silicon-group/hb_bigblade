BSG_MACHINE_NAME =tapeout
BSG_PLATFORM     =tapeout-vcs
CL_DIR           =$(BSG_F1_DIR)
HARDWARE_PATH    =$(CL_DIR)/hardware
LIBRARIES_PATH   =$(CL_DIR)/libraries
EXAMPLES_PATH    =$(CL_DIR)/examples
BSG_PLATFORM_PATH=$(LIBRARIES_PATH)/platforms/$(BSG_PLATFORM)

# hardware.mk defines a rule for building bsg_bladerunner_pkg.v from
# the Makefile.machine.include file
include $(BSG_F1_DIR)/hardware/hardware.mk

# libraries.mk defines rules for building the shared libraries in
# LIBRARIES_PATH and BSG_PLATFORM_PATH
include $(BSG_F1_DIR)/libraries/libraries.mk

BSG_BLADERUNNER_LINKS := $(BSG_MACHINE_PATH)/libdmamem.so
BSG_BLADERUNNER_LINKS += $(BSG_MACHINE_PATH)/libdramsim3.so
BSG_BLADERUNNER_LINKS += $(BSG_MACHINE_PATH)/libbsg_manycore_runtime.so
BSG_BLADERUNNER_LINKS += $(BSG_MACHINE_PATH)/libbsg_manycore_regression.so
BSG_BLADERUNNER_LINKS += $(BSG_MACHINE_PATH)/libbsgmc_cuda_legacy_pod_repl.so

$(BSG_MACHINE_PATH)/libdmamem.so: $(LIBRARIES_PATH)/features/dma/simulation/libdmamem.so
$(BSG_MACHINE_PATH)/libdramsim3.so: $(LIBRARIES_PATH)/features/dma/simulation/libdramsim3.so
$(BSG_MACHINE_PATH)/libbsg_manycore_runtime.so: $(BSG_PLATFORM_PATH)/libbsg_manycore_runtime.so
$(BSG_MACHINE_PATH)/libbsg_manycore_regression.so: $(BSG_PLATFORM_PATH)/libbsg_manycore_regression.so
$(BSG_MACHINE_PATH)/libbsgmc_cuda_legacy_pod_repl.so: $(BSG_PLATFORM_PATH)/libbsgmc_cuda_legacy_pod_repl.so
$(BSG_BLADERUNNER_LINKS):
	ln -nsf $< $@


