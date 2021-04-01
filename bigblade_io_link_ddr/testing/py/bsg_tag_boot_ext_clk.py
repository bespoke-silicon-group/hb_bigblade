from bsg_tag_trace_gen import *

if __name__ == "__main__":

  # instantiate tg
  num_masters_p = 1
  num_clients_p = 9
  max_payload_width_p = 7
  tg = TagTraceGen(num_masters_p, num_clients_p, max_payload_width_p)

  # reset all bsg_tag_master
  tg.send(masters=0b1, client_id=0, data_not_reset=0, length=0, data=0)

  # wait 32 cycles
  tg.wait(32)



  # reset clk_gen
  tg.send(masters=0b1, client_id=2, data_not_reset=0, length=1, data=0b1)
  tg.send(masters=0b1, client_id=3, data_not_reset=0, length=5, data=0b11111)
  tg.send(masters=0b1, client_id=4, data_not_reset=0, length=1, data=0b1)
  tg.send(masters=0b1, client_id=5, data_not_reset=0, length=7, data=0b1111111)
  tg.send(masters=0b1, client_id=6, data_not_reset=0, length=2, data=0b11)

  # select ext clk
  tg.send(masters=0b1, client_id=6, data_not_reset=1, length=2, data=0b10)



  # reset link clients
  tg.send(masters=0b1, client_id=0, data_not_reset=0, length=3, data=0b111)
  tg.send(masters=0b1, client_id=1, data_not_reset=0, length=2, data=0b11)
  # reset core clients
  tg.send(masters=0b1, client_id=7, data_not_reset=0, length=1, data=0b1)
  # reset node clients
  tg.send(masters=0b1, client_id=8, data_not_reset=0, length=1, data=0b1)



  # STEP 1: initialize everything
  # init io_link io and core control
  tg.send(masters=0b1, client_id=0, data_not_reset=1, length=3, data=0b110)
  tg.send(masters=0b1, client_id=1, data_not_reset=1, length=2, data=0b11)
  # reset core clients
  tg.send(masters=0b1, client_id=7, data_not_reset=1, length=1, data=0b1)
  # reset node clients
  tg.send(masters=0b1, client_id=8, data_not_reset=1, length=1, data=0b1)



  # STEP 2: perform async token reset
  # async token reset for io_link
  tg.send(masters=0b1, client_id=0, data_not_reset=1, length=3, data=0b111)
  tg.send(masters=0b1, client_id=0, data_not_reset=1, length=3, data=0b110)



  # STEP 3: de-assert upstream io reset
  # de-assert upstream reset for io_link
  tg.send(masters=0b1, client_id=0, data_not_reset=1, length=3, data=0b010)



  # STEP 4: de-assert downstream io reset
  # de-assert downstream reset for io_link
  tg.send(masters=0b1, client_id=0, data_not_reset=1, length=3, data=0b000)



  # STEP 5/6: de-assert upstream/downstream core reset
  # de-assert core reset for io_link
  tg.send(masters=0b1, client_id=1, data_not_reset=1, length=2, data=0b00)



  # STEP 7: de-assert ct and fifo reset



  # STEP 8: de-assert core reset
  # de-assert reset for core
  tg.send(masters=0b1, client_id=7, data_not_reset=1, length=1, data=0b0)



  # STEP 9: de-assert node reset
  # de-assert reset for node
  tg.send(masters=0b1, client_id=8, data_not_reset=1, length=1, data=0b0)



  tg.wait(64)
  tg.done()