# https://makefiletutorial.com/ is an ok tutorial

# Explicitly use aarch64 gcc in implicit rules
CC := aarch64-unknown-linux-gnu-gcc
LD := aarch64-unknown-linux-gnu-ld

# Define some directories
BUILD_DIR := build
SRC_DIR := src

# -ffreestanding: Don't assume standard library exists, or main() is the
# program starting point.
# -std=c99: This program conforms to the C99 language standard
# -mgeneral-regs-only: Only use general registers, not floating point or SIMD
# registers.
CFLAGS := -std=c99 -ffreestanding -mgeneral-regs-only

# Here's the ultimate deliverable of our project
TARGET := kernel8.img

# Use find to find every C and assembler (.s) file
SRCS := $(shell find $(SRC_DIR) -name '*.c' -or -name '*.s')

# Define objects as the source files but with a .o extension
# Also replace src/ with build/
# % is text to preserve in the substition pattern.
OBJS := $(patsubst $(SRC_DIR)/%,$(BUILD_DIR)/%.o,$(SRCS))

# Build a dependency file (makes handling header file updates easier)
# This is a shortform for $(patsubst %.o,%.d,$(OBJS))
DEPS := $(OBJS:.o=.d)

# Include $(SRC_DIR) and all subdirectories as having .h files
INC_DIRS := $(shell find $(SRC_DIR) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# The -MMD and -MP flags together generate Makefiles for us for header files!
# These files will have .d instead of .o as the output.
CPPFLAGS := $(INC_FLAGS) -MMD -MP

## Explicit make rules

# Special (properly called "automatic") variables to remember:
# $@ - name of rule target
# $< - first prerequisite
# $^ - all prerequisites

# Being the first target, running make without any
# arguments will first run kernel8.img -- our final output -- which will
# cascade to generate all of its dependencies if necessary.

# Convert our linked ELF binary into a raw one (termed "binary")
$(BUILD_DIR)/$(TARGET): $(BUILD_DIR)/kernel
	aarch64-unknown-linux-gnu-objcopy -O binary $^ $@
# Append filesystem to the end of the kernel binary
	dd if=lib/os.img >> $@

# Link our object files without including the C standard library functions.
$(BUILD_DIR)/kernel: $(SRC_DIR)/link_script.lds $(OBJS)
	$(LD) -nostdlib -T $< -o $@ $(OBJS)

# Define patterns that will be implicit rules for our various source
# and derived files

# We need .c.o and .s.o extensions because we need to have disambiguity
# in our rules, we can't have make just figure out that a .o rule only
# applies to .s files or .c files.
$(BUILD_DIR)/%.c.o: $(SRC_DIR)/%.c
# Create build/ if it doesn't exist already
	mkdir -p $(dir $@)	
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# How to turn .s files into .o files
$(BUILD_DIR)/%.s.o: $(SRC_DIR)/%.s
# Create build/ if it doesn't exist already
	mkdir -p $(dir $@)
	$(CC) -c $< -o $@

# Don't look for files with the name of these targets, just run them.
# This prevents cases where a equally named file will prevent the tasks
# from running because make thinks the file is unchanged and thus the
# target doesn't need to be run.
.PHONY: clean run

clean:
	rm -r $(BUILD_DIR)

run: $(BUILD_DIR)/$(TARGET)
	qemu-system-aarch64 -M raspi3b -serial stdio -kernel $<

# Include the .d makefiles. The - at the front suppresses the errors of missing
# Makefiles. Initially, all the .d files will be missing, and we don't want those
# errors to show up.
-include $(DEPS)