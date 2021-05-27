#include <stdint.h>
#include <string.h>
#include <bp_utils.h>

#define INFMEM_EPA_ADDR 0x00010000

/*
    Random numbers generated using Python on x86
    x_subcoord_rand =  {12, 15, 8, 16, 7, 2, 13, 4, 6, 10, 14, 14, 1, 7, 2, 15}
    y_pod_coord_rand = { 0,  2, 0,  0, 2, 2,  2, 0, 0,  0,  2,  0, 2, 0, 0,  0}

    The idea is to create a situation with intermixed high and low latency MMIO requests (i.e to 
    different tiles on the network) and generate a scenario where there could be backpressure on the
    reorder FIFO.
*/

void main(uint64_t argc, char * argv[]) {
    // All addresses >= 0x80000000 live in the manycore. Therefore, enable all domains
    *did_mask_addr = 0xFFF;

    int i;
    hb_mc_packet_t req_pkt, resp_pkt;

    // Fixme: rand() and srand() don't seem to be recognized by the linker
    // Fixme: For some number > 12, GCC optimizes the array initialization to a call to memcpy. This optimization can be turned off
    // or we use the memcpy function. Currently, both don't seem to be working.
    uint64_t x_coord_rand[] = {12, 15, 8, 16, 7, 2, 13, 4, 6, 10, 14, 14};
    uint64_t y_coord_rand[] = { 0,  2, 0,  0, 2, 2,  2, 0, 0,  0,  2,  0};
    uint32_t *mmio_addr[12];

    // Create an array of random x and y coordinates
    uint64_t x_coord, y_pod_coord, y_coord;
    uint32_t expected[12];

    for (i = 0; i < 12; i++) {
        x_coord = ((1 << HB_MC_POD_X_SUBCOORD_WIDTH) | x_coord_rand[i]) << (2 + HB_MC_TILE_EPA_WIDTH);
        y_pod_coord = (y_coord_rand[i] == 0) ? ((0 << HB_MC_POD_Y_SUBCOORD_WIDTH) | 7) : ((2 << HB_MC_POD_Y_SUBCOORD_WIDTH) | 0);
        y_coord = y_pod_coord << (2 + HB_MC_TILE_EPA_WIDTH + HB_MC_X_COORD_WIDTH);
        mmio_addr[i] = (uint32_t *) (mc_tile_mmio | y_coord | x_coord | (INFMEM_EPA_ADDR << 2));
        expected[i] = i;
    }

    // Stores are non-blocking so stream them to the bridge
    for (i = 0; i < 12; i += 6) {
        *(mmio_addr[i]) = i;
        *(mmio_addr[i + 1]) = i + 1;
        *(mmio_addr[i + 2]) = i + 2;
        *(mmio_addr[i + 3]) = i + 3;
        *(mmio_addr[i + 4]) = i + 4;
        *(mmio_addr[i + 5]) = i + 5;
    }

    // Loads are blocking
    for (i = 0; i < 12; i++) {        
        if (*(mmio_addr[i]) != expected[i])
            bp_finish(i);
    }

    bp_finish(0);
}