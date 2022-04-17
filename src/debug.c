#include "debug.h"
#include "print.h"
#include "stdint.h"

void error_check(char *file, uint64_t line) {
    printk("ERROR: Assertion Failed [%s: %u]\r\n", file, line);
}