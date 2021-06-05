set DESIGN_NAME $::env(DESIGN_NAME)
source $::env(BSG_CAD_SETUP_SCRIPT)
set_app_options -name lib.workspace.allow_missing_related_pg_pins -value true
create_workspace -flow normal -technology ${ICC2_TECH_FILE} work
read_lef ./${DESIGN_NAME}.lef
check_workspace -allow_missing
commit_workspace -force -output ${DESIGN_NAME}_black_box.ndm
exit
