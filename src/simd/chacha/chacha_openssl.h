#include <stdint.h>
#include <string.h>

#define U8TO32_LITTLE(p)                              \
  (((uint32_t)((p)[0])) | ((uint32_t)((p)[1]) << 8) | \
   ((uint32_t)((p)[2]) << 16) | ((uint32_t)((p)[3]) << 24))

void chacha20_openssl(uint8_t *out, const uint8_t *inp,
			size_t len, const uint32_t key[8],
			const uint32_t counter[4]);


