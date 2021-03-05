print("### automatically generated from gen_hor_pin_constraints.py")

ymap = {}
layermap = {}
Y_OFFSET = 0
curr_layer = "K1"

with open("../../../../common/manycore_tile_pin_y.csv") as f:
  for line in f.readlines():
    stripped = line.strip()
    
    words = stripped.split(",")
    key = words[0]
    yval = float(words[1]) + Y_OFFSET
    ymap[key] = yval
    layermap[key] = curr_layer
    if curr_layer == "K1":
      curr_layer = "K3"
    else:
      curr_layer = "K1"

HB_LINK_WIDTH_P = 154
HB_RUCHE_LINK_WIDTH_P = 140

def place_pin(port, key, x):
  y = ymap[key]
  layer = layermap[key]
  print "set_individual_pin_constraints -ports {} -allowed_layers {} -location \"{} {}\"".format(port, layer, x, y)


########################################
for i in range(HB_RUCHE_LINK_WIDTH_P):
  # local link
  port = "core_hor_link_sif_i[{}]".format(i)
  key = "link_o[{}]".format(i)
  y = ymap[key]
  layer = layermap[key]
  print "set_individual_pin_constraints -ports {} -allowed_layers {} -location \"$core_urx {}\"".format(port, layer, y)

  # ruche link
  port = "core_ruche_link_i[{}]".format(i)
  key = "ruche_link_o[{}]".format((2*HB_RUCHE_LINK_WIDTH_P)+i)
  y = ymap[key]
  layer = layermap[key]
  print "set_individual_pin_constraints -ports {} -allowed_layers {} -location \"$core_urx {}\"".format(port, layer, y)

for i in range(HB_RUCHE_LINK_WIDTH_P, HB_LINK_WIDTH_P):
  # local link
  port = "core_hor_link_sif_i[{}]".format(i)
  key = "link_o[{}]".format(i)
  y = ymap[key]
  layer = layermap[key]
  print "set_individual_pin_constraints -ports {} -allowed_layers {} -location \"$core_urx {}\"".format(port, layer, y)



for i in range(HB_RUCHE_LINK_WIDTH_P):
  # local link
  port = "core_hor_link_sif_o[{}]".format(i)
  key = "link_i[{}]".format(i)
  y = ymap[key]
  layer = layermap[key]
  print "set_individual_pin_constraints -ports {} -allowed_layers {} -location \"$core_urx {}\"".format(port, layer, y)

  # ruche link
  port = "core_ruche_link_o[{}]".format(i)
  key = "ruche_link_i[{}]".format((2*HB_RUCHE_LINK_WIDTH_P)+i)
  y = ymap[key]
  layer = layermap[key]
  print "set_individual_pin_constraints -ports {} -allowed_layers {} -location \"$core_urx {}\"".format(port, layer, y)


for i in range(HB_RUCHE_LINK_WIDTH_P, HB_LINK_WIDTH_P):
  # local link
  port = "core_hor_link_sif_o[{}]".format(i)
  key = "link_i[{}]".format(i)
  y = ymap[key]
  layer = layermap[key]
  print "set_individual_pin_constraints -ports {} -allowed_layers {} -location \"$core_urx {}\"".format(port, layer, y)




##################################
HB_REV_PACKET_WIDTH   =  53
HB_REV_READY_IDX      =  53
HB_REV_VALID_IDX      =  54

HB_FWD_START_IDX      =  55
HB_FWD_PACKET_WIDTH   =  97
HB_FWD_READY_IDX      =  152
HB_FWD_VALID_IDX      =  153


HB_RUCHE_REV_PACKET_WIDTH   =  46
HB_RUCHE_REV_READY_IDX      =  46
HB_RUCHE_REV_VALID_IDX      =  47
HB_RUCHE_FWD_START_IDX      =  48
HB_RUCHE_FWD_PACKET_WIDTH   =  90
HB_RUCHE_FWD_READY_IDX      =  138
HB_RUCHE_FWD_VALID_IDX      =  139


# rev upstream
for i in range(HB_REV_PACKET_WIDTH):
  port = "io_rev_link_data_o[{}]".format(i)
  key = "link_o[{}]".format(i)
  place_pin(port, key, "$core_llx")

port = "io_rev_link_token_i"
key = "link_o[{}]".format(HB_REV_READY_IDX)
place_pin(port, key, "$core_llx")
  
port = "io_rev_link_v_o"
key = "link_o[{}]".format(HB_REV_VALID_IDX)
place_pin(port, key, "$core_llx")

port = "io_rev_link_clk_o"
key = "ruche_link_o[{}]".format((2*HB_RUCHE_LINK_WIDTH_P)+HB_REV_PACKET_WIDTH/2)
place_pin(port, key, "$core_llx")


# fwd upstream
for i in range(HB_FWD_PACKET_WIDTH):
  port = "io_fwd_link_data_o[{}]".format(i)
  key = "link_o[{}]".format(i+HB_FWD_START_IDX)
  place_pin(port, key, "$core_llx")

port = "io_fwd_link_token_i"
key = "link_o[{}]".format(HB_FWD_READY_IDX)
place_pin(port, key, "$core_llx")
  
port = "io_fwd_link_v_o"
key = "link_o[{}]".format(HB_FWD_VALID_IDX)
place_pin(port, key, "$core_llx")

port = "io_fwd_link_clk_o"
key = "ruche_link_o[{}]".format((2*HB_RUCHE_LINK_WIDTH_P)+HB_FWD_START_IDX+HB_FWD_PACKET_WIDTH/2)
place_pin(port, key, "$core_llx")



# rev downstream
for i in range(HB_REV_PACKET_WIDTH):
  port = "io_rev_link_data_i[{}]".format(i)
  key = "link_i[{}]".format(i)
  place_pin(port, key, "$core_llx")

port = "io_rev_link_token_o"
key = "link_i[{}]".format(HB_REV_READY_IDX)
place_pin(port, key, "$core_llx")
  
port = "io_rev_link_v_i"
key = "link_i[{}]".format(HB_REV_VALID_IDX)
place_pin(port, key, "$core_llx")

port = "io_rev_link_clk_i"
key = "ruche_link_i[{}]".format((2*HB_RUCHE_LINK_WIDTH_P)+HB_REV_PACKET_WIDTH/2)
place_pin(port, key, "$core_llx")

# fwd downstream
for i in range(HB_FWD_PACKET_WIDTH):
  port = "io_fwd_link_data_i[{}]".format(i)
  key = "link_i[{}]".format(i+HB_FWD_START_IDX)
  place_pin(port, key, "$core_llx")

port = "io_fwd_link_token_o"
key = "link_i[{}]".format(HB_FWD_READY_IDX)
place_pin(port, key, "$core_llx")
  
port = "io_fwd_link_v_i"
key = "link_i[{}]".format(HB_FWD_VALID_IDX)
place_pin(port, key, "$core_llx")

port = "io_fwd_link_clk_i"
key = "ruche_link_i[{}]".format((2*HB_RUCHE_LINK_WIDTH_P)+HB_FWD_START_IDX+HB_FWD_PACKET_WIDTH/2)
place_pin(port, key, "$core_llx")



