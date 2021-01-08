from bsg_tag_trace_gen import *

if __name__ == "__main__":

  # instantiate tg
  num_masters_p = 2
  num_clients_p = 136
  max_payload_width_p = 10
  tg = TagTraceGen(num_masters_p, num_clients_p, max_payload_width_p)

  # reset all bsg_tag_master
  tg.send(masters=0b11, client_id=0, data_not_reset=0, length=0, data=0)

  # wait 32 cycles
  tg.wait(32)



  # reset clk_gen
  tg.send(masters=0b10, client_id=0, data_not_reset=0, length=1, data=0b1)

  tg.send(masters=0b10, client_id=1, data_not_reset=0, length=5, data=0b11111)
  tg.send(masters=0b10, client_id=2, data_not_reset=0, length=5, data=0b11111)
  tg.send(masters=0b10, client_id=3, data_not_reset=0, length=5, data=0b11111)

  tg.send(masters=0b10, client_id=4, data_not_reset=0, length=1, data=0b1)
  tg.send(masters=0b10, client_id=5, data_not_reset=0, length=1, data=0b1)
  tg.send(masters=0b10, client_id=6, data_not_reset=0, length=1, data=0b1)

  tg.send(masters=0b10, client_id=7, data_not_reset=0, length=7, data=0b1111111)
  tg.send(masters=0b10, client_id=8, data_not_reset=0, length=7, data=0b1111111)
  tg.send(masters=0b10, client_id=9, data_not_reset=0, length=7, data=0b1111111)

  tg.send(masters=0b10, client_id=10, data_not_reset=0, length=2, data=0b11)
  tg.send(masters=0b10, client_id=11, data_not_reset=0, length=2, data=0b11)
  tg.send(masters=0b10, client_id=12, data_not_reset=0, length=2, data=0b11)

  # reset io_link clk_gen
  for i in range(4):
    tg.send(masters=0b10, client_id=13+i, data_not_reset=0, length=5, data=0b11111)
    tg.send(masters=0b10, client_id=17+i, data_not_reset=0, length=1, data=0b1)
    tg.send(masters=0b10, client_id=21+i, data_not_reset=0, length=7, data=0b1111111)
    tg.send(masters=0b10, client_id=25+i, data_not_reset=0, length=2, data=0b11)

  # reset io_link clk_gen
  for i in range(16):
    tg.send(masters=0b10, client_id=37+i, data_not_reset=0, length=5, data=0b11111)
    tg.send(masters=0b10, client_id=53+i, data_not_reset=0, length=1, data=0b1)
    tg.send(masters=0b10, client_id=69+i, data_not_reset=0, length=7, data=0b1111111)
    tg.send(masters=0b10, client_id=85+i, data_not_reset=0, length=2, data=0b11)

  # select ext clk
  tg.send(masters=0b10, client_id=10, data_not_reset=1, length=2, data=0b10)
  tg.send(masters=0b10, client_id=11, data_not_reset=1, length=2, data=0b10)
  tg.send(masters=0b10, client_id=12, data_not_reset=1, length=2, data=0b10)
  for i in range(4):
    tg.send(masters=0b10, client_id=25+i, data_not_reset=1, length=2, data=0b10)
  for i in range(16):
    tg.send(masters=0b10, client_id=85+i, data_not_reset=1, length=2, data=0b10)



  # reset io_link clients
  for i in range(4):
    tg.send(masters=0b11, client_id=29+i, data_not_reset=0, length=3, data=0b111)
    tg.send(masters=0b11, client_id=33+i, data_not_reset=0, length=4, data=0b1111)

  # reset mem_link clients
  for i in range(16):
    tg.send(masters=0b11, client_id=101+i, data_not_reset=0, length=3, data=0b111)
    tg.send(masters=0b11, client_id=117+i, data_not_reset=0, length=4, data=0b1111)

  # reset hb clients
  tg.send(masters=0b11, client_id=133, data_not_reset=0, length=2, data=0b11)
  tg.send(masters=0b11, client_id=134, data_not_reset=0, length=7, data=0b1111111)
  tg.send(masters=0b11, client_id=135, data_not_reset=0, length=7, data=0b1111111)



  # STEP 1: initialize everything
  # init io_link io and core control
  for i in range(4):
    tg.send(masters=0b11, client_id=29+i, data_not_reset=1, length=3, data=0b110)
    tg.send(masters=0b11, client_id=33+i, data_not_reset=1, length=4, data=0b1111)
  # init mem_link io and core control
  for i in range(16):
    tg.send(masters=0b11, client_id=101+i, data_not_reset=1, length=3, data=0b110)
    tg.send(masters=0b11, client_id=117+i, data_not_reset=1, length=4, data=0b1111)
  # init hb reset
  tg.send(masters=0b11, client_id=133, data_not_reset=1, length=2, data=0b01)
  # init hb cords
  tg.send(masters=0b11, client_id=134, data_not_reset=1, length=7, data=0b0000000)
  tg.send(masters=0b11, client_id=135, data_not_reset=1, length=7, data=0b1000000)



  # STEP 2: perform async token reset
  # async token reset for io_link
  for i in range(4):
    tg.send(masters=0b11, client_id=29+i, data_not_reset=1, length=3, data=0b111)
    tg.send(masters=0b11, client_id=29+i, data_not_reset=1, length=3, data=0b110)
  # async token reset for mem_link
  for i in range(16):
    tg.send(masters=0b11, client_id=101+i, data_not_reset=1, length=3, data=0b111)
    tg.send(masters=0b11, client_id=101+i, data_not_reset=1, length=3, data=0b110)



  # STEP 3: de-assert upstream io reset
  # de-assert upstream reset for io_link
  for i in range(4):
    tg.send(masters=0b11, client_id=29+i, data_not_reset=1, length=3, data=0b010)
  # de-assert upstream reset for mem_link
  for i in range(16):
    tg.send(masters=0b11, client_id=101+i, data_not_reset=1, length=3, data=0b010)



  # STEP 4: de-assert downstream io reset
  # de-assert downstream reset for io_link
  for i in range(4):
    tg.send(masters=0b11, client_id=29+i, data_not_reset=1, length=3, data=0b000)
  # de-assert downstream reset for mem_link
  for i in range(16):
    tg.send(masters=0b11, client_id=101+i, data_not_reset=1, length=3, data=0b000)



  # STEP 5/6: de-assert upstream/downstream core reset
  # de-assert core reset for io_link
  for i in range(4):
    tg.send(masters=0b11, client_id=33+i, data_not_reset=1, length=4, data=0b0011)
  # de-assert core reset for mem_link
  for i in range(16):
    tg.send(masters=0b11, client_id=117+i, data_not_reset=1, length=4, data=0b0011)



  # STEP 7: de-assert ct and fifo reset
  # de-assert ct and fifo reset for io_link
  for i in range(4):
    tg.send(masters=0b11, client_id=33+i, data_not_reset=1, length=4, data=0b0000)
  # de-assert ct and fifo reset for mem_link
  for i in range(16):
    tg.send(masters=0b11, client_id=117+i, data_not_reset=1, length=4, data=0b0000)



  # STEP 8: de-assert hb reset
  # de-assert reset for ASIC hb
  tg.send(masters=0b10, client_id=133, data_not_reset=1, length=2, data=0b00)
  # de-assert reset for GW hb
  tg.send(masters=0b01, client_id=133, data_not_reset=1, length=2, data=0b00)



  tg.wait(64)
  tg.done()