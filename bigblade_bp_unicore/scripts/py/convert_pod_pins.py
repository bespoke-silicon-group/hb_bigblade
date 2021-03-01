#!/usr/bin/python

import sys
import re

if __name__ == "__main__":
    csv_in_path = sys.argv[1]
    csv_out_path = sys.argv[2]

    with open(csv_in_path, "r") as file_in:
        with open(csv_out_path, "w") as file_out:
            for line in file_in.readlines():
                # Filter out tiles > 2 (we only have 3 lineks)
                tile_number = int(re.search(r'y_(\d+)', line).group(1))
                if tile_number < 5:
                    continue
                if "ruche" in line and tile_number != 6:
                    continue

                # How many tiles from the bottom
                tile_offset = 7 - tile_number

                # Filter out pod prefix
                bp_pin = re.sub("\w+/","",line)

                # Flip pins
                bp_pin = bp_pin.replace("ruche_link_o", "mc_ruche_links_i").replace("ruche_link_i", "mc_ruche_links_o")
                bp_pin = bp_pin.replace("link_i", "mc_hor_links_o").replace("link_o", "mc_hor_links_i")

                # Offset hor and ruche links
                pin_number = int(re.search(r'\[(\d+)\]', bp_pin).group(1))
                if "ruche" in bp_pin:
                    offset = -280
                else:
                    offset = (7 - tile_number) * 154
                bp_pin = bp_pin.replace('[' + str(pin_number) + ']', '[' + str(pin_number+offset) + ']')

                # Offset initial pin location
                pos = float(re.search(r',(\d+.\d+)', bp_pin).group(1))
                bp_pin = bp_pin.replace(str(pos), str(pos-155.52))

                file_out.write(bp_pin)

