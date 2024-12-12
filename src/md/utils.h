#ifndef _FUNCS_MD_RFC
#define _FUNCS_MD_RFC

#define MD_DIGEST_LENGTH 16

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

int man(int argc, char **argv, unsigned char *(*cMD)(unsigned char *, unsigned long, unsigned char *));

#endif
