#ifndef __MEMORY_H__
#define __MEMORY_H__

#include "stdint.h"

struct Page {
    struct Page* next;
};

// Base physical memory address of kernel
#define KERNEL_BASE_ADDR 0xffff000000000000

// Translate physical to virtual memory and back again
#define P2VMem(p) ((uint64_t)(p) + KERNEL_BASE_ADDR)
#define V2PMem(v) ((uint64_t)(v) - KERNEL_BASE_ADDR)

/* End of allocatable memory for kernel
 * Areas above here are used by something other than
 * kernel level process memory.
 */
#define MEMORY_END P2VMem(0x30000000)
// Our page size is two megabytes
#define PAGE_SIZE (2*1024*1024)

// Align given address up/down to page address boundary
// The right-shifting and left-shift basically clears offset portions
#define PAGE_ALIGN_UP(v) ((((uint64_t)v + PAGE_SIZE - 1) >> 21) << 21)
#define PAGE_ALIGN_DOWN(v) (((uint64_t)v >> 21) << 21)

void* kalloc(void);
void kfree(uint64_t v);
void init_memory(void);
#endif