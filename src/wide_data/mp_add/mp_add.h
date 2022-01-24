#ifndef __MP_ADD_H
#define __MP_ADD_H

#include "hal/sys.h"
#include "share.h"

extern const unsigned int x_add_y[NUM_WORDS + 1];

int mp_add_ref(const void *a, const void *b, void *res, int n_words);
int mp_add_com(const void *a, const void *b, void *res, int n_words, int n_cores);

void test_mp_add();

#endif
