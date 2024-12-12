# Define the compiler and compiler flags
CC = gcc
CFLAGS = -Iinclude -Wall -Wextra -std=c89

# Detect conflicting flags and ensure only one is set
ifeq ($(arch), 32)
    CFLAGS += -m32
endif

ifeq ($(arch), 64)
    CFLAGS += -m64
endif

# Echo the current shell explicitly
$(info Current shell is: $(shell echo $$SHELL))

# Define RM, MV, and SEP command specific to platform
ifeq ($(OS),Windows_NT)
    SHARED_FILE = cMDA.dll
    INSTALL_DIR = $(shell echo %windir:~0,2%)/Byte-Ocelots
    ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
        RM = rm -f
        CP = cp
        MV = mv
        SEP = /
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
	SEP = /
	ifeq ($(shell uname), Darwin)
		# macOS-specific settings
		SHARED_FILE = cMDA.dylib
		INSTALL_DIR = /usr/local/Byte-Ocelots
	else
		# Linux or other Unix-based OS
		PREFIX ?= /usr/local
		LIN_BIN_DIR = $(PREFIX)/bin
		LIN_LIB_DIR = $(PREFIX)/lib
		LIN_INC_DIR = $(PREFIX)/include/cMDA
		SHARED_FILE = cMDA.so
	endif
endif



# Default target
all: static shared build tests
all-c: all clean-o clean-d

# Define directories
SRC_MD_DIR = src/md
SRC_RFC_DIR = src/rfc
TEST_DIR = tests
BIN_DIR = bin
LIB_DIR = lib

# Find all .c files in the src/md directory
SRC_MD_MD_FILES = $(wildcard $(SRC_MD_DIR)/md*.c)
MD_MD_OBJ_FILES = $(patsubst $(SRC_MD_DIR)/%.c, $(SRC_MD_DIR)/%.o, $(SRC_MD_MD_FILES))

