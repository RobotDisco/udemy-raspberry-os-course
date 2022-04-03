#include "uart.h"

void KernelMain(void) {
    write_string("Hello Raspberry Pi World!\n");
    while (1) {
        // Just infinite loop as our proof of concept
    }
}