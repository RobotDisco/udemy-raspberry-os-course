#include "stdint.h"
#include "print.h"

void handler(uint64_t exception_id, uint64_t esr, uint64_t elr) {
    switch (exception_id) {
        case 1:
            printk("synchronous error at %x: with context %x\r\n", elr, esr);
            while (1) { }
        default:
            printk("unknown exception\r\n");
            while (1) { }
    }
}