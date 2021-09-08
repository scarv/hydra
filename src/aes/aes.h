// This file adapted from https://github.com/kokke/tiny-AES-c

/*****************************************************************************/
/* Includes:                                                                 */
/*****************************************************************************/
#include <stdint.h>

/*****************************************************************************/
/* Defines:                                                                  */
/*****************************************************************************/
#define AES_BLOCKLEN 16 // Block length in bytes - AES is 128b block only

#define AES_KEYLEN 16   // Key length in bytes
#define AES_keyExpSize 176

struct AES_ctx
{
    uint8_t RoundKey[AES_keyExpSize];
};

void AES_init_ctx(struct AES_ctx* ctx, const uint8_t* key);

void AES_ECB_encrypt(const struct AES_ctx* ctx, uint8_t* buf);
