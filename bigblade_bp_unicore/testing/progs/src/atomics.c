#include <bp_utils.h>
#include <stdint.h>

int main(uint64_t argc, char *argv[]) {
  // Enable all domains for the manycore
  *did_mask_addr = 0xFFF;

  uint32_t some_mc_dram_eva = (uint32_t) 0x810000000;
  uint32_t vcache_block_offset = (uint32_t) 0x10000;

  // There are 32 V$'s in total and split across 2 pods
  // There is a single row of V$'s at the north side and a single row of V$'s at the south side
  int data[32];
  
  hb_mc_packet_t req_packet, resp_packet;

  req_packet.request.x_src = (0 << 4) | 0;
  req_packet.request.y_src = (1 << 3) | 1;
  req_packet.request.op_v2 = 2;
  req_packet.request.reg_id = 0xff;
  
  for (int y = 0; y < 2; y++) {
    for(int x = 0; x < 16; x++) {
      req_packet.request.x_dst = (1 << 4) | x;
      req_packet.request.y_dst = (y == 1) ? ((2 << 3) | 0): ((0 << 3) | 7);
      req_packet.request.data = x + (y * 16);
      req_packet.request.addr = some_mc_dram_eva + ((x + (y * 16)) * vcache_block_offset);
      
      // Store the data for future compares
      data[x + (y * 16)] = x + (y * 16);

      // Wait for credits
      while ((16 - *mc_link_bp_req_credits_addr) == 0);

      *mc_link_bp_req_fifo_addr = req_packet.words[0];
      *mc_link_bp_req_fifo_addr = req_packet.words[1];
      *mc_link_bp_req_fifo_addr = req_packet.words[2];
      *mc_link_bp_req_fifo_addr = req_packet.words[3];
    }
  }

  req_packet.request.x_src = (0 << 4) | 0;
  req_packet.request.y_src = (1 << 3) | 1;
  req_packet.request.op_v2 = 4; // AMOSWAP
  req_packet.request.reg_id = 0xff;

  for (int y = 0; y < 2; y++) {
    for(int x = 0; x < 16; x++) {
      req_packet.request.x_dst = (1 << 4) | x;
      req_packet.request.y_dst = (y == 1) ? ((2 << 3) | 0): ((0 << 3) | 7);
      req_packet.request.data = data[x + (y * 16)] + 1;
      req_packet.request.addr = some_mc_dram_eva + ((x + (y * 16)) * vcache_block_offset);
      
      while ((16 - *mc_link_bp_req_credits_addr) == 0);

      *mc_link_bp_req_fifo_addr = req_packet.words[0];
      *mc_link_bp_req_fifo_addr = req_packet.words[1];
      *mc_link_bp_req_fifo_addr = req_packet.words[2];
      *mc_link_bp_req_fifo_addr = req_packet.words[3];

      // Wait for response
      while (*mc_link_bp_resp_entries_addr == 0);

      resp_packet.words[0] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[1] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[2] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[3] = *mc_link_bp_resp_fifo_addr;

      if (resp_packet.response.data != data[x + (y * 16)]) {
        bp_finish(1);
      }
      
      data[x + (y * 16)] += 1;
    }
  }

  req_packet.request.x_src = (0 << 4) | 0;
  req_packet.request.y_src = (1 << 3) | 1;
  req_packet.request.op_v2 = 5; // AMOADD
  req_packet.request.reg_id = 0xff;

  for (int y = 0; y < 2; y++) {
    for(int x = 0; x < 16; x++) {
      req_packet.request.x_dst = (1 << 4) | x;
      req_packet.request.y_dst = (y == 1) ? ((2 << 3) | 0): ((0 << 3) | 7);
      req_packet.request.data = 31 - data[x + (y * 16)];
      req_packet.request.addr = some_mc_dram_eva + ((x + (y * 16)) * vcache_block_offset);
      
      while ((16 - *mc_link_bp_req_credits_addr) == 0);

      *mc_link_bp_req_fifo_addr = req_packet.words[0];
      *mc_link_bp_req_fifo_addr = req_packet.words[1];
      *mc_link_bp_req_fifo_addr = req_packet.words[2];
      *mc_link_bp_req_fifo_addr = req_packet.words[3];

      while (*mc_link_bp_resp_entries_addr == 0);

      resp_packet.words[0] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[1] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[2] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[3] = *mc_link_bp_resp_fifo_addr;

      if (resp_packet.response.data != data[x + (y * 16)]) {
        bp_finish(2);
      }
      
      data[x + (y * 16)] = 31;
    }
  }

  req_packet.request.x_src = (0 << 4) | 0;
  req_packet.request.y_src = (1 << 3) | 1;
  req_packet.request.op_v2 = 8; // AMOOR
  req_packet.request.reg_id = 0xff;

  for (int y = 0; y < 2; y++) {
    for(int x = 0; x < 16; x++) {
      req_packet.request.x_dst = (1 << 4) | x;
      req_packet.request.y_dst = (y == 1) ? ((2 << 3) | 0): ((0 << 3) | 7);
      req_packet.request.data = 0xBAD00000;
      req_packet.request.addr = some_mc_dram_eva + ((x + (y * 16)) * vcache_block_offset);
      
      while ((16 - *mc_link_bp_req_credits_addr) == 0);

      *mc_link_bp_req_fifo_addr = req_packet.words[0];
      *mc_link_bp_req_fifo_addr = req_packet.words[1];
      *mc_link_bp_req_fifo_addr = req_packet.words[2];
      *mc_link_bp_req_fifo_addr = req_packet.words[3];

      while (*mc_link_bp_resp_entries_addr == 0);

      resp_packet.words[0] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[1] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[2] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[3] = *mc_link_bp_resp_fifo_addr;

      if (resp_packet.response.data != data[x + (y * 16)]) {
        bp_finish(3);
      }
      
      data[x + (y * 16)] |= 0xBAD00000;
    }
  }

  req_packet.request.x_src = (0 << 4) | 0;
  req_packet.request.y_src = (1 << 3) | 1;
  req_packet.request.op_v2 = 0; // Load
  req_packet.request.reg_id = 0xff;

  for (int y = 0; y < 2; y++) {
    for(int x = 0; x < 16; x++) {
      req_packet.request.x_dst = (1 << 4) | x;
      req_packet.request.y_dst = (y == 1) ? ((2 << 3) | 0): ((0 << 3) | 7);
      req_packet.request.data = 0x0;
      req_packet.request.addr = some_mc_dram_eva + ((x + (y * 16)) * vcache_block_offset);
      
      while ((16 - *mc_link_bp_req_credits_addr) == 0);

      *mc_link_bp_req_fifo_addr = req_packet.words[0];
      *mc_link_bp_req_fifo_addr = req_packet.words[1];
      *mc_link_bp_req_fifo_addr = req_packet.words[2];
      *mc_link_bp_req_fifo_addr = req_packet.words[3];

      while (*mc_link_bp_resp_entries_addr == 0);

      resp_packet.words[0] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[1] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[2] = *mc_link_bp_resp_fifo_addr;
      resp_packet.words[3] = *mc_link_bp_resp_fifo_addr;

      if (resp_packet.response.data != data[x + (y * 16)]) {
        bp_finish(4);
      }
    }
  }

  bp_finish(0);
}
