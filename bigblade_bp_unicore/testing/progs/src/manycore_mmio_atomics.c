#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <bp_utils.h>

/*
  Perform a chain of MMIO atomic requests to a random tile
*/

void main(uint64_t argc, char * argv[]) {
    // All addresses >= 0x80000000 live in the manycore. Therefore, enable all domains
    *hio_mask_addr = 0xFFF;

    uint64_t addr = 0x10000;
    hb_mc_packet_t req_pkt, resp_pkt;

    // Seed the random number generator for reproducible results
    // Remove for more randomness
    srand(0);

    uint64_t x_coord = ((1 << HB_MC_POD_X_SUBCOORD_WIDTH) | (uint64_t)((rand() % 16) + 1)) << (2 + HB_MC_TILE_EPA_WIDTH);
    uint64_t y_pod_coord = rand() % 2;
    uint64_t y_coord = (y_pod_coord == 0) 
                        ? ((0 << HB_MC_POD_Y_SUBCOORD_WIDTH) | (uint64_t) 7) << (2 + HB_MC_TILE_EPA_WIDTH + HB_MC_X_COORD_WIDTH)
                        : ((2 << HB_MC_POD_Y_SUBCOORD_WIDTH) | (uint64_t) 0) << (2 + HB_MC_TILE_EPA_WIDTH + HB_MC_X_COORD_WIDTH);

    uint64_t *mmio_addr = (uint64_t *) (mc_tile_mmio | y_coord | x_coord | (addr << 2));

    // Perform atomic operations
    *mmio_addr = 0x000003E8;
    
    // Atomic operations use the uncached datapath which currently does not slice the result data correctly
    // to obtain the correct word. Therefore, perform only 64-bit loads
    uint64_t result;
    __asm__ volatile ("amoswap.d %[result], %[val], 0(%[addr])" : [result] "=r"(result) : [val] "r"(0x000007D0), [addr] "r"(mmio_addr));
    __asm__ volatile ("amoadd.d  %[result], %[val], 0(%[addr])" : [result] "=r"(result) : [val] "r"(0x000000C8), [addr] "r"(mmio_addr));
    __asm__ volatile ("amoor.d   %[result], %[val], 0(%[addr])" : [result] "=r"(result) : [val] "r"(0xFFFF0000), [addr] "r"(mmio_addr));

    if (result != 0x00000898)
      bp_finish(1);

    result = *mmio_addr;
    if (result != 0xFFFF0898)
      bp_finish(2);

    // All operations below should perform an amoswap, because the bridge doesn't support them
    __asm__ volatile ("amoxor.d  %[result], %[val], 0(%[addr])" : [result] "=r"(result) : [val] "r"(0x1) , [addr] "r"(mmio_addr));
    __asm__ volatile ("amoand.d  %[result], %[val], 0(%[addr])" : [result] "=r"(result) : [val] "r"(0x2) , [addr] "r"(mmio_addr));
    __asm__ volatile ("amomax.d  %[result], %[val], 0(%[addr])" : [result] "=r"(result) : [val] "r"(0x3) , [addr] "r"(mmio_addr));
    __asm__ volatile ("amomin.d  %[result], %[val], 0(%[addr])" : [result] "=r"(result) : [val] "r"(0x4) , [addr] "r"(mmio_addr));
    __asm__ volatile ("amomaxu.d %[result], %[val], 0(%[addr])" : [result] "=r"(result) : [val] "r"(0x5) , [addr] "r"(mmio_addr));
    __asm__ volatile ("amominu.d %[result], %[val], 0(%[addr])" : [result] "=r"(result) : [val] "r"(0x6) , [addr] "r"(mmio_addr));

    if (result != 0x5)
      bp_finish(3);

    result = *mmio_addr;
    if (result != 0x6)
      bp_finish(4);

    bp_finish(0);
}