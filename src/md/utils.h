#ifndef _FUNCS_MD_RFC
#define _FUNCS_MD_RFC

#define MD_DIGEST_LENGTH 16

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

int man(int argc, char **argv, uint8_t *(*cMD)(uint8_t *, uint64_t, uint8_t *));

#endif
