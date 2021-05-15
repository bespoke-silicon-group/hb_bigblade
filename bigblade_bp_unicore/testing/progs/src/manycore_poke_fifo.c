
#include <stdint.h>
#include "bp_utils.h"

typedef struct response_packet {
        uint8_t   x_dst; //!< x coordinate of the requester
        uint8_t   y_dst; //!< y coordinate of the requester
        uint8_t   load_id; //!< read response id
        uint32_t  data; //!< packet's payload data
        uint8_t   op;    //!< opcode
        uint8_t   reserved[8];
} __attribute__((packed)) hb_mc_response_packet_t;

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
}  __attribute__((packed)) hb_mc_request_packet_t;

typedef union packet {
        hb_mc_request_packet_t request; /**/
        hb_mc_response_packet_t response; /* from the Hammerblade Manycore */
        uint32_t words[4];
} hb_mc_packet_t;

void main(uint64_t argc, char * argv[]) {
    
    uint64_t bp_cfg_offset = 0x200000;
    volatile uint64_t *did_mask_addr = (uint64_t *) (0x0009 + bp_cfg_offset);
    volatile uint64_t *sac_mask_addr = (uint64_t *) (0x000a + bp_cfg_offset);

    // All addresses >= 0x80000000 live in the manycore. Therefore, enable all domains
    *did_mask_addr = 0xFFF;
    
    uint64_t  mc_host_bit = 0x100000;

    volatile uint64_t *mc_link_bp_req_fifo_addr     = (uint64_t *) (0x01000 | mc_host_bit );
    volatile uint64_t *mc_link_bp_req_credits_addr  = (uint64_t *) (0x02000 | mc_host_bit );
    volatile uint64_t *mc_link_bp_resp_fifo_addr    = (uint64_t *) (0x03000 | mc_host_bit );
    volatile uint64_t *mc_link_bp_resp_entries_addr = (uint64_t *) (0x04000 | mc_host_bit );
    volatile uint64_t *mc_link_mc_req_fifo_addr     = (uint64_t *) (0x05000 | mc_host_bit );
    volatile uint64_t *mc_link_mc_req_entries_addr  = (uint64_t *) (0x06000 | mc_host_bit );
    volatile uint64_t *mc_link_rom_start_addr       = (uint64_t *) (0x07000 | mc_host_bit );
    volatile uint64_t *mc_link_rom_end_addr         = (uint64_t *) (0x07fff | mc_host_bit );

    // Set up EPA mapping according to vanilla core map
    // For now, store to some manycore V$ EVA
    uint32_t some_mc_dram_eva = (uint32_t) 0x810000000;

    hb_mc_packet_t req_packet;

    // Store deadbeef to manycore V$ at the right coordinates (based on data striping)
    req_packet.request.x_dst    = (1 << 4) | 1;
    req_packet.request.y_dst    = (0 << 3) | 7;
    // Unused
    req_packet.request.x_src    = (0 << 0) | 0;
    // Unused
    req_packet.request.y_src    = (1 << 3) | 1;
    req_packet.request.data     = 0xdeadbeef;
    // Store mask
    req_packet.request.reg_id   = 0xff;
    req_packet.request.op_v2    = 2; // Store Word
    req_packet.request.addr     = some_mc_dram_eva;

    *mc_link_bp_req_fifo_addr = req_packet.words[0];
    *mc_link_bp_req_fifo_addr = req_packet.words[1];
    *mc_link_bp_req_fifo_addr = req_packet.words[2];
    *mc_link_bp_req_fifo_addr = req_packet.words[3];

    // Read deadbeef from manycore V$ at the right coordinates (based on data striping)
    req_packet.request.x_dst    = (1 << 4) | 1;
    req_packet.request.y_dst    = (0 << 3) | 7;
    // Unused
    req_packet.request.x_src    = (0 << 0) | 0;
    // Unused
    req_packet.request.y_src    = (1 << 3) | 1;
    req_packet.request.data     = 0;
    // Store mask
    req_packet.request.reg_id   = 0x10;
    req_packet.request.op_v2    = 0; // Load
    req_packet.request.addr     = some_mc_dram_eva;

    *mc_link_bp_req_fifo_addr = req_packet.words[0];
    *mc_link_bp_req_fifo_addr = req_packet.words[1];
    *mc_link_bp_req_fifo_addr = req_packet.words[2];
    *mc_link_bp_req_fifo_addr = req_packet.words[3];

    // Wait for response
    while (*mc_link_bp_resp_entries_addr == 0);

    hb_mc_packet_t resp_packet;

    resp_packet.words[0] = *mc_link_bp_resp_fifo_addr;
    resp_packet.words[1] = *mc_link_bp_resp_fifo_addr;
    resp_packet.words[2] = *mc_link_bp_resp_fifo_addr;
    resp_packet.words[3] = *mc_link_bp_resp_fifo_addr;

    // Send finish packet
    bp_finish(0);
}

