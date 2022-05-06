#ifndef __MP_MUL_H
#define __MP_MUL_H

#include "hal/sys.h"
#include "share.h"
extern const unsigned int x_times_y[NUM_WORDS * 2];

int mp_mul_ref(const void *a, const void *b, void *res, int n_words);
int mp_mul_com(const void *a, const void *b, void *res, int n_words, int n_cores);

void test_mp_mul();
void eval_mp_mul(int len);
#endif
