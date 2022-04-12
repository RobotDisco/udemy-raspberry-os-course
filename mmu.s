// Some compile-time constants
.equ MAIR_ATTR, (0x44 << 8)
.equ TCR_T0SZ, (16)
.equ TCR_T1SZ, (16 << 16)
.equ TCR_TG0, (0 << 14)
.equ TCR_TG1, (2 << 30)
.equ TCR_VALUE, (TCR_T0SZ | TCR_T1SZ | TCR_TG0 | TCR_TG1)
.equ PAGE_SIZE, (2*1024*1024)

// Public procedures
.global enable_mmu
.global setup_vm

enable_mmu:
    adr x0, pgd_ttbr1
    msr ttbr1_el1, x0

    adr x0, pgd_ttbr0
    msr ttbr0_el1, x0

    ldr x0, =MAIR_ATTR
    msr mair_el1, x0

    ldr x0, =TCR_VALUE
    msr tcr_el1, x0

    mrs x0, sctlr_el1
    orr x0, x0, #1
    msr sctlr_el1, x0

    ret

setup_vm:
// Set up kernel-space virtual memory   
setup_kvm:
    // Populate first Global Page Table record with first entry in our
    // Upper Page Table record 
    adr x0, pgd_ttbr1
    adr x1, pud_ttbr1
    // Populate first entry of global page table to indicate it is an
    // intermediate table entry and the entry is valid
    orr x1, x1, #3
    str x1, [x0]

    // Populate first Upper Page Table record with first entry in our
    // Medium Page Table record 
    adr x0, pud_ttbr1
    adr x1, pmd_ttbr1
    // Populate first entry of upper page table to indicate it is an
    // intermediate table entry and the entry is valid
    orr x1, x1, #3
    str x1, [x0]

kmem_pagetable_init_setup:
    // This is the upper kernel-space address limit
    mov x2, #0x34000000
    // This is the first entry in our Medium Paging Table
    adr x1, pmd_ttbr1
    // We use medium page table as the terminal page table
    // Define starting flags for each entry
    mov x0, #(1 << 10 | 1 << 2 | 1 << 0)

kmem_pagetable_init_loop:
    // Loop from first entry in medium paging table until
    // kernel-space address limit, storing default entries
    str x0, [x1], #8
    add x0, x0, #PAGE_SIZE
    cmp x0, x2
    blo kmem_pagetable_init_loop

kmem_io_init_setup:
    // Define our device memory mapped base bottom / top addresses
    mov x2, #0x40000000
    mov x0, #0x3f000000

    // This memory address lives within our kernel space
    // Compute the starting offset based on our medium page table. 
    adr x3, pmd_ttbr1
    // Shift range up by 2M, accounting for each entry being 8 bytes
    lsr x1, x0, #(21 - 3)
    add x1, x1, x3

    // Mark the initial entry as a direct device memory mapped memory
    // page entry
    orr x0, x0, #1
    orr x0, x0, #(1 << 10)

// Populate the memory table for our generic timer
// memory address 0x40000000 - 0x41000000
kmem_io_init_loop:
    // As above, init timer memory-mapped space
    str x0, [x1], #8
    add x0, x0, #PAGE_SIZE
    cmp x0, x2
    blo kmem_io_init_loop

qemu_timer_init_setup:
    // The QEMU timer interrupt memory is outside our kernel space
    // Make a different middle page table for generic timer vmemory
    // and add a new entry for that to the upper page table
    adr x0, pud_ttbr1
    // Populate second entry in upper page table with address for
    // second medium table
    add x0, x0, #(1 * 8)
    adr x1, pmd2_ttbr1
    orr x1, x1, #3
    str x1, [x0]

    // This are our upper/lower generic timer memory boundaries
    mov x2, #0x41000000
    mov x0, #0x40000000

    // Default value for our second middle paging entries
    adr x1, pmd2_ttbr1
    orr x0, x0, #1
    orr x0, x0, #(1 << 10)

 qemu_timer_init_loop:
    // Populate our second middle page table
    str x0, [x1], #8
    add x0, x0, #PAGE_SIZE
    cmp x0, x2
    blo qemu_timer_init_loop

// Set up userspace virtual memory
setup_uvm:
    // Create first entry in our global page table, pointing to our
    // upper page table
    adr x0, pgd_ttbr0
    adr x1, pud_ttbr0
    orr x1, x1, #3
    str x1, [x0]
    // Ditto with the first entry in our upper page table pointing to
    // our middle page table
    adr x0, pud_ttbr0
    adr x1, pmd_ttbr0
    orr x1, x1, #3
    str x1, [x0]

    /* 
     * This is the lowest level page table entry so needs some
     * extra flags set
     */
    adr x1, pmd_ttbr0
    mov x0, #(1 << 10 | 1 << 2 | 1 << 0)
    str x0, [x1]

    // We don't loop because we're presumably going to create more entries at
    // runtime, whereas we prematurely map all the kernel entryspace

    ret

// Each of our MMU page tables are 4k entries large
.balign 4096
// Define our main kernel-space page table hierarchy
pgd_ttbr1:
    .space 4096
pud_ttbr1:
    .space 4096
pmd_ttbr1:
    .space 4096

// Define our second kernelspace page table hierarchy
// We use this for our kernel timer address space
pmd2_ttbr1:
    .space 4096

// Define our userspace page table hierarchy
pgd_ttbr0:
    .space 4096
pud_ttbr0:
    .space 4096
pmd_ttbr0:
    .space 4096
