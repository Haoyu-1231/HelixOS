; HelixOS 1.0 Build 03 (Classic 1)
; 主文件 (汇编)
; 编写：浩宇_1231
; 日期：2025.4.8

		ORG		0xc200			; 这个程序会被读入哪里

        MOV     AL,0x13         ; VGA显卡，320x200x8位彩色
        MOV     AH,0x00
        INT     0x10

        MOV		SI,msg

putloop:
		MOV		AL,[SI]
		ADD		SI,1			; 给SI加1
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; 显示一个文字
		MOV		BX,15			; 指定字符颜色
		INT		0x10			; 调用显卡BIOS
		JMP		putloop

fin:
		HLT
		JMP		fin

msg:
		DB		0x0a, 0x0a		; 换行两次
		DB		"Welcome to the HelixOS!"
		DB		0
