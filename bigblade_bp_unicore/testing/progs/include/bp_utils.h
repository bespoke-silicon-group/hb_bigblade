#ifndef BP_UTILS_H
#define BP_UTILS_H
#include <stdint.h>

static uint8_t *mc_finish_epa_addr       = (char *) (0xead0);
static uint8_t *mc_time_epa_addr         = (char *) (0xead4);
static uint8_t *mc_fail_epa_addr         = (char *) (0xead8);
static uint8_t *mc_stdout_epa_addr       = (char *) (0xeadc);
static uint8_t *mc_stderr_epa_addr       = (char *) (0xeae0);
static uint8_t *mc_branch_trace_epa_addr = (char *) (0xeae4);
static uint8_t *mc_print_stat_epa_addr   = (char *) (0xea0c);


uint64_t bp_get_hart();

void bp_hprint(uint8_t hex);

void bp_cprint(uint8_t ch);

void bp_finish(uint8_t code);

#endif
