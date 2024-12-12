#ifndef INC_cMD2
#define INC_cMD2

#include <stdint.h>

#define MD2_DIGEST_LENGTH 16

uint8_t *cMD2(uint8_t *message, uint64_t message_len, uint8_t *digest);

#endif