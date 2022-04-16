#include "file.h"
#include "print.h"
#include "debug.h"

static struct BPB *get_fs_bpb(void) {
    uint32_t lba = *(uint32_t*)(FS_BASE + 0x1be + 8);

    return (struct BPB*)(FS_BASE + lba * 512);
}

void init_fs(void) {
    uint8_t *p = (uint8_t*)get_fs_bpb();

    if (p[0x1fe] != 0x55 || p[0x1ff] != 0xaa) {
        // When I made this signature too long, the FAT16 loading failed.
        // Is this because the code that loads the filesystem into memory
        // doesn't account properly for the size of the .text segment?
        printk("invalid FAT16 signature: %x,%x\r\n",
            p[0x1fe],
            p[0x1ff]
        );
        ASSERT(0);
    } else {
        printk("FAT16 file system is loaded\r\n");
    }
}