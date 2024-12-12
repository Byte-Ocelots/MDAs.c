#include "funcs.h"

/* unsigned int long htobe64(unsigned int long host_64bits)
{
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
	return __builtin_bswap64(host_64bits);
#else
	return host_64bits;
#endif
} */

unsigned int F(unsigned int X, unsigned int Y, unsigned int Z)
{
	return (X & Y) | ((~X) & Z);
}

unsigned int G4(unsigned int X, unsigned int Y, unsigned int Z)
{
	return (X & Y) | (X & Z) | (Y & Z);
}

unsigned int G5(unsigned int X, unsigned int Y, unsigned int Z)
{
	return (X & Z) | (Y & (~Z));
}

unsigned int H(unsigned int X, unsigned int Y, unsigned int Z)
{
	return X ^ Y ^ Z;
}

unsigned int I(unsigned int X, unsigned int Y, unsigned int Z)
{
	return Y ^ (X | (~Z));
}

unsigned int ROTL(unsigned int x, unsigned char n)
{
	return (x << n) | (x >> (32 - n));
}
