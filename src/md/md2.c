#include "cMDA/md2.h"
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

/* Function to print a byte array in the selected format */
void printHash(uint8_t *data, uint8_t data_len, const char *format)
{
	static const char base64_table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	char base64_output[25]; /* Enough for 16 bytes of MD2 digest */
	int j, bits, buffer;
	uint8_t i;

	if (strcmp(format, "upper") == 0)
	{
		for (i = 0; i < data_len; i++)
		{
			printf("%02X", data[i]);
		}
	}
	else if (strcmp(format, "base64") == 0)
	{
		memset(base64_output, 0, sizeof(base64_output));
		j = 0;
		bits = 0;
		buffer = 0;
		for (i = 0; i < data_len; i++)
		{
			buffer = (buffer << 8) | data[i];
			bits += 8;
			while (bits >= 6)
			{
				base64_output[j++] = base64_table[(buffer >> (bits - 6)) & 0x3F];
				bits -= 6;
			}
		}
		if (bits > 0)
		{
			base64_output[j++] = base64_table[(buffer << (6 - bits)) & 0x3F];
		}
		while (j % 4 != 0)
		{
			base64_output[j++] = '=';
		}
		printf("%s", base64_output);
	}
	else
	{
		/* Default to lowercase hexadecimal */
		for (i = 0; i < data_len; i++)
		{
			printf("%02x", data[i]);
		}
	}
}

/* Function to compute and print the MD2 hash for a given string */
void computeAndPrintMD2(const char *input, const char *format)
{
	uint8_t md2_digest[16]; /* MD2_DIGEST_LENGTH */
	cMD2((uint8_t *)input, strlen(input), md2_digest);

	printf("%s -> ", input);
	printHash(md2_digest, 16, format);
	printf("\n");
}

/* Function to process a file line by line */
void processFile(const char *filename, const char *format)
{
	FILE *file;
	char buffer[1024];
	size_t len;

	file = fopen(filename, "r");
	if (!file)
	{
		fprintf(stderr, "Error: Could not open file '%s'.\n", filename);
		return;
	}

	while (fgets(buffer, sizeof(buffer), file))
	{
		/* Remove trailing newline character */
		len = strlen(buffer);
		if (len > 0 && buffer[len - 1] == '\n')
		{
			buffer[len - 1] = '\0';
		}
		computeAndPrintMD2(buffer, format);
	}
	fclose(file);
}

/* Main function */
int main(int argc, char **argv)
{
	const char *format = "lower";
	int i;
	int expect_file = 0;

	if (argc < 2)
	{
		printf("Usage: %s [options] <input>\n", argv[0]);
		printf("Options:\n");
		printf("  --help, -h        Show this help message.\n");
		printf("  --file, -f FILE   Specify file input (multiple files allowed).\n");
		printf("  --format FORMAT   Specify output format: lower, upper, base64 (default: lower).\n");
		return 0;
	}

	for (i = 1; i < argc; i++)
	{
		if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0)
		{
			printf("Usage: %s [options] <input>\n", argv[0]);
			printf("Options:\n");
			printf("  --help, -h        Show this help message.\n");
			printf("  --file, -f FILE   Specify file input (multiple files allowed).\n");
			printf("  --format FORMAT   Specify output format: lower, upper, base64 (default: lower).\n");
			return 0;
		}
		else if (strcmp(argv[i], "--format") == 0)
		{
			if (i + 1 < argc)
			{
				format = argv[++i];
				if (strcmp(format, "lower") != 0 && strcmp(format, "upper") != 0 && strcmp(format, "base64") != 0)
				{
					fprintf(stderr, "Warning: Invalid format '%s'. Defaulting to 'lower'.\n", format);
					format = "lower";
				}
			}
			else
			{
				fprintf(stderr, "Error: --format requires an argument.\n");
				return 1;
			}
		}
		else if (strcmp(argv[i], "--file") == 0 || strcmp(argv[i], "-f") == 0)
		{
			expect_file = 1;
		}
		else if (expect_file)
		{
			processFile(argv[i], format);
			expect_file = 0;
		}
		else if (argv[i][0] == '-')
		{
			fprintf(stderr, "Warning: Unrecognized option '%s'. Ignoring.\n", argv[i]);
		}
		else
		{
			computeAndPrintMD2(argv[i], format);
		}
	}

	if (expect_file)
	{
		fprintf(stderr, "Error: --file option provided without a file path.\n");
		return 1;
	}

	return 0;
}
