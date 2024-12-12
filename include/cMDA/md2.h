#ifndef INC_cMD2
#define INC_cMD2

#define MD2_DIGEST_LENGTH 16

unsigned char *cMD2(unsigned char *message, unsigned long message_len, unsigned char *digest);

#endif