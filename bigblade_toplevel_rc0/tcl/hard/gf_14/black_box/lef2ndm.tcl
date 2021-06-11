set DESIGN_NAME $::env(DESIGN_NAME)
source $::env(BSG_CAD_SETUP_SCRIPT)
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
create_workspace -flow normal -technology ${ICC2_TECH_FILE} work
read_lef ./${DESIGN_NAME}.lef
current_block bsg_chip_block:bsg_chip_block.design
set_app_options -name lib.physical_model.pin_channel_distances -value {{G1 50} {G2 50}}
check_workspace -allow_missing
#commit_workspace -force -output ${DESIGN_NAME}_black_box.ndm
commit_workspace -force -output ${DESIGN_NAME}_etm.ndm
exit
