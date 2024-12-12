#include "utils.h"

/* Function to print a byte array in the selected format */
void printHash(unsigned char *data, unsigned char data_len, const char *format)
{
	static const char base64_table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	char base64_output[25]; /* Enough for 16 bytes of MD2 digest */
	int j, bits, buffer;
	unsigned char i;

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
void computeAndPrintMD2(unsigned char *message,unsigned long message_len, const char *format, const char *holder, unsigned char *(*cMD)(unsigned char *,unsigned long, unsigned char *))
{
	unsigned char md_digest[MD_DIGEST_LENGTH]; /* MD_DIGEST_LENGTH */
	cMD(message, message_len, md_digest);

	printf("%s -> ", holder);
	printHash(md_digest, MD_DIGEST_LENGTH, format);
	printf("\n");
}

/* Function to process a file line by line */
void processFile(const char *filename, const char *format, unsigned char *(*cMD)(unsigned char *,unsigned long, unsigned char *))
{
	FILE *file;
	unsigned char buffer[1024];
	size_t bytes_read;
	/* MD2 requires the entire message at once to compute the hash */
	/* Use a dynamic array to collect all the bytes */
	size_t total_size = 0;
	size_t capacity = 1024; /* Initial capacity */
	unsigned char *file_data = malloc(capacity);
	unsigned char *new_data;

	file = fopen(filename, "rb"); /* Open the file in binary mode */
	if (!file)
	{
		fprintf(stderr, "Error: Could not open file '%s'.\n", filename);
		return;
	}

	if (!file_data)
	{
		fprintf(stderr, "Error: Memory allocation failed.\n");
		fclose(file);
		return;
	}

	while ((bytes_read = fread(buffer, 1, sizeof(buffer), file)) > 0)
	{
		/* Expand the array if needed */
		if (total_size + bytes_read > capacity)
		{
			capacity += total_size + bytes_read + 1;
			new_data = (unsigned char *)realloc(file_data, capacity);
			if (!new_data)
			{
				fprintf(stderr, "Error: Memory reallocation failed.\n");
				free(file_data);
				fclose(file);
				return;
			}
			file_data = new_data;
		}
		/* Append the read bytes to the array */
		memcpy(file_data + total_size, buffer, bytes_read);
		total_size += bytes_read;
	}

	fclose(file);

	/* Compute and Print the hash */
	computeAndPrintMD2(file_data, total_size, format, filename, cMD);

	/* Free allocated memory */
	free(file_data);
}


int man(int argc, char **argv, unsigned char *(*cMD)(unsigned char *,unsigned long, unsigned char *))
{
	const char *format = "lower";
	int i;
	int expect_file = 0;

	if (argc < 2)
	{
		printf("Usage: %s [options] <message>\n", argv[0]);
		printf("Options:\n");
		printf("  --help, -h        Show this help message.\n");
		printf("  --file, -f FILE   Specify file message (multiple files allowed).\n");
		printf("  --format FORMAT   Specify output format: lower, upper, base64 (default: lower).\n");
		return 0;
	}

	for (i = 1; i < argc; i++)
	{
		if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0)
		{
			printf("Usage: %s [options] <message>\n", argv[0]);
			printf("Options:\n");
			printf("  --help, -h        Show this help message.\n");
			printf("  --file, -f FILE   Specify file message (multiple files allowed).\n");
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
			processFile(argv[i], format, cMD);
			expect_file = 0;
		}
		else if (argv[i][0] == '-')
		{
			fprintf(stderr, "Warning: Unrecognized option '%s'. Ignoring.\n", argv[i]);
		}
		else
		{
			computeAndPrintMD2((unsigned char *)argv[i], strlen(argv[i]), format, argv[i], cMD);
		}
	}

	if (expect_file)
	{
		fprintf(stderr, "Error: --file option provided without a file path.\n");
		return 1;
	}

	return 0;
}
