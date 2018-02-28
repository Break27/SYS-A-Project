; mainfounc

[FORMAT "WCOFF"]		; mode
[BITS 32]			; 32-bit mode

; info

[FILE "halt.asm"]		; filename info
	GLOBAL	   _io_hlt	; function name
	
; functions
[SECTION .text]			

_io_hlt:	; void io_hlt(void)
	HLT
	RET

