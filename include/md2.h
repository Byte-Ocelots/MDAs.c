#ifndef INC_MD2
#define INC_MD2

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MD2_DIGEST_LENGTH 16

uint8_t *MD2(uint8_t *message, uint64_t message_len, uint8_t *digest);

#endif