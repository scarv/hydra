/* Copyright (C) 2021 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */
#include <stdint.h>
#include <stdio.h>
#include "chacha.h"
#include "chacha_openssl.h"

void print_bytes(uint8_t * p, int len){
    print_string(" 0x");
    for (int i = 0; i < len; i++) {
        char c = (p[i] >> 4) & 0xf;
        if (c < 10) print_char(c + '0');
        else print_char(c - 10 + 'a');
        c = p[i] & 0xf;
        if (c < 10) print_char(c + '0');
        else print_char(c - 10 + 'a');
    }
}
void test_chacha() {

  int len[5] = {64, 128, 256, 512, 1024};
  uint8_t data[4096]={0};
  //uint32_t rand = 1;
  for (int i = 0; i < 4096; i++) {
    //rand *= 101;
    //rand %= 16777213; // random prime
    //data[i] = (uint8_t)(rand); 
    data[i] =0;
  }

  uint8_t key[32] = "Setec astronomy;too many secrets";
  uint8_t nonce[12] = "BurnAfterUse";

  uint8_t ref[4096];
  uint8_t com[4096];

  uint8_t nonce1[16] = {0};
  memcpy(nonce1+4, nonce, 12);

  uint8_t counter[16] = {0};
  memcpy(counter+4, nonce, 12);
  
  int num_bytes;
  for (int i = 0; i<5; i++) {
    num_bytes = len[i];
    print_int(num_bytes);
    print_string("-bytes using chacha_openssl: ");
    MEASURE( chacha20_openssl(ref, data, num_bytes, (uint32_t *)key, (uint32_t *)counter); )
    print_int(num_bytes);
    print_string("-bytes using chacha20: ");
    MEASURE( chacha20_ref(ref, data, num_bytes, key, nonce, 0); )
    print_int(num_bytes);
    print_string("-bytes using chacha20 in the composed mode: ");
    MEASURE( chacha20_com(com, data, num_bytes, key, nonce1); )

    if (!check_result(ref, com, num_bytes)) {
        print_string("chacha failed!\n");
        print_string("   data    :");
        print_bytes(data, num_bytes);
        print_string("\n chacha ref:");
        print_bytes(ref, num_bytes);
        print_string("\n chacha com:");
        print_bytes(com, num_bytes);
    } 
  }
}
