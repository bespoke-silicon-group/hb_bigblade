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

  #for row in range(4):
  #  for pos in range(2):
  #    offset = bp_hp_offset+(row*2+pos)*hp_num_clients_p
  #    tg.send(masters=0b11, client_id=4+offset, data_not_reset=0, length=1, data=0b1)
  #    tg.send(masters=0b11, client_id=4+offset, data_not_reset=1, length=1, data=0b1)
  # disable cgra
  #for row in range(4):
  #  for pos in range(2):
  #    offset = cgra_hp_offset+(row*2+pos)*hp_num_clients_p
  #    tg.send(masters=0b11, client_id=4+offset, data_not_reset=0, length=1, data=0b1)
  #    tg.send(masters=0b11, client_id=4+offset, data_not_reset=1, length=1, data=0b1)

  # reset clk_gen
  for noc in range(9):
    for link in range(2):
      for clk in range(2):
        offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)+(clk*clk_num_clients_p)
        tg.send(masters=0b11, client_id=2+offset, data_not_reset=0, length=1, data=0b1)
        tg.send(masters=0b11, client_id=3+offset, data_not_reset=0, length=5, data=0b11111)
        tg.send(masters=0b11, client_id=4+offset, data_not_reset=0, length=1, data=0b1)
        tg.send(masters=0b11, client_id=5+offset, data_not_reset=0, length=7, data=0b1111111)
        tg.send(masters=0b11, client_id=6+offset, data_not_reset=0, length=2, data=0b11)
        tg.send(masters=0b11, client_id=7+offset, data_not_reset=0, length=1, data=0b1)

  for row in range(4):
    offset = clk_gen_offset+(row*clk_num_clients_p)
    tg.send(masters=0b11, client_id=0+offset, data_not_reset=0, length=1, data=0b1)
    tg.send(masters=0b11, client_id=1+offset, data_not_reset=0, length=5, data=0b11111)
    tg.send(masters=0b11, client_id=2+offset, data_not_reset=0, length=1, data=0b1)
    tg.send(masters=0b11, client_id=3+offset, data_not_reset=0, length=7, data=0b1111111)
    tg.send(masters=0b11, client_id=4+offset, data_not_reset=0, length=2, data=0b11)
    tg.send(masters=0b11, client_id=5+offset, data_not_reset=0, length=1, data=0b1)

  for row in range(4):
    for pos in range(2):
      offset = bp_clk_offset+(row*2+pos)*clk_num_clients_p
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=0, length=1, data=0b1)
      tg.send(masters=0b11, client_id=1+offset, data_not_reset=0, length=5, data=0b11111)
      tg.send(masters=0b11, client_id=2+offset, data_not_reset=0, length=1, data=0b1)
      tg.send(masters=0b11, client_id=3+offset, data_not_reset=0, length=7, data=0b1111111)
      tg.send(masters=0b11, client_id=4+offset, data_not_reset=0, length=2, data=0b11)
      tg.send(masters=0b11, client_id=5+offset, data_not_reset=0, length=1, data=0b1)

  for row in range(4):
    for pos in range(2):
      offset = cgra_clk_offset+(row*2+pos)*clk_num_clients_p
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=0, length=1, data=0b1)
      tg.send(masters=0b11, client_id=1+offset, data_not_reset=0, length=5, data=0b11111)
      tg.send(masters=0b11, client_id=2+offset, data_not_reset=0, length=1, data=0b1)
      tg.send(masters=0b11, client_id=3+offset, data_not_reset=0, length=7, data=0b1111111)
      tg.send(masters=0b11, client_id=4+offset, data_not_reset=0, length=2, data=0b11)
      tg.send(masters=0b11, client_id=5+offset, data_not_reset=0, length=1, data=0b1)

  # assert output_disable signal
  tg.send(masters=0b01, client_id=2, data_not_reset=1, length=1, data=0b1)

  # all clk_gen select zero output, reset monotor ds
  for noc in range(9):
    for link in range(2):
      for clk in range(2):
        offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)+(clk*clk_num_clients_p)
        tg.send(masters=0b10, client_id=6+offset, data_not_reset=1, length=2, data=0b11)
        tg.send(masters=0b10, client_id=7+offset, data_not_reset=1, length=1, data=0b1)

  for row in range(4):
    offset = clk_gen_offset+(row*clk_num_clients_p)
    tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=2, data=0b11)
    tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=1, data=0b1)

  for row in range(4):
    for pos in range(2):
      offset = bp_clk_offset+(row*2+pos)*clk_num_clients_p
      tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=2, data=0b11)
      tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=1, data=0b1)

  for row in range(4):
    for pos in range(2):
      offset = cgra_clk_offset+(row*2+pos)*clk_num_clients_p
      tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=2, data=0b11)
      tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=1, data=0b1)

  # de-assert output_disable signal
  tg.send(masters=0b01, client_id=2, data_not_reset=1, length=1, data=0b0)

  # config clk_gen output
  for noc in range(9):
    for link in range(2):
      for clk in range(2):
        offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)+(clk*clk_num_clients_p)
        if len(sys.argv) == 2 and (sys.argv[1] == 'use_clk_gen'):
          
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
          tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=7, data=0b0000000)
          
          # select ds output clk
          tg.send(masters=0b10, client_id=6+offset, data_not_reset=1, length=2, data=0b01)

          # de-assert monitor ds reset
          tg.send(masters=0b10, client_id=7+offset, data_not_reset=1, length=1, data=0b0)

          # set ds value
          tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=7, data=0b0000010)
          
          # set oscillator value, then trigger
          tg.send(masters=0b10, client_id=3+offset, data_not_reset=1, length=5, data=0b11000)
          tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=1, data=0b1)
          tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=1, data=0b0)

        else:

          # select ext output clk
          tg.send(masters=0b10, client_id=6+offset, data_not_reset=1, length=2, data=0b10)

          # de-assert monitor ds reset
          tg.send(masters=0b10, client_id=7+offset, data_not_reset=1, length=1, data=0b0)

  # reset noc blocks
  for noc in range(9):
    offset = link_offset+(noc*noc_num_clients_p)
    # reset noc clients
    tg.send(masters=0b11, client_id=0+noc_local_offset+offset, data_not_reset=0, length=1, data=0b1)
    # reset sdr clients
    tg.send(masters=0b11, client_id=1+noc_local_offset+offset, data_not_reset=0, length=1, data=0b1)
    tg.send(masters=0b11, client_id=2+noc_local_offset+offset, data_not_reset=0, length=1, data=0b1)
    tg.send(masters=0b11, client_id=3+noc_local_offset+offset, data_not_reset=0, length=1, data=0b1)
    tg.send(masters=0b11, client_id=4+noc_local_offset+offset, data_not_reset=0, length=1, data=0b1)
    for link in range(2):
      offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)
      # reset link clients
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=0, length=3, data=0b111)
      tg.send(masters=0b11, client_id=1+offset, data_not_reset=0, length=2, data=0b11)
      # reset iodelay clients
      for dly in range(2):
        offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)+(dly*dly_num_clients_p)
        tg.send(masters=0b11, client_id=0+dly_local_offset+offset, data_not_reset=0, length=12, data=0b111111111111)
        tg.send(masters=0b11, client_id=1+dly_local_offset+offset, data_not_reset=0, length=12, data=0b111111111111)
        tg.send(masters=0b11, client_id=2+dly_local_offset+offset, data_not_reset=0, length=10, data=0b1111111111)
        tg.send(masters=0b11, client_id=3+dly_local_offset+offset, data_not_reset=0, length=2, data=0b11)

  # reset pod rows
  for row in range(4):
    for corner in range(4):
      offset = row_sdr_offset+(row*4+corner)*(2*sdr_num_clients_p)
      # reset sdr clients
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=0, length=1, data=0b1)
      tg.send(masters=0b11, client_id=1+offset, data_not_reset=0, length=1, data=0b1)
      tg.send(masters=0b11, client_id=2+offset, data_not_reset=0, length=1, data=0b1)
      tg.send(masters=0b11, client_id=3+offset, data_not_reset=0, length=1, data=0b1)
      tg.send(masters=0b11, client_id=4+offset, data_not_reset=0, length=1, data=0b1)
      tg.send(masters=0b11, client_id=5+offset, data_not_reset=0, length=1, data=0b1)
      tg.send(masters=0b11, client_id=6+offset, data_not_reset=0, length=1, data=0b1)
      tg.send(masters=0b11, client_id=7+offset, data_not_reset=0, length=1, data=0b1)
    for pod in range(4):
      offset = row_pod_offset+(row*4+pod)
      # reset pod clients
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=0, length=1, data=0b1)

  # reset bp
  for row in range(4):
    for pos in range(2):
        offset = bp_hp_offset+(row*2+pos)*hp_num_clients_p
        # reset sdr clients
        tg.send(masters=0b11, client_id=0+offset, data_not_reset=0, length=1, data=0b1)
        tg.send(masters=0b11, client_id=1+offset, data_not_reset=0, length=1, data=0b1)
        tg.send(masters=0b11, client_id=2+offset, data_not_reset=0, length=1, data=0b1)
        tg.send(masters=0b11, client_id=3+offset, data_not_reset=0, length=1, data=0b1)
        # reset sdr disable
        tg.send(masters=0b11, client_id=4+offset, data_not_reset=0, length=1, data=0b1)
        # reset cord
        tg.send(masters=0b11, client_id=5+offset, data_not_reset=0, length=7, data=0b0000000)
        # reset core reset
        tg.send(masters=0b11, client_id=6+offset, data_not_reset=0, length=1, data=0b1)

  # reset cgra
  for row in range(4):
    for pos in range(2):
        offset = cgra_hp_offset+(row*2+pos)*hp_num_clients_p
        # reset sdr clients
        tg.send(masters=0b11, client_id=0+offset, data_not_reset=0, length=1, data=0b1)
        tg.send(masters=0b11, client_id=1+offset, data_not_reset=0, length=1, data=0b1)
        tg.send(masters=0b11, client_id=2+offset, data_not_reset=0, length=1, data=0b1)
        tg.send(masters=0b11, client_id=3+offset, data_not_reset=0, length=1, data=0b1)
        # reset sdr disable
        tg.send(masters=0b11, client_id=4+offset, data_not_reset=0, length=1, data=0b1)
        # reset cord
        tg.send(masters=0b11, client_id=5+offset, data_not_reset=0, length=7, data=0b0000000)
        # reset core reset
        tg.send(masters=0b11, client_id=6+offset, data_not_reset=0, length=1, data=0b1)

  # STEP 1: initialize everything
  for noc in range(9):
    offset = link_offset+(noc*noc_num_clients_p)
    # reset noc clients
    tg.send(masters=0b11, client_id=0+noc_local_offset+offset, data_not_reset=1, length=1, data=0b1)
    # reset sdr clients
    tg.send(masters=0b11, client_id=1+noc_local_offset+offset, data_not_reset=1, length=1, data=0b0)
    tg.send(masters=0b11, client_id=2+noc_local_offset+offset, data_not_reset=1, length=1, data=0b1)
    tg.send(masters=0b11, client_id=3+noc_local_offset+offset, data_not_reset=1, length=1, data=0b1)
    tg.send(masters=0b11, client_id=4+noc_local_offset+offset, data_not_reset=1, length=1, data=0b1)
    for link in range(2):
      offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)
      # reset link clients
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=3, data=0b110)
      tg.send(masters=0b11, client_id=1+offset, data_not_reset=1, length=2, data=0b11)
      # reset iodelay clients
      for dly in range(2):
        offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)+(dly*dly_num_clients_p)
        tg.send(masters=0b11, client_id=0+dly_local_offset+offset, data_not_reset=1, length=12, data=0b000000000000)
        tg.send(masters=0b11, client_id=1+dly_local_offset+offset, data_not_reset=1, length=12, data=0b000000000000)
        tg.send(masters=0b11, client_id=2+dly_local_offset+offset, data_not_reset=1, length=10, data=0b0000000000)
        tg.send(masters=0b11, client_id=3+dly_local_offset+offset, data_not_reset=1, length=2, data=0b00)

  # STEP 2: perform async token reset
  # async token reset for io_link
  for noc in range(9):
    for link in range(2):
      offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=3, data=0b111)
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=3, data=0b110)



  # STEP 3: de-assert upstream io reset
  # de-assert upstream reset for io_link
  for noc in range(9):
    for link in range(2):
      offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=3, data=0b010)



  # STEP 4: de-assert downstream io reset
  # de-assert downstream reset for io_link
  for noc in range(9):
    for link in range(2):
      offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=3, data=0b000)



  # STEP 5/6: de-assert upstream/downstream core reset
  # de-assert core reset for io_link
  for noc in range(9):
    for link in range(2):
      offset = link_offset+(noc*noc_num_clients_p)+(link*link_num_clients_p)
      tg.send(masters=0b11, client_id=1+offset, data_not_reset=1, length=2, data=0b00)

  for row in range(4):
    offset = clk_gen_offset+(row*clk_num_clients_p)
    # select ext output clk
    tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=2, data=0b10)
    # de-assert monitor ds reset
    tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=1, data=0b0)

  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = bp_clk_offset+(row*2+pos)*clk_num_clients_p
        # select ext output clk
        tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=2, data=0b10)
        # de-assert monitor ds reset
        tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=1, data=0b0)

  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = cgra_clk_offset+(row*2+pos)*clk_num_clients_p
        # select ext output clk
        tg.send(masters=0b10, client_id=4+offset, data_not_reset=1, length=2, data=0b10)
        # de-assert monitor ds reset
        tg.send(masters=0b10, client_id=5+offset, data_not_reset=1, length=1, data=0b0)

  for row in range(4):
    for corner in range(4):
      offset = row_sdr_offset+(row*4+corner)*(2*sdr_num_clients_p)
      # reset sdr clients
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b0)
      tg.send(masters=0b11, client_id=1+offset, data_not_reset=1, length=1, data=0b1)
      tg.send(masters=0b11, client_id=2+offset, data_not_reset=1, length=1, data=0b1)
      tg.send(masters=0b11, client_id=3+offset, data_not_reset=1, length=1, data=0b1)
      tg.send(masters=0b11, client_id=4+offset, data_not_reset=1, length=1, data=0b0)
      tg.send(masters=0b11, client_id=5+offset, data_not_reset=1, length=1, data=0b1)
      tg.send(masters=0b11, client_id=6+offset, data_not_reset=1, length=1, data=0b1)
      tg.send(masters=0b11, client_id=7+offset, data_not_reset=1, length=1, data=0b1)
    for pod in range(4):
      offset = row_pod_offset+(row*4+pod)
      # reset pod clients
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b1)

  for row in range(4):
    for pos in range(2):
      offset = bp_hp_offset+(row*2+pos)*hp_num_clients_p
      # init sdr clients
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b0)
      tg.send(masters=0b11, client_id=1+offset, data_not_reset=1, length=1, data=0b1)
      tg.send(masters=0b11, client_id=2+offset, data_not_reset=1, length=1, data=0b1)
      tg.send(masters=0b11, client_id=3+offset, data_not_reset=1, length=1, data=0b1)
      if (row == 0 and pos == 0):
        # init sdr disable
        tg.send(masters=0b11, client_id=4+offset, data_not_reset=1, length=1, data=0b0)
        # init coord
        tg.send(masters=0b11, client_id=5+offset, data_not_reset=1, length=7, data=0b0001001)
        # init core reset
        tg.send(masters=0b11, client_id=6+offset, data_not_reset=1, length=1, data=0b1)
      else:
        tg.send(masters=0b11, client_id=4+offset, data_not_reset=1, length=1, data=0b1)

  for row in range(4):
    for pos in range(2):
      offset = cgra_hp_offset+(row*2+pos)*hp_num_clients_p
      # init sdr clients
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b0)
      tg.send(masters=0b11, client_id=1+offset, data_not_reset=1, length=1, data=0b1)
      tg.send(masters=0b11, client_id=2+offset, data_not_reset=1, length=1, data=0b1)
      tg.send(masters=0b11, client_id=3+offset, data_not_reset=1, length=1, data=0b1)
      if (row == 0 and pos == 0):
        cord = ((row+1) << 4) | (0 if pos == 0 else 4)
        # init sdr disable
        tg.send(masters=0b11, client_id=4+offset, data_not_reset=1, length=1, data=0b0)
        # init coord
        tg.send(masters=0b11, client_id=5+offset, data_not_reset=1, length=7, data=cord)
        # init core reset
        tg.send(masters=0b11, client_id=6+offset, data_not_reset=1, length=1, data=0b1)
      else:
        tg.send(masters=0b11, client_id=4+offset, data_not_reset=1, length=1, data=0b1)

  # STEP 7: SDR perform async token reset
  for noc in range(9):
    offset = link_offset+(noc*noc_num_clients_p)
    tg.send(masters=0b11, client_id=1+noc_local_offset+offset, data_not_reset=1, length=1, data=0b1)
    tg.send(masters=0b11, client_id=1+noc_local_offset+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for corner in range(4):
      offset = row_sdr_offset+(row*4+corner)*(2*sdr_num_clients_p)
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b1)
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b0)
      tg.send(masters=0b11, client_id=4+offset, data_not_reset=1, length=1, data=0b1)
      tg.send(masters=0b11, client_id=4+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = bp_hp_offset+(row*2+pos)*(hp_num_clients_p)
        tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b1)
        tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = cgra_hp_offset+(row*2+pos)*(hp_num_clients_p)
        tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b1)
        tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b0)

  # STEP 8: SDR de-assert uplink reset
  for noc in range(9):
    offset = link_offset+(noc*noc_num_clients_p)
    tg.send(masters=0b11, client_id=4+noc_local_offset+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for corner in range(4):
      offset = row_sdr_offset+(row*4+corner)*(2*sdr_num_clients_p)
      tg.send(masters=0b11, client_id=3+offset, data_not_reset=1, length=1, data=0b0)
      tg.send(masters=0b11, client_id=7+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = bp_hp_offset+(row*2+pos)*(hp_num_clients_p)
        tg.send(masters=0b11, client_id=3+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = cgra_hp_offset+(row*2+pos)*(hp_num_clients_p)
        tg.send(masters=0b11, client_id=3+offset, data_not_reset=1, length=1, data=0b0)


  # STEP 9: SDR de-assert downlink reset
  for noc in range(9):
    offset = link_offset+(noc*noc_num_clients_p)
    tg.send(masters=0b11, client_id=3+noc_local_offset+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for corner in range(4):
      offset = row_sdr_offset+(row*4+corner)*(2*sdr_num_clients_p)
      tg.send(masters=0b11, client_id=2+offset, data_not_reset=1, length=1, data=0b0)
      tg.send(masters=0b11, client_id=6+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = bp_hp_offset+(row*2+pos)*(hp_num_clients_p)
        tg.send(masters=0b11, client_id=2+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = cgra_hp_offset+(row*2+pos)*(hp_num_clients_p)
        tg.send(masters=0b11, client_id=2+offset, data_not_reset=1, length=1, data=0b0)


  # STEP 10: SDR de-assert downstream reset
  for noc in range(9):
    offset = link_offset+(noc*noc_num_clients_p)
    tg.send(masters=0b11, client_id=2+noc_local_offset+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for corner in range(4):
      offset = row_sdr_offset+(row*4+corner)*(2*sdr_num_clients_p)
      tg.send(masters=0b11, client_id=1+offset, data_not_reset=1, length=1, data=0b0)
      tg.send(masters=0b11, client_id=5+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = bp_hp_offset+(row*2+pos)*(hp_num_clients_p)
        tg.send(masters=0b11, client_id=1+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = cgra_hp_offset+(row*2+pos)*(hp_num_clients_p)
        tg.send(masters=0b11, client_id=1+offset, data_not_reset=1, length=1, data=0b0)


  # STEP 11: de-assert noc reset
  for noc in range(9):
    offset = link_offset+(noc*noc_num_clients_p)
    tg.send(masters=0b11, client_id=0+noc_local_offset+offset, data_not_reset=1, length=1, data=0b0)



  # STEP 12: de-assert pod reset
  # de-assert reset for core
  for row in range(4):
    for pod in range(4):
      offset = row_pod_offset+(row*4+pod)
      tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = bp_hp_offset+(row*2+pos)*(hp_num_clients_p)
        tg.send(masters=0b11, client_id=6+offset, data_not_reset=1, length=1, data=0b0)
  for row in range(4):
    for pos in range(2):
      if (row == 0 and pos == 0):
        offset = cgra_hp_offset+(row*2+pos)*(hp_num_clients_p)
        tg.send(masters=0b11, client_id=6+offset, data_not_reset=1, length=1, data=0b0)


  tg.wait(64)
  tg.done()
