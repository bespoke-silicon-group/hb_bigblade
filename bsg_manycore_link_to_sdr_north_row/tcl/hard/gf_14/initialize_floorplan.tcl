source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_common_variables.tcl


initialize_floorplan \
  -control_type core \
  -coincident_boundary true \
  -shape R \
  -side_length "$sdr_vert_row_width $sdr_vert_row_height"

