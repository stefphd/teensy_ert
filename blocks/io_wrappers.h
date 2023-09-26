/* 
 * Wrappers to make I/O functions available with C linkage. This allows C++
 * methods to be called from C code.
 *
 * Copyright 2009-2014 The MathWorks, Inc. */

#ifndef __io_wrappers_h__
#define __io_wrappers_h__

#include <inttypes.h>
#include <stdio.h> /* for size_t */

#ifdef __cplusplus
extern "C" { 
#endif        
void Serial_begin(long r);
int Serial_read(void);
void Serial_write(uint8_t * c, size_t s);
#ifdef __cplusplus
}
#endif        

#endif  /* __io_wrappers_h__ */
