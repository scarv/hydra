/* Copyright (C) 2021 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */
#include "hal/sys.h"
#include "share.h"


extern void chacha20_ref( uint8_t *out, const uint8_t *in,
			              size_t in_len, const uint8_t key[32],
			              const uint8_t nonce[12], uint32_t counter );
extern void chacha20_com( uint8_t *out, const uint8_t *in,
			              size_t in_len, const uint8_t key[32],
			              const uint8_t nonce[16]);

void test_chacha(); 
