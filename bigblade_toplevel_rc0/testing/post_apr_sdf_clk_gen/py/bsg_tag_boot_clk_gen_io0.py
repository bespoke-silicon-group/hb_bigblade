import sys
import os
sys.path.append(os.environ.get("BSG_DESIGNS_TARGET_DIR")+"/../common/util")
from bsg_tag_trace_gen import *

if __name__ == "__main__":

  # instantiate tg
  num_masters_p = 2
  num_clients_p = 1024
  max_payload_width_p = 12
  tg = TagTraceGen(num_masters_p, num_clients_p, max_payload_width_p)

  # parameters
  clk_num_clients_p  = 6
  sdr_num_clients_p  = 4
  dly_num_clients_p  = 4
  link_num_clients_p = 2+2*clk_num_clients_p+2*dly_num_clients_p
  noc_num_clients_p  = 2*link_num_clients_p+sdr_num_clients_p+1
  hp_num_clients_p   = 3+sdr_num_clients_p

  link_offset    = 0
  row_sdr_offset = link_offset+noc_num_clients_p*9
  row_pod_offset = row_sdr_offset+4*(2*sdr_num_clients_p)*4
  clk_gen_offset = row_pod_offset+4*1*4
  bp_clk_offset   = clk_gen_offset +4*clk_num_clients_p
  cgra_clk_offset = bp_clk_offset  +8*clk_num_clients_p
  bp_hp_offset    = cgra_clk_offset+8*clk_num_clients_p
  cgra_hp_offset  = bp_hp_offset   +8*hp_num_clients_p

  noc_local_offset = 2*link_num_clients_p
  dly_local_offset = 2+2*clk_num_clients_p

  # reset all bsg_tag_master
  tg.send(masters=0b11, client_id=0, data_not_reset=0, length=0, data=0)

  # wait 64 cycles
  tg.wait(64)


  # assert output_disable signal
  tg.send(masters=0b01, client_id=2, data_not_reset=1, length=1, data=0b1)

  # de-assert output_disable signal
  tg.send(masters=0b01, client_id=2, data_not_reset=1, length=1, data=0b0)


  # io / noc clocks
  for noc in range(1):
    for link in range(1):
      for clk in [0]:
        offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)+(clk*clk_num_clients_p)
        tg.send(masters=0b11, client_id=2+offset, data_not_reset=0, length=1, data=0b1)
        tg.send(masters=0b11, client_id=3+offset, data_not_reset=0, length=5, data=0b11111)
        tg.send(masters=0b11, client_id=4+offset, data_not_reset=0, length=1, data=0b1)
        tg.send(masters=0b11, client_id=5+offset, data_not_reset=0, length=7, data=0b1111111)
        tg.send(masters=0b11, client_id=6+offset, data_not_reset=0, length=2, data=0b11)
        tg.send(masters=0b11, client_id=7+offset, data_not_reset=0, length=1, data=0b1)

  for noc in range(1):
    for link in range(1):
      for clk in [0]:
        offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)+(clk*clk_num_clients_p)
  
        # select zero output clk
        tg.send(masters=0b10, client_id=6+offset, data_not_reset=1, length=2, data=0b11)
  
        # reset oscillator and trigger flops
        tg.send(masters=0b10, client_id=2+offset, data_not_reset=1, length=1, data=0b1)
        
        # init trigger to low, init oscillator to zero
        # OSC INIT VALUE MUST BE ZERO TO AVOID X IN SIMULATION
        tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=1, data=0b0)
        tg.send(masters=0b10, client_id=3+offset, data_not_reset=1, length=5, data=0b00000)
        
        # take oscillator and trigger flops out of reset
        tg.send(masters=0b10, client_id=2+offset, data_not_reset=1, length=1, data=0b0)
        
        # trigger oscillator value
        tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=1, data=0b1)
        tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=1, data=0b0)
        
        # reset ds, then set ds value
        tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=7, data=0b0000001)
        tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=7, data=0b0111110)
  
        # select ds output clk
        #tg.send(masters=0b10, client_id=6+offset, data_not_reset=1, length=2, data=0b01)
  
        # de-assert monitor ds reset
        tg.send(masters=0b10, client_id=7+offset, data_not_reset=1, length=1, data=0b0)
  
        # set ds value
        tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=7, data=0b0000010)
        
        for tap in range(32):
          tg.send(masters=0b10, client_id=3+offset, data_not_reset=1, length=5, data=tap)
          tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=1, data=0b1)
          tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=1, data=0b0)

        # set ds value
        tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=7, data=0b0000000)
        
        for tap in range(16):
          tg.send(masters=0b10, client_id=3+offset, data_not_reset=1, length=5, data=tap)
          tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=1, data=0b1)
          tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=1, data=0b0)



  tg.wait(64)
  tg.done()
