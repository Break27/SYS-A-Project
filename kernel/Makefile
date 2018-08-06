

# PATHS
vpath %.h boot/include/
vpath %.inc boot/asmlibs/
vpath %.asm boot/
vpath %.C boot/
vpath %.ASM asmlibs/
vpath %.H include/

# VARIABLES
BASENAME = null
KERNEL_VERSION = 0
IMGNAME = $(BASENAME)-$(KERNEL_VERSION).img
FMPOINT = /mnt/floppy/
ASMINC = boot/asmlibs/

# THE VALUE MUST BE THE SAME AS 'KernelEntryPointPhyAddr'
ETYPOINT = 0x30400

# IT DEPENDS ON 'ETYPONT'
ETYOFFST = 0x400

# ASSEMBLE COMPLIE
BOOT16.BIN : boot16.asm Loader.inc F12HDR.inc
	nasm -I $(ASMINC) $< -o $@

F12LOADER.BIN : F12LOADER.asm Loader.inc F12HDR.inc
	nasm -I $(ASMINC) $< -o $@

OLDFUNC.O : OLDFUNC.ASM
	nasm -I $(ASMINC) -f elf $< -o $@

KERNEL32.O : kernel32.asm
	nasm -f elf $< -o $@
	
# C COMPLIE
BEGIN.O : CBEGIN.C
	gcc -I boot/include/ -c -fno-builtin $< -o $@ 

# KERNEL BUILDING
KERNEL32.BIN : KERNEL.O BEGIN.O OLDFUNC.O 
	ld -s -Ttext $(ETYPOINT) -o $@ KERNEL.O BEGIN.O OLDFUNC.O

# IMG FILE GENERATEING
$(IMGNAME) : BOOT16.BIN F12LOADER.BIN
	dd if=BOOT16.BIN of=$(IMGNAME) bs=512 count=1 conv=notrunc
	mount -o loop $(IMGNAME) $(FMPOINT)
	cp -fv F12LOADER.BIN $(FMPOINT)/boot/
	cp -fv KERNEL32.BIN $(FMPOINT)/boot/
	unmount $(FMPOINT)

# CLEAN
.PHONY : clean
clean : 
	rm *.O
		