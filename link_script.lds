/* The linker script presumably tells our linker
 * what to do with the object files it has been given
 */

/* Start instruction pointer at "start" label */
ENTRY(start)
SECTIONS
{
    /* Set current location to 0x80000, our designed userspace memory boundary
     * All further instructions will load data into the memory above this
     * location until told otherwise */
    . = 0x80000;

    /* Ensure boot.o's .text definitions go first (since it's our bootloader.)
     * After that include them from all the inputs
     */
    .text : {
        boot.o(.text)
        *(.text)
    }
    
    /* Include any rodata definitions from all our input files */
    .rodata : {
        *(.rodata)
    }

    /* Ensure data segment is aligned to a 16 byte boundary
     * i.e. round our location up to an address divisible by 16 bytes.
     */
    . = ALIGN(16);
    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
    }
}