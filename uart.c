#include "uart.h"
#include "lib.h"

void write_char(unsigned char c) {
    /* The third bit in UART0's flag register indicates whether the device is
     * busy sending data. If it is, we loop until it has capacity for a new
     * write operation.
     */
    while (in_word(UART0_FR) & (1 << 3)) {
        /* Do nothing */
    }
    out_word(UART0_DR, c);
}

unsigned char read_char(void) {
    return in_word(UART0_DR);
}

void write_string(const char *string) {
    for (int i = 0; string[i] != '\0'; ++i) {
        write_char(string[i]);
    }
}

void uart_handler(void) {
    uint32_t status = in_word(UART0_MIS);

    /* Bit 4 indicates we received an interrupt */
    if (status & (1 << 4)) {
        char ch = read_char();

        /*
         * The Raspberry Pi and our terminal emulation will
         * disagree on what our end of line encoding is
         * (CR vs CF + LF)
         */ 
        if (ch == '\r') {
            write_string("\r\n");
        } else {}
            write_char(ch);

        // We've processed our interrupt, clear its flag
        out_word(UART0_ICR, (1 << 4));
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
    out_word(UART0_LCRH, (1 << 5) | (1 << 6));
    /* Enable handling Receive I/O interrupt processing */
    out_word(UART0_IMSC, (1 << 4));
    /* Bit 0: Enable UART
     * Bit 8: Enable transmit functionality
     * Bit 9: Enable receive functionality
     */
    out_word(UART0_CR, (1 << 0) | (1 << 8) | (1 << 9));
}