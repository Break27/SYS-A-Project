;; Functions.inc

DisReturn:
	push					szReturn
	call					ScrOpt								; printf("\n");
	add	esp, 4

	ret

ScrOpt:
	push				ebp
	mov					ebp, esp
	push				ebx
	push				esi
	push				edi

	mov					esi, [ebp + 8]							; pszInfo
	mov					edi, [dwDisPos]
	mov					ah, 0Fh
.1:
	lodsb
	test				al, al
	jz					.2
	cmp					al, 0Ah									; Enter
	jnz					.3
	push				eax
	mov					eax, edi
	mov					bl, 160
	div					bl
	and					eax, 0FFh
	inc					eax
	mov					bl, 160
	mul					bl
	mov					edi, eax
	pop					eax
	jmp					.1
.3:
	mov					[gs:edi], ax
	add					edi, 2
	jmp					.1

.2:
	mov					[dwDisPos], edi

	pop					edi
	pop					esi
	pop					ebx
	pop					ebp
	ret

DisInt:
	mov					eax, [esp + 4]
	shr					eax, 24
	call				DisAL

	mov					eax, [esp + 4]
	shr					eax, 16
	call				DisAL

	mov					eax, [esp + 4]
	shr					eax, 8
	call				DisAL

	mov					eax, [esp + 4]
	call				DisAL

	mov					ah, 07h									; Fore GRAY, Back BLACK
	mov					al, 'h'
	push				edi
	mov					edi, [dwDisPos]
	mov					[gs:edi], ax
	add					edi, 4
	mov					[dwDisPos], edi
	pop					edi

	ret

DisAL:
	push				ecx
	push				edx
	push				edi

	mov					edi, [dwDisPos]

	mov					ah, 0Fh									; Fore WHITE, Back BLACK
	mov					dl, al
	shr					al, 4
	mov					ecx, 2
.begin:
	and					al, 01111b
	cmp					al, 9
	ja					.1
	add					al, '0'
	jmp					.2
.1:
	sub					al, 0Ah
	add					al, 'A'
.2:
	mov					[gs:edi], ax
	add					edi, 2

	mov					al, dl
	loop				.begin
	;add				edi, 2

	mov					[dwDisPos], edi

	pop					edi
	pop					edx
	pop					ecx

	ret
