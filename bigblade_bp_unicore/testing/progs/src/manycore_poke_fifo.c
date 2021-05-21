#include <stdint.h>
#include <bp_utils.h>

void main(uint64_t argc, char * argv[]) {
    // All addresses >= 0x80000000 live in the manycore. Therefore, enable all domains
    *did_mask_addr = 0xFFF;

    // Set up EPA mapping according to vanilla core map
    // For now, store to some manycore V$ EVA
    uint32_t some_mc_dram_eva = (uint32_t) 0x810000000;

    hb_mc_packet_t req_packet;

    // Store deadbeef to manycore V$ at the right coordinates (based on data striping)
    req_packet.request.x_dst    = (1 << 4) | 1;
    req_packet.request.y_dst    = (0 << 3) | 7;
    req_packet.request.x_src    = (0 << 4) | 0;
    req_packet.request.y_src    = (1 << 3) | 1;
    req_packet.request.data     = 0xdeadbeef;
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
    req_packet.request.x_src    = (0 << 4) | 0;
    req_packet.request.y_src    = (1 << 3) | 1;
    req_packet.request.data     = 0;
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

