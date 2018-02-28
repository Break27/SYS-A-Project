; SYS/A

CYLS	EQU	0x0ff0		; bootsector
LEDS	EQU	0x0ff1
VMODE	EQU	0x0ff2		; color
SCRNX	EQU	0x0ff4		; screen x
SCRNY	EQU	0x0ff6		; screen y
VRAM	EQU	0x0ff8		; vram begin
	
	ORG	0xc200
	MOV	AL,0x13		; vga 8-bit colors 320x200
	MOV	AH,0x00
	INT	0x10
	MOV	BYTE [VMODE],8	; screen recording mode
	MOV	WORD [SCRNX],320
	MOV 	WORD [SCRNY],200
	MOV	DWORD [VRAM],0x000a0000

; Getting LED status from BIOS
	MOV	AH,0x02
	INT	0x16
	MOV	[LEDS],AL

fin:
	HLT
	JMP	fin
