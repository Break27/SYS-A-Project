;; boot16.asm	Filesys Fat12

	org						07c00h						; load to 7c00

	jmp short LABEL_START								; boot
	nop

	%include				"F12HDR.inc"
	%include				"Loader.inc"

LABEL_START:
	mov 					ax, cs
	mov 					ds, ax
	mov 					es, ax
	mov						ss, ax
	mov						sp, BaseOfStack

	;; Clear screen
	mov						ax, 0600h					; AH=6, AL=0h
	mov						bx, 0700h					; Fore WHITE, Back BLACK
	mov						cx, 0
	mov						dx, 0184fh
	int						10h

	;;Disply
	mov						dh, 0
	call					DispStr

	xor						ah, ah
	xor						dl, dl
	int						13h

;; Find F12LOADER.BIN under the root directory of A-dirve
	mov						word 	[wSectorNo], SectorNoOfRootDirectory

LABEL_SrhRootDir_BEGIN:
	cmp						word 	[wRootDirSizForLoop], 0
	jz						LABEL_NORESULT				; unable to find
	dec						word 	[wRootDirSizForLoop]
	mov						ax, BaseOfLoader
	mov						es, ax
	mov 					bx, OffsetOfLoader
	mov						ax, [wSectorNo]
	mov 					cl, 1
	call					ReadSector

	mov 					si, LoaderFileName
	mov						di, OffsetOfLoader
	cld
	mov						dx, 10h

LABEL_SrhLoader:
	cmp						dx, 0
	jz						LABEL_NxtSecInRoot
	dec						dx
	mov						cx, 0

LABEL_CmpFlNm:
	cmp						cx, 0
	jz						LABEL_FOUND
	dec						cx
	lodsb
	cmp						al, byte [es:di]
	jz						LABEL_CONTIN
	jmp						LABEL_MISMATCH

LABEL_CONTIN:
	inc						di
	jmp						LABEL_CmpFlNm

LABEL_MISMATCH:
	and						di, 0FFE0h
	add						di, 20h
	mov						si, LoaderFileName
	jmp						LABEL_SrhLoader

LABEL_NxtSecInRoot:
	add						word	[wSectorNo], 1
	jmp						LABEL_SrhRootDir_BEGIN

LABEL_NORESULT:
	mov						dh, 2
	call 					DispStr
	jmp 					$							; loop

LABEL_FOUND:
	mov						ax, RootDirSectors
	and						di, 0FFE0h
	add						di, 01Ah
	mov						cx, word	[es:di]
	push					cx
	add						cx, ax
	add						cx, DeltaSectorNo
	mov						ax, BaseOfLoader
	mov						es, ax
	mov						bx, OffsetOfLoader
	mov						ax, cx

LABEL_LOADING:
	mov						cl, 1
	int						10h
	pop						bx
	pop						ax

	mov						cl, 1
	call					ReadSector
	pop						ax
	call					GetFATEntry
	cmp						ax, 0FFFh
	jz						LABEL_LOADED
	push					ax
	mov						dx, RootDirSectors
	add						ax, dx
	add						ax, DeltaSectorNo
	add						bx, [BPB_BytsPerSec]
	jmp						LABEL_LOADING

LABEL_LOADED:
	mov						dh, 1
	call					DispStr

	jmp						BaseOfLoader:OffsetOfLoader	; Load f12loader.bin

;; variables
	wRootDirSizForLoop		dw		RootDirSectors
	wSectorNo				dw		0
	bODD					db		0
	LoaderNm				db		"F12LOADER  BIN"	; Loader filename
	MsgLength				equ		55

;; strings
	BootMSG:				db 		"BOOT16: BOOTING ...    						        "
	MsgReady				db		"BOOT16: 'F12LOADER.BIN' FOUND.      				    "
	MsgNoLoader				db		"BOOT16: ERROR! 'F12LOADER.BIN' NOT FOUND, ABORTING.    "

DispStr:
	mov 					ax, MsgLength
	mul						dh
	add						ax, ds
	mov						bp, ax
	mov						ax, ds
	mov						es, ax
	mov						cx, MsgLength
	mov						ax, 01301h					; AH=13, AL=01h
	mov						bx, 0007h					; Fore WHITE, Back BLACK
	mov						dl, 0
	int						10h
	ret

ReadSector:
	push					bp
	mov						bp, sp
	sub						esp, 2

	mov						byte [bp-2], cl
	push					bx
	mov						bl, [BPB_SecPerTrk]
	div						bl
	inc						ah
	mov 					cl, ah
	mov						dh, al
	shr						al, 1
	mov						ch, al
	and						dh, 1
	pop						bx

	mov						dl, [BS_DrvNum]				; Drive number

GetFATEntry:
	push					es
	push					bx
	push					ax
	mov						ax, BaseOfLoader
	sub						ax, 0100h
	mov						es, ax
	pop						ax
	mov						bx, 3
	mul						bx
	mov						bx, 2
	div						bx
	cmp						dx, 0
	jz						LABEL_EVEN
	mov						byte 	[bODD], 1

LABEL_EVEN:
	xor						dx, dx
	mov						bx, [BPB_BytsPerSec]
	div						bx

	push					dx
	mov						bx, 0
	add						ax, SectorNoOfFAT1
	mov						cl, 2
	call					ReadSector

	pop						dx
	add						bx, dx
	mov						ax, [es:bx]
	cmp						byte	[bODD], 1
	jnz						LABEL_EVEN_2
	shr						ax, 4

LABEL_OK:
	pop						bx
	pop						es
	ret
.ContinReading:
	mov						ah, 2						; Read
	mov 					al, byte [bp-2]				; read sectors
	int						13h
	jc						.ContinReading

	add						esp, 2
	pop						bp
	ret

	;; end
	times 					510 - ($-$$) db 0			; Fill up empty space
	dw 						0xaa55
