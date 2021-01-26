
import math
import sys

class NBF:

    # Initialize
    def __init__(self, filename):
        self.filename = filename
        self.addr_width = 32
        self.data_width = 32
        self.cache_block_size = 256
        self.cache_set = 64
        self.cache_ways = 8
        self.cache_size = self.cache_set * self.cache_ways * self.cache_block_size / self.data_width
        self.num_tiles_x = 16
        self.num_tiles_y = 8

    # BSG_SAFE_CLOG2(x)
    def safe_clog2(self, x):
      if x == 1:
        return 1
      else:
        return int(math.ceil(math.log(x,2)))
  
    # take width and val and convert to binary string
    def get_binstr(self, val, width):
        return format(val, "0"+str(width)+"b")

    # take width and val and convert to hex string
    def get_hexstr(self, val, width):
        return format(val, "0"+str(width)+"x")

    # Selects bits from a number
    def select_bits(self, num, start, end):
        retval = 0

        for i in range(start, end+1):
            b = num & (1 << i)
            retval = retval | b

        return (retval >> start)

    # take x,y coord, epa, data and turn it into nbf format.
    def print_nbf(self, x, y, epa, data):
        line =  self.get_hexstr(x, 2) + "_"
        line += self.get_hexstr(y, 2) + "_"
        line += self.get_hexstr(epa, 8) + "_"
        line += self.get_hexstr(data, 8)
        print(line)

    # Initialize DRAMs
    def init_dram(self):
        cache_size = self.cache_size
        lg_x = self.safe_clog2(self.num_tiles_x)
        lg_block_size = self.safe_clog2(self.cache_block_size)
        lg_set = self.safe_clog2(self.cache_set)
        index_width = self.addr_width-1-lg_block_size-1

        f = open(self.filename, "r")

        curr_addr = 0
        count = 0

        # hashing for power of 2 banks
        for line in f.readlines():
            stripped = line.strip()
            if not stripped:
                continue
            elif stripped.startswith("@"):
                curr_addr = int(stripped.strip("@"), 16)
                continue

            for word in stripped.split(): 
                # TODO: This hash function is broken
                addr = curr_addr
                data = int(word, 16)
                x = self.select_bits(addr, lg_block_size, lg_block_size + lg_x - 1) + 1
                y = self.select_bits(addr, lg_block_size + lg_x, lg_block_size + lg_x)
                index = self.select_bits(addr, lg_block_size+lg_x+1, lg_block_size+lg_x+1+index_width-1)
                epa = self.select_bits(addr, 0, lg_block_size-1) | (index << lg_block_size)
                curr_addr += 4

                if y == 0:
                    self.print_nbf(x, 0, epa, data)
                else:
                    self.print_nbf(x, num_tiles_y, epa, data)

    #  // BP EPA Map
    #  // dev: 0 -- CFG
    #  //      1 -- CCE ucode
    #  //      2 -- CLINT
    #  typedef struct packed
    #  {
    #    logic [3:0]  dev;
    #    logic [11:0] addr;
    #  } bp_epa_s;

    # BP core configuration
    def init_config(self):
        cfg_base_addr          = 0x0000
        cfg_reg_freeze         = 0x02
        cfg_domain_mask        = 0x09
        cfg_sac_mask           = 0x0a
        cfg_reg_icache_mode    = 0x22
        cfg_reg_dcache_mode    = 0x43

        self.print_nbf(0, 1, cfg_base_addr + cfg_domain_mask, -1)
        self.print_nbf(0, 1, cfg_base_addr + cfg_sac_mask, -1)
        self.print_nbf(0, 1, cfg_base_addr + cfg_reg_icache_mode, -1)
        self.print_nbf(0, 1, cfg_base_addr + cfg_reg_dcache_mode, -1)

        self.fence()

        self.print_nbf(0, 1, cfg_base_addr + cfg_reg_freeze, 0)

    # print finish
    def finish(self):
        self.print_nbf(0xff, 0xff, 0xffffffff, 0xffffffff)

    # fence
    def fence(self):
        self.print_nbf(0xff, 0xff, 0x0, 0x0)

    # Dump the nbf
    def dump(self):
        self.init_dram()
        self.fence()
        self.init_config()
        self.fence()
        self.finish()


if __name__ == "__main__":
    if len(sys.argv) == 2:
        gen = NBF(sys.argv[1])
        gen.dump()
    else:
        print("Usage: nbf.py filename.mem")

