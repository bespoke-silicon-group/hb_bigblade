
puts "BSG-info: Running script [info script]\n"

########################################
## Source common scripts
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/hb_design_constants.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_async.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_cdc.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/../common/bsg_chip_misc.tcl
source -echo -verbose $::env(BASEJUMP_STL_DIR)/hard/gf_14/bsg_link/tcl/bsg_link_sdr.constraints.tcl

source -echo -verbose $::env(BSG_DESIGNS_TARGET_DIR)/tcl/hard/gf_14/adk.tcl

########################################
## App Var Setup
# Needed for CDC multiple clock path constraints
set_app_var timing_enable_multiple_clocks_per_reg true
# Needed for retiming in some cases
set_app_var compile_keep_original_for_external_references true
# Needed for automatic clock-gate insertions
set_app_var case_analysis_propagate_through_icg true


  #=========================================================================
  # Design Constraints File
  #=========================================================================
  
  # This constraint sets the target clock period for the chip in
  # nanoseconds. Note that the first parameter is the name of the clock
  # signal in your verlog design. If you called it something different than
  # clk you will need to change this. You should set this constraint
  # carefully. If the period is unrealistically small then the tools will
  # spend forever trying to meet timing and ultimately fail. If the period
  # is too large the tools will have no trouble but you will get a very
  # conservative implementation.
  
  set clock_net  clk
  set clock_name core_clk
  set clock_period 1000
  
  create_clock -name ${clock_name} \
               -period ${clock_period} \
               [get_ports ${clock_net}]
  set_clock_uncertainty 20 [get_clocks $clock_name]

  # This constraint sets the load capacitance in picofarads of the
  # output pins of your design.
  
  #set_load -pin_load $ADK_TYPICAL_ON_CHIP_LOAD [all_outputs]
  set load_lib_pin $LIB_CELLS(invx8,load_pin)
  set_load [load_of [get_lib_pin */${load_lib_pin}]] [all_outputs]
  
  # This constraint sets the input drive strength of the input pins of
  # your design. We specifiy a specific standard cell which models what
  # would be driving the inputs. This should usually be a small inverter
  # which is reasonable if another block of on-chip logic is driving
  # your inputs.
  
  #set_driving_cell -no_design_rule \
  #  -lib_cell $ADK_DRIVING_CELL [all_inputs]

  set_driving_cell -min -no_design_rule -lib_cell $LIB_CELLS(invx2) [all_inputs]
  set_driving_cell -max -no_design_rule -lib_cell $LIB_CELLS(invx8) [all_inputs]
  set_driving_cell -no_design_rule -lib_cell "SC7P5T_CKBUFX1_SSC14R" [get_ports clk]
  
  # set_input_delay constraints for input ports
  #
  # - make this non-zero to avoid hold buffers on input-registered designs
  
  set_input_delay -clock ${clock_name} [expr ${clock_period}*0.3] [all_inputs]
  
  # set_output_delay constraints for output ports
  
  set_output_delay -clock ${clock_name} [expr ${clock_period}*0.6] [all_outputs]
  
  # Make all signals limit their fanout
  
  #set_max_fanout 20 $DESIGN_NAME
  
  # Make all signals meet good slew
  
  #set_max_transition [expr 0.25*${clock_period}] $DESIGN_NAME
  
  #set_input_transition 1 [all_inputs]
  #set_max_transition 10 [all_outputs]
  
  #-------------------------------------------------------------------------
  # Register retiming
  #-------------------------------------------------------------------------
  
  set_optimize_registers true \
                         -design LLFU \
                         -clock ${clock_name} \
                         -delay_threshold ${clock_period} \
                         -check_design \
                         -verbose \
                         -print_critical_loop
  
  #-------------------------------------------------------------------------
  # Disable timing
  #-------------------------------------------------------------------------

  set_false_path -from [get_ports x_cord[*]]
  set_false_path -from [get_ports y_cord[*]]

