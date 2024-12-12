#include "common.h"
#include "cMDA/md4.h"
#include "funcs.h"

void _a4(unsigned *a, unsigned b, unsigned c, unsigned d, unsigned char k, unsigned char s, unsigned (*OP)(unsigned, unsigned, unsigned), unsigned *X, unsigned z)
{
	(*a) = ROTL(((*a) + OP(b, c, d) + X[k] + z), s);
}

unsigned char *cMD4(unsigned char *message, unsigned long message_len, unsigned char *digest)
{
	unsigned long i;
	unsigned ABCD[4];
	unsigned char j;

	unsigned char *M = NULL;
	unsigned A = 0x67452301, B = 0xefcdab89, C = 0x98badcfe, D = 0x10325476; /* Step 3. Initialize MD Buffer */
	unsigned AA, BB, CC, DD;
	unsigned X[16];
	unsigned zs[3] = {0x0,
					  0x5A827999,
					  0x6ED9EBA1};
	unsigned long b = message_len * 8;
	unsigned long shy_bits = b % 512;
	unsigned long remaining_bits;
	unsigned long N;

	/* Step 1. Append Padding Bits */
	if (shy_bits < 448)
	{
		remaining_bits = 448 - shy_bits;
	}
	else if (shy_bits >= 448)
	{
		remaining_bits = 512 - shy_bits + 448;
	}

	N = (b + remaining_bits + 64) / 8;
	M = (unsigned char *)malloc(N);
	memset(M, 0, N);
	memcpy(M, message, message_len);
	memset(M + message_len, 0, remaining_bits / 8);
	M[message_len] = 1 << 7;

	/* Step 2. Append Length */
	for (i = 0; i < 8; i++)
	{
		M[N - 8 + i] = (unsigned char)(b >> i * 8) & 0xFF;
	}

	/* Step 4. Process Message in 16-Word Blocks */
	for (i = 0; i <= N / 64 - 1; i++)
	{
		for (j = 0; j <= 15; j++)
		{
			X[j] = (unsigned)M[i * 64 + j * 4] |
				   ((unsigned)M[i * 64 + j * 4 + 1] << 8) |
				   ((unsigned)M[i * 64 + j * 4 + 2] << 16) |
				   ((unsigned)M[i * 64 + j * 4 + 3] << 24);
		}

		AA = A;
		BB = B;
		CC = C;
		DD = D;

		/* Round 1 */
		_a4(&A, B, C, D, 0, 3, F, X, 0);
		_a4(&D, A, B, C, 1, 7, F, X, 0);
		_a4(&C, D, A, B, 2, 11, F, X, 0);
		_a4(&B, C, D, A, 3, 19, F, X, 0);

		_a4(&A, B, C, D, 4, 3, F, X, 0);
		_a4(&D, A, B, C, 5, 7, F, X, 0);
		_a4(&C, D, A, B, 6, 11, F, X, 0);
		_a4(&B, C, D, A, 7, 19, F, X, 0);

		_a4(&A, B, C, D, 8, 3, F, X, 0);
		_a4(&D, A, B, C, 9, 7, F, X, 0);
		_a4(&C, D, A, B, 10, 11, F, X, 0);
		_a4(&B, C, D, A, 11, 19, F, X, 0);

		_a4(&A, B, C, D, 12, 3, F, X, 0);
		_a4(&D, A, B, C, 13, 7, F, X, 0);
		_a4(&C, D, A, B, 14, 11, F, X, 0);
		_a4(&B, C, D, A, 15, 19, F, X, 0);

		/* Round 2 */
		_a4(&A, B, C, D, 0, 3, G4, X, zs[1]);
		_a4(&D, A, B, C, 4, 5, G4, X, zs[1]);
		_a4(&C, D, A, B, 8, 9, G4, X, zs[1]);
		_a4(&B, C, D, A, 12, 13, G4, X, zs[1]);

		_a4(&A, B, C, D, 1, 3, G4, X, zs[1]);
		_a4(&D, A, B, C, 5, 5, G4, X, zs[1]);
		_a4(&C, D, A, B, 9, 9, G4, X, zs[1]);
		_a4(&B, C, D, A, 13, 13, G4, X, zs[1]);

		_a4(&A, B, C, D, 2, 3, G4, X, zs[1]);
		_a4(&D, A, B, C, 6, 5, G4, X, zs[1]);
		_a4(&C, D, A, B, 10, 9, G4, X, zs[1]);
		_a4(&B, C, D, A, 14, 13, G4, X, zs[1]);

		_a4(&A, B, C, D, 3, 3, G4, X, zs[1]);
		_a4(&D, A, B, C, 7, 5, G4, X, zs[1]);
		_a4(&C, D, A, B, 11, 9, G4, X, zs[1]);
		_a4(&B, C, D, A, 15, 13, G4, X, zs[1]);

		/* Round 3 */
		_a4(&A, B, C, D, 0, 3, H, X, zs[2]);
		_a4(&D, A, B, C, 8, 9, H, X, zs[2]);
		_a4(&C, D, A, B, 4, 11, H, X, zs[2]);
		_a4(&B, C, D, A, 12, 15, H, X, zs[2]);

		_a4(&A, B, C, D, 2, 3, H, X, zs[2]);
		_a4(&D, A, B, C, 10, 9, H, X, zs[2]);
		_a4(&C, D, A, B, 6, 11, H, X, zs[2]);
		_a4(&B, C, D, A, 14, 15, H, X, zs[2]);

		_a4(&A, B, C, D, 1, 3, H, X, zs[2]);
		_a4(&D, A, B, C, 9, 9, H, X, zs[2]);
		_a4(&C, D, A, B, 5, 11, H, X, zs[2]);
		_a4(&B, C, D, A, 13, 15, H, X, zs[2]);

		_a4(&A, B, C, D, 3, 3, H, X, zs[2]);
		_a4(&D, A, B, C, 11, 9, H, X, zs[2]);
		_a4(&C, D, A, B, 7, 11, H, X, zs[2]);
		_a4(&B, C, D, A, 15, 15, H, X, zs[2]);

		A += AA;
		B += BB;
		C += CC;
		D += DD;
	}
	free(M);

	ABCD[0] = A;
	ABCD[1] = B;
	ABCD[2] = C;
	ABCD[3] = D;

	for (i = 0; i < 4; ++i)
	{
		digest[i * 4] = (unsigned char)(ABCD[i] & 0xFF);
		digest[i * 4 + 1] = (unsigned char)((ABCD[i] >> 8) & 0xFF);
		digest[i * 4 + 2] = (unsigned char)((ABCD[i] >> 16) & 0xFF);
		digest[i * 4 + 3] = (unsigned char)((ABCD[i] >> 24) & 0xFF);
	}

	return digest;
}