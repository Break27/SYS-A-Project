# KERNEL SUB MAKEFILE | LOCATION: kernel/Makefile

# PATHS
vpath %.H include/

.PHONY : sub

# RULE
sub : KERNEL32.BIN

# C COMPLIE
BEGIN.O : CBEGIN.C
	gcc -I include/ -c -fno-builtin $< -o $@ 

# KERNEL BUILDING
KERNEL32.O : kernel32.asm
	nasm -f elf $< -o $@

KERNEL32.BIN : KERNEL32.O BEGIN.O ../boot/ELDER.O 
	ld -s -Ttext $(ETYPOINT) -o $@ KERNEL.O BEGIN.O ELDER.O