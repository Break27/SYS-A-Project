

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

IMGEN = boot/BOOT16.BIN boot/F12LOADER.BIN boot/KERNEL32.BIN $(IMGNAME)
MAKALL = $(IMGEN) clean

# THE VALUE MUST BE THE SAME AS 'KernelEntryPointPhyAddr'
ETYPOINT = 0x30400

# IT DEPENDS ON 'ETYPOINT'
ETYOFFST = 0x400

.PHONY : imgen all clean
# RULES
imgen :	$(IMGEN)

all : $(MAKALL)

clean : 
	rm *.O

# ASSEMBLY COMPLIE
boot/BOOT16.BIN : boot16.asm Loader.inc F12HDR.inc
	nasm -I $(ASMINC) $< -o $@
	
boot/F12LOADER.BIN : F12LOADER.asm Loader.inc F12HDR.inc
	nasm -I $(ASMINC) $< -o $@

boot/OLDFUNC.O : OLDFUNC.ASM
	nasm -I $(ASMINC) -f elf $< -o $@

boot/KERNEL32.O : kernel32.asm
	nasm -f elf $< -o $@
	
# C COMPLIE
boot/BEGIN.O : CBEGIN.C
	gcc -I boot/include/ -c -fno-builtin $< -o $@ 

# KERNEL BUILDING
boot/KERNEL32.BIN : boot/KERNEL32.O boot/BEGIN.O boot/OLDFUNC.O 
	ld -s -Ttext $(ETYPOINT) -o $@ KERNEL.O BEGIN.O OLDFUNC.O

# IMG FILE GENERATEING
$(IMGNAME) : boot/BOOT16.BIN boot/F12LOADER.BIN
	dd if=boot/BOOT16.BIN of=$(IMGNAME) bs=512 count=1 conv=notrunc
	mount -o loop $(IMGNAME) $(FMPOINT)
	cp -fv boot/F12LOADER.BIN $(FMPOINT)/boot/
	cp -fv boot/KERNEL32.BIN $(FMPOINT)/boot/
	unmount $(FMPOINT)
		