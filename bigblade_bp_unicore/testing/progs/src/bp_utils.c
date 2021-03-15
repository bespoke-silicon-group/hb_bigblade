#include <stdint.h>
#include "bp_utils.h"

void bp_finish(uint8_t code) {
  if (!code) {
    *mc_finish_epa_addr = 0;
  } else {
    *mc_fail_epa_addr = 0;
  }
}

void bp_hprint(uint8_t hex) {
  *mc_stdout_epa_addr = ('0' + hex);
}

void bp_cprint(uint8_t ch) {
  *mc_stdout_epa_addr = ch;
}

uint64_t bp_get_hart() {
    uint64_t core_id;
    __asm__ volatile("csrr %0, mhartid": "=r"(core_id): :);
    return core_id;
}

