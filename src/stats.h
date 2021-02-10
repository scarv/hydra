#include "aes.h"

void print_stats(unsigned int cycles, unsigned int instructions);

int multi_add_stats(const void *a, const void *b, void *res, int n_words);
int multi_sub_stats(const void *a, const void *b, void *res, int n_words);
// void multi_mult_stats(const void *a, const void *b, void *res, int n_words);

void AES_init_ctx_stats(struct AES_ctx* ctx, const uint8_t* key);
void AES_ECB_encrypt_stats(const struct AES_ctx* ctx, uint8_t* buf);
