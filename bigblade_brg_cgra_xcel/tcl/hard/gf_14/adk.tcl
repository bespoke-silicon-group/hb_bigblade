#=========================================================================
# ASIC Design Kit Setup TCL File
#=========================================================================
# This file is sourced by every asic flow tcl script that uses the
# ASIC design kit. This allows us to set ADK-specific variables.

#-------------------------------------------------------------------------
# ADK_PROCESS
#-------------------------------------------------------------------------
# This variable is used by the Innovus Foundation Flow to automatically
# configure process-specific options (e.g., extraction engines).
#
# The process can be "28", "180", etc., with units in nm.

set ADK_PROCESS 14

#-------------------------------------------------------------------------
# Preferred routing layers
#-------------------------------------------------------------------------
# These variables are used by the Synopsys DC Topographical flow and also
# by the Innovus Foundation Flow. Typically the top few metal layers are
# reserved for power straps and maybe clock routing.

set ADK_MIN_ROUTING_LAYER_DC M2
set ADK_MAX_ROUTING_LAYER_DC M11

set ADK_MAX_ROUTING_LAYER_INNOVUS 11

#-------------------------------------------------------------------------
# Power mesh layers
#-------------------------------------------------------------------------
# These variables are used in Innovus scripts to reference the layers used
# for the coarse power mesh.

set ADK_POWER_MESH_BOT_LAYER 12
set ADK_POWER_MESH_TOP_LAYER 13

#-------------------------------------------------------------------------
# ADK_DRIVING_CELL
#-------------------------------------------------------------------------
# This variable should indicate which cell to use with the
# set_driving_cell command. The tools will assume all inputs to a block
# are being driven by this kind of cell. It should usually be some kind
# of simple inverter.

set ADK_DRIVING_CELL "SC7P5T_INVX0P5_SSC14R"

#-------------------------------------------------------------------------
# ADK_TYPICAL_ON_CHIP_LOAD
#-------------------------------------------------------------------------
# Our default timing constraints assume that we are driving another block
# of on-chip logic. Select how much load capacitance in picofarads we
# should drive here. This is the load capacitance that the output pins of
# the block will expect to be driving.
#
# The stdcell lib shows about 2fF for an inverter x4, so about 5fF is
# reasonable.

set ADK_TYPICAL_ON_CHIP_LOAD 5

#-------------------------------------------------------------------------
# ADK_FILLER_CELLS
#-------------------------------------------------------------------------
# This variable should include a space delimited list of the names of
# the filler cells in the library. Note, you must order the filler cells
# from largest to smallest because ICC / Innovus will start by using the
# first filler cell, and only use the second filler cell if there is
# space.
#.........................................................................
# Picking the right filler cell
#.........................................................................
# These are the filler cells available:
#
#  - FILL
#  - FILLSGCAP <- choosing this one
#  - FILLXGCAP
#
# NOTE: There are no FILL2 or FILL1 for the FILLXGCAP and FILLSGCAP
# categories, probably because it doesn't fit.
#
# According to the general databook from ARM:
#
#     FILLSGCAP and FILLXGCAP
#
#     FILLSGCAP and FILLXGCAP cells function as FILL cells with
#     decoupling capacitors. Inside the FILSGCAP cells, using thin
#     oxide, the PMOS and NMOS devices form decoupling capacitors
#     between the VDD and VSS rails. These decoupling capacitors
#     reduce the ground bounce in the power grids. The FILLSGCAP cell
#     is designed using the series gate capacitance. This style of
#     decap provides the best RC response because it optimizes both
#     the capacitance and resistance. The FILLXGCAP cell is designed
#     using the cross-coupled capacitance. This style of decap is not
#     recommended by ARM, but it provides a larger decap than the
#     FILLSGCAP cell.
#
# So I think we should use FILLSGCAP since it seems more
# general-purpose.

set ADK_FILLER_CELLS \
  "SC7P5T_FILLX64_SSC14R \
   SC7P5T_FILLX32_SSC14R \
   SC7P5T_FILLX16_SSC14R \
   SC7P5T_FILLX8_SSC14R \
   SC7P5T_FILLX6_SSC14R \
   SC7P5T_FILLX4_SSC14R \
   SC7P5T_FILLX3_SSC14R \
   SC7P5T_FILLX2_SSC14R \
   SC7P5T_FILLX64_SSC14L \
   SC7P5T_FILLX32_SSC14L \
   SC7P5T_FILLX16_SSC14L \
   SC7P5T_FILLX8_SSC14L \
   SC7P5T_FILLX6_SSC14L \
   SC7P5T_FILLX4_SSC14L \
   SC7P5T_FILLX3_SSC14L \
   SC7P5T_FILLX2_SSC14L \ 
   SC7P5T_FILLX64_SSC14SL \
   SC7P5T_FILLX32_SSC14SL \
   SC7P5T_FILLX16_SSC14SL \
   SC7P5T_FILLX6_SSC14SL \
   SC7P5T_FILLX8_SSC14SL \
   SC7P5T_FILLX4_SSC14SL \
   SC7P5T_FILLX3_SSC14SL \
   SC7P5T_FILLX2_SSC14SL"

