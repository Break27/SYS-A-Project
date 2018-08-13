# F12LOADER SUB MAKEFILE | LOCATION: boot/Makefile

# PATHS
vpath %.inc asmlibs/
vpath %.ASM asmlibs/

.PHONY : sub

# RULE
sub : BOOT16.BIN F12LOADER.BIN

# ASSEMBLY COMPLIE
BOOT16.BIN : boot16.asm Loader.inc F12HDR.inc
	nasm -I asmlibs/ $< -o $@
	
F12LOADER.BIN : F12LOADER.asm Loader.inc F12HDR.inc Base.inc
	nasm -I asmlibs/ $< -o $@

ELDER.O : ELDER.ASM
	nasm -I asmlibs/ -f elf $< -o $@

