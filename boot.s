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
    // ARM device starts in exception level 2; move to exception
    // level 1 and configure some system registers
    mrs x0, currentel
    // shift x0 right by two since bits 2-3 contain system level
    lsr x0, x0, #2
    cmp x0, #2
    // if system level isn't 2 on start, abort boot
    bne end

    // zero out system configuration registers
    msr sctlr_el1, xzr
    // Set bit which indicates we are in 64-bit mode
    mov x0, #(1 << 31)
    msr hcr_el2, x0

    // The only way to go down an exception level on ARM systems is through an
    // exception return, which restores the PSTATE and return address during
    // the instruction that triggered the exception. Since we're booting up,
    // we fake the return state by manually setting the return registers for
    // the boot exception level 2 since we want to drop down to 1.

    // disable interrupts handling and specify exception level 1
    // (see PSTATE format)
    mov x0, #0b1111000101
    msr spsr_el2, x0

    // grab the address of the specified label and set it in the return entry
    // register
    adr x0, el1_entry
    msr elr_el2, x0

    // return from our fake exception
    eret

el1_entry:
    // Reserve memory address 0x80000 and above for the kernel.
    // Our stack pointer will grow downwards from here.
    mov sp, #0x80000

    // setup virtual memory and MMU
    bl setup_vm
    bl enable_mmu

    // zero out the bss region
    // we are assuming that the value at address 0 is 0.
    ldr x0, =bss_start
    ldr x1, =bss_end
    sub x2, x1, x0
    mov x1, #0
    bl memset

    // populate vector table address register for exception level 1
    // with the address for our defined vector table
    ldr x0, =vector_table
    msr vbar_el1, x0

    // Set stack pointer to physical address
    mov x0, #0xffff000000000000
    add sp, sp, x0

    // jump to the KernelMain() function, defined in C
    // we use to load address directly but now use a register so we can
    // translate virtual memory into physical memory 
    // bl sets a link register, I don't know what that is.
    ldr x0, =KernelMain
    blr x0

    // if the kernel ever stops running, jump to our infinite loop
    b end
