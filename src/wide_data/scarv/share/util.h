/* Copyright (C) 2019 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#ifndef __LIBSCARV_UTIL_H
#define __LIBSCARV_UTIL_H

#include  <stdarg.h>
#include <stdbool.h>
#include  <stdint.h>

#include  <string.h>

#define SIZEOF(x) ( sizeof(x)     )
#define BITSOF(x) ( sizeof(x) * 8 )

#define MAX(x,y) ( ( (x) > (y) ) ? (x) : (y) )
#define MIN(x,y) ( ( (x) < (y) ) ? (x) : (y) )

#define ABS(x) ( ( (x) < 0 ) ? -(x) : +(x) )

#define U8_TO_U8_N(r,x) {                                                                     \
  (r)[  0 ] = (x)[  0 ]; (r)[  1 ] = (x)[  1 ]; (r)[  2 ] = (x)[  2 ]; (r)[  3 ] = (x)[  3 ]; \
  (r)[  4 ] = (x)[  4 ]; (r)[  5 ] = (x)[  5 ]; (r)[  6 ] = (x)[  6 ]; (r)[  7 ] = (x)[  7 ]; \
  (r)[  8 ] = (x)[  8 ]; (r)[  9 ] = (x)[  9 ]; (r)[ 10 ] = (x)[ 10 ]; (r)[ 11 ] = (x)[ 11 ]; \
  (r)[ 12 ] = (x)[ 12 ]; (r)[ 13 ] = (x)[ 13 ]; (r)[ 14 ] = (x)[ 14 ]; (r)[ 15 ] = (x)[ 15 ]; \
}
#define U8_TO_U8_T(r,x) {                                                                     \
  (r)[  0 ] = (x)[  0 ]; (r)[  1 ] = (x)[  4 ]; (r)[  2 ] = (x)[  8 ]; (r)[  3 ] = (x)[ 12 ]; \
  (r)[  4 ] = (x)[  1 ]; (r)[  5 ] = (x)[  5 ]; (r)[  6 ] = (x)[  9 ]; (r)[  7 ] = (x)[ 13 ]; \
  (r)[  8 ] = (x)[  2 ]; (r)[  9 ] = (x)[  6 ]; (r)[ 10 ] = (x)[ 10 ]; (r)[ 11 ] = (x)[ 14 ]; \
  (r)[ 12 ] = (x)[  3 ]; (r)[ 13 ] = (x)[  7 ]; (r)[ 14 ] = (x)[ 11 ]; (r)[ 15 ] = (x)[ 15 ]; \
}

#define U32_TO_U8_LE(r,x,i) {                  \
  (r)[ (i) + 0 ] = ( (x) >>  0 ) & 0xFF;       \
  (r)[ (i) + 1 ] = ( (x) >>  8 ) & 0xFF;       \
  (r)[ (i) + 2 ] = ( (x) >> 16 ) & 0xFF;       \
  (r)[ (i) + 3 ] = ( (x) >> 24 ) & 0xFF;       \
}

#define U32_TO_U8_BE(r,x,i) {                  \
  (r)[ (i) + 3 ] = ( (x) >>  0 ) & 0xFF;       \
  (r)[ (i) + 2 ] = ( (x) >>  8 ) & 0xFF;       \
  (r)[ (i) + 1 ] = ( (x) >> 16 ) & 0xFF;       \
  (r)[ (i) + 0 ] = ( (x) >> 24 ) & 0xFF;       \
}

#define U64_TO_U8_BE(r,x,i) {                  \
  (r)[ (i) + 7 ]= ((x) >>  0) & 0xFF;          \
  (r)[ (i) + 6 ]= ((x) >>  8) & 0xFF;          \
  (r)[ (i) + 5 ]= ((x) >> 16) & 0xFF;          \
  (r)[ (i) + 4 ]= ((x) >> 24) & 0xFF;          \
  (r)[ (i) + 3 ]= ((x) >> 32) & 0xFF;          \
  (r)[ (i) + 2 ]= ((x) >> 40) & 0xFF;          \
  (r)[ (i) + 1 ]= ((x) >> 48) & 0xFF;          \
  (r)[ (i) + 0 ]= ((x) >> 56) & 0xFF;          \
}

#define U8_TO_U32_LE(r,x,i) {                  \
  (r)  = ( uint32_t )( (x)[ (i) + 0 ] ) <<  0; \
  (r) |= ( uint32_t )( (x)[ (i) + 1 ] ) <<  8; \
  (r) |= ( uint32_t )( (x)[ (i) + 2 ] ) << 16; \
  (r) |= ( uint32_t )( (x)[ (i) + 3 ] ) << 24; \
}

#define U8_TO_U32_BE(r,x,i) {                  \
  (r)  = ( uint32_t )( (x)[ (i) + 3 ] ) <<  0; \
  (r) |= ( uint32_t )( (x)[ (i) + 2 ] ) <<  8; \
  (r) |= ( uint32_t )( (x)[ (i) + 1 ] ) << 16; \
  (r) |= ( uint32_t )( (x)[ (i) + 0 ] ) << 24; \
}

#define U8_TO_U64_BE(r,x,i) {                  \
  (r)  = ( uint64_t )( (x)[ (i) + 7 ] ) <<  0; \
  (r) |= ( uint64_t )( (x)[ (i) + 6 ] ) <<  8; \
  (r) |= ( uint64_t )( (x)[ (i) + 5 ] ) << 16; \
  (r) |= ( uint64_t )( (x)[ (i) + 4 ] ) << 24; \
  (r) |= ( uint64_t )( (x)[ (i) + 3 ] ) << 32; \
  (r) |= ( uint64_t )( (x)[ (i) + 2 ] ) << 40; \
  (r) |= ( uint64_t )( (x)[ (i) + 1 ] ) << 48; \
  (r) |= ( uint64_t )( (x)[ (i) + 0 ] ) << 56; \
}

#define U32_SHL(x,y) (   (x) << (y) )
#define U64_SHL(x,y) (   (x) << (y) )

#define U32_SHR(x,y) (   (x) >> (y) )
#define U64_SHR(x,y) (   (x) >> (y) )

#define U32_RTL(x,y) ( ( (x) << (y) ) | ( (x) >> ( 32 - (y) ) ) )
#define U64_RTL(x,y) ( ( (x) << (y) ) | ( (x) >> ( 32 - (y) ) ) )

#define U32_RTR(x,y) ( ( (x) >> (y) ) | ( (x) << ( 32 - (y) ) ) )
#define U64_RTR(x,y) ( ( (x) >> (y) ) | ( (x) << ( 64 - (y) ) ) )

#endif
