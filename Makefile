# https://makefiletutorial.com/ is an ok tutorial

# Explicitly use aarch64 gcc in implicit rules
CC := aarch64-unknown-linux-gnu-gcc
LD := aarch64-unknown-linux-gnu-ld

# clean is not a file, so don't look for one
.PHONY: clean

# An explicit rule for each file. This means running make without any
# arguments will first run kernel8.img -- our final output -- which will
# cascade to generate all of its dependencies if necessary.

# Special (properly called "automatic") variables:
# $@ - name of rule target
# $< - first prerequisite
# $^ - all prerequisites

OBJECTS :=  boot.o debug.o main.o lib.o uart.o print.o
LINK_SCRIPT := link_script.lds

# Convert our linked ELF binary into a raw one (termed "binary")
kernel8.img: kernel
	aarch64-unknown-linux-gnu-objcopy -O binary $^ $@

# Link our object files without including the C standard library functions.
kernel: $(LINK_SCRIPT) $(OBJECTS)
	$(LD) -nostdlib -T $< -o $@ $(OBJECTS)

# -ffreestanding: Don't assume standard library exists, or main() is the
# program starting point.
# -std=c99: This program conforms to the C99 language standard
# -mgeneral-regs-only: Only use general registers, not floating point or SIMD
# registers.
main.o: main.c
	$(CC) -std=c99 -ffreestanding -mgeneral-regs-only -c $^ -o $@
debug.o: debug.c
	$(CC) -std=c99 -ffreestanding -mgeneral-regs-only -c $^ -o $@
print.o: print.c
	$(CC) -std=c99 -ffreestanding -mgeneral-regs-only -c $^ -o $@
uart.o: uart.c
	$(CC) -std=c99 -ffreestanding -mgeneral-regs-only -c $^ -o $@

boot.o: boot.s
	$(CC) -c $^ -o $@

lib.o: lib.s
	$(CC) -c $^ -o $@

clean:
	rm kernel8.img kernel $(OBJECTS)

run:
	qemu-system-aarch64 -M raspi3b -serial stdio -kernel kernel8.img