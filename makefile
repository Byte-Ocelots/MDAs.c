# Define the compiler and compiler flags
CC = gcc
CFLAGS = -Iinclude -Wall -Wextra -ansi -pedantic -std=c89

# Echo the current shell explicitly
$(info Current shell is: $(shell echo $$SHELL))
$(info $(findstring bash,$(shell echo $$SHELL)))

# Define RM, MV and SEP command specific to platform
ifeq ($(OS),Windows_NT)
	SHARED_F = cMDA.dll
	INSTALL_DIR = $(shell echo %windir:~0,2%)\\Byte-Ocelots
	ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
		RM = rm -f
		CP = cp
		MV = mv
		SEP =/
	else
		RM = del /Q /F
		CP = xcopy /Y /E /I
		MV = move
		SEP = \\
	endif
else
	RM = rm -f
	CP = cp
	MV = mv
	SEP =/
	SHARED_F = cMDA.so
endif

# Define directories
SRC_MD_DIR = src/md
SRC_RFC_DIR = src/rfc
TEST_DIR = tests
BIN_DIR = bin
LIB_DIR = lib

# Find all .c files in the src/md directory
SRC_MD_FILES = $(wildcard $(SRC_MD_DIR)/md*.c)
MD_OBJ_FILES = $(patsubst $(SRC_MD_DIR)/%.c, $(SRC_MD_DIR)/%.o, $(SRC_MD_FILES))

OTHER_SRC_FILES = $(filter-out $(SRC_MD_DIR)/md%.c, $(wildcard $(SRC_MD_DIR)/*.c))
OTHER_OBJ_FILES = $(patsubst $(SRC_MD_DIR)/%.c, $(SRC_MD_DIR)/%.o, $(OTHER_SRC_FILES))

MD_BIN_FILES = $(patsubst $(SRC_MD_DIR)/%.c,$(BIN_DIR)/%,$(SRC_MD_FILES))

# Find all .c files in the src/rfc directory
SRC_RFC_FILES = $(wildcard $(SRC_RFC_DIR)/*.c)
RFC_OBJ_FILES = $(patsubst $(SRC_RFC_DIR)/%.c,$(SRC_RFC_DIR)/%.o,$(SRC_RFC_FILES))

# Find all .c files in the test directory
TEST_FILES = $(wildcard $(TEST_DIR)/*.c)
TEST_BIN_FILES = $(patsubst $(TEST_DIR)/%.c,$(TEST_DIR)/build/%,$(TEST_FILES))

# Define the static library
STATIC_LIB = $(LIB_DIR)/libcMDA.a
SHARED_LIB = $(LIB_DIR)/$(SHARED_F)

# Default target
all: _static _shared _build _test clean_o

# Build target for src/md files
_build: $(MD_BIN_FILES)
build: _build clean_o

# Rule to compile each .c file into its corresponding .o object file
$(SRC_MD_DIR)/%.o: $(SRC_MD_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

# Rule to compile each .c file in src/md into its corresponding binary
$(BIN_DIR)/%: $(SRC_MD_DIR)/%.o $(OTHER_OBJ_FILES) | $(BIN_DIR) $(STATIC_LIB)
	$(CC) $(CFLAGS) -L$(LIB_DIR) -o $@ $^ -lm -lcMDA

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
tests : _test clean_o

# Rule to compile each .c file in test into its corresponding binary
$(TEST_DIR)/build/%: $(TEST_DIR)/%.c |  $(TEST_DIR)/build $(STATIC_LIB)
	$(CC) $(CFLAGS) -o $@ $< -L$(LIB_DIR) -lcMDA -lm

# Create the bin directory if it doesn't exist
$(BIN_DIR):
ifeq ($(OS),Windows_NT)
ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
	mkdir -p $(BIN_DIR)
else
	if not exist "$(BIN_DIR)" mkdir "$(BIN_DIR)"
endif
else
	mkdir -p $(BIN_DIR)
endif

$(TEST_DIR)/build:
ifeq ($(OS),Windows_NT)
ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
		mkdir -p $(subst /,$(SEP),$(TEST_DIR)/build)
else
		if not exist "$(subst /,$(SEP),$(TEST_DIR)/build)" mkdir "$(subst /,$(SEP),$(TEST_DIR)/build)"
endif
else
	mkdir -p $(subst /,$(SEP),$(TEST_DIR)/build)
endif

# Create the lib directory if it doesn't exist
$(LIB_DIR):
ifeq ($(OS),Windows_NT)
ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
	mkdir -p $(LIB_DIR)
else
	if not exist "$(LIB_DIR)" mkdir "$(LIB_DIR)"
endif
else
	mkdir -p $(LIB_DIR)
endif

install: _static _shared _build clean_o
ifeq ($(OS),Windows_NT)
ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
	mkdir -p $(INSTALL_DIR)
else
	if not exist "$(INSTALL_DIR)" mkdir "$(INSTALL_DIR)"
endif
else
	mkdir -p $(INSTALL_DIR)
endif
	
	$(CP) lib $(subst /,$(SEP),$(INSTALL_DIR)/lib) 
	$(CP) include $(subst /,$(SEP),$(INSTALL_DIR)/include) 
	$(CP) bin $(subst /,$(SEP),$(INSTALL_DIR)/bin) 

# Clean target to remove compiled binaries and libraries
clean_bin:
	$(RM) $(subst /,$(SEP),$(BIN_DIR)/*)

clean_tests:
	$(RM) $(subst /,$(SEP),$(TEST_DIR)/build/*) 

clean_o:
	$(RM) $(subst /,$(SEP),$(RFC_OBJ_FILES))


clean: clean_bin clean_tests clean_o

.PHONY: all shared build static test clean clean_o
