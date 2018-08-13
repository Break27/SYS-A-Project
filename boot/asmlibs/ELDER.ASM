	;; ELDER.ASM

	[SECTION .data]

	dispos					dd			0

	[SECTION .text]

	global StrOpt

	global MemCpy

StrOpt:
	push					ebp
	mov						ebp, esp

	mov						esi, [ebp + 8]
	mov						edi, [dispos]
	mov						ah, 0Fh
.1:
	lodsb
	test					al, al
	jz						.2
	cmp						al, 0Ah						; Enter check
	jnz						.3
	push					eax
	mov						eax, edi
	mov						bl, 160
	div						bl
	and						eax, 0FFh
	inc						eax
	mov						bl, 160
	mul						bl
	mov						edi, eax
	pop						eax
	jmp						.1
.3:
	mov						[gs:edi], ax
	add						edi, 2
	jmp						.1
.2:
	mov						[dispos], edi

	pop						ebp
	ret

memcpy:
	push					ebp
	mov						ebp, esp

	push					esi
	push					edi
	push					ecx

	mov						edi, [ebp + 8]
	mov						esi, [ebp + 12]
	mov						ecx, [ebp + 16]
.1:
	cmp						ecx, 0
	jz						.2

	mov						al, [ds:esi]
	inc						esi

	mov						byte [es:edi], al
	inc						edi

	dec						ecx
	jmp						.1
.2:
	mov						eax, [ebp + 8]

	pop						ecx
	pop						edi
	pop						esi
	mov						esp, ebp
	pop						ebp

	ret
