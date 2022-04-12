#include "memory.h"
#include "debug.h"
#include "print.h"

#include "stddef.h"

// Linked list for free memory
static struct Page free_memory;
// Defined in linker_script.lds
extern char kernel_end;

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


void init_memory(void) {
    free_region((uint64_t)&kernel_end, MEMORY_END);
    print_memory();
}