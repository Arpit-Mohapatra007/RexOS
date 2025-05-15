[BITS 16] 
[ORG 0x7C00]
KERNEL_LOCATION equ 0x1000

DISK: 

	db 0 
; Set up segments and stack 
mov [DISK], dl ; Save boot drive number
xor ax, ax 
mov es, ax 
mov ds, ax 
mov bp, 0x8000
mov sp,bp 

; Read kernel from disk 
mov bx, KERNEL_LOCATION 
mov dh, 20

; Destination buffer 
mov ah, 0x02 ; BIOS read sector function 
mov al, dh ; Number of sectors to read (20 * 512 = 10KB) 
mov ch, 0x00 ; Cylinder 0 
mov cl, 0x02 ; Sector 2 (after boot sector) 
mov dh, 0x00 ; Head 0 
mov dl, [DISK] ; Drive number 
int 0x13 ; BIOS disk interrupt

jc disk_error ; If carry flag set, handle error

; Set video mode (80x25 text) 
mov ah, 0x00 
mov al, 0x03 
int 0x10

; Set up GDT 
cli 
lgdt [GDT_descriptor]

; Enable protected mode 
mov eax, cr0 
or eax, 1 
mov cr0, eax

; Jump to 32-bit protected mode 
jmp CODE_SEG:ProtectedMode

; Disk read error handler 
disk_error: 
	mov si, error_msg 

print_loop: 
	lodsb 
	cmp al, 0 
	je halt 

mov ah, 0x0E 
int 0x10 
jmp print_loop 

halt: 
	cli 
	hlt

error_msg: db "Disk read error!", 0

; GDT definitions 

GDT_Start: 
	Null_descriptor:
 		dq 0x0000000000000000 
	code_descriptor: 
		dw 0xFFFF ; Limit (low) 
		dw 0x0000 ; Base (low) 
		db 0x00 ; Base (middle) 
		db 10011010b ; Access (present, ring 0, code, executable, readable) 
		db 11001111b ; Granularity (4KB pages, 32-bit mode) + Limit (high) 
		db 0x00 ; Base (high) 

	data_descriptor: 
		dw 0xFFFF ; Limit (low) 
		dw 0x0000 ; Base (low) 
		db 0x00 ; Base (middle) 
		db 10010010b ; Access (present, ring 0, data, writable) 
		db 11001111b ; Granularity (4KB pages, 32-bit mode) + Limit (high) 
		db 0x00 ; Base (high) 

GDT_End:
GDT_descriptor: 
	dw GDT_End - GDT_Start - 1 ; GDT size 
	dd GDT_Start ; GDT base address

; Segment selectors 
CODE_SEG equ code_descriptor - GDT_Start 
DATA_SEG equ data_descriptor - GDT_Start

; 32-bit protected mode 
[BITS 32] 

ProtectedMode: 
; Set up segment registers 
	mov ax, DATA_SEG 
	mov ds, ax 
	mov es, ax 
	mov fs, ax 
	mov gs, ax 
	mov ss, ax
	mov ebp, 0x90000
	mov esp, ebp ; Stack at 0x90000

; Jump to kernel
jmp KERNEL_LOCATION

; Boot sector padding and signature 
times 510 - ($ - $$) db 0 
dw 0xAA55