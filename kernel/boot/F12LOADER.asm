;; F12loader.asm

	org						0100h

	jmp						LABEL_START

	%include				"F12HDR.inc"
	%include				"Loader.inc"

	;GDT                    SBA					LMT    		PRO
LABEL_GDT:					Descriptor 0,       0,     		0
LABEL_DFLAT_C:				Descriptor 0,   	0fffffh, 	DA_CR | DA_32 | DA_LIMIT_4K		; 0-4GB
LABEL_DFLAT_RW:				Descriptor 0,   	0fffffh,	DA_DRW | DA_32 | DA_LIMIT_4K	; 0-4GB
LABEL_DVIDEO:				Descriptor 0B8000h, 0ffffh,		DA_DRW | DA_DPL3

	GdtLen					equ		$-LABEL_GDT
	GdtPtr					dw		GdtLen - 1
							dd		BaseOfLoaderPhyAddr + LABEL_GDT

	SelectorFlatC			equ		LABEL_DFLAT_C - LABEL_GDT
	SelectorFlatRW			equ		LABEL_DLAT_RW - LABEL_GDT
	SelectorFlatVd			equ		LABEL_DVIDEO - LABEL_GDT + SA_RPL3

	PageDirBase				equ		100000h
	PageTblBase				equ		101000h

LABLE_START:
	mov						ax, cs
	mov						ds, ax
	mov						es, ax
	mov						ss, ax
	mov						sp, BaseOfStack

	mov						dh, 0
	call					DispStr

	;; Get memory size
	mov						ebx, 0
	mov						di, _MemChkBuff
.MemChkLp:
	mov						eax, 0E820h
	mov						ecx, 20
	mov						edx, 0534D4150h
	int						15h
	jc						.MemChkFail
	add						di, 20
	inc						dword	[_dwMCRNum]
	cmp						cbx, 0
	jne						.MemChkLp
	jmp						.MemChkOK
.MemChkFail:
	mov						dword	[_dwMCRNum], 0
.MemChkOK:
	mov						word 	[wSectorNo], SectorNoOfRootDirectory
	xor						ah, ah
	xor						dl, dl
	int						13h

LABEL_SrhRootDir_BEGIN:
	cmp						word 	[wRootDirSizForLoop], 0
	jz						LABEL_NORESULT
	dec						word	[wRootDirSizForLoop]
	mov						ax, BaseOfKernelFile
	mov						es, ax
	mov						bx, OffsetOfKernelFile
	mov						ax, [wSectorNo]
	mov						cl, 1
	call					ReadSector

	mov						si, KernelNm
	mov						di, OffsetOfKernelFile
	cld
	mov						dx, 10h

LABEL_SrhKernel:
	cmp						dx, 0
	jz						LABEL_NxtSecInRoot
	dec						dx
	mov						cx, 11

LABEL_CmpName:
	cmp						cx, 0
	jz						LABEL_FOUND
	deccx
	lodsb
	cmp						al, byte	[es:di]
	jz						LABEL_CONTIN
	jmp						LABEL_MISMATCH

LABEL_CONTIN:
	inc						di
	jmp						LABEL_CmpFlNm

LABEL_MISMATCH:
	and						di, 0FFE0h
	and						di, 20h
	mov						si, KernelNm
	jmp						LABEL_SrhKernel

LABEL_NxtSecInRoot:
	add						word	[wSectorNo], 1
	jmp						LABEL_SrhRootDir_BEGIN

LABEL_NORESULT:
	mov						dh, 2
	call					DispStr
	jmp						$

LABEL_FOUND:
	mov						ax, RootDirSectors
	and						di, 0FFF0h

	push					eax
	mov						eax, [es:di + 01Ch]
	mov						dword 	[dwKernelSize], eax
	pop						eax

	add						di, 01Ah
	mov						cx, word [es:di]
	push					cx
	add						cx, DeltaSectorNo
	mov						ax, BaseOfKernelFile
	mov						es, ax
	mov						bx, OffsetOfKernelFile
	mov						ax, cx

LABEL_LOADING:
	mov						cl, 1
	call					ReadSector
	pop						ax
	call					GetFATEntry
	cmp						ax, 0FFFh
	jz						LABEL_FILE_LOADED
	push					ax
	mov						dx, RootDirSector
	add						ax, dx
	add						ax, DeltaSectorNo
	add						bx, [BPB_BytsPerSec]
	jmp						LABEL_LOADING

LABEL_LOADED:
	call					DRV_LIGHTS_OUT

	mov						dh, 1
	call					DispStr

	;; Get into the Protection-mode
	lgdt					[GdtPtr]

	; close interrupt
	cli

	in						al, 92h
	or						al, 00000010b
	out						92h, al

	; get ready
	mov						eax, cr0
	or						eax, 1
	mov						cr0, eax

	jmp						dword	SelectorFlatC:(BaseOfLoaderPhyAddr + LABEL_PM_START)

;; variables
	wRootDirSizForLoop		dw		RootDirSectors
	wSectorNo				dw		0
	KernelNm				db		"KERNEL32  BIN"	; Loader filename
	MsgLength				equ		55

;; strings
	LoadMSG:				db 		"LOADER: LOADING 'KERNEL32.BIN' ...    				    "
	MsgReady				db		"Ready.      									        "
	MsgNoLoader				db		"LOADER: ERROR! 'KERNEL32.BIN' NOT FOUND, ABORTING.     "

DispStr:
	mov 					ax, MsgLength
	mul						dh
	add						ax, LoadMSG
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

	mov						byte 	[bp-2], cl
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

