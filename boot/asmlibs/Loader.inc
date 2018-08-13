;; Loader.inc

	BaseOfLoader					equ		09000h
	OffsetOfLoader					equ		0100h
	BaseOfLoaderPhyAddr				equ		BaseOfLoader * 10h

	BaseOfKernelFile				equ		08000h
	OffsetOfKernelFile				equ		0h

	KernelEntryPointPhyAddr			equ		030400h
	BaseOfKernelFilePhyAddr				equ		BaseOfKernelFile * 10h
