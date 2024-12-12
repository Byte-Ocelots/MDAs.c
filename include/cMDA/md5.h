#ifndef INC_cMD5
#define INC_cMD5

#define MD5_DIGEST_LENGTH 16

unsigned char *cMD5(unsigned char *message, unsigned long message_len, unsigned char *digest);

#endif