SRC_MD_OTHER_FILES = $(filter-out $(SRC_MD_DIR)/md%.c, $(wildcard $(SRC_MD_DIR)/*.c))
MD_OTHER_OBJ_FILES = $(patsubst $(SRC_MD_DIR)/%.c, $(SRC_MD_DIR)/%.o, $(SRC_MD_OTHER_FILES))

MD_BIN_FILES = $(patsubst $(SRC_MD_DIR)/%.c,$(BIN_DIR)/%,$(SRC_MD_MD_FILES))

# Find all .c files in the src/rfc directory
SRC_RFC_FILES = $(wildcard $(SRC_RFC_DIR)/*.c)
RFC_OBJ_FILES = $(patsubst $(SRC_RFC_DIR)/%.c,$(SRC_RFC_DIR)/%.o,$(SRC_RFC_FILES))

# Find all .c files in the test directory
TEST_FILES = $(wildcard $(TEST_DIR)/*.c)
TEST_BIN_FILES = $(patsubst $(TEST_DIR)/%.c,$(TEST_DIR)/build/%,$(TEST_FILES))

# Define the static library
STATIC_LIB = $(LIB_DIR)/libcMDA.a
SHARED_LIB = $(LIB_DIR)/$(SHARED_FILE)

# DEP FILES
DEP_FILES = $(patsubst $(SRC_MD_DIR)/%.c, $(SRC_MD_DIR)/%.d, $(wildcard $(SRC_MD_DIR)/*.c)) $(patsubst $(SRC_RFC_DIR)/%.c, $(SRC_RFC_DIR)/%.d, $(SRC_RFC_FILES)) $(patsubst $(TEST_DIR)/%.c, $(TEST_DIR)/%.d, $(TEST_FILES))

# Include the generated dependency files
#-include $(DEP_FILES)

# Rule to generate .d files for src/md/*.c
$(SRC_MD_DIR)/%.d: $(SRC_MD_DIR)/%.c
	$(CC) $(CFLAGS) -MM -MP -MF $@ $<

# Rule to generate .d files for src/rfc/*.c
$(SRC_RFC_DIR)/%.d: $(SRC_RFC_DIR)/%.c
	$(CC) $(CFLAGS) -MM -MP -MF $@ $<

# Rule to generate .d files for tests/*.c
$(TEST_DIR)/%.d: $(TEST_DIR)/%.c
	$(CC) $(CFLAGS) -MM -MP -MF $@ $<


# --------------------------------- build rules ---------------------------------

# Build target for src/md files
build: static $(DEP_FILES) $(MD_BIN_FILES)
build-c: build clean-o clean-d

# Rule to compile each .c file into its corresponding .o object file
$(SRC_MD_DIR)/%.o: $(SRC_MD_DIR)/%.c $(STATIC_LIB) $(SRC_MD_DIR)/%.d
	$(CC) $(CFLAGS) -c -o $@ $< -lm

# Rule to compile each .c file in src/md into its corresponding binary
$(BIN_DIR)/%: $(SRC_MD_DIR)/%.o $(MD_OTHER_OBJ_FILES) | $(BIN_DIR)
	$(CC) $(CFLAGS) -L$(LIB_DIR) -o $@ $^ -lcMDA -lm


# --------------------------------- shared and static lib rules ---------------------------------

# Rule to compile each .c file in src/rfc into position-independent code (.o files)
$(SRC_RFC_DIR)/%.o: $(SRC_RFC_DIR)/%.c $(SRC_RFC_DIR)/%.d
	$(CC) $(CFLAGS) -fPIC -c -o $@ $< -lm

# Build target for static library
static: $(DEP_FILES) $(STATIC_LIB)
static-c: static clean-o clean-d

# Rule to create the static library from src/rfc files
$(STATIC_LIB): $(RFC_OBJ_FILES) | $(LIB_DIR)
	ar rcs $@ $(RFC_OBJ_FILES)

# Build target for shared library
shared: $(DEP_FILES) $(SHARED_LIB)
shared-c : shared clean-o clean-d

# Rule to create the shared library from src/rfc files
$(SHARED_LIB): $(RFC_OBJ_FILES) | $(LIB_DIR)
	$(CC) -shared -o $@ $(RFC_OBJ_FILES)


# --------------------------------- test file rules ---------------------------------

# Build target for test files
tests: static $(TEST_BIN_FILES)
tests-c : tests clean-o clean-d

# Rule to compile each .c file in test into its corresponding binary
$(TEST_DIR)/build/%: $(TEST_DIR)/%.c $(TEST_DIR)/%.d | $(TEST_DIR)/build
	$(CC) $(CFLAGS) -o $@ $< -L$(LIB_DIR) -lcMDA -lm


# --------------------------------- mkdir rules ---------------------------------

# Create the bin, lib, and test directories if they don't exist
$(BIN_DIR) $(LIB_DIR) $(TEST_DIR)/build:
ifeq ($(OS),Windows_NT)
ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
	mkdir -p $(BIN_DIR) $(LIB_DIR) $(TEST_DIR)/build
else
	if not exist "$(BIN_DIR)" mkdir "$(BIN_DIR)"
	if not exist "$(LIB_DIR)" mkdir "$(LIB_DIR)"
	if not exist "$(TEST_DIR)/build" mkdir "$(TEST_DIR)/build"
endif
else
	mkdir -p $(BIN_DIR) $(LIB_DIR) $(TEST_DIR)/build
endif


# --------------------------------- install rules ---------------------------------

_install-static: static
	@echo ""
	@echo "-------------------installing static------------------------"
ifeq ($(OS),Windows_NT)
ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
	mkdir -p $(INSTALL_DIR)
else
	if not exist "$(INSTALL_DIR)" mkdir "$(INSTALL_DIR)"
	
	$(CP) lib $(subst /,$(SEP),$(INSTALL_DIR)/lib)
endif
else
	mkdir -p $(LIN_LIB_DIR)
	install -m 644 lib/* $(LIN_LIB_DIR)
endif
	@echo ""
install-static: _install-static clean-static  clean-o clean-d


_install-shared: shared
	@echo ""
	@echo "-------------------installing shared------------------------"
ifeq ($(OS),Windows_NT)
ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
	mkdir -p $(INSTALL_DIR)
else
	if not exist "$(INSTALL_DIR)" mkdir "$(INSTALL_DIR)"
	
	$(CP) lib $(subst /,$(SEP),$(INSTALL_DIR)/lib)
endif
else
	mkdir -p $(LIN_LIB_DIR)
	install -m 644 lib/* $(LIN_LIB_DIR)
endif
	@echo ""
install-shared: _install-shared clean-shared  clean-o clean-d


install-headers:
	@echo ""
	@echo "-------------------installing headers------------------------"
ifeq ($(OS),Windows_NT)
ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
	mkdir -p $(INSTALL_DIR)
else
	if not exist "$(INSTALL_DIR)" mkdir "$(INSTALL_DIR)"
	
	$(CP) include $(subst /,$(SEP),$(INSTALL_DIR)/include)
endif
else
	mkdir -p $(LIN_INC_DIR)
	install -m 644 include/cMDA/* $(LIN_INC_DIR)
endif
	@echo ""


_install-bin: build
	@echo ""
	@echo "-------------------installing bin------------------------"
ifeq ($(OS),Windows_NT)
ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
	mkdir -p $(INSTALL_DIR)
else
	if not exist "$(INSTALL_DIR)" mkdir "$(INSTALL_DIR)"
	
	$(CP) bin $(subst /,$(SEP),$(INSTALL_DIR)/bin)
endif
else
	mkdir -p $(LIN_BIN_DIR)
	install -m 755 bin/* $(LIN_BIN_DIR)
endif
	@echo ""
install-bin: _install-bin clean-bin  clean-o clean-d


# Install the files
install: _install-static _install-shared install-headers _install-bin clean
	@echo ''
	@echo "Install complete."


# --------------------------------- uninstall rules ---------------------------------

uninstall:
	@echo ''
	@echo "-------------------uninstalling------------------------"
ifeq ($(OS),Windows_NT)
ifeq ($(findstring bash,$(shell echo $$SHELL)),bash)
# For bash on Windows (e.g., Git Bash)
	rm -f $(subst /,$(SEP),$(INSTALL_DIR)/bin/md*)
	rm -f $(subst /,\,$(INSTALL_DIR)/$(STATIC_LIB))
	rm -f $(subst /,\,$(INSTALL_DIR)/$(SHARED_LIB))
	rm -rf $(subst /,$(SEP),$(INSTALL_DIR)/include/cMDA)
else
# For cmd.exe on Windows
	if exist $(subst /,\,$(INSTALL_DIR)/bin/md*) del /q $(subst /,\,$(INSTALL_DIR)/bin/md*)
	@if exist $(subst /,\,$(INSTALL_DIR)/${STATIC_LIB}) del /q $(subst /,\,$(INSTALL_DIR)/$(STATIC_LIB))
	@if exist $(subst /,\,$(INSTALL_DIR)/${SHARED_LIB}) del /q $(subst /,\,$(INSTALL_DIR)/$(SHARED_LIB))
	if exist $(subst /,\,$(INSTALL_DIR)/include/cMDA) rmdir /s /q $(subst /,\,$(INSTALL_DIR)/include/cMDA)
endif
else
# Unix-based systems
	rm -f $(LIN_BIN_DIR)/*
	rm -f $(LIN_LIB_DIR)/libcMDA.a
	rm -f $(LIN_LIB_DIR)/$(SHARED_FILE)
	rm -rf $(LIN_INC_DIR)
endif
	@echo ''
	@echo "Uninstall complete."


# --------------------------------- clean rules ---------------------------------

# Clean target to remove compiled binaries and libraries
clean-bin:
	$(RM) $(subst /,$(SEP),$(BIN_DIR)/*)

clean-tests:
	$(RM) $(subst /,$(SEP),$(TEST_DIR)/build/*)

clean-o:
	$(RM) $(subst /,$(SEP),$(RFC_OBJ_FILES)) $(subst /,$(SEP),$(MD_MD_OBJ_FILES)) $(subst /,$(SEP),$(MD_OTHER_OBJ_FILES)) $(subst /,$(SEP),$(TEST_OBJ_FILES))

clean-d:
	$(RM) $(subst /,$(SEP),$(DEP_FILES))

clean-static:
	$(RM) $(subst /,$(SEP),$(STATIC_LIB))

clean-shared:
	$(RM) $(subst /,$(SEP),$(SHARED_LIB))

clean: clean-bin clean-tests clean-o clean-static clean-shared clean-d


.PHONY: all shared build static tests clean
.SECONDARY: $(MD_MD_OBJ_FILES) $(MD_OTHER_OBJ_FILES) $(RFC_OBJ_FILES) $(STATIC_LIB) $(SHARED_LIB)
.NOTPARALLEL: static shared
.WAIT: static
.IGNORE: clean
.LOW_RESOLUTION_TIME:
