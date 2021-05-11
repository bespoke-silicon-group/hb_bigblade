#export BSG_MACHINE_PATH	=$(BSG_OUT_DIR)
export BSG_MACHINE_NAME =tapout
export BSG_PLATFORM     =tapeout-vcs
export CL_DIR		=$(BSG_F1_DIR)
export HARDWARE_PATH	=$(CL_DIR)/hardware
export LIBRARIES_PATH	=$(CL_DIR)/libraries
export EXAMPLES_PATH    =$(CL_DIR)/examples
export BSG_PLATFORM_PATH=$(LIBRARIES_PATH)/platforms/$(BSG_PLATFORM)

include $(BSG_F1_DIR)/hardware/hardware.mk
include $(BSG_F1_DIR)/libraries/libraries.mk
include $(BSG_F1_DIR)/examples/link.mk

BSG_BLADERUNNER_LINKS := $(BSG_MACHINE_PATH)/libdmamem.so
BSG_BLADERUNNER_LINKS += $(BSG_MACHINE_PATH)/libdramsim3.so
BSG_BLADERUNNER_LINKS += $(BSG_MACHINE_PATH)/libbsg_manycore_runtime.so
BSG_BLADERUNNER_LINKS += $(BSG_MACHINE_PATH)/libbsg_manycore_regression.so

$(BSG_MACHINE_PATH)/libdmamem.so: $(LIBRARIES_PATH)/features/dma/simulation/libdmamem.so
$(BSG_MACHINE_PATH)/libdramsim3.so: $(LIBRARIES_PATH)/features/dma/simulation/libdramsim3.so
$(BSG_MACHINE_PATH)/libbsg_manycore_runtime.so: $(BSG_PLATFORM_PATH)/libbsg_manycore_runtime.so
$(BSG_MACHINE_PATH)/libbsg_manycore_regression.so: $(BSG_PLATFORM_PATH)/libbsg_manycore_regression.so
$(BSG_BLADERUNNER_LINKS):
	ln -nsf $< $@


