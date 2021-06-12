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
  offset = 0
  sdr_num_clients_p  = 4

  # reset all bsg_tag_master
  tg.send(masters=0b11, client_id=0, data_not_reset=0, length=0, data=0)

  # wait 64 cycles
  tg.wait(64)

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
  # init sdr clients
  tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b0)
  tg.send(masters=0b11, client_id=1+offset, data_not_reset=1, length=1, data=0b1)
  tg.send(masters=0b11, client_id=2+offset, data_not_reset=1, length=1, data=0b1)
  tg.send(masters=0b11, client_id=3+offset, data_not_reset=1, length=1, data=0b1)
  # init sdr disable
  tg.send(masters=0b11, client_id=4+offset, data_not_reset=1, length=1, data=0b0)
  # init cord
  tg.send(masters=0b11, client_id=5+offset, data_not_reset=1, length=7, data=0b0001001)
  # init core reset
  tg.send(masters=0b11, client_id=6+offset, data_not_reset=1, length=1, data=0b1)

  # STEP 7: SDR perform async token reset
  tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b1)
  tg.send(masters=0b11, client_id=0+offset, data_not_reset=1, length=1, data=0b0)

  # STEP 8: SDR de-assert uplink reset
  tg.send(masters=0b11, client_id=3+offset, data_not_reset=1, length=1, data=0b0)

  # STEP 9: SDR de-assert downlink reset
  tg.send(masters=0b11, client_id=2+offset, data_not_reset=1, length=1, data=0b0)

  # STEP 10: SDR de-assert downstream reset
  tg.send(masters=0b11, client_id=1+offset, data_not_reset=1, length=1, data=0b0)

  # STEP 12: de-assert pod reset
  # de-assert reset for core
  tg.send(masters=0b11, client_id=6+offset, data_not_reset=1, length=1, data=0b0)

  tg.wait(64)
  tg.done()
