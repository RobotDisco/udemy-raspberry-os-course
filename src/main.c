#include "debug.h"
#include "lib.h"
#include "uart.h"
#include "print.h"
#include "handler.h"
#include "memory.h"
#include "file.h"

#include <stddef.h>

void KernelMain(void) {
    uint64_t value = 0x1234567890ACBDEF;
    init_uart();
    printk("%s", "Hello Raspberry Pi World!\r\n");
    printk("Test unsigned %u\r\n", value);
    printk("Test decimal %d\r\n", -1 * value);
    printk("Test hexadecimal %x\r\n", value);

    printk("Current ARM exception level: %u\r\n", (uint64_t) get_el());

    init_memory();
    init_fs();

    void *p = kalloc();
    ASSERT(p != NULL);
    if (load_file("TEST.BIN", (uint64_t)p) == 0) {
        printk("File data: %s\r\n", p);
    }

    init_timer();
    init_interrupt_controller();
    enable_irq();

    while (1) {
        // Just infinite loop as our proof of concept
    }
}