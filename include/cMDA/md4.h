#ifndef INC_cMD4
#define INC_cMD4

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MD4_DIGEST_LENGTH 16

uint8_t *cMD4(uint8_t *message, uint64_t message_len, uint8_t *digest);

#endif