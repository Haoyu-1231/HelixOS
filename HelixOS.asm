; HelixOS 1.0 Build 04 (Classic 1)
; ���ļ� (���)
; ��д������_1231
; ���ڣ�2025.4.8

BOTPAK	EQU		0x00280000		; bootpack�ļ���λ��
DSKCAC	EQU		0x00100000		; ���̻����λ��
DSKCAC0	EQU		0x00008000		; ���̻����λ�ã���ʵģʽ��

; �й�BOOT_INFO
CYLS	EQU		0x0ff0			; �趨������
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; �й���ɫ��Ŀ����Ϣ����ɫ��λ����
SCRNX	EQU		0x0ff4			; �ֱ��ʵ�X��screen x��
SCRNY	EQU		0x0ff6			; �ֱ��ʵ�Y��screen y��
VRAM	EQU		0x0ff8			; ͼ�񻺳����Ŀ�ʼ��ַ

		ORG		0xc200			; �������Ҫ��װ�ص��ĸ��ط��أ�

        MOV     AL,0x13         ; VGA �Կ���320x200x8λ��ɫ
        MOV     AH,0x00
        INT     0x10
        MOV		BYTE [VMODE],8	; ��¼����ģʽ
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

; ��BIOSȡ�ü����ϸ���LEDָʾ�Ƶ�״̬

		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL

        MOV		SI,msg

putloop:
		MOV		AL,[SI]
		ADD		SI,1			; ��SI��1
		CMP		AL,0
		JE		entry
		MOV		AH,0x0e			; ��ʾһ������
		MOV		BX,15			; ָ���ַ���ɫ
		INT		0x10			; �����Կ�BIOS
		JMP		putloop

entry:

; Ϊ��ʹPIC�������κ��ж�
;	����AT���ݻ��Ĺ淶�����Ҫ��ʼ��PIC��
;	������CLI֮ǰ��ɣ�������ʱ����ֹ���
;	PIC�ĳ�ʼ���Ժ����

		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; ��˵��Щ��������ʹ��OUT����᲻˳��������
		OUT		0xa1,AL

		CLI						; ��һ����CPU�����ֹ�ж�

; Ϊ��ʹCPU�ܹ����ʳ���1MB���ڴ棬������A20GATE

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL
		CALL	waitkbdout

; ����ģʽת��

		LGDT	[GDTR0]			; �����ݶ�GDT
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; ��bit31��Ϊ0�����ֹ��ҳ��
		OR		EAX,0x00000001	; ��bit0����λ1���Ա���뱣��ģʽ��
		MOV		CR0,EAX
		JMP		pipelineflush
pipelineflush:
		MOV		AX,1*8			;  �ɶ�д�Ķ���32λ
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

; bootpack�Ĵ���

		MOV		ESI,bootpack	; ת��Դ
		MOV		EDI,BOTPAK		; ת��Ŀ�ĵ�
		MOV		ECX,512*1024/4
		CALL	memcpy

; ˳��Ѵ�������Ҳת�Ƶ�ԭ����λ��

; ���ȴ�����������ʼ

		MOV		ESI,0x7c00		; ת��Դ
		MOV		EDI,DSKCAC		; ת��Ŀ�ĵ�
		MOV		ECX,512/4
		CALL	memcpy

; ʣ�µ�ȫ��

		MOV		ESI,DSKCAC0+512	; ת��Դ
		MOV		EDI,DSKCAC+512	; ת��Ŀ�ĵ�
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; ��������ת��Ϊ�ֽ���/4
		SUB		ECX,512/4		; �۳�IPL�Ĳ���
		CALL	memcpy

; ��Ϊ���Ѿ�����asmhead�б��������������鶼�����ˣ�
;	֮��ͽ���bootpack��

; bootpack������

		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; û����Ҫת���Ķ���
		MOV		ESI,[EBX+20]	; ת��Դ
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; ת��Ŀ�ĵ�
		CALL	memcpy

skip:
		MOV		ESP,[EBX+12]	; ջ��ʼֵ
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		; ���AND�Ľ����Ϊ0����ת��waitkbdout
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			; ������������Ϊ0����ת��memcpy
		RET
; memcpy��������Ǵ���ַ��Сǰ׺�Ļ���Ҳ�������ַ���ָ����д

		ALIGNB	16

GDT0:
		RESB	8				; ��ѡ����
		DW		0xffff,0x0000,0x9200,0x00cf	; �ɶ�д�Ķ���32λ
		DW		0xffff,0x0000,0x9a28,0x0047	; ��ִ�ж�32λ������bootpack��

		DW		0

GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16

bootpack:

msg:
		DB		0x0a, 0x0a		; ��������
		DB		"Welcome to the HelixOS!                 "
        DB		0x0a    		; ����
        DB		"Now is in protect mode now"
		DB		0
