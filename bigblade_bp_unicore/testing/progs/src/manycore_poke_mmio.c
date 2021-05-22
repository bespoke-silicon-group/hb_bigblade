#include <stdint.h>
#include <bp_utils.h>

#define VCACHE_TAG_EPA_ADDR 0x20000000

void main(uint64_t argc, char * argv[]) {
    // All addresses >= 0x80000000 live in the manycore. Therefore, enable all domains
    *did_mask_addr = 0xFFF;

    // First write a packet to a V$ via FIFO interface
    hb_mc_packet_t req_pkt;
    req_pkt.request.addr = VCACHE_TAG_EPA_ADDR;
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

    // V$ address map
    // { vcache_not_bp (2-bits) | pod_y_coord (3-bits) | x_coord (7-bits) | epa (28-bits) | low_bits (2-bits))}

    // Read the vcache via MMIO interface
    uint64_t vcache_x_coord = ((1UL << HB_MC_POD_X_SUBCOORD_WIDTH) | 0) << (2 + HB_MC_MAX_EPA_WIDTH);
    uint64_t vcache_pod_y_coord = ((0UL << HB_MC_POD_Y_SUBCOORD_WIDTH) >> 1) << (2 + HB_MC_MAX_EPA_WIDTH + HB_MC_X_COORD_WIDTH);
    volatile uint64_t *vcache_mmio_addr = (uint64_t *) (mc_vcache_mmio | vcache_pod_y_coord | vcache_x_coord | VCACHE_TAG_EPA_ADDR);

    uint64_t mmio_read_value = *vcache_mmio_addr;
    if (mmio_read_value != 0xcaffe801)
      bp_finish(1);

    // Write to the vcache via MMIO interface
    uint64_t mmio_write_value = 0xcaffe800;
    *vcache_mmio_addr = 0xcaffe800;

    // Read from the vcache via FIFO interface
    req_pkt.request.addr = VCACHE_TAG_EPA_ADDR;
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
      bp_finish(2);

    // Send finish packet
    bp_finish(0);
}