#include "stdint.h"
#include "stdarg.h"
#include "uart.h"

static void write_console(const char *buffer, int size) {
    for (int i = 0; i < size; ++i) {
        write_char(buffer[i]);
    }
}

static int read_string(char *buffer, int position, const char *string) {
    int index = 0;

    for (index = 0; string[index] != '\0'; ++index) {
        buffer[position++] = string[index];
    }

    return index;
}

static int hex_to_string(char *buffer, int position, uint64_t digits) {
    char digits_buffer[25];
    char digits_map[16] = "0123456789ABCDEF";
    int size = 0;

    do {
        digits_buffer[size++] = digits_map[digits % 16];
        digits /= 16;
    } while (digits != 0);

    // For disambiguation, prefix hex values with '0x' as is standard.
    buffer[position++] = '0';
    buffer[position++] = 'x';

    for (int i = size-1; i >= 0; --i) {
        buffer[position++] = digits_buffer[i];
    }

    /* Account for the 0x prefix */
    return size + 2;

}

static int uint64_to_string(char *buffer, int position, uint64_t digits) {
    char digits_buffer[25];
    char digits_map[10] = "0123456789";
    int size = 0;

    do {
        digits_buffer[size++] = digits_map[digits % 10];
        digits /= 10;
    } while (digits != 0);

    for (int i = size-1; i >= 0; --i) {
        buffer[position++] = digits_buffer[i];
    }

    return size;
}

static int int64_to_string(char *buffer, int position, int64_t digits) {
    int size = 0;

    // We need to handle the case where our integer is a negative value
    if (digits < 0) {
        digits = -digits;
        buffer[position++] = '-';
        size = 1;
    }

    size += uint64_to_string(buffer, position, (uint64_t) digits);
    return size;
}


int printk(const char *format, ...) {
    char buffer [1024];
    int buffer_size = 0;
    int64_t integer = 0;
    char *string = 0;
    /* The va_ macros from stdargs are for handling variable argument
     * functions. */
    va_list args;

    va_start(args, format);

    /* Iterate over every character in the format string. */
    for (int i = 0; format[i] != '\0'; ++i) {
        /* If you are not a % character, just print as-is. */
        if (format[i] != '%') {
            buffer[buffer_size++] = format[i];
        } else {
            switch (format[++i]) {
                case 'x':
                    /* Handle hex representation */
                    integer = va_arg(args, int64_t);
                    buffer_size += hex_to_string(buffer, buffer_size, (uint64_t) integer);
                    break;
                case 'u':
                    /* Handle unsigned integer representation */
                    integer = va_arg(args, int64_t);
                    buffer_size += uint64_to_string(buffer, buffer_size, (uint64_t) integer);
                    break;
                case 'd':
                    /* Handle signed integer representation */
                    integer = va_arg(args, int64_t);
                    buffer_size += int64_to_string(buffer, buffer_size, (uint64_t) integer);
                    break;
                case 's':
                    /* Handle string representation */
                    string = va_arg(args, char*);
                    buffer_size += read_string(buffer, buffer_size, string);
                    break;
                default:
                    /* This wasn't an accepted formatting directive, assume literal % */
                    buffer[buffer_size++] = '%';
                    /* We assumed we were consuming two characters, but in this case we didn't */
                    --i;
            }
        }
    }

    write_console(buffer, buffer_size);
    va_end(args);

    return buffer_size;
}