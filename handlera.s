.section .text
.global vector_table
// Exception handlers are defined as a table with a fixed 32-instruction width
// for each handler. If we need more instructions we branch out to a different
// label.

// There are four kinds of handlers needed for each mode:
// synchronous error, irq, fast interrupt, and system error

// Each exception level has its own table and needs to implement four sets of
// handlers:
// current exception level using stack pointer 0 / link register 0
// current exception level using stack pointer 1 / link register 1
// lower exception level in 32-bit mode
// lower exception level in 64-bit mode

// We align to 2k
.balign 0x800;
vector_table:
// We don't use many the following exceptions, so if we ever run them, just
// error out this is an unanticipated situation
current_el_sp0_sync:
    b error

// Align each handler to 128k

// Exception handlers for exception level 1 using stack pointer 0
.balign 0x80
current_el_sp0_irq:
    b error

.balign 0x80
current_el_sp0_fiq:
    b error

.balign 0x80
current_el_sp0_serror:
    b error

// Exception handlers for exception level 1 using stack pointer 1
.balign 0x80
current_el_spn_sync:
    b sync_handler

.balign 0x80
current_el_spn_irq:
    b error

.balign 0x80
current_el_spn_fiq:
    b error

.balign 0x80
current_el_spn_serror:
    b error

// We won't be implementing exception handlers for exception level 0
// (userspace) just yet, so leave unimplemented
.balign 0x80
lower_el_aarch64_sync:
    b error

.balign 0x80
lower_el_aarch64_irq:
    b error

.balign 0x80
lower_el_aarch64_fiq:
    b error

.balign 0x80
lower_el_aarch64_serror:
    b error

.balign 0x80
lower_el_aarch32_sync:
    b error

.balign 0x80
lower_el_aarch32_irq:
    b error

.balign 0x80
lower_el_aarch32_fiq:
    b error

.balign 0x80
lower_el_aarch32_serror:
    b error

error:
    mov x0, #0
    bl handler

    eret

sync_handler:
    mov x0, #1
    // This register contains information about the current exception
    mrs x1, esr_el1
    // This register contains the address we should return to when we finish
    // handling the exception
    mrs x2, elr_el1
    bl handler

    eret
