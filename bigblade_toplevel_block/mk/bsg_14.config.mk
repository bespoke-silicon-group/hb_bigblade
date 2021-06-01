export BSG_TOPLEVEL_DESIGN_TYPE :=block
export BSG_FLOW_STYLE           :=flat
export BSG_FLOW_USE_DP          :=true
export BSG_PACKAGE              :=basejump_fcbga_785
export BSG_PINOUT               :=bsg_bigblade_v0
export BSG_PACKAGING_FOUNDRY    :=gf_14_invecas_1p8v
export BSG_PADMAPPING           :=default

export PREP_MEMGEN_JSON_FILE := $(BSG_DESIGNS_TARGET_DIR)/json/gf_14/memgen.json 

#export BSG_FLOW_GENERATE_TOPLEVEL_ETM := true
export BSG_FLOW_GENERATE_TOPLEVEL_ETM := false

export BSG_POWER_GRID := bigblade_toplevel_block
export BSG_CAD_SETUP := default
export BSG_POWER_INTENT := sv_standard


export DC_FLOW_RMPLUS_FLOW :=rtm_exp
export DC_FLOW_ENABLE_TOPOGRAPHICAL_MODE := false
export DC_FLOW_COMPILE_DISABLE_CLOCK_GATING := false
export DC_FLOW_COMPILE_FLATTEN_DESIGN := false
export DC_FLOW_COMPILE_DISABLE_RETIMING := false
export DC_FLOW_INCREMENTAL_COMPILE_DISABLE_CLOCK_GATING := false
export DC_FLOW_INCREMENTAL_COMPILE_FLATTEN_DESIGN := false
export DC_FLOW_INCREMENTAL_COMPILE_DISABLE_RETIMING := false


export PTSI_FLOW_ACTIVITY_FILE :=
export PTSI_FLOW_ACTIVITY_WEIGHTS :=
export PTSI_FLOW_STRIP_PATH :=


#export USE_ICC2_2020 := 1

export ICC2_NUM_CORES := 32
export DC_NUM_CORES   := 32
