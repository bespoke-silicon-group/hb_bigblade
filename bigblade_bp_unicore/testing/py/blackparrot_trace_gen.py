from bsg_tag_trace_gen import *
import sys
import math

if __name__ == "__main__":
  num_clients = 3
  payload_width = 7 # y cord width
  lg_payload_width = int(math.ceil(math.log(payload_width+1,2)))
  max_payload_width = 10
  tg = TagTraceGen(1, num_clients, max_payload_width)

  tg.send(masters=1,client_id=0,data_not_reset=0,length=0,data=0)
  tg.wait(32)

  # reset all clients
  for i in range(num_clients):
    tg.send(masters=1, client_id=i, data_not_reset=0, length=max_payload_width, data=(2**max_payload_width)-1)

  # Set coordinates
  for i in range(num_clients):
    tg.send(masters=1, client_id=i, data_not_reset=1, length=payload_width, data=1+i)

  tg.wait(64)
  tg.done()
