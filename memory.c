#include "memory.h"
#include "debug.h"
#include "print.h"
#include "lib.h"

#include <stdbool.h>
#include <stddef.h>

// Linked list for free memory
static struct Page free_memory;
// Defined in linker_script.lds
extern char kernel_end;

// Defined in mmu.s
void load_pgd(uint64_t map);

static void free_region(uint64_t v, uint64_t e) {
    // Mark all pages in this memory range as free
    for (uint64_t start = PAGE_ALIGN_UP(v); start + PAGE_SIZE <= e; start += PAGE_SIZE) {
        /* assumption seems to be that kernel memory starts at
         * virtual memory address 0
         */ 
        if (start + PAGE_SIZE <= MEMORY_END) {
            kfree(start);
        }
    }
}

// Add the specified page address to free memory linked list
void kfree(uint64_t v) {
    // Make sure memory is aligned to page size
    ASSERT(v % PAGE_SIZE == 0);
    // Make sure memory is not in kernel code space
    ASSERT(v >= (uint64_t)&kernel_end);
    // Make sure memory is within kernel memory bounds
    ASSERT(v + PAGE_SIZE <= MEMORY_END);

    // Create a new page and place it at the front of the
    // linked list of free memory pages
    struct Page *page_address = (struct Page*) v;
    page_address->next = free_memory.next;
    free_memory.next = page_address;
}

/* Remove and return the first available free memory page from
 * the free page linked list
 */
void* kalloc(void) {
    struct Page *page_address = free_memory.next;

    if (page_address != NULL) {
        // Make sure memory is aligned to page size
        ASSERT((uint64_t)page_address % PAGE_SIZE == 0);
        // Make sure memory is not in kernel code space
        ASSERT((uint64_t)page_address >= (uint64_t)&kernel_end);
        // Make sure memory is within kernel memory bounds
        ASSERT((uint64_t)page_address + PAGE_SIZE <= MEMORY_END);

        free_memory.next = page_address->next;
    }

    return page_address;
}

void print_memory(void) {
    struct Page *v = free_memory.next;
    uint64_t size = 0;
    uint64_t i = 0;

    while (v != NULL) {
        size += PAGE_SIZE;
        printk("free memory linked list item %d base is address %x\r\n", i++, v);
        v = v->next;
    }

    printk("memory size is %u megabytes\r\n", size/1024/1024);
}

static uint64_t* find_pgd_entry(uint64_t map, uint64_t v, int alloc, uint64_t attr) {
    uint64_t *ptr = (uint64_t*)map;
    void *addr = NULL;
    // Isolate the index portion of the entry
    unsigned int index = (v >> 39) & 0x1ff;

    // Do we already have a valid global page table entry?
    if (ptr[index] & VALID_ENTRY) {
        addr = (void*)P2VMem(PAGE_DIR_ADDR(ptr[index]));
    } else if (alloc == 1) {
        // If alloc is 1, allocate memory for this entry
        // and populate with supplied attributes
        addr = kalloc();
        if (addr != NULL) {
            memset(addr, 0, PAGE_SIZE);
            ptr[index] = (V2PMem(addr) | attr | TABLE_ENTRY);
        }
    }

    return addr;
}

static uint64_t* find_pud_entry(uint64_t map, uint64_t v, int alloc, uint64_t attr) {
    uint64_t *ptr = NULL;
    void *addr = NULL;
    // Isolate the index portion of the entry
    unsigned int index = (v >> 30) & 0x1ff;

    // First find the page entry in the upper translation table.
    ptr = find_pgd_entry(map, v, alloc, attr);
    if (ptr == NULL) {
        return NULL;
    }

    // Do we already have a valid upper page table entry?
    if (ptr[index] & VALID_ENTRY) {
        addr = (void*)P2VMem(PAGE_DIR_ADDR(ptr[index]));
    } else if (alloc == 1) {
        // If alloc is 1, create new entry with value 0
        // and populate with supplied attributes
        addr = kalloc();
        if (addr != NULL) {
            memset(addr, 0, PAGE_SIZE);
            ptr[index] = (V2PMem(addr) | attr | TABLE_ENTRY);
        }
    }

    return addr;
}

// Map specified virtual address to physical page with global table
// and specified attributes
bool map_page(uint64_t map, uint64_t v, uint64_t pa, uint64_t attr) {
   uint64_t vstart = PAGE_ALIGN_DOWN(v);
   uint64_t *ptr = NULL;

   // Location of page is within kernel memory boundaries and is aligned
   ASSERT(vstart + PAGE_SIZE < MEMORY_END);
   ASSERT(pa % PAGE_SIZE == 0);
   ASSERT(pa + PAGE_SIZE <= V2PMem(MEMORY_END));

   ptr = find_pud_entry(map, vstart, 1, attr);
   // If upper page translation table has no entry, we don't have one. 
   if (ptr == NULL) {
       return false;
   }

   // Isolate the index portion of the entry
   unsigned int index = (vstart >> 21) & 0x1ff;
   // Are we a valid entry? If not, crash
   ASSERT((ptr[index] & VALID_ENTRY) == 0);

   // Set entry to be a block entry with specified physical address
   // and attributes
   ptr[index] = (pa | attr | BLOCK_ENTRY);

   return true;
}

void init_memory(void) {
    free_region((uint64_t)&kernel_end, MEMORY_END);
    //print_memory();
}

bool setup_uvm(void) {
    bool status = false;

    return status;
}

void switch_vm(uint64_t map) {
    load_pgd(V2PMem(map));
}