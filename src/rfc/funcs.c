#include "funcs.h"

unsigned long htobe64(unsigned long host_64bits)
{
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
	return __builtin_bswap64(host_64bits);
#else
	return host_64bits;
#endif
}

unsigned F(unsigned X, unsigned Y, unsigned Z)
{
	return (X & Y) | ((~X) & Z);
}

unsigned G4(unsigned X, unsigned Y, unsigned Z)
{
	return (X & Y) | (X & Z) | (Y & Z);
}

unsigned G5(unsigned X, unsigned Y, unsigned Z)
{
	return (X & Z) | (Y & (~Z));
}

unsigned H(unsigned X, unsigned Y, unsigned Z)
{
	return X ^ Y ^ Z;
}

unsigned I(unsigned X, unsigned Y, unsigned Z)
{
	return Y ^ (X | (~Z));
}

unsigned ROTL(unsigned x, unsigned char n)
{
	return (x << n) | (x >> (32 - n));
}
