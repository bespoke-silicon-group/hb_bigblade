puts "BSG-info: Running script [info script]\n"

#route_eco
set REPORT_QOR 0
set REPORT_QOR_REPORT_CONGESTION 0
 
remove_placement_blockages [get_placement_blockages "bsg_*"] 


puts "BSG-info: Completed script [info script]\n"
