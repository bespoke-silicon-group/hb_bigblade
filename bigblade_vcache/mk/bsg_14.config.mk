export BSG_TOPLEVEL_DESIGN_TYPE :=block
export BSG_FLOW_STYLE           :=flat
export BSG_FLOW_USE_DP          :=true
export BSG_PACKAGE              :=uw_bga
export BSG_PINOUT               :=bsg_asic_cloud
export BSG_PACKAGING_FOUNDRY    :=gf_14_invecas_1p8v
export BSG_PADMAPPING           :=default

export PREP_MEMGEN_JSON_FILE := $(BSG_DESIGNS_TARGET_DIR)/json/gf_14/memgen.json 

export BSG_FLOW_GENERATE_TOPLEVEL_ETM := true

export BSG_POWER_GRID := default_wb
export BSG_CAD_SETUP := default
export BSG_POWER_INTENT := sv_standard



export DC_FLOW_RMPLUS_FLOW :=
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





time.pnr:
	grep -R current_build/pnr/ -e "^real.*m.*s$$" --color

time.dp:
	grep -R current_build/dp/logs -e "^real.*m.*s$$" --color

time.synth:
	grep -R current_build/synth/ -e "^real.*m.*s$$" --color
