#ifndef __MEMORY_H__
#define __MEMORY_H__

#include <stdbool.h>
#include <stdint.h>

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

// Strip the flags from a page entry to just get the memory address
#define PAGE_DIR_ADDR(p) ((uint64_t)p & 0xfffffffff000)
#define PAGE_TABLE_ADDR(p) ((uint64_t)p & 0xffffffe00000)

// Attributes found in page table entries
#define VALID_ENTRY (1 << 0)
#define TABLE_ENTRY (1 << 1)
#define BLOCK_ENTRY (0 << 1)
#define ENTRY_ACCESSED (1 << 10)
#define NORMAL_MEMORY (1 << 2)
#define DEVICE_MEMORY (0 << 2)

void* kalloc(void);
void kfree(uint64_t v);
void init_memory(void);
bool map_page(uint64_t map, uint64_t v, uint64_t pa, uint64_t attr);
void switch_vm(uint64_t map);
bool setup_uvm(void);
#endif