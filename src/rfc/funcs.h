#ifndef _FUNCS_MD_RFC
#define _FUNCS_MD_RFC


unsigned long htobe64(unsigned long host_64bits);

unsigned F(unsigned X, unsigned Y, unsigned Z);

unsigned G4(unsigned X, unsigned Y, unsigned Z);

unsigned G5(unsigned X, unsigned Y, unsigned Z);

unsigned H(unsigned X, unsigned Y, unsigned Z);

unsigned I(unsigned X, unsigned Y, unsigned Z);

unsigned G_md5(unsigned X, unsigned Y, unsigned Z);

unsigned ROTL(unsigned x, unsigned char n);

#endif
