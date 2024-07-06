#include "funcs.h"

uint64_t htobe64(uint64_t host_64bits)
{
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
	return __builtin_bswap64(host_64bits);
#else
	return host_64bits;
#endif
}

uint32_t F(uint32_t X, uint32_t Y, uint32_t Z)
{
	return (X & Y) | ((~X) & Z);
}

uint32_t G(uint32_t X, uint32_t Y, uint32_t Z)
{
	return (X & Y) | (X & Z) | (Y & Z);
}

uint32_t H(uint32_t X, uint32_t Y, uint32_t Z)
{
	return X ^ Y ^ Z;
}

uint32_t I(uint32_t X, uint32_t Y, uint32_t Z)
{
	return Y ^ (X | (~Z));
}

uint32_t G_md5(uint32_t X, uint32_t Y, uint32_t Z)
{
	return (X & Z) | (Y & (~Z));
}

uint32_t ROTL(uint32_t x, uint8_t n)
{
	return (x << n) | (x >> (32 - n));
}