DRV_LIGHTS_OUT:
	push					dx
	mov						dx, 03F2h
	mov						al, 0
	out						dx, al
	pop						dx
	ret

	;; Protection mode
	[SECTION .s32]

	ALIGN 32

	[BITS 32]

	%include				"Functions.inc"

LABEL_PM_START:
	mov						ax, SelectorVideo
	mov						gs, ax

	mov						ax, SelectorFlatRW
	mov						ds, ax
	mov						es, ax
	mov						fs, ax
	mov						esp, TopOfStack

	push					szMemChkTitle
	call					ScrOpt
	add						esp, 4

	call					DisMemInfo
	call					SetupPagin

	mov						ah, 0Fh					; Fore WHITE, Back BLACK
	mov						al, 'P'
	mov						[gs:((80 * 0 + 39) * 2)], ax
	call					InitKernel

	jmp						SelectorFlatC:KernelEntryPointPhyAddr

	;; Stack definitions
	StackSpace				times	1024 db 0
	TopOfStack				equ		BaseOfLoaderPhyAddr + $

DisMemInfo:
	push					esi
	push					edi
	push					ecx

	mov						esi, MemChkBuf
	mov						ecx, [dw_MCRNum]
.loop:
	mov						edx, 5
	mov						edi, ARDStruct
.1:
	push					dword	[esi]
	call					DisInt
	pop						eax
	stosd
	add						esi, 4
	dec						edx
	cmp						edx, 0
	jnz						.1
	call					DisReturn
	cmp						dword	[dwType], 1
	jne						.2
	mov						eax, [dwBaseAddrLow]
	add						eax, [dwLengthLow]
	cmp						eax, [dwMemSize]
	jb 						.2
	mov						[dwMemSize], eax
.2:
	loop					.loop

	call					DisReturn
	push					RAMSz
	call					ScrOpt
	add						esp, 4

	push					dword	[dwMemSize]
	call					DisInt
	add						esp, 4

	pop						ecx
	pop						edi
	pop						esi
	ret

SetupPagin:
	xor						edx, edx
	mov						eax, [dw_MemSize]
	mov						ebx, 400000h			; 400000h = 4MB
	div						ebx
	mov						ecx, eax
	test					edx, edx
	jz						.no_remainder
	inc						ecx
.no_remainder:
	push					ecx

	mov						ax, SelectorFlatRW
	mov						es, ax
	mov						edi, PageTblBase | PG_P | PG_USU | PG_RWW
.1:
	stosd
	add						eax, 4096
	loop					.1

	;; Reinitializing page table
	pop						eax
	mov						ebx, 1024
	mul						ecx, eax
	mov						edi, PageTblBase
	xor						eax, eax
	mov						eax, PG_P | PG_USU | PG_RWW
.2:
	stosd
	add						eax, 4096
	loop					.2

	mov						eax, PageDirBase
	mov						cr3, eax
	mov						eax, 80000000h
	mov						cr0, eax
	jmp short				.3
.3:
	nop
	ret

InitKernel:
	xor						esi, esi
	mov						cx, word [BaseOfKernelFilePhyAddr + 2Ch]
	movzx					ecx, cx
	mov						esi, [BaseOfKernelFilePhyAddr + 1Ch]
	add						esi, BaseOfKernelFilePhyAddr
.Begin:
	mov						eax, [esi + 0]
	cmp						eax, 0
	jz						.NoAction
	push					dword	[esi + 010h]
	mov						eax, [esi + 04h]
	add						eax, BaseOfKernelFilePhyAddr
	push					eax
	push					dword	[esi + 08h]
	call					MemCpy
	add						esp, 12
.NoAction:
	add						esi, 020h
	dec						ecx
	jnz						.Begin
	ret

	[SECTION .data1]

	ALIGN 32

LABEL_DATA:
	;;Strings
	_szMemChkTitle:			db		"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0
	_RAMSz:					db		"RAM Size: ", 0
	_szReturn:				db		0Ah, 0

	;;Variables
	_dwMCRNum:				dd		0					; Memory check
	_dwDisPos				dd		(80 * 60 + 0) * 2	; Line 6, Column 0
	_dwMemSize				dd		0
	_ARDStruct:											; Address Range Descriptor
	_dwBaseAddrLow:			dd		0
	_dwBaseAddrHigh:		dd		0
	_dwLengthLow:			dd		0
	_dwLengthHigh:			dd		0
	_dwType:				dd		0
	_MemChkBuf				times	256		db		0

	;; these are used under the Protection-mode
	szMemChkTitle			equ		BaseOfLoaderPhyAddr + _szMemChkTitle
	RAMSz					equ		BaseOfLoaderPhyAddr + _RAMSz
	szReturn				equ		BaseOfLoaderPhyAddr + _szReturn
	dwDisPos				equ		BaseOfLoaderPhyAddr + _dwDisPos
	dwMemSize				equ		BaseOfLoaderPhyAddr + _dwMemSize
	dwMCRNum				equ		BaseOfLoaderPhyAddr + _dwMCRNum
	ARDStruct				equ		BaseOfLoaderPhyAddr + _ARDStruct
	dwBaseAddrLow			equ		BaseOfLoaderPhyAddr + _dwBaseAddrLow
	dwBaseAddrHigh			equ		BaseOfLoaderPhyAddr + _dwBaseAddrHigh
	dwLengthLow				equ		BaseOfLoaderPhyAddr + _dwLengthLow
	dwLengthHigh			equ		BaseOfLoaderPhyAddr + _dwLengthHigh
	dwType					equ		BaseOfLoaderPhyAddr + _dwType
	MemChkBuf				equ		BaseOfLoaderPhyAddr + _MemChkBuf

