
# For this design, we want to generate a simple physical only view of the
# bigblade_toplevel_block before we start design planning.

generate_toplevel_block_bbox:
	$(MAKE) -C $(BSG_DESIGNS_TARGET_DIR)/../bigblade_toplevel_block/bsg_14/current_build dp.place_pins
	touch $(BUILD_VPATH)/$@

clean.generate_toplevel_block_bbox:
	rm -f $(BUILD_VPATH)/generate_toplevel_block_bbox

dp.init_dp: | generate_toplevel_block_bbox

