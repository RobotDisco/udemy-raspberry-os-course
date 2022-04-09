#ifndef __IRQ_H__
#define __IRQ_H__

/* since we're writing this for QEMU, we're using the generic ARM 64-bit
 * generic timer rather than a Raspberry Pi specific one.
 * https://documentation-service.arm.com/static/600eb3264ccc190e5e68023a?token=
 */ 
#define CNTP_EL0 (0x40000040)
#define CNTP_STATUS_EL0 (0x40000060)

#endif