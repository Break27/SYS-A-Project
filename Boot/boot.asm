    ;; 跳转到0000:7c00处，将控制权交给引导代码。
    org 07c00h                  ; load 07c00h
    mov ax, cs                  
    mov ds, ax                  
    mov es, ax                  
    call  DispStr               
    jmp $                       

DispStr:
    mov ax, BootMessage         
    mov bp, ax                  
    mov cx, 16                  
    mov ax, 01301h              
    mov bx, 000ch               ; red, highlight
    mov dl, 0                   ; dh=lines dl=column
    int 10h                     ; displaying text
    ret
BootMessage:    db "Hello, OS world!"

    times 510-($-$$) db 0           ; fill
    dw 0xaa55                       ; END

