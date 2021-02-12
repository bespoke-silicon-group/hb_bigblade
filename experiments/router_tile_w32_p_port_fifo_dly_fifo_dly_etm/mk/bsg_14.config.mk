####################################################################################################
#                                           DESIGN VARS                                            #
####################################################################################################

# Select the design type for the toplevel. If set to 'block' then the toplevel will not have IO
# drivers but rather pins (good for creating hard-macros or for doing apr runs before the toplevel
# is ready). If set to 'chip_*' the toplevel will have IO drivers, and the die size is determined by
# the *. Only certain die sizes have been implemented. Available options are:
#
#		1. block       - block level (no GPIOs)
#		2. chip_3x3    - 3mm by 3mm die size
#		3. chip_11x9   - 11mm by 9mm die size

export BSG_TOPLEVEL_DESIGN_TYPE := block

# Select the backend flow style (either hier or flat). This determines if ICC2 is going to perform a
# hierarchical or flat physical implementation of the chip. When set to flat, you may still
# synthesize hierarchically. To synthesize flat, setup your design's hier.mk such that there is only
# a single block. If there is only a single block in your design's hier.mk, this variable has no
# effect and is effectively forced to flat.

export BSG_FLOW_STYLE := flat

# *NOTE -- this flag currently does nothing as the feature has been disabled. It is planned to
# return in the future* Select if the backend flow is going to perform Design Planning (DP). Design
# planning is about 10 additional steps that occur before any placement and routing actually occurs.
# These steps are used to partition the physical hierarchy and implement a full-chip floorplan early
# on in the building flow.  It is possible to skip this step and go directly to place and route
# however this may result in poor QoR, particularly for hierarchical flows.

export BSG_FLOW_USE_DP := true

# Determines if the flow should generate an ETM (ndm + db files) for the toplevel block. The primary
# difference is that during PTSI, model extraction will be performed to generate .db files that can
# be used in higher level of the hierarchy. Other aspects of the flow might also change to allow for
# higher-level integration.

export BSG_FLOW_GENERATE_TOPLEVEL_ETM := true

# Select the target package. Inside of bsg_packaging there are multiple packages to choose from that
# determine the intended package for the ASIC.

export BSG_PACKAGE := uw_bga

# Select the target pinout. For each package inside of bsg_packaging, there can be multiple specific
# pinouts defined. This selects the intended pinout for the ASIC.

export BSG_PINOUT := bsg_asic_cloud

# Select the target packaging foundry. This is going to select IO cells for your specific process
# but for a given target process there may be multiple IP vendors that supply IO cells that we have
# support for therefore we don't just use the BSG_TARGET_PROCESS variables however they are often
# correlated.

export BSG_PACKAGING_FOUNDRY := gf_14_invecas_1p8v

# Select the target padmapping. For each pinout inside of a package inside of bsg_packaging, there
# can be multiple padmappings. These padmappings often change configurations of various pads.

export BSG_PADMAPPING := default

# Select the target power grid. We have multiple power grid implementations that can be used.
# Currently available power grids include:
#
# +----------------------+-------------------------------------------------------------------------+
# | Name                 | Description                                                             |
# +----------------------+-------------------------------------------------------------------------+
# | none                 | Just contains standard cell M1 rails.                                   |
# |                      |                                                                         |
# | default_wb (default) | Default wire-bond power grid implementation.                            |
# +----------------------+-------------------------------------------------------------------------+

export BSG_POWER_GRID := none

# Select the target power intent. The power intent contains the power ports and
# nets that will be available as well as maps cells to power domains. Currently
# available power intents:
#
# +-----------------------+------------------------------------------------------------------------+
# | Name                  | Description                                                            |
# +-----------------------+------------------------------------------------------------------------+
# | sv_standard (default) | Single voltage with standard core power ports (ie. VDD/VSS). Contains  |
# |                       | standard IO power ports (ie. VDDIO/VSSIO) for non-block level designs. |
# |                       |                                                                        |
# | mv_standard_pll       | Multi voltage with standard core power ports (ie. VDD/VSS) as well as  |
# |                       | a pll power port (ie. PLL_VDD). Contains standard IO power ports (ie.  |
# |                       | VDDIO/VSSIO) and pll IO power ports (ie. PLL_VDDIO/PLL_VSSIO) for      |
# |                       | non-block level designs.                                               |
# +-----------------------+------------------------------------------------------------------------+

