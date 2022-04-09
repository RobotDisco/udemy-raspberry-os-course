#include "irq.h"
#include "lib.h"
#include "print.h"
#include "stdint.h"

/* I guess these declaration allows an externally written assembler function
 * to be referenced? I don't know why this is required when it hasn't been
 * elsewhere.
 */ 
void enable_timer(void);
uint32_t read_timer_freq(void);
uint32_t read_timer_status(void);
void set_timer_interval(uint32_t value);

static uint32_t timer_interval = 0;
static uint64_t ticks = 0;

void init_timer(void) {
    /* Why do we do this in C AND Assembler?
     * I guess it's because our C code needs to update
     * this regularly
     */
    timer_interval = read_timer_freq() / 100;
    /* This is an assembler function prepping timer registers */
    enable_timer();
    /* Setting bit 1 enables the timer */
    /* This isn't a register, this is a memory address */
    out_word(CNTP_EL0, (1 << 1));
}

static void timer_interrupt_handler(void) {
    uint32_t status = read_timer_status();
    if (status & (1 << 2)) {
        ++ticks;
        if (ticks % 100 == 0) {
            /* Effectively only print every second, not every tick */
            printk("timer %d\r\n", ticks);
        }
        set_timer_interval(timer_interval);
    }
}

void handler(uint64_t exception_id, uint64_t esr, uint64_t elr) {
    uint32_t irq;

    switch (exception_id) {
        case 1:
            printk("synchronous error at %x: with context %x\r\n", elr, esr);
            while (1) { }
        case 2:
            irq = in_word(CNTP_STATUS_EL0);
            if (irq & (1 << 1)) {
                timer_interrupt_handler();
            } else {
                printk("unknown irq \r\n");
                while (1) {}
            }
            break;
        default:
            printk("unknown exception\r\n");
            while (1) { }
    }
}