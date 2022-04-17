#ifndef __FILE_H__
#define __FILE_H__

#include "memory.h"

#include <stdint.h>

// The base address of our embedded FAT16 filesystem
#define FS_BASE P2VMem(0x30000000)

// FAT entries, apparently deleted files are different from unpopulated entries
#define ENTRY_EMPTY 0
#define ENTRY_DELETED 0xe5

/*
 * We're implementing FAT16; it's readable on all major operating systems
 * and thus can bootstrap it in our dev environment. Also, it's less
 * complicated than FAT32, whose extensions and advances we don't need given
 * the small and static size of our OS filesystem.
 */

/*
 * BIOS Partition Block, the first thing in the partition
 * http://www.ntfs.com/fat-partition-sector.htm
 */
struct BPB {
    uint8_t jump[3]; // Jump Instruction
    uint8_t oem[8]; // OEM Name, in text
    uint16_t bytes_per_sector;
    uint8_t sectors_per_cluster;
    /* Start of sectors from Partition Boot Sector to start of first FAT */
    uint16_t reserved_sector_count;
    uint8_t fat_count;
    uint16_t root_entry_count;
    /* Number of sectors on volume if number fits in 16 bits */
    uint16_t small_sector_count;
    /* Type of disk media; 0xF8 for hard disk */
    uint8_t media_type;
    uint16_t sectors_per_fat;
    uint16_t sectors_per_track;
    uint16_t head_count;
    /* Same as "Relative Sector" field in partition table */
    uint32_t hidden_sector_count;
    /* If small_sector_count is 0, use this larger field */
    uint32_t large_sector_count;
    /* BIOS physical disk number;
     * 0x00 start for floppies, 0x80 start for hard disks
     */
    uint8_t drive_number;
    /* Not used */
    uint8_t current_head;
    uint8_t signature; // Should be 0x28 or 0x29?
    uint32_t volume_id;
    uint8_t volume_label[11];
    uint8_t file_system[8]; // FAT12 or FAT16
} __attribute__((packed)); // Don't add any padding to the data structure

/*
 * FAT Directory Entry
 * http://www.ntfs.com/fat-folder-structure.htm
 */
struct DirEntry {
    uint8_t name[8];
    uint8_t ext[3];
    uint8_t attributes;
    uint8_t reserved;
    uint8_t create_ms;
    uint16_t create_time;
    uint16_t create_date;
    uint16_t access_date;
    uint16_t attr_index;
    uint16_t m_time;
    uint16_t m_date;
    uint16_t cluster_index;
    uint32_t file_size;
} __attribute__((packed));

void init_fs(void);
int load_file(char *path, uint64_t addr);
#endif