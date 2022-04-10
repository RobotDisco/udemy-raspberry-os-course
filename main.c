#include "debug.h"
#include "lib.h"
#include "uart.h"
#include "print.h"
#include "handler.h"

void KernelMain(void) {
    uint64_t value = 0x1234567890ACBDEF;
    init_uart();
    printk("%s", "Hello Raspberry Pi World!\r\n");
    printk("Test unsigned %u\r\n", value);
    printk("Test decimal %d\r\n", -1 * value);
    printk("Test hexadecimal %x\r\n", value);

    printk("Current ARM exception level: %u\r\n", (uint64_t) get_el());
    
    init_timer();
    init_interrupt_controller();
    enable_irq();

    //while (1) {
        // Just infinite loop as our proof of concept
    //}
}