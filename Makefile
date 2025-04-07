# ?æ”z’uD QEMU

# àÒ??ì

default :
	make.exe img

# •¶Œ¶¬??

ipl.bin : ipl.asm Makefile
	nasm.exe ipl.asm -o ipl.bin

HelixOS.img : ipl.bin Makefile
	edimg.exe   imgin:fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0   imgout:HelixOS.img

# –½—ß

asm :
	make.exe -r ipl.bin

img :
	make.exe -r HelixOS.img

run :
	make.exe img
	qemu-system-x86_64.exe -L pc-bios -no-reboot -m 512 -display sdl -fda HelixOS.img

clean :
	-del ipl.bin

src_only :
	make.exe clean
	-del HelixOS.img
