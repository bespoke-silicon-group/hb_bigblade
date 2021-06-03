#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <bp_utils.h>

/*
    The idea is to create a situation with intermixed high and low latency MMIO requests (i.e to 
    different tiles on the network) and generate a scenario where requests return out of order to check
    if the reorder FIFO and associated logic do their job correctly.
*/

void main(uint64_t argc, char * argv[]) {
    // All addresses >= 0x80000000 live in the manycore. Therefore, enable all domains
    *hio_mask_addr = 0xFFF;

    uint64_t addr = 0x10000;
    hb_mc_packet_t req_pkt, resp_pkt;

    // Seed the random number generator for reproducible results
    // Remove for more randomness
    srand(0);

    uint64_t x_coord, y_pod_coord, y_coord;
    uint32_t *mmio_addr[32];
    uint32_t i;

    for (i = 0;i < 32; i++) {
        x_coord = ((1 << HB_MC_POD_X_SUBCOORD_WIDTH) | (uint64_t)((rand() % 16) + 1)) << (2 + HB_MC_TILE_EPA_WIDTH);
        y_pod_coord = rand() % 2;

        if (y_pod_coord == 0) {
            y_coord = ((0 << HB_MC_POD_Y_SUBCOORD_WIDTH) | (uint64_t) 7) << (2 + HB_MC_TILE_EPA_WIDTH + HB_MC_X_COORD_WIDTH);
        }
        else {
            y_coord = ((2 << HB_MC_POD_Y_SUBCOORD_WIDTH) | (uint64_t) 0) << (2 + HB_MC_TILE_EPA_WIDTH + HB_MC_X_COORD_WIDTH);
        }

        mmio_addr[i] = (uint32_t *) (mc_tile_mmio | y_coord | x_coord | (addr << 2));
        addr++;
    }

    // Stores are non-blocking so stream them to the bridge
    for (i = 0; i < 32; i += 8) {
        *(mmio_addr[i]) = i + 1;
        *(mmio_addr[i + 1]) = i + 2;
        *(mmio_addr[i + 2]) = i + 3;
        *(mmio_addr[i + 3]) = i + 4;
        *(mmio_addr[i + 4]) = i + 5;
        *(mmio_addr[i + 5]) = i + 6;
        *(mmio_addr[i + 6]) = i + 7;
        *(mmio_addr[i + 7]) = i + 8;
    }

    for (i = 0; i < 32; i++) {
        if (*(mmio_addr[i]) != (i + 1))
            bp_finish(i+1);
    }

    bp_finish(0);
}