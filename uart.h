#ifndef _UART_H
#define _UART_H

/* See Raspberry Pi 3's UART manual for reference
 * https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf

/* Page 177: Base memory-mapped address for RPi3 I/O subsystem
 * I/O module: 0x7E200000
 * UART0 base: 0x7E200000 + 0x1000
 * 
 * I don't know why 0x7Exxxxxx makps to 0x3Fxxxxxx
 */
#define IO_BASE_ADDR 0x3f200000

/* Data Register, 32 bits */
#define UART0_DR IO_BASE_ADDR + 0x1000
/* Flag Register, 32 bits */
#define UART0_FR IO_BASE_ADDR + 0x1018
/* Control Register, 32 bits */
#define UART0_CR IO_BASE_ADDR + 0x1030
/* Line Control Register, 32 bits */
#define UART0_LCRH IO_BASE_ADDR + 0x102c
/* Fractional Baud Rate Divisor,  32 bits */
#define UART0_FBRD IO_BASE_ADDR + 0x1028
/* Integer Baud Rate Divisor, 32 bits */
#define UART0_IBRD IO_BASE_ADDR + 0x1024
/* Interrupt Mask Set Clear Register, 32 bits */
#define UART0_IMSC IO_BASE_ADDR + 0x1038
/* Interrupt Mask Interrupt Register */
#define UART0_MIS IO_BASE_ADDR + 0x1040
/* Interrupt Clear Register */
#define UART0_ICR IO_BASE_ADDR + 0x1044

unsigned char read_char(void);
void write_char(unsigned char c);
void write_string(const char *string);
void init_uart(void);
void uart_handler(void);

#endif



