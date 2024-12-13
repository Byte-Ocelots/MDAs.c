# cMDA

## Overview

`cMDA` is a versatile cryptographic library for hashing operations. It supports MD2, MD4, and MD5 standards. The library includes:

- A collection of headers for seamless integration into your applications.
- Command-line utilities for hashing messages and files.

## Installation

### **Source Code**

Users can clone the source code and build the library and binaries using `make`.

#### **Windows**

- By default, the library will be installed in `C:\Byte-Ocelots`.
- To specify a custom installation directory, use:
  ```sh
  make install INSTALL_DIR="path\to\install"
  ```

#### **Linux**

- By default, the library will be installed in `/usr/local`.
- To specify a custom installation directory, use:
  ```sh
  make install PREFIX="path/to/install"
  ```

## Usage

### **Headers**

Include the desired header files in your application:

- To include all supported MD versions:
  ```c
  #include <cMDA/all.h>
  ```
- To include specific versions, use:
  ```c
  #include <cMDA/md2.h>   // For MD2
  #include <cMDA/md4.h>   // For MD4
  #include <cMDA/md5.h>   // For MD5
  ```

### **Functions**

Following are the available functions:
```c
uint8_t *cMD2(uint8_t *message, uint64_t message_len, uint8_t *digest);   // For MD2
uint8_t *cMD4(uint8_t *message, uint64_t message_len, uint8_t *digest);   // For MD4
uint8_t *cMD5(uint8_t *message, uint64_t message_len, uint8_t *digest);   // For MD5
```

*example:*
```c
#include "cMDA/all.h"   // all cMDA functions
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(void) {
    char * message = "your message";
    uint8_t md2_digest[MD2_DIGEST_LENGTH];
    uint8_t md4_digest[MD4_DIGEST_LENGTH];
    uint8_t md5_digest[MD5_DIGEST_LENGTH];

    cMD2((uint8_t *)message, strlen(message), md2_digest);
    cMD4((uint8_t *)message, strlen(message), md4_digest);
    cMD5((uint8_t *)message, strlen(message), md5_digest);

    return 0;
}
```

### **Compiling with cMDA**

When compiling your application, link against the `cMDA` library using the `-lcMDA` flag:

```sh
gcc your_program.c -lcMDA -o your_program
```

### **Binaries**

The library includes terminal-based binaries for hashing operations:

- **Usage:**
  ```sh
  md[version] "your message"
  ```
  Example for MD5:
  ```sh
  md5 "This is a test message"
  ```
- To hash files, use the `-f` option:
  ```sh
  md5 -f "path/to/file"
  ```
- Multiple files and messages can be passed simultaneously.

## Building

### Default Build

Run the following to build both the libraries and binaries:

```bash
make all
```

### Build Only Binaries

To build just the binaries:

```bash
make build
```

### Specifying a Compiler

Pass a specific compiler using:

```bash
make CC="your-compiler"
```

### Linux Architecture

Specify the architecture for Linux builds:

* Default: Uses the compiler’s default architecture.
* To specify:
    ```bash
    make arch=32
    ```
    ```bash
    make arch=64
    ```

### Windows Architecture

Windows builds rely on the architecture supported by the provided compiler, as multilib is not supported.

## License

This library is open source and available under the terms of the [MIT License](./LICENSE).
