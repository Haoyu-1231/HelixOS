# �༭ǰ���������ú� QEMU

MAKE     = make.exe -r
NASM     = nasm.exe
EDIMG    = edimg.exe
QEMU     = qemu-system-x86_64.exe
COPY     = copy
DEL      = del

# Ĭ�϶���

default :
	$(MAKE) img

# �ļ����ɹ���

ipl.bin : ipl.asm Makefile
	$(NASM) ipl.asm -o ipl.bin

HelixOS.sys : HelixOS.asm Makefile
	$(NASM) HelixOS.asm -o HelixOS.sys

HelixOS.img : ipl.bin HelixOS.sys Makefile
	$(EDIMG)   imgin:fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 \
		copy from:HelixOS.sys to:@: \
		imgout:HelixOS.img

# ����

img :
	$(MAKE) HelixOS.img

run :
	$(MAKE) img
	$(QEMU) -L pc-bios -no-reboot -m 512 -display sdl -fda HelixOS.img

clean :
	-$(DEL) ipl.bin
	-$(DEL) HelixOS.sys

src_only :
	$(MAKE) clean
	-$(DEL) HelixOS.img
