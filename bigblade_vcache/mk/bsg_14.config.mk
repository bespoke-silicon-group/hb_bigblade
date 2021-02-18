export BSG_TOPLEVEL_DESIGN_TYPE :=block
export BSG_FLOW_STYLE           :=hier
export BSG_FLOW_USE_DP          :=true
export BSG_TARGET_PROCESS       :=gf_14
export BSG_PACKAGE              :=uw_bga
export BSG_PINOUT               :=bsg_asic_cloud
export BSG_PACKAGING_FOUNDRY    :=gf_14_invecas_1p8v
export BSG_PADMAPPING           :=default

export PREP_MEMGEN_JSON_FILE := $(BSG_DESIGNS_TARGET_DIR)/json/gf_14/memgen.json 

export BSG_FLOW_GENERATE_TOPLEVEL_ETM := true


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


export PDK_ENABLE_KIT_IV7P5_RVT_C14  		:=true
export PDK_ENABLE_KIT_IV7P5_LVT_C14  		:=true
export PDK_ENABLE_KIT_IV7P5_SLVT_C14 		:=true
export PDK_ENABLE_KIT_IV7P5_HVT_C16  		:=false
export PDK_ENABLE_KIT_IV7P5_RVT_C16  		:=true
export PDK_ENABLE_KIT_IV7P5_LVT_C16  		:=true
export PDK_ENABLE_KIT_IV7P5_SLVT_C16 		:=true
export PDK_ENABLE_KIT_IV7P5_HVT_LPK  		:=false
export PDK_ENABLE_KIT_IV7P5_RVT_LPK  		:=false
export PDK_ENABLE_KIT_IV7P5_LVT_LPK  		:=false
export PDK_ENABLE_KIT_IV7P5_SLVT_LPK 		:=false
export PDK_ENABLE_KIT_IV7P5_HVT_HPK  		:=false
export PDK_ENABLE_KIT_IV7P5_RVT_HPK  		:=true
export PDK_ENABLE_KIT_IV7P5_LVT_HPK  		:=true
export PDK_ENABLE_KIT_IV7P5_SLVT_HPK 		:=true
export PDK_ENABLE_KIT_IV7P5_HVT_ECO  		:=false
export PDK_ENABLE_KIT_IV7P5_RVT_ECO  		:=false
export PDK_ENABLE_KIT_IV7P5_LVT_ECO  		:=false
export PDK_ENABLE_KIT_IV7P5_SLVT_ECO 		:=false
export PDK_ENABLE_KIT_IV7P5_HVT_SHIFT  	:=false
export PDK_ENABLE_KIT_IV7P5_RVT_SHIFT  	:=false
export PDK_ENABLE_KIT_IV7P5_LVT_SHIFT  	:=false
export PDK_ENABLE_KIT_IV7P5_SLVT_SHIFT 	:=false
export PDK_ENABLE_KIT_IV1P8V_GPIO      	:=true
export PDK_ENABLE_KIT_MEMGEN           	:=true
export PDK_ENABLE_KIT_CDMM             	:=true

export PDK_ENABLE_RVT_LIB  :=true
export PDK_ENABLE_HVT_LIB  :=false
export PDK_ENABLE_LVT_LIB  :=true
export PDK_ENABLE_SLVT_LIB :=true

export PDK_ENABLE_LPK_LIB   :=false
export PDK_ENABLE_HPK_LIB   :=true
export PDK_ENABLE_ECO_LIB   :=false
export PDK_ENABLE_SHIFT_LIB :=false

export PDK_ENABLE_GPIO_LIB   :=false
export PDK_ENABLE_MEMGEN_LIB :=true

export BSG_POWER_INTENT := sv_standard




time.pnr:
	grep -R current_build/pnr/ -e "^real.*m.*s$$" --color

time.dp:
	grep -R current_build/dp/logs -e "^real.*m.*s$$" --color

time.synth:
	grep -R current_build/synth/ -e "^real.*m.*s$$" --color
