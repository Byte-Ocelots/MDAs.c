#ifndef _RFC1321_H
#define _RFC1321_H

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define MD5_DIGEST_LENGTH 16

uint8_t *MD5(uint8_t *message, uint64_t message_len, uint8_t *digest);

#endif