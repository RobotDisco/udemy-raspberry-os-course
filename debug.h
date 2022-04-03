#ifndef __DEBUG_H__
#define __DEBUG_H__

#include "stdint.h"

/* Asserts are wrapped in do blocks so
 * we can handle if conditions (or possibly
 * nested if conditions) without breaking
 * 
 * __FILE__ and __LINE__ are builtin macros
 */
#define ASSERT(e) do { \
    if (!(e)) \
        error_check(__FILE__, __LINE__); \
} while (0)

void error_check(char *file, uint64_t line);

#endif