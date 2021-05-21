
#include <stdint.h>
#include "bp_utils.h"

#define HB_MC_MAX_EPA_WIDTH 28
#define HB_MC_POD_X_COORD_WIDTH 3
#define HB_MC_POD_Y_COORD_WIDTH 4
#define HB_MC_POD_X_SUBCOORD_WIDTH 4
#define HB_MC_POD_Y_SUBCOORD_WIDTH 3
#define HB_MC_X_COORD_WIDTH HB_MC_POD_X_COORD_WIDTH + HB_MC_POD_X_SUBCOORD_WIDTH
#define HB_MC_Y_COORD_WIDTH HB_MC_POD_Y_COORD_WIDTH + HB_MC_POD_Y_SUBCOORD_WIDTH

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
    
    // Send a MMIO packet to the vcache
    uint64_t  mc_host_fifo = 0b111000000000000000000000000000000000000000;
    uint64_t  mc_vcache_mmio = 0b100000000000000000000000000000000000000000;

    // FIFO addresses
    volatile uint64_t *mc_link_bp_req_fifo_addr     = (uint64_t *) (0x01000 | mc_host_fifo);
    volatile uint64_t *mc_link_bp_req_credits_addr  = (uint64_t *) (0x02000 | mc_host_fifo);
    volatile uint64_t *mc_link_bp_resp_fifo_addr    = (uint64_t *) (0x03000 | mc_host_fifo);
    volatile uint64_t *mc_link_bp_resp_entries_addr = (uint64_t *) (0x04000 | mc_host_fifo);
    volatile uint64_t *mc_link_mc_req_fifo_addr     = (uint64_t *) (0x05000 | mc_host_fifo);
    volatile uint64_t *mc_link_mc_req_entries_addr  = (uint64_t *) (0x06000 | mc_host_fifo);
    volatile uint64_t *mc_link_rom_start_addr       = (uint64_t *) (0x07000 | mc_host_fifo);
    volatile uint64_t *mc_link_rom_end_addr         = (uint64_t *) (0x07fff | mc_host_fifo);

    // First write a packet to a V$ via FIFO interface
    hb_mc_packet_t req_pkt;
    req_pkt.request.addr = 0x20000000;
    req_pkt.request.data = 0xcaffe801;
    req_pkt.request.x_dst = (1 << HB_MC_POD_X_SUBCOORD_WIDTH) | 0;
    req_pkt.request.y_dst = (0 << HB_MC_POD_Y_SUBCOORD_WIDTH) | 7;
    req_pkt.request.x_src = (0 << HB_MC_POD_X_SUBCOORD_WIDTH) | 0;
    req_pkt.request.y_src = (1 << HB_MC_POD_Y_SUBCOORD_WIDTH) | 1;
    req_pkt.request.op_v2 = 2; // Store Word
    req_pkt.request.reg_id = 0xff;

    *mc_link_bp_req_fifo_addr = req_pkt.words[0];
    *mc_link_bp_req_fifo_addr = req_pkt.words[1];
    *mc_link_bp_req_fifo_addr = req_pkt.words[2];
    *mc_link_bp_req_fifo_addr = req_pkt.words[3];

    // Read the vcache via MMIO interface
    // V$ address map
    // { vcache_not_bp (2-bits) | pod_y_coord (3-bits) | x_coord (7-bits) | epa (28-bits) | low_bits (2-bits))}
    uint64_t vcache_epa = (0x20000000 >> 2);
    uint64_t vcache_x_coord = (1 << HB_MC_POD_X_SUBCOORD_WIDTH) | 0;
    uint64_t vcache_pod_y_coord = ((0 << HB_MC_POD_Y_SUBCOORD_WIDTH) >> 1);
    volatile uint64_t *vcache_mmio_addr = (uint64_t *) (mc_vcache_mmio | (vcache_pod_y_coord << (2 + HB_MC_MAX_EPA_WIDTH + HB_MC_X_COORD_WIDTH)) | (vcache_x_coord << (2 + HB_MC_MAX_EPA_WIDTH)) | (vcache_epa << 2));

    uint64_t mmio_read_value = *vcache_mmio_addr;
    if (mmio_read_value != 0xcaffe801)
      bp_finish(1);

    // Write to the vcache via MMIO interface
    uint64_t mmio_write_value = 0xcaffe800;
    *vcache_mmio_addr = 0xcaffe800;

    // Read from the vcache via FIFO interface
    req_pkt.request.addr = 0x20000000;
    req_pkt.request.data = 0;
    req_pkt.request.x_dst = (1 << HB_MC_POD_X_SUBCOORD_WIDTH) | 0;
    req_pkt.request.y_dst = (0 << HB_MC_POD_Y_SUBCOORD_WIDTH) | 7;
    req_pkt.request.x_src = (0 << HB_MC_POD_X_SUBCOORD_WIDTH) | 0;
    req_pkt.request.y_src = (1 << HB_MC_POD_Y_SUBCOORD_WIDTH) | 1;
    req_pkt.request.op_v2 = 0; // Load
    req_pkt.request.reg_id = 0xff;

    *mc_link_bp_req_fifo_addr = req_pkt.words[0];
    *mc_link_bp_req_fifo_addr = req_pkt.words[1];
    *mc_link_bp_req_fifo_addr = req_pkt.words[2];
    *mc_link_bp_req_fifo_addr = req_pkt.words[3];

    // Wait for response
    while (*mc_link_bp_resp_entries_addr == 0);

    hb_mc_packet_t resp_pkt;
    resp_pkt.words[0] = *mc_link_bp_resp_fifo_addr;
    resp_pkt.words[1] = *mc_link_bp_resp_fifo_addr;
    resp_pkt.words[2] = *mc_link_bp_resp_fifo_addr;
    resp_pkt.words[3] = *mc_link_bp_resp_fifo_addr;

    if (resp_pkt.response.data != mmio_write_value)
      bp_finish(1);

    // Send finish packet
    bp_finish(0);
}

