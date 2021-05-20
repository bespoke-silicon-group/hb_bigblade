puts "BSG-info: Running script [info script]\n"

# BSG-STD: optimize some hotspots that have DRCs and try to spot fix them
optimize_routability -route
optimize_routability -remove_keepouts

puts "BSG-info: Completed script [info script]\n"
