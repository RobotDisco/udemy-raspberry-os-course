#ifndef __FILE_H__
#define __FILE_H__

#include "memory.h"

#define FS_BASE P2VMem(0x30000000)

void init_fs(void);

#endif