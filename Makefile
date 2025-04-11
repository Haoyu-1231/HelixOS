# 编辑前，请先配置好 MINGW-W64 和 QEMU

TOOLPATH = tools/

MAKE     = $(TOOLPATH)make.exe -r
NASM     = $(TOOLPATH)nasm.exe
GCC      = gcc.exe -m32 -nostdinc -nostdlib -fno-builtin -ffreestanding -fno-stack-protector -Qn -fno-pic -fno-pie -fno-asynchronous-unwind-tables -mpreferred-stack-boundary=2 -fomit-frame-pointer -O0 -finput-charset=UTF-8 -w -c
OBJ2BIM  = $(TOOLPATH)obj2bim.exe
BIM2HRB  = $(TOOLPATH)bim2hrb.exe
RULEFILE = $(TOOLPATH)helixos.rul
EDIMG    = $(TOOLPATH)edimg.exe
QEMU     = qemu-system-x86_64.exe
COPY     = copy
DEL      = del

# 默认动作

default :
	$(MAKE) img

# 文件生成规则

ipl.bin : ipl.asm Makefile
	$(NASM) ipl.asm -o ipl.bin

boot.bin : boot.asm Makefile
	$(NASM) boot.asm -o boot.bin

bootpack.obj : bootpack.c Makefile
	$(GCC) bootpack.c -o bootpack.obj

nasmfunc.obj : nasmfunc.asm Makefile
	$(NASM) -f win32 nasmfunc.asm -o nasmfunc.obj

bootpack.bim : bootpack.obj nasmfunc.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map \
		bootpack.obj nasmfunc.obj
# 3MB+64KB=3136KB

bootpack.hrb : bootpack.bim Makefile
	$(BIM2HRB) bootpack.bim bootpack.hrb 0

helixos.sys : boot.bin bootpack.hrb Makefile
	copy /B boot.bin+bootpack.hrb helixos.sys

helixos.img : ipl.bin helixos.sys Makefile
	$(EDIMG)   imgin:$(TOOLPATH)fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 \
		copy from:helixos.sys to:@: \
		imgout:helixos.img

# 命令

img :
	$(MAKE) helixos.img

run :
	$(MAKE) img
	$(QEMU) -L pc-bios -no-reboot -m 512 -display sdl -fda helixos.img

clean :
	-$(DEL) *.bin
	-$(DEL) *.obj
	-$(DEL) bootpack.map
	-$(DEL) bootpack.bim
	-$(DEL) bootpack.hrb
	-$(DEL) helixos.sys

src_only :
	$(MAKE) clean
	-$(DEL) helixos.img
