# TODO write-up about the .text, .bss, .rodata, .bss sections

.section .text
// expose start label to linker
.global start

start:
    /* Since we're only using a single core, we figure out if we're CPU 0
     * if we are, we proceed to enter the kernel.
     * If not, we loop infinitely since our toy OS isn't multi-processor.
     */

    // Copy contents of mpidr_el1 to register; it contains CPU info. 
    mrs x0, mpidr_el1
    // mask away everything but the last two bits, which contain the active.
    // CPU's ID
    and x0, x0, #3
    // are we CPU 0?
    cmp x0, #0
    // if we are CPU 0, jump to the kernel_entry label.
    beq kernel_entry
    // otherwise, fall into next assembly line which happens to be "end".

// An infinite loop, branch to itself.
end:
    b end

kernel_entry:
    // Reserve membery address 0x80000 and above for the kernel.
    // Our stack pointer will grow downwards from here.
    mov sp, #0x80000

    // zero out the bss region
    // we are assuming that the value at address 0 is 0.
    ldr x0, =bss_start
    ldr x1, =bss_end
    sub x2, x1, x0
    mov x1, #0
    bl memset
    // jump to the KernelMain() function, defined in C
    // bl sets a link register, I don't know what that is.
    bl KernelMain
    // if the kernel ever stops running, jump to our infinite loop
    b end
