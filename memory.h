#ifndef __MEMORY_H__
#define __MEMORY_H__

#include "stdint.h"

#define KERNEL_BASE_ADDR 0xffff000000000000

#define P2VMem(p) ((uint64_t)(p) + KERNEL_BASE_ADDR)
#define V2PMem(v) ((uint64_t)(v) - KERNEL_BASE_ADDR)

#endif