import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--east_not_west', type=int, default=0, help='generate east-version pin constraints')
east_not_west = parser.parse_args().east_not_west

hb_port_o = "i" if east_not_west==0 else "o"
hb_port_i = "o" if east_not_west==0 else "i"
hb_link_x_loc  = "$core_urx" if east_not_west==0 else "$core_llx"
sdr_link_x_loc = "$core_llx" if east_not_west==0 else "$core_urx"

print("### automatically generated from gen_hor_pin_constraints.py")
print("### east_not_west = {}".format(east_not_west))

ymap = {}
layermap = {}
Y_OFFSET = 0
curr_layer = "K1"

with open("../../../../../manycore_tile_pin_y.csv") as f:
  for line in f.readlines():
    stripped = line.strip()
    
    words = stripped.split(",")
    key = words[0]
    yval = float(words[1]) + Y_OFFSET
    ymap[key] = yval
    layermap[key] = words[2]

HB_LINK_WIDTH_P = 154
HB_RUCHE_LINK_WIDTH_P = 140

def place_pin(port, key, x):
  y = ymap[key]
  layer = layermap[key]
  print "set_individual_pin_constraints -ports {} -allowed_layers {} -location \"{} {}\"".format(port, layer, x, y)


########################################
for i in range(HB_RUCHE_LINK_WIDTH_P):
  # local link
  port = "core_hor_link_sif_{}[{}]".format(hb_port_o, i)
  key = "link_o[{}]".format(i)
  place_pin(port, key, hb_link_x_loc)

  # ruche link
  port = "core_ruche_link_{}[{}]".format(hb_port_o, i)
  ruche_idx = i if east_not_west==1 else (2*HB_RUCHE_LINK_WIDTH_P)+i
  key = "ruche_link_o[{}]".format(ruche_idx)
  place_pin(port, key, hb_link_x_loc)

for i in range(HB_RUCHE_LINK_WIDTH_P, HB_LINK_WIDTH_P):
  # local link
  port = "core_hor_link_sif_{}[{}]".format(hb_port_o, i)
  key = "link_o[{}]".format(i)
  place_pin(port, key, hb_link_x_loc)



for i in range(HB_RUCHE_LINK_WIDTH_P):
  # local link
  port = "core_hor_link_sif_{}[{}]".format(hb_port_i, i)
  key = "link_i[{}]".format(i)
  place_pin(port, key, hb_link_x_loc)

  # ruche link
  port = "core_ruche_link_{}[{}]".format(hb_port_i, i)
  ruche_idx = i if east_not_west==1 else (2*HB_RUCHE_LINK_WIDTH_P)+i
  key = "ruche_link_i[{}]".format(ruche_idx)
  place_pin(port, key, hb_link_x_loc)


for i in range(HB_RUCHE_LINK_WIDTH_P, HB_LINK_WIDTH_P):
  # local link
  port = "core_hor_link_sif_{}[{}]".format(hb_port_i, i)
  key = "link_i[{}]".format(i)
  place_pin(port, key, hb_link_x_loc)




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


# disable pins
port = "async_rev_link_o_disable_i"
key = "ruche_link_o[{}]".format(0)
place_pin(port, key, sdr_link_x_loc)

port = "async_fwd_link_o_disable_i"
key = "ruche_link_o[{}]".format(1)
place_pin(port, key, sdr_link_x_loc)

port = "async_rev_link_i_disable_i"
key = "ruche_link_o[{}]".format(2)
place_pin(port, key, sdr_link_x_loc)

port = "async_fwd_link_i_disable_i"
key = "ruche_link_o[{}]".format(3)
place_pin(port, key, sdr_link_x_loc)


# rev upstream
for i in range(HB_REV_PACKET_WIDTH):
  port = "io_rev_link_data_o[{}]".format(i)
  key = "link_o[{}]".format(i)
  place_pin(port, key, sdr_link_x_loc)

port = "io_rev_link_token_i"
key = "link_o[{}]".format(HB_REV_READY_IDX)
place_pin(port, key, sdr_link_x_loc)
  
port = "io_rev_link_v_o"
key = "link_o[{}]".format(HB_REV_VALID_IDX)
place_pin(port, key, sdr_link_x_loc)

port = "io_rev_link_clk_o"
key = "ruche_link_o[{}]".format((2*HB_RUCHE_LINK_WIDTH_P)+HB_REV_PACKET_WIDTH/2)
place_pin(port, key, sdr_link_x_loc)


# fwd upstream
for i in range(HB_FWD_PACKET_WIDTH):
  port = "io_fwd_link_data_o[{}]".format(i)
  key = "link_o[{}]".format(i+HB_FWD_START_IDX)
  place_pin(port, key, sdr_link_x_loc)

port = "io_fwd_link_token_i"
key = "link_o[{}]".format(HB_FWD_READY_IDX)
place_pin(port, key, sdr_link_x_loc)
  
port = "io_fwd_link_v_o"
key = "link_o[{}]".format(HB_FWD_VALID_IDX)
place_pin(port, key, sdr_link_x_loc)

port = "io_fwd_link_clk_o"
key = "ruche_link_o[{}]".format((2*HB_RUCHE_LINK_WIDTH_P)+HB_FWD_START_IDX+HB_FWD_PACKET_WIDTH/2)
place_pin(port, key, sdr_link_x_loc)



# rev downstream
for i in range(HB_REV_PACKET_WIDTH):
  port = "io_rev_link_data_i[{}]".format(i)
  key = "link_i[{}]".format(i)
  place_pin(port, key, sdr_link_x_loc)

port = "io_rev_link_token_o"
key = "link_i[{}]".format(HB_REV_READY_IDX)
place_pin(port, key, sdr_link_x_loc)
  
port = "io_rev_link_v_i"
key = "link_i[{}]".format(HB_REV_VALID_IDX)
place_pin(port, key, sdr_link_x_loc)

port = "io_rev_link_clk_i"
key = "ruche_link_i[{}]".format((2*HB_RUCHE_LINK_WIDTH_P)+HB_REV_PACKET_WIDTH/2)
place_pin(port, key, sdr_link_x_loc)

# fwd downstream
for i in range(HB_FWD_PACKET_WIDTH):
  port = "io_fwd_link_data_i[{}]".format(i)
  key = "link_i[{}]".format(i+HB_FWD_START_IDX)
  place_pin(port, key, sdr_link_x_loc)

port = "io_fwd_link_token_o"
key = "link_i[{}]".format(HB_FWD_READY_IDX)
place_pin(port, key, sdr_link_x_loc)
  
port = "io_fwd_link_v_i"
key = "link_i[{}]".format(HB_FWD_VALID_IDX)
place_pin(port, key, sdr_link_x_loc)

port = "io_fwd_link_clk_i"
key = "ruche_link_i[{}]".format((2*HB_RUCHE_LINK_WIDTH_P)+HB_FWD_START_IDX+HB_FWD_PACKET_WIDTH/2)
place_pin(port, key, sdr_link_x_loc)



