# Define the compiler and compiler flags
CC = gcc
CFLAGS = -Iinclude -Wall -Wextra -ansi -pedantic -std=c89 

# Define RM, MV and SEP command specific to platform
ifeq ($(OS),Windows_NT)
	RM = del /Q /F
	MV = move
	SEP = \\
else
	RM = rm -f
	MV = mv
	SEP =/
endif

# Define directories
SRC_MD_DIR = src/md
SRC_RFC_DIR = src/rfc
TEST_DIR = tests
BIN_DIR = bin
LIB_DIR = lib

# Find all .c files in the src/md directory
SRC_MD_FILES = $(wildcard $(SRC_MD_DIR)/*.c)
MD_BIN_FILES = $(patsubst $(SRC_MD_DIR)/%.c,$(BIN_DIR)/%,$(SRC_MD_FILES))

# Find all .c files in the src/rfc directory
SRC_RFC_FILES = $(wildcard $(SRC_RFC_DIR)/*.c)
RFC_OBJ_FILES = $(patsubst $(SRC_RFC_DIR)/%.c,$(SRC_RFC_DIR)/%.o,$(SRC_RFC_FILES))

# Find all .c files in the test directory
TEST_FILES = $(wildcard $(TEST_DIR)/*.c)
TEST_BIN_FILES = $(patsubst $(TEST_DIR)/%.c,$(BIN_DIR)/%,$(TEST_FILES))

# Define the static library
STATIC_LIB = $(LIB_DIR)/libcMDA.a

# Define the shared library
ifeq ($(OS),Windows_NT)
	SHARED_LIB = $(LIB_DIR)/cMDA.dll
else
	SHARED_LIB = $(LIB_DIR)/cMDA.so
endif

# Default target
all: _static _shared _build _test clean_o

# Build target for src/md files
_build: $(MD_BIN_FILES)
build: _build clean_o

# Rule to compile each .c file in src/md into its corresponding binary
$(BIN_DIR)/%: $(SRC_MD_DIR)/%.c | $(BIN_DIR) $(STATIC_LIB)
	$(CC) $(CFLAGS) -L$(LIB_DIR) -o $@ $< -lm -lcMDA

# Build target for static library
_static: $(STATIC_LIB)
static: _static clean_o

# Rule to create the static library from src/rfc files
$(STATIC_LIB): $(RFC_OBJ_FILES) | $(LIB_DIR)
	ar rcs $@ $(RFC_OBJ_FILES)

# Build target for shared library
_shared: $(SHARED_LIB)
shared : _shared clean_o

# Rule to create the shared library from src/rfc files
$(SHARED_LIB): $(RFC_OBJ_FILES) | $(LIB_DIR)
	$(CC) -shared -o $@ $(RFC_OBJ_FILES)

# Rule to compile each .c file in src/rfc into position-independent code (.o files)
$(SRC_RFC_DIR)/%.o: $(SRC_RFC_DIR)/%.c
	$(CC) $(CFLAGS) -fPIC -c -o $@ $<

# Build target for test files
_test: $(TEST_BIN_FILES)
test : _test clean_o

# Rule to compile each .c file in test into its corresponding binary
$(BIN_DIR)/%: $(TEST_DIR)/%.c | $(BIN_DIR) $(STATIC_LIB)
	$(CC) $(CFLAGS) -o $@ $< -L$(LIB_DIR) -lcMDA -lm

# Create the bin directory if it doesn't exist
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Create the lib directory if it doesn't exist
$(LIB_DIR):
	mkdir -p $(LIB_DIR)

# Clean target to remove compiled binaries and libraries
clean:
	$(RM) $(subst /,$(SEP),$(BIN_DIR)/* $(LIB_DIR)/* $(SRC_RFC_DIR)/*.o)

clean_bin:
	$(RM) $(subst /,$(SEP),$(BIN_DIR)/*)

clean_o:
	$(RM) $(subst /,$(SEP),$(RFC_OBJ_FILES))

.PHONY: all shared build static test clean clean_o
