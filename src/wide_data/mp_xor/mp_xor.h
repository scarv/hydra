#ifndef __MP_XOR_H
#define __MP_XOR_H

#include "hal/sys.h"
#include "share.h"

extern const unsigned int x_xor_y[NUM_WORDS];

void mp_xor_ref(const void *a, const void *b, void *res, int n_words);
void mp_xor_com(const void *a, const void *b, void *res, int n_words, int n_cores);

void test_mp_xor();

#endif
