
write_sdf -compress gzip -version 3.0 -context Verilog -level 2 -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_level_2.sdf

write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/io_link" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_noc_io.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/mem_link_0__link" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_noc_mem_0.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/mem_link_1__link" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_noc_mem_1.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/mem_link_2__link" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_noc_mem_2.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/mem_link_3__link" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_noc_mem_3.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/mem_link_4__link" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_noc_mem_4.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/mem_link_5__link" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_noc_mem_5.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/mem_link_6__link" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_noc_mem_6.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/mem_link_7__link" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_noc_mem_7.sdf

write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/core_complex_core_0__clk_gen" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_clk_gen_0.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/core_complex_core_1__clk_gen" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_clk_gen_1.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/core_complex_core_2__clk_gen" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_clk_gen_2.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/core_complex_core_3__clk_gen" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_clk_gen_3.sdf

write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/core_complex_core_0__podrow" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_podrow_0.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/core_complex_core_1__podrow" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_podrow_1.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/core_complex_core_2__podrow" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_podrow_2.sdf
write_sdf -compress gzip -version 3.0 -context Verilog -instance "block/core_complex_core_3__podrow" -input_port_nets -output_port_nets ${RESULTS_DIR}/${DESIGN_NAME}_podrow_3.sdf
