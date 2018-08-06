;; F12HDR.inc

	;; constants
	BS_OEMNAME 				db 		'BREAK027'
	BPB_BytsPerSec 			dw 		512					; bytes per sector
	BPB_SecPerClus 			db 		1					; sector per clust
	BPB_RsvdSecCnt 			dw 		1					; boot record occupying
	BPB_RootEntCnt 			dw 		224
	BPB_TotSec16 			dw 		2880				; the number of logical sectors
	BPB_Media 				db 		0xF0
	BPB_FATSz16 			dw 		9					; the number of every fat-sectors
	BPB_SecPerTrk 			dw 		18					; sector per track
	BPB_NumHeads 			dw 		2
	BPB_HiddSec 			dd 		0
	BPB_TotSec32 			dd 		0
	BS_DrvNum 				db 		0
	BS_Reserved1			db		0					; unused
	BS_BootSig				db		29h
	BS_VolID				dd 		0
	BS_VolLab				db		'DEFLABEL012'
	BS_FileSysType			db		'FAT12'

	;;variables
	FATSz					equ		9
	RootDirSectors 			equ		14
	SectorNoOfRootDirectory equ		19
	SectorNoOfFAT1			equ 	1
	DeltaSectorNo			equ		17
