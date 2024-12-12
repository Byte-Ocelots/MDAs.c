#ifndef INC_cMD4
#define INC_cMD4

#define MD4_DIGEST_LENGTH 16

unsigned char *cMD4(unsigned char *message, unsigned long message_len, unsigned char *digest);

#endif