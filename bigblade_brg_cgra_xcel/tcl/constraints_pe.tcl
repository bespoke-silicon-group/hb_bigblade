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
set clock_name ideal_clock
set clock_uncertainty_ps 20

create_clock -name ${clock_name} \
             -period ${dc_clock_period} \
             [get_ports ${clock_net}]
set_clock_uncertainty [expr $clock_uncertainty_ps] [get_clocks $clock_name]

# This constraint sets the load capacitance in picofarads of the
# output pins of your design.

set_load -pin_load $ADK_TYPICAL_ON_CHIP_LOAD [all_outputs]

# This constraint sets the input drive strength of the input pins of
# your design. We specifiy a specific standard cell which models what
# would be driving the inputs. This should usually be a small inverter
# which is reasonable if another block of on-chip logic is driving
# your inputs.

set_driving_cell -no_design_rule \
  -lib_cell $ADK_DRIVING_CELL [all_inputs]

# set_input_delay constraints for input ports
#
# - make this non-zero to avoid hold buffers on input-registered designs

set_input_delay -clock ${clock_name} [expr ${dc_clock_period}*0.2] [all_inputs]

# set_output_delay constraints for output ports

set_output_delay -clock ${clock_name} [expr ${dc_clock_period}*0.1] [all_outputs]

# Make all signals limit their fanout

set_max_fanout 20 $dc_design_name

# Make all signals meet good slew

set_max_transition [expr 0.25*${dc_clock_period}] $dc_design_name

#set_input_transition 1 [all_inputs]
#set_max_transition 10 [all_outputs]

#-------------------------------------------------------------------------
# Register retiming
#-------------------------------------------------------------------------

if {[info exists ::env(llfu_name)]} {
set_optimize_registers true \
                       -design $::env(llfu_name)\
                       -clock ${clock_name} \
                       -delay_threshold ${dc_clock_period} \
                       -check_design \
                       -verbose \
                       -print_critical_loop
}

#-------------------------------------------------------------------------
# Disable timing
#-------------------------------------------------------------------------

# if {[info exists ::env(pe_ddc)]} {
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__7/in_q__3/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__15/in_q__3/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__23/in_q__3/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__31/in_q__3/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__39/in_q__3/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__47/in_q__3/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__55/in_q__3/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__56/in_q__0/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__57/in_q__0/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__58/in_q__0/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__59/in_q__0/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__60/in_q__0/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__61/in_q__0/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__62/in_q__0/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__63/in_q__0/dpath/queue/clk_gate_regs_reg_*/latch/Z]
#   set_disable_timing [get_pins cgra_xcel/dpath/cgra/dpath/PE_rc__63/in_q__3/dpath/queue/clk_gate_regs_reg_*/latch/Z]
# }
