config bsg_config;
  design `BSG_DESIGNS_TESTING_LIBRARY_NAME.`BSG_TOP_SIM_MODULE;
  default liblist `BSG_DESIGNS_TESTING_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME work;
  instance `BSG_CHIP_INSTANCE_PATH liblist `BSG_CHIP_LIBRARY_NAME;

  // each ip block with its library
  cell bsg_manycore_tile_compute_ruche liblist `BSG_MANYCORE_TILE_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
  cell bsg_manycore_tile_vcache liblist `BSG_MANYCORE_TILE_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
  
  //cell bigblade_clk_gen liblist `BIGBLADE_CLK_GEN_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
  //cell bsg_chip_io_link_ddr liblist `BIGBLADE_IO_LINK_DDR_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;

  //cell bsg_chip_noc_io_link liblist `BIGBLADE_NOC_IO_LINK_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
  //cell bsg_chip_noc_mem_link liblist `BIGBLADE_NOC_MEM_LINK_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;

  cell bsg_manycore_link_ruche_to_sdr_east liblist `BSG_MANYCORE_LINK_SDR_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
  cell bsg_manycore_link_ruche_to_sdr_west liblist `BSG_MANYCORE_LINK_SDR_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
  cell bsg_manycore_link_to_sdr_north liblist `BSG_MANYCORE_LINK_SDR_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
  cell bsg_manycore_link_to_sdr_south liblist `BSG_MANYCORE_LINK_SDR_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
  cell bsg_manycore_link_wh_to_sdr_ne liblist `BSG_MANYCORE_LINK_SDR_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
  cell bsg_manycore_link_wh_to_sdr_nw liblist `BSG_MANYCORE_LINK_SDR_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
  cell bsg_manycore_link_wh_to_sdr_se liblist `BSG_MANYCORE_LINK_SDR_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;
  cell bsg_manycore_link_wh_to_sdr_sw liblist `BSG_MANYCORE_LINK_SDR_LIBRARY_NAME `BSG_CHIP_LIBRARY_NAME;

endconfig
