#ifndef _FUNCS_MD_RFC
#define _FUNCS_MD_RFC

#include <stdint.h>

uint64_t htobe64(uint64_t host_64bits);

uint32_t F(uint32_t X, uint32_t Y, uint32_t Z);

uint32_t G4(uint32_t X, uint32_t Y, uint32_t Z);

uint32_t G5(uint32_t X, uint32_t Y, uint32_t Z);

uint32_t H(uint32_t X, uint32_t Y, uint32_t Z);

uint32_t I(uint32_t X, uint32_t Y, uint32_t Z);

uint32_t G_md5(uint32_t X, uint32_t Y, uint32_t Z);

uint32_t ROTL(uint32_t x, uint8_t n);

#endif