export BSG_POWER_INTENT := sv_standard

# Change the CAD setup file that is used throughout the flow. This has a HUGE impact on run time and
# QoR. The default setup is default. Available options are:
#   1. default -- puts the CAD flow into the highest effort signoff quality mode we have.
#   2. tt_only -- puts the CAD flow into a single scenario mode (typical corner).

export BSG_CAD_SETUP := tt_only

####################################################################################################
#                                            PREP FLOW                                             #
####################################################################################################

# Overrides the default memgen.json in bsg_14. Only these memories will be generated when running
# make prep; however, SRAMs which have already been generated will not be removed.

export PREP_MEMGEN_JSON_FILE := $(BSG_DESIGNS_TARGET_DIR)/scripts/harden/bsg_14.memgen.json

####################################################################################################
#                                             DC FLOW                                              #
####################################################################################################

# Selects the RM+ flow for DC. This is part of the Synopsys Reference Methodology and controls the
# effort and optimizations performed during synthesis. Available options are the following:
#   1. *blank* -- This is the default mode and is the most balanced
#   2. hc      -- High-connectivity is design to optimize area and density
#   3. hplp    -- High-performance, low-power is designed to optimize performance
#   4. rtm_exp -- Runtime exploration is designed to be quick and used for early experiments

export DC_FLOW_RMPLUS_FLOW :=

# Turns on topographical mode to take into physical design constraints and wire delay. This will
# increase runtime significantly and if the constraints are not set correctly can actually reduce
# QoR for designs with lots of structure (like large mesh topographies).

export DC_FLOW_ENABLE_TOPOGRAPHICAL_MODE := false

# Turns off automatic clock gate insertion during synthesis compilation.

export DC_FLOW_COMPILE_DISABLE_CLOCK_GATING := true

# Turns on design flattening during synthesis compilation, removing all logical hierarchy in the
# design.

export DC_FLOW_COMPILE_FLATTEN_DESIGN := false

# Turns off register retiming during synthesis compilation. Note: even when retiming is enabled,
# register retiming is only performed on registers that have been marked in the design constraints.

export DC_FLOW_COMPILE_DISABLE_RETIMING := false

# The same as DC_FLOW_COMPILE_DISABLE_CLOCK_GATING but for the incremental compile stage of
# synthesis (note: depending on the value of DC_FLOW_RMPLUS_FLOW, incremental compilation might not
# be executed).

export DC_FLOW_INCREMENTAL_COMPILE_DISABLE_CLOCK_GATING := true

# The same as DC_FLOW_COMPILE_FLATTEN_DESIGN, but for the incremental compile stage of synthesis
# (note: depending on the value of DC_FLOW_RMPLUS_FLOW, incremental compilation might not be
# executed).

export DC_FLOW_INCREMENTAL_COMPILE_FLATTEN_DESIGN := false

# The same as DC_FLOW_COMPILE_DISABLE_RETIMING, but for the incremental compile stage of synthesis
# (note: depending on the value of DC_FLOW_RMPLUS_FLOW, incremental compilation might not be
# executed).

export DC_FLOW_INCREMENTAL_COMPILE_DISABLE_RETIMING := false

####################################################################################################
#                                            PTSI FLOW                                             #
####################################################################################################

# The path to a set of SAIF files to use for power analysis in PTSI.

export PTSI_FLOW_ACTIVITY_FILE :=

# The relative weights of each activity file. Does not need to be normalized.

export PTSI_FLOW_ACTIVITY_WEIGHTS :=

# The module hierarchy to strip from the SAIF file. Most often this is the path to the DUT starting
# from the testbench.

export PTSI_FLOW_STRIP_PATH :=

