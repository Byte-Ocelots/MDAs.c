#include "cMDA/utils.h"
#include <stdlib.h>
#include <stdio.h>

char *cMDA_toHexString(uint8_t *digest, char *output)
{
	uint8_t i;

	if (output == NULL)
	{
		output = (char *)malloc(32);
	}

	for (i = 0; i < 16; i++)
	{
		sprintf(&output[i * 2], "%02X", digest[i]);
	}
	output[32] = '\0'; /* Null-terminate the string */

	return output;
}