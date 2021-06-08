
# For this design, we want to generate a simple physical only view of the
# bigblade_toplevel_block_rc0 before we start design planning.

generate_black_box:
	$(eval export DESIGN_NAME=bsg_chip_block)
	cd $(BSG_DESIGNS_TARGET_DIR)/../bigblade_toplevel_block_rc0/bsg_14/current_build/pnr/bsg_chip_block && \
		$(ICC2_SHELL) -f $(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14/black_box/generate_lef_from_init_design.tcl
	mkdir -p $(BUILD_DIR)/black_box/$(DESIGN_NAME)
	mv /tmp/temp_$(DESIGN_NAME).lef $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef.orig
	cp $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef.orig $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER T1/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER G1/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER G2/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER C4/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER C5/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER H1/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER H2/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER J3/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER A4/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER CK/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER U1/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER U2/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER U3/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER KH/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER N1/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER HG/,/LAYER/{/RECT/d}}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER C4/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER C5/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER H1/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER H2/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER G1/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER G2/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER J3/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER A4/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER CK/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER U1/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER U2/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER U3/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER KH/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER N1/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER HG/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	sed -i -e '/OBS/,/END/{/LAYER T1/d}' $(BUILD_DIR)/black_box/$(DESIGN_NAME)/$(DESIGN_NAME).lef
	cd $(BUILD_DIR)/black_box/$(DESIGN_NAME) && \
		$(ICC2_LM_SHELL) -f $(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14/black_box/lef2ndm.tcl
	touch $(BUILD_VPATH)/$@

clean.generate_black_box:
	rm -rf $(BUILD_DIR)/black_box
	rm -f $(BUILD_VPATH)/generate_black_box

dp.init_dp: | generate_black_box

