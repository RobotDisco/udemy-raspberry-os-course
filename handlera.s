.section .text
.global enable_irq
.global enable_timer
.global read_timer_freq
.global read_timer_status
.global set_timer_interval
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
    b irq_handler

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
    // save all register values on the stack to preserve them for when we return
    sub sp, sp, #(32 * 8)
    stp x0, x1, [sp]
    stp x2, x3, [sp, #(16 * 1)]
    stp x4, x5, [sp, #(16 * 2)]
    stp x6, x7, [sp, #(16 * 3)]
    stp x8, x9, [sp, #(16 * 4)]
    stp x10, x11, [sp, #(16 * 5)]
    stp x12, x13, [sp, #(16 * 6)]
    stp x14, x15, [sp, #(16 * 7)]
    stp x16, x17, [sp, #(16 * 8)]
    stp x18, x19, [sp, #(16 * 9)]
    stp x20, x21, [sp, #(16 * 10)]
    stp x22, x23, [sp, #(16 * 11)]
    stp x24, x25, [sp, #(16 * 12)]
    stp x26, x27, [sp, #(16 * 13)]
    stp x28, x29, [sp, #(16 * 14)]
    str x30, [sp, #(16 * 15)]

    mov x0, #0
    bl handler

    // restore all register values from the stack for the originating function
    ldp x0, x1, [sp]
    ldp x2, x3, [sp, #(16 * 1)]
    ldp x4, x5, [sp, #(16 * 2)]
    ldp x6, x7, [sp, #(16 * 3)]
    ldp x8, x9, [sp, #(16 * 4)]
    ldp x10, x11, [sp, #(16 * 5)]
    ldp x12, x13, [sp, #(16 * 6)]
    ldp x14, x15, [sp, #(16 * 7)]
    ldp x16, x17, [sp, #(16 * 8)]
    ldp x18, x19, [sp, #(16 * 9)]
    ldp x20, x21, [sp, #(16 * 10)]
    ldp x22, x23, [sp, #(16 * 11)]
    ldp x24, x25, [sp, #(16 * 12)]
    ldp x26, x27, [sp, #(16 * 13)]
    ldp x28, x29, [sp, #(16 * 14)]
    ldr x30, [sp, #(16 * 15)]
    add sp, sp, #(32 * 8)

    eret

irq_handler:
    // save all register values on the stack to preserve them for when we return
    sub sp, sp, #(32 * 8)
    stp x0, x1, [sp]
    stp x2, x3, [sp, #(16 * 1)]
    stp x4, x5, [sp, #(16 * 2)]
    stp x6, x7, [sp, #(16 * 3)]
    stp x8, x9, [sp, #(16 * 4)]
    stp x10, x11, [sp, #(16 * 5)]
    stp x12, x13, [sp, #(16 * 6)]
    stp x14, x15, [sp, #(16 * 7)]
    stp x16, x17, [sp, #(16 * 8)]
    stp x18, x19, [sp, #(16 * 9)]
    stp x20, x21, [sp, #(16 * 10)]
    stp x22, x23, [sp, #(16 * 11)]
    stp x24, x25, [sp, #(16 * 12)]
    stp x26, x27, [sp, #(16 * 13)]
    stp x28, x29, [sp, #(16 * 14)]
    str x30, [sp, #(16 * 15)]

    mov x0, #2
    // This register contains information about the current exception
    mrs x1, esr_el1
    // This register contains the address we should return to when we finish
    // handling the exception
    mrs x2, elr_el1
    bl handler

    // restore all register values from the stack for the originating function
    ldp x0, x1, [sp]
    ldp x2, x3, [sp, #(16 * 1)]
    ldp x4, x5, [sp, #(16 * 2)]
    ldp x6, x7, [sp, #(16 * 3)]
    ldp x8, x9, [sp, #(16 * 4)]
    ldp x10, x11, [sp, #(16 * 5)]
    ldp x12, x13, [sp, #(16 * 6)]
    ldp x14, x15, [sp, #(16 * 7)]
    ldp x16, x17, [sp, #(16 * 8)]
    ldp x18, x19, [sp, #(16 * 9)]
    ldp x20, x21, [sp, #(16 * 10)]
    ldp x22, x23, [sp, #(16 * 11)]
    ldp x24, x25, [sp, #(16 * 12)]
    ldp x26, x27, [sp, #(16 * 13)]
    ldp x28, x29, [sp, #(16 * 14)]
    ldr x30, [sp, #(16 * 15)]
    add sp, sp, #(32 * 8)

    eret

sync_handler:
    // save all register values on the stack to preserve them for when we return
    sub sp, sp, #(32 * 8)
    stp x0, x1, [sp]
    stp x2, x3, [sp, #(16 * 1)]
    stp x4, x5, [sp, #(16 * 2)]
    stp x6, x7, [sp, #(16 * 3)]
    stp x8, x9, [sp, #(16 * 4)]
    stp x10, x11, [sp, #(16 * 5)]
    stp x12, x13, [sp, #(16 * 6)]
    stp x14, x15, [sp, #(16 * 7)]
    stp x16, x17, [sp, #(16 * 8)]
    stp x18, x19, [sp, #(16 * 9)]
    stp x20, x21, [sp, #(16 * 10)]
    stp x22, x23, [sp, #(16 * 11)]
    stp x24, x25, [sp, #(16 * 12)]
    stp x26, x27, [sp, #(16 * 13)]
    stp x28, x29, [sp, #(16 * 14)]
    str x30, [sp, #(16 * 15)]

    mov x0, #1
    // This register contains information about the current exception
    mrs x1, esr_el1
    // This register contains the address we should return to when we finish
    // handling the exception
    mrs x2, elr_el1
    bl handler

    // restore all register values from the stack for the originating function
    ldp x0, x1, [sp]
    ldp x2, x3, [sp, #(16 * 1)]
    ldp x4, x5, [sp, #(16 * 2)]
    ldp x6, x7, [sp, #(16 * 3)]
    ldp x8, x9, [sp, #(16 * 4)]
    ldp x10, x11, [sp, #(16 * 5)]
    ldp x12, x13, [sp, #(16 * 6)]
    ldp x14, x15, [sp, #(16 * 7)]
    ldp x16, x17, [sp, #(16 * 8)]
    ldp x18, x19, [sp, #(16 * 9)]
    ldp x20, x21, [sp, #(16 * 10)]
    ldp x22, x23, [sp, #(16 * 11)]
    ldp x24, x25, [sp, #(16 * 12)]
    ldp x26, x27, [sp, #(16 * 13)]
    ldp x28, x29, [sp, #(16 * 14)]
    ldr x30, [sp, #(16 * 15)]
    add sp, sp, #(32 * 8)

    eret

read_timer_freq:
    mrs x0, CNTFRQ_EL0
    ret

set_timer_interval:
    msr CNTP_TVAL_EL0, x0
    ret

enable_timer:
    stp x29, x30, [sp, #-16]!

    // We want our timer to fire every 10ms.
    // So divide the builtin counter frequency by 100
    // and populate the time interval register.
    bl read_timer_freq
    mov x1, #100
    udiv x0, x0, x1
    bl set_timer_interval

    // Setting bit 0 to 1 to this register enables
    // the timer, now that we've populating settings
    mov x0, #1
    msr CNTP_CTL_EL0, x0

    ldp x29, x30, [sp], #16
    ret

read_timer_status:
    mrs x0, CNTP_CTL_EL0
    ret

enable_irq:
    // We need to flip on the bit that says that we should process interrupts
    msr daifclr, #2
    ret
