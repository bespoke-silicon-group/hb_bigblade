#include <stdint.h>
#include <bp_utils.h>

#define INFMEM_EPA_ADDR 0x00010000

void main(uint64_t argc, char * argv[]) {
    // All addresses >= 0x80000000 live in the manycore. Therefore, enable all domains
    *did_mask_addr = 0xFFF;

    // Infinite memory as a tile
    // { mc_tile_not_bp (2-bits) | 000000 (6-bits) | y_coord (7-bits) | x_coord (7-bits) | Tile EPA (18-bits) | 00 (2-bits))}

    // Write to infinite mem via MMIO interface
    uint64_t tile_epa = INFMEM_EPA_ADDR << 2;
    uint64_t x_coord = ((1 << HB_MC_POD_X_SUBCOORD_WIDTH) | 0) << (2 + HB_MC_TILE_EPA_WIDTH);
    uint64_t y_coord = ((0 << HB_MC_POD_Y_SUBCOORD_WIDTH) | 7) << (2 + HB_MC_TILE_EPA_WIDTH + HB_MC_X_COORD_WIDTH);
    uint32_t *infmem_mmio_addr = (uint32_t *) (mc_tile_mmio | y_coord | x_coord | tile_epa);

    *infmem_mmio_addr = 0xdeadbeef;

    uint32_t mmio_read_value = *infmem_mmio_addr;
    if (mmio_read_value != 0xdeadbeef)
      bp_finish(1);

    // Send finish packet
    bp_finish(0);
}