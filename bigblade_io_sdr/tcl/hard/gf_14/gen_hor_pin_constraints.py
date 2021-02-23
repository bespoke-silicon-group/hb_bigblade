print("### automatically generated from gen_hor_pin_constraints.py")

ymap = {}
layermap = {}
Y_OFFSET = -158.336+(0.128*22)
curr_layer = "K1"

with open("../../../../common/pod_pin_y.csv") as f:
  for line in f.readlines():
    stripped = line.strip()
    if not stripped.startswith("pod_mc_y_7"):
      continue
    
    words = stripped.split(",")
    key = words[0].split("/")[1]
    yval = float(words[1]) + Y_OFFSET
    ymap[key] = yval
    layermap[key] = curr_layer
    if curr_layer == "K1":
      curr_layer = "K3"
    else:
      curr_layer = "K1"

HB_LINK_WIDTH_P = 154
HB_RUCHE_LINK_WIDTH_P = 140

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

