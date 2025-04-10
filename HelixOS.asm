; HelixOS 1.0 Build 04 (Classic 1)
; 主文件 (汇编)
; 编写：浩宇_1231
; 日期：2025.4.8

BOTPAK	EQU		0x00280000		; bootpack的加载位置
DSKCAC	EQU		0x00100000		; 磁盘缓存的位置
DSKCAC0	EQU		0x00008000		; 磁盘缓存的位置（真实模式）

; 有关BOOT_INFO
CYLS	EQU		0x0ff0			; 设定启动区
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; 有关颜色数目的信息。颜色的位数。
SCRNX	EQU		0x0ff4			; 分辨率的X（screen x）
SCRNY	EQU		0x0ff6			; 分辨率的Y（screen y）
VRAM	EQU		0x0ff8			; 图像缓冲区的开始地址

		ORG		0xc200			; 这个程序将要被装载到哪个地方呢？

        MOV     AL,0x13         ; VGA 显卡，320x200x8位彩色
        MOV     AH,0x00
        INT     0x10
        MOV		BYTE [VMODE],8	; 记录画面模式
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

; 用BIOS取得键盘上各种LED指示灯的状态

		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL

        MOV		SI,msg

putloop:
		MOV		AL,[SI]
		ADD		SI,1			; 给SI加1
		CMP		AL,0
		JE		entry
		MOV		AH,0x0e			; 显示一个文字
		MOV		BX,15			; 指定字符颜色
		INT		0x10			; 调用显卡BIOS
		JMP		putloop

entry:

; 为了使PIC不接受任何中断
;	根据AT兼容机的规范，如果要初始化PIC，
;	必须在CLI之前完成，否则有时会出现挂起
;	PIC的初始化稍后进行

		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; 听说有些机型连续使用OUT命令会不顺利，所以
		OUT		0xa1,AL

		CLI						; 进一步在CPU级别禁止中断

; 为了使CPU能够访问超过1MB的内存，请设置A20GATE

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL
		CALL	waitkbdout

; 保护模式转换

		LGDT	[GDTR0]			; 设置暂定GDT
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; 将bit31设为0（因禁止分页）
		OR		EAX,0x00000001	; 将bit0设置位1（以便进入保护模式）
		MOV		CR0,EAX
		JMP		pipelineflush
pipelineflush:
		MOV		AX,1*8			;  可读写的段落32位
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

; bootpack的传送

		MOV		ESI,bootpack	; 转发源
		MOV		EDI,BOTPAK		; 转发目的地
		MOV		ECX,512*1024/4
		CALL	memcpy

; 顺便把磁盘数据也转移到原来的位置

; 首先从引导扇区开始

		MOV		ESI,0x7c00		; 转发源
		MOV		EDI,DSKCAC		; 转发目的地
		MOV		ECX,512/4
		CALL	memcpy

; 剩下的全部

		MOV		ESI,DSKCAC0+512	; 转发源
		MOV		EDI,DSKCAC+512	; 转发目的地
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; 从气缸数转换为字节数/4
		SUB		ECX,512/4		; 扣除IPL的部分
		CALL	memcpy

; 因为我已经把在asmhead中必须做的所有事情都做完了，
;	之后就交给bootpack吧

; bootpack的启动

		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; 没有需要转发的东西
		MOV		ESI,[EBX+20]	; 转发源
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; 转发目的地
		CALL	memcpy

skip:
		MOV		ESP,[EBX+12]	; 栈初始值
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		; 如果AND的结果不为0，则转到waitkbdout
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			; 如果减法结果不为0，则转到memcpy
		RET
; memcpy如果不忘记带地址大小前缀的话，也可以用字符串指令来写

		ALIGNB	16

GDT0:
		RESB	8				; 空选择器
		DW		0xffff,0x0000,0x9200,0x00cf	; 可读写的段落32位
		DW		0xffff,0x0000,0x9a28,0x0047	; 可执行段32位（用于bootpack）

		DW		0

GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16

bootpack:

msg:
		DB		0x0a, 0x0a		; 换行两次
		DB		"Welcome to the HelixOS!                 "
        DB		0x0a    		; 换行
        DB		"Now is in protect mode now"
		DB		0
