ifeq ($(design),hb_cgra_pod_pe_0.3.12)
  design_name  = ProcElement
  llfu_name    = LLFU
  clock_period = 855.0
  design_v     = ../designs/hb_cgra_pod_0.3.12/hb_bigblade_cgra/v/HBEndpointCGRAXcel_8x8Array_4x4KB
  setup_script = ../designs/hb_cgra_pod_0.3.12/hb_bigblade_cgra/tcl/module_setup_pe.tcl
  basejump_stl_dir = ../designs/hb_cgra_pod_0.3.12/basejump_stl
  bsg_manycore_dir = ../designs/hb_cgra_pod_0.3.12/bsg_manycore
  cgra_dir     = ../designs/hb_cgra_pod_0.3.12/hb_bigblade_cgra
endif

ifeq ($(design),hb_cgra_pod_0.3.12)
  design_name  = brg_cgra_pod
  pe_ddc       = ../build-cgra-pod-pe-0.3.12/results/dc-synthesis/ProcElement.mapped.ddc
  clock_period = 950.0
  design_v     = ../designs/hb_cgra_pod_0.3.12/hb_bigblade_cgra/v/brg_cgra_pod.v
  setup_script = ../designs/hb_cgra_pod_0.3.12/hb_bigblade_cgra/tcl/module_setup.tcl
  basejump_stl_dir = ../designs/hb_cgra_pod_0.3.12/basejump_stl
  bsg_manycore_dir = ../designs/hb_cgra_pod_0.3.12/bsg_manycore
  cgra_dir     = ../designs/hb_cgra_pod_0.3.12/hb_bigblade_cgra
endif

puts "BSG-info: Running script [info script]\n"

# constraints dir
set constraints_dir $::env(BSG_DESIGNS_TARGET_DIR)/tcl

if { ${DESIGN_NAME} == "hb_cgra_pod" } {
  source -echo -verbose $constraints_dir/.constraints.tcl
if { ${DESIGN_NAME} == "brg_cgra_pod" } {
  source -echo -verbose $constraints_dir/constraints_pod.tcl
} elseif { ${DESIGN_NAME} == "ProcElement" } {
  source -echo -verbose $constraints_dir/constraints_pe.tcl
}
