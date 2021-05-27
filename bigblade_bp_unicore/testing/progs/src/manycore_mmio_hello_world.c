#include <stdint.h>
#include <bp_utils.h>

void main(uint64_t argc, char * argv[]) {
    // All addresses >= 0x80000000 live in the manycore. Therefore, enable all domains
    *did_mask_addr = 0xFFF;

    // Make a series of uncached stores (non-blocking) to the STDOUT EPA
    // The reorder FIFO has a capacity of 4 elements and streaming stores should create
    // backpressure from the FIFO.
    uint64_t x_coord = ((0 << HB_MC_POD_X_SUBCOORD_WIDTH) | 0) << (2 + HB_MC_TILE_EPA_WIDTH);
    uint64_t y_coord = ((1 << HB_MC_POD_Y_SUBCOORD_WIDTH) | 0) << (2 + HB_MC_TILE_EPA_WIDTH + HB_MC_X_COORD_WIDTH);
    // The EPA should ideally be shifted by 2 bits, but the I/O monitor in the host appends 2 zeros at the end of the
    uint32_t *stdout_addr = (uint32_t *) (mc_tile_mmio | y_coord | x_coord | HB_MC_HOST_STDOUT_EPA);

    // Print "Hello World!"
    // Don't use bp_cprint pr bp_hprint because function call overhead can
    // defeat the purpose of the test
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x00000048)); // H
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x00000065)); // e
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x0000006C)); // l
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x0000006C)); // l
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x0000006F)); // o
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x00000020)); //
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x00000057)); // W
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x0000006F)); // o
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x00000072)); // r
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x0000006C)); // l
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x00000064)); // d
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x00000021)); // !
    __asm__ volatile ("sw %1, 0(%0)" : : "r"(stdout_addr), "r"(0x0000000A)); // '\n'

    // Send finish packet
    bp_finish(0);
}