;; kernel32.asm

	SELECTOR_KERNEL_CS		equ			8

	;; Import functions
	extern					CBEGIN

	;; Import global constants
	extern					gdt_ptr

	[SECTION .bss]
	StackSpace				resb		2 * 1024

StackTop:
	[SECTION .text]

	global_start

_start:
	mov						esp, StackTop

	sgdt					[gdt_ptr]
	call					CBEGIN
	lgdt					[gdt_ptr]

	jmp						SELECTOR_KERNEL_CS:CSINIT

CSINIT:
	push					0
	popfd														; Pop top of stack into EFLAGS
	hlt

