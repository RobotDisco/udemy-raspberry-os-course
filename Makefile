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

# Use find to fine every C and assembler (.s) file
SRCS := $(shell find $(SRC_DIR) -name '*.c' -or -name '*.s')

# Define objects as the source files but with a .o extension
OBJS := $(patsubst $(SRC_DIR)/%,$(BUILD_DIR)/%.o,$(SRCS))

# Build a dependency file (makes handling header file updates easier)
DEPS := $(OBJS:.o=.d)

# Include the current directory as having .h files
INC_DIRS := $(shell find $(SRC_DIR) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# The -MMD and -MP flags together generate Makefiles for us!
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
# applies to .s files or .o files.
$(BUILD_DIR)/%.c.o: $(SRC_DIR)/%.c
	mkdir -p $(dir $@)	
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# How to turn .s files into .o files
$(BUILD_DIR)/%.s.o: $(SRC_DIR)/%.s
	mkdir -p $(dir $@)
	$(CC) -c $< -o $@

# clean is not a file, so don't look for one
.PHONY: clean run

clean:
	rm -r $(BUILD_DIR)

run: $(BUILD_DIR)/$(TARGET)
	qemu-system-aarch64 -M raspi3b -serial stdio -kernel $<

# Include the .d makefiles. The - at the front suppresses the errors of missing
# Makefiles. Initially, all the .d files will be missing, and we don't want those
# errors to show up.
-include $(DEPS)