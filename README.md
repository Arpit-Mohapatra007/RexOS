RexOS - A Simple Operating System (lol)

Welcome to RexOS, a basic operating system project designed to help you learn how an OS works.

But to be honest I am also a dumbo newbie learned all this from different source and still need to develop a lot of things I request you if you are a smart cyber chad please help me lear other things.
Honestly I need Helllllllllllllllllllllllp!!!!!!!!!!!!!!!!!!! Sir

This project includes a bootloader, a simple kernel, and some assembly code to get the OS running on real hardware or an emulator like QEMU. Below, you’ll find an explanation of each file and what it does, plus instructions to build and run the OS.
Project Overview
RexOS is a tiny operating system that:

Boots from a disk using a bootloader.
Switches the CPU to 32-bit protected mode.
Loads a small kernel into memory.
Displays "Welcome to RexOS" on the screen in green text.

This is a starting point for learning OS development. It runs in 16-bit real mode (for the bootloader) and 32-bit protected mode (for the kernel).
Files and Their Significance
Here’s a breakdown of each file in the project and why it’s important:

boot.asm

What it does: This is the bootloader, the first piece of code that runs when your computer starts. It’s written in 16-bit assembly because the CPU starts in real mode (an old, limited mode).
Key tasks:
Saves the boot drive number.
Sets up a stack for temporary memory.
Reads the kernel from the disk (sectors 2–21) into memory at address 0x1000.
Switches the CPU to 32-bit protected mode using a Global Descriptor Table (GDT).
Jumps to the kernel code.


Why it’s important: Without the bootloader, the computer wouldn’t know how to load your OS. It’s like the “starter” for your OS engine.


kernel.cpp

What it does: This is the kernel, the core of your OS. It’s written in C++ and contains a simple main function.
Key tasks:
Writes the text "Welcome to RexOS" to the VGA text buffer (memory at 0xB8000), which displays text on the screen.
Colors the text green (using the attribute 0x34).


Why it’s important: The kernel is the heart of your OS. Right now, it just shows a message, but later you can add features like a command line or memory management.


kernel_entry.asm

What it does: This is a small assembly file that acts as a bridge between the bootloader and the kernel.
Key tasks:
Calls the main function in kernel.cpp.
Enters an infinite loop (jmp $) to prevent the CPU from running random code after the kernel finishes.


Why it’s important: The bootloader can’t directly call C++ code, so this file connects the assembly world (bootloader) to the C++ world (kernel).


padding.asm

What it does: Adds 40,960 bytes of zeros to the final binary file.
Why it’s important: The bootloader expects the kernel to be a certain size and aligned on the disk. This padding ensures the disk image has enough space and the kernel is placed correctly.



How to Build and Run RexOS
Prerequisites

NASM: To assemble .asm files (e.g., boot.asm, kernel_entry.asm).
GCC: To compile kernel.cpp (use a cross-compiler for OS development, like i686-elf-gcc).
QEMU: To emulate the OS without real hardware.
Make: (Optional) To automate the build process.
Linux/macOS/Windows with WSL: These instructions assume a Unix-like environment.

Install these tools:
# On Ubuntu
sudo apt update
sudo apt install nasm gcc make qemu-system-x86

For the cross-compiler, follow this guide to set up i686-elf-gcc.

Build Steps

Assemble the bootloader:
nasm -f bin boot.asm -o boot.bin

This creates a 512-byte binary file (boot.bin) for the boot sector.

Assemble the kernel entry:
nasm -f elf32 kernel_entry.asm -o kernel_entry.o

This creates an object file in ELF format for linking with the kernel.

Compile the kernel:
i386-elf-gcc -ffreestanding -c kernel.cpp -o kernel.o

The -ffreestanding flag tells the compiler there’s no standard library (OSes don’t use one).

Link the kernel:
i386-elf-ld -Ttext 0x1000 kernel_entry.o kernel.o -o kernel.elf

This links the kernel to load at address 0x1000 (matching KERNEL_LOCATION in boot.asm).

Convert the kernel to binary:
i386-elf-objcopy -O binary kernel.elf kernel.bin


Assemble the padding:
nasm -f bin padding.asm -o padding.bin


Combine all parts:
cat boot.bin kernel.bin padding.bin > rexos.bin

This creates the final disk image (rexos.bin).


Run in QEMU
qemu-system-i386 -fda rexos.bin

This emulates a PC booting from a floppy disk image. You should see "Welcome to RexOS" in green text.
Troubleshooting

"Disk read error!": The bootloader couldn’t read the kernel. Check that rexos.bin is correctly formed and QEMU is using the right disk image.
Blank screen: The kernel might not be loading at 0x1000. Verify the linker command (-Ttext 0x1000).
QEMU crashes: Ensure you’re using qemu-system-i386 and the disk image isn’t corrupted.

Next Steps
To make RexOS a full-fledged OS, I want to add:

Keyboard input: Let users type commands.
Shell: Create a command-line interface.
Memory management: Allocate memory for programs.
File system: Store and read files.
Interrupts: Handle hardware events like key presses.

 Sources: OSDev Wiki, Youtube, Book: Writig A Simple Operating System from Scratch By Mr. Nick Blundell

Happy coding, and enjoy building your OS!
