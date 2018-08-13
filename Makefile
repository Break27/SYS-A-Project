# MAIN MAKEFILE

# VARIABLES
BASENAME = null
KERNEL_VERSION = 0
IMGNAME = $(BASENAME)-$(KERNEL_VERSION).img
FMPOINT = /mnt/floppy/

MAKEFILES = .BLDLoader .BLDKernel
IMGEN = $(MAKEFILES) $(IMGNAME)
MAKALL = $(IMGEN) clean

# THE VALUE MUST BE THE SAME AS 'KernelEntryPointPhyAddr'
ETYPOINT = 0x30400
# IT DEPENDS ON 'ETYPOINT'
ETYOFFST = 0x400

# GLOBAL CONSTANTS
export ETYPOINT ETYOFFSET

.PHONY : imgen all clean .BLDLoader .BLDKernel

# Sub-Makefiles
.BLDLoader : 
	make sub -C boot/
	
.BLDKernel :
	make sub -C kernel/

# RULES
imgen :	$(IMGEN)

all : $(MAKALL)

clean : 
	rm *.O

# IMG FILE GENERATEING
$(IMGNAME) : boot/BOOT16.BIN boot/F12LOADER.BIN
	dd if=boot/BOOT16.BIN of=$(IMGNAME) bs=512 count=1 conv=notrunc
	mount -o loop $(IMGNAME) $(FMPOINT)
	cp -fv boot/F12LOADER.BIN $(FMPOINT)/boot/
	cp -fv kernel/KERNEL32.BIN $(FMPOINT)/boot/
	unmount $(FMPOINT)
		