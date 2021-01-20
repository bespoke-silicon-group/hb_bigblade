from bsg_tag_trace_gen import *

if __name__ == "__main__":

  # instantiate tg
  num_masters_p = 2
  num_clients_p = 138
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
  for i in range(2):
    tg.send(masters=0b10, client_id=13+i, data_not_reset=0, length=5, data=0b11111)
    tg.send(masters=0b10, client_id=15+i, data_not_reset=0, length=1, data=0b1)
    tg.send(masters=0b10, client_id=17+i, data_not_reset=0, length=7, data=0b1111111)
    tg.send(masters=0b10, client_id=19+i, data_not_reset=0, length=2, data=0b11)

  # reset io_link clk_gen
  for i in range(16):
    tg.send(masters=0b10, client_id=25+i, data_not_reset=0, length=5, data=0b11111)
    tg.send(masters=0b10, client_id=41+i, data_not_reset=0, length=1, data=0b1)
    tg.send(masters=0b10, client_id=57+i, data_not_reset=0, length=7, data=0b1111111)
    tg.send(masters=0b10, client_id=73+i, data_not_reset=0, length=2, data=0b11)

  # select ext clk
  tg.send(masters=0b10, client_id=10, data_not_reset=1, length=2, data=0b10)
  tg.send(masters=0b10, client_id=11, data_not_reset=1, length=2, data=0b10)
  tg.send(masters=0b10, client_id=12, data_not_reset=1, length=2, data=0b10)
  for i in range(2):
    tg.send(masters=0b10, client_id=19+i, data_not_reset=1, length=2, data=0b10)
  for i in range(16):
    tg.send(masters=0b10, client_id=73+i, data_not_reset=1, length=2, data=0b10)



  # reset io_link clients
  for i in range(2):
    tg.send(masters=0b11, client_id=21+i, data_not_reset=0, length=3, data=0b111)
    tg.send(masters=0b11, client_id=23+i, data_not_reset=0, length=4, data=0b1111)

  # reset mem_link clients
  for i in range(16):
    tg.send(masters=0b11, client_id=89+i, data_not_reset=0, length=3, data=0b111)
    tg.send(masters=0b11, client_id=105+i, data_not_reset=0, length=4, data=0b1111)

  # reset hb clients
  tg.send(masters=0b11, client_id=121, data_not_reset=0, length=2, data=0b11)
  for i in range(4):
    for j in range(4):
      for k in range(2):
        tg.send(masters=0b11, client_id=122+(i*4+j)*2+k, data_not_reset=0, length=8, data=0b11111111)



  # STEP 1: initialize everything
  # init io_link io and core control
  for i in range(2):
    tg.send(masters=0b11, client_id=21+i, data_not_reset=1, length=3, data=0b110)
    tg.send(masters=0b11, client_id=23+i, data_not_reset=1, length=4, data=0b1111)
  # init mem_link io and core control
  for i in range(16):
    tg.send(masters=0b11, client_id=89+i, data_not_reset=1, length=3, data=0b110)
    tg.send(masters=0b11, client_id=105+i, data_not_reset=1, length=4, data=0b1111)
  # init hb reset
  tg.send(masters=0b11, client_id=121, data_not_reset=1, length=2, data=0b01)
  # init hb pod
  for i in range(4):
    for j in range(4):
      for k in range(2):
        if j < 2:
          tg.send(masters=0b11, client_id=122+(i*4+j)*2+k, data_not_reset=1, length=8, data=0b10001111)
        else:
          tg.send(masters=0b11, client_id=122+(i*4+j)*2+k, data_not_reset=1, length=8, data=0b11010000)


  # STEP 2: perform async token reset
  # async token reset for io_link
  for i in range(2):
    tg.send(masters=0b11, client_id=21+i, data_not_reset=1, length=3, data=0b111)
    tg.send(masters=0b11, client_id=21+i, data_not_reset=1, length=3, data=0b110)
  # async token reset for mem_link
  for i in range(16):
    tg.send(masters=0b11, client_id=89+i, data_not_reset=1, length=3, data=0b111)
    tg.send(masters=0b11, client_id=89+i, data_not_reset=1, length=3, data=0b110)



  # STEP 3: de-assert upstream io reset
  # de-assert upstream reset for io_link
  for i in range(2):
    tg.send(masters=0b11, client_id=21+i, data_not_reset=1, length=3, data=0b010)
  # de-assert upstream reset for mem_link
  for i in range(16):
    tg.send(masters=0b11, client_id=89+i, data_not_reset=1, length=3, data=0b010)



  # STEP 4: de-assert downstream io reset
  # de-assert downstream reset for io_link
  for i in range(2):
    tg.send(masters=0b11, client_id=21+i, data_not_reset=1, length=3, data=0b000)
  # de-assert downstream reset for mem_link
  for i in range(16):
    tg.send(masters=0b11, client_id=89+i, data_not_reset=1, length=3, data=0b000)



  # STEP 5/6: de-assert upstream/downstream core reset
  # de-assert core reset for io_link
  for i in range(2):
    tg.send(masters=0b11, client_id=23+i, data_not_reset=1, length=4, data=0b0011)
  # de-assert core reset for mem_link
  for i in range(16):
    tg.send(masters=0b11, client_id=105+i, data_not_reset=1, length=4, data=0b0011)



  # STEP 7: de-assert ct and fifo reset
  # de-assert ct and fifo reset for io_link
  for i in range(2):
    tg.send(masters=0b11, client_id=23+i, data_not_reset=1, length=4, data=0b0000)
  # de-assert ct and fifo reset for mem_link
  for i in range(16):
    tg.send(masters=0b11, client_id=105+i, data_not_reset=1, length=4, data=0b0000)



  # STEP 8: de-assert hb reset
  # de-assert reset for ASIC hb
  tg.send(masters=0b10, client_id=121, data_not_reset=1, length=2, data=0b00)
  # de-assert reset for GW hb
  tg.send(masters=0b01, client_id=121, data_not_reset=1, length=2, data=0b00)

  # de-assert reset for ASIC pod
  for i in range(4):
    for j in range(4):
      for k in range(2):
        if j < 2:
          tg.send(masters=0b10, client_id=122+(i*4+j)*2+k, data_not_reset=1, length=8, data=0b00001111)
        else:
          tg.send(masters=0b10, client_id=122+(i*4+j)*2+k, data_not_reset=1, length=8, data=0b01010000)

  tg.wait(64)
  tg.done()