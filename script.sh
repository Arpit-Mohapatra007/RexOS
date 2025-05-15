#!/bin/bash

# Assemble bootloader
nasm -f bin "boot/boot.asm" -o "boot/boot.bin"

# Assemble kernel entry 
nasm -f elf "kernel/kernel_entry.asm" -o "kernel/kernel_entry.o"

# Assemble padding
nasm -f bin "misc/padding.asm" -o "misc/padding.bin"

# Compile kernel
i386-elf-gcc -ffreestanding -m32 -g -c "kernel/kernel.cpp" -o "kernel/kernel.o"

# Link kernel
i386-elf-ld -o "kernel/kernel.bin" -Ttext 0x1000 "kernel/kernel_entry.o" "kernel/kernel.o" --oformat binary

# Create disk image
cat "boot/boot.bin" "kernel/kernel.bin" "misc/padding.bin" > "OS.bin"

# Run in QEMU
qemu-system-x86_64 -m 128 -drive file="OS.bin",format=raw,index=0,if=floppy