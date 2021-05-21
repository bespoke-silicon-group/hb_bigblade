#include <bp_utils.h>
#include <stdint.h>

typedef struct response_packet {
        uint8_t   x_dst; //!< x coordinate of the requester
        uint8_t   y_dst; //!< y coordinate of the requester
        uint8_t   load_id; //!< read response id
        uint32_t  data; //!< packet's payload data
        uint8_t   op;    //!< opcode
        uint8_t   reserved[8];
} __attribute__((packed, aligned(4))) hb_mc_response_packet_t;

typedef struct request_packet {
        uint8_t  x_dst; //!< x coordinate of the responder
        uint8_t  y_dst; //!< y coordinate of the responder
        uint8_t  x_src; //!< x coordinate of the requester
        uint8_t  y_src; //!< y coordinate of the requester
        uint32_t data;  //!< packet's payload data
        uint8_t  reg_id; //!< 5-bit id for load or amo
        uint8_t  op_v2;  //!< 4-bit byte mask
        uint32_t addr;  //!< address field (EPA)
        uint8_t  reserved[2];
}  __attribute__((packed, aligned(4))) hb_mc_request_packet_t;

typedef union packet {
        hb_mc_request_packet_t request; /**/
        hb_mc_response_packet_t response; /* from the Hammerblade Manycore */
        uint32_t words[4];
} hb_mc_packet_t;

int main(uint64_t argc, char *argv[]) {
  
  // Enable all domains for the manycore
  uint64_t bp_cfg_offset = 0x200000;
  volatile uint64_t *did_mask_addr = (uint64_t *) (bp_cfg_offset + 0x0009);
  volatile uint64_t *sac_mask_addr = (uint64_t *) (bp_cfg_offset + 0x000a);
  *did_mask_addr = 0xFFF;

  uint64_t  mc_hi_bit = 0b111000000000000000000000000000000000000000;

  volatile uint64_t *mc_link_bp_req_fifo_addr     = (uint64_t *) (0x01000 | mc_hi_bit);
  volatile uint64_t *mc_link_bp_req_credits_addr  = (uint64_t *) (0x02000 | mc_hi_bit);
  volatile uint64_t *mc_link_bp_resp_fifo_addr    = (uint64_t *) (0x03000 | mc_hi_bit);
  volatile uint64_t *mc_link_bp_resp_entries_addr = (uint64_t *) (0x04000 | mc_hi_bit);
  volatile uint64_t *mc_link_mc_req_fifo_addr     = (uint64_t *) (0x05000 | mc_hi_bit);
  volatile uint64_t *mc_link_mc_req_entries_addr  = (uint64_t *) (0x06000 | mc_hi_bit);
  volatile uint64_t *mc_link_rom_start_addr       = (uint64_t *) (0x07000 | mc_hi_bit);
  volatile uint64_t *mc_link_rom_end_addr         = (uint64_t *) (0x07fff | mc_hi_bit);

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
      while (*mc_link_bp_req_credits_addr != 0);

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
      
      while (*mc_link_bp_req_credits_addr != 0);

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
      
      while (*mc_link_bp_req_credits_addr != 0);

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
      
      while (*mc_link_bp_req_credits_addr != 0);

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
      
      while (*mc_link_bp_req_credits_addr != 0);

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
  return 0;
}