# To solve spacing DRCs set the width of the smallest FILLER in this ADK
set ADK_FILLER_MIN_WIDTH 0.168 
#-------------------------------------------------------------------------
# ADK_TIE_CELLS
#-------------------------------------------------------------------------
# This list should specify the cells to use for tying high to VDD and
# tying low to VSS.

set ADK_TIE_CELLS \
  "SC7P5T_TIEHIX4_SSC14R \
   SC7P5T_TIELOX4_SSC14R"

#-------------------------------------------------------------------------
# ADK_WELL_TAP_CELL
#-------------------------------------------------------------------------
# This list should specify the well tap cell if the stdcells in the
# library do not already include taps.

set ADK_WELL_TAP_CELL "SC7P5T_TAPX14_SSC14R"

#-------------------------------------------------------------------------
# ADK_END_CAP_CELL
#-------------------------------------------------------------------------
# This list should specify the end cap cells if the library requires them.

##set ADK_END_CAP_CELL  "SC7P5T_COLCAPNX2_SSC14R    SC7P5T_COLCAPNX3_SSC14R    SC7P5T_COLCAPPX2_SSC14R    SC7P5T_COLCAPPX3_SSC14R    SC7P5T_ROWCAPLX8_SSC14R  SC7P5T_ROWCAPRX8_SSC14R"

set ADK_END_CAPL_CELL "SC7P5T_ROWCAPLX8_SSC14R"
set ADK_END_CAPR_CELL "SC7P5T_ROWCAPRX8_SSC14R"

#-------------------------------------------------------------------------
# ADK_ANTENNA_CELL
#-------------------------------------------------------------------------
# This list has the antenna diode cell used to avoid antenna DRC
# violations.

set ADK_ANTENNA_CELL "SC7P5T_ANTENNAX2_SSC14R"

#-------------------------------------------------------------------------
# ADK_LVS_EXCLUDE_CELL_LIST (OPTIONAL)
#-------------------------------------------------------------------------
# For LVS, we usually want a netlist that excludes physical cells that
# have no devices in them (or else LVS will have issues). Specifically for
# filler cells, the extracted layout will not have any trace of the
# fillers because there are no devices in them. Meanwhile, the schematic
# generated from the netlist will show filler cells instances with VDD/VSS
# ports, and this will cause LVS to flag a "mismatch" with the layout.
#
# This list can be used to filter out physical-only cells from the netlist
# generated for LVS. If this is left empty, LVS will just be a bit more
# difficult to deal with.

set ADK_LVS_EXCLUDE_CELL_LIST \
  "SC7P5T_FILLX* \
   SC7P5T_TIE* \
   SC7P5T_COLCAP* \
   SC7P5T_DECAPST* \
   SC7P5T_NOM1COLCAP* \
   SC7P5T_ROWCAP* \
   PAD* \
   PCORNERE* \
   PFILLERE*"

#-------------------------------------------------------------------------
# ADK_VIRTUOSO_EXCLUDE_CELL_LIST (OPTIONAL)
#-------------------------------------------------------------------------
# Similar to the case with LVS, we may want to filter out certain cells
# for Virtuoso simulation. Specifically, decaps can make Virtuoso
# simulation very slow. While we do eventually want to do a complete
# simulation including decaps, excluding them can speed up simulation
# significantly.
#
# This list can be used to filter out such cells from the netlist
# generated for Virtuoso simulation. If this is left empty, then Virtuoso
# simulations will just run more slowly.

set ADK_VIRTUOSO_EXCLUDE_CELL_LIST \
  "SC7P5T_FILLX* \
   SC7P5T_TIE* \
   SC7P5T_COLCAP* \
   SC7P5T_DECAPST* \
   SC7P5T_NOM1COLCAP* \
   SC7P5T_ROWCAP* \
   PAD* \
   PCORNERE* \
   PFILLERE*"

#  "FILL1* \
#   FILL2* \
#   FILLSGCAP* \
#   FILLTIE* \
#   ENDCAPTIE* \
#   PAD* \
#   PCORNERE* \
#   PFILLERE*"

