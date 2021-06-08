set PLACEMENT_FORCE_BOUNDARY_CELL_INSERTION "true"

set TIMING_DRIVEN_PLACEMENT ""

# Specify a Tcl script to read in your TLU+ files by using the read_parasitic_tech command
if {[file exists [which $TCL_PARASITIC_SETUP_FILE]]} {
   puts "RM-info : Sourcing [which $TCL_PARASITIC_SETUP_FILE]"
   source -echo $TCL_PARASITIC_SETUP_FILE
} elseif {$TCL_PARASITIC_SETUP_FILE != ""} {
   puts "RM-error : TCL_PARASITIC_SETUP_FILE($TCL_PARASITIC_SETUP_FILE) is invalid. Please correct it."
} else {
   puts "RM-info : No TLU plus files sourced, Parastic library containing TLU+ must be included in library reference list"
}

# BSG-STD: Modified to use search path
if {[file exists [which $TCL_MCMM_SETUP_FILE]]} {
   puts "RM-info : Loading TCL_MCMM_SETUP_FILE ([which $TCL_MCMM_SETUP_FILE])"
   source -echo $TCL_MCMM_SETUP_FILE 
} else {
   puts "RM-error : Cannot find TCL_MCMM_SETUP_FILE ($TCL_MCMM_SETUP_FILE)"
   error
}
