#ifndef __IRQ_H__
#define __IRQ_H__

#include "memory.h"

/* since we're writing this for QEMU, we're using the generic ARM 64-bit
 * generic timer rather than a Raspberry Pi specific one.
 * https://documentation-service.arm.com/static/600eb3264ccc190e5e68023a?token=
 */ 
#define CNTP_EL0 P2VMem(0x40000040)
#define CNTP_STATUS_EL0 P2VMem(0x40000060)

/* See Raspberry Pi 3's UART manual for reference
 * https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf
 *
 * Page 112 is where we see how to work with hardware via interrupts
 */
#define IRQ_BASE_ADDR P2VMem(0x3f000000)

#define IRQ_BASIC_PENDING (IRQ_BASE_ADDR + 0xB200)
#define ENABLE_IRQS_1 (IRQ_BASE_ADDR + 0xB210)
#define ENABLE_IRQS_2 (IRQ_BASE_ADDR + 0xB214)
#define ENABLE_BASIC_IRQS (IRQ_BASE_ADDR + 0xB218)
#define DISABLE_IRQS_1 (IRQ_BASE_ADDR + 0xB21C)
#define DISABLE_IRQS_2 (IRQ_BASE_ADDR + 0xB220)
#define DISABLE_BASIC_IRQS (IRQ_BASE_ADDR + 0xB224)

#endif