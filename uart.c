#include "uart.h"
#include "lib.h"

void write_char(unsigned char c) {
    /* The fifth bit in UART0's flag register indicates whether the transmit
     * buffer is full. If it is, we loop until it has capacity for a new write
     * operation.
     */
    while (in_word(UART0_FR) & (1 << 5)) {
        /* Do nothing */
    }
    out_word(UART0_DR, c);
}

unsigned char read_char(void) {
    /* The fourth bit in UART0's flag register indicates whether the receive
     * buffer is empty. If it is, we loop until it has capacity for a new read
     * operation.
     */
    while (in_word(UART0_FR) & (1 << 4))  {
        /* Do nothing */
    }
    return in_word(UART0_DR);
}

void write_string(const char *string) {
    for (int i = 0; string[i] != '\0'; ++i) {
        write_char(string[i]);
    }
}

void init_uart(void) {
    /* Disable the UART so we can configure it */
    out_word(UART0_CR, 0);
    /* Set UART's baud to 115200 through a convoluted formula described in
     * page 183 of the ARM Peripherals document.
     * The value we want is 26.04, which we set in the two registers
     * dedicated to each portion of the rational value.
     */
    out_word(UART0_IBRD, 26);
    out_word(UART0_FBRD, 0); 
    /* Bit 4: Enable FIFO buffers
     * Bit 5 + 6: Set word length to 8 bits
     */
    out_word(UART0_LCRH, (1 << 4) | (1 << 5) | (1 << 6));
    /* Clear all registers since we won't be handling them */
    out_word(UART0_IMSC, 0);
    /* Bit 0: Enable UART
     * Bit 8: Enable transmit functionality
     * Bit 9: Enable receive functionality
     */
    out_word(UART0_CR, (1 << 0) | (1 << 8) | (1 << 9));
}