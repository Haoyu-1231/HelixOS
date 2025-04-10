; HelixOS 1.0 Build 04 (Classic 1)
; IPL�ļ� (���)
; ��д������_1231
; ���ڣ�2025.4.8

CYLS	EQU		10				; ����ʲô�ط�

		ORG		0x7c00			; ָ�������װ�ص�ַ

; ��������Ǳ�׼FAT12��ʽ����ʹ�õĴ���

		JMP		entry
		DB		0x90
		DB		"HELIXIPL"		; �����������ƿ�����������ַ�����8�ֽڣ�
		DW		512				; ÿ��������sector���Ĵ�С������512�ֽڣ�
		DB		1				; �أ�cluster���Ĵ�С������Ϊ1��������
		DW		1				; FAT����ʼλ�ã�һ��ӵ�һ��������ʼ��
		DB		2				; FAT�ĸ���������Ϊ2��
		DW		224				; ��Ŀ¼�Ĵ�С��һ�����224�
		DW		2880			; �ô��̵Ĵ�С������Ϊ2880������
		DB		0xf0			; ���̵����ࣨ������0xf0��
		DW		9				; FAT�ĳ��ȣ�������9������
		DW		18				; 1���ŵ���track���м���������������18��
		DW		2				; ��ͷ����������2��
		DD		0				; ��ʹ�÷�����������0
		DD		2880			; ��дһ�δ��̴�С
		DB		0,0,0x29		; ���岻�����̶�
		DD		0xffffffff		; �������ǣ�������
		DB		"HELIXOS    "	; ���̵����ƣ�11�ֽڣ�
		DB		"FAT12   "		; ���̵ĸ�ʽ���ƣ�8�ֽڣ�
		TIMES 18 DB 0			; �ȿճ�18�ֽ�

; �������

entry:
		MOV		AX,0			; ��ʼ���Ĵ���
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX
		MOV		SI,msg

putloop:
		MOV		AL,[SI]
		ADD		SI,1			; ��SI��1
		CMP		AL,0
		JE		reed
		MOV		AH,0x0e			; ��ʾһ������
		MOV		BX,15			; ָ���ַ���ɫ
		INT		0x10			; �����Կ�BIOS
		JMP		putloop

; ������

reed:
		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; ����0
		MOV		DH,0			; ��ͷ0
		MOV		CL,2			; ����2

readloop:
		MOV		SI,0			; ��¼ʧ�ܴ����ļĴ���

retry:
		MOV		AH,0x02			; AH=0x02 : �������
		MOV		AL,1			; 1������
		MOV		BX,0
		MOV		DL,0x00			; A������
		INT		0x13			; ���ô���BIOS

		JNC		next			; û����Ļ���ת��next
		ADD		SI,1			; ��SI��1
		CMP		SI,5			; �Ƚ�SI��5
		JAE		error			; SI >= 5 ʱ����ת��error
		MOV		AH,0x00
		MOV		DL,0x00			; A������
		INT		0x13			; ����������
		JMP		retry

next:
		MOV		AX,ES			; ���ڴ��ַ����0x200
		ADD		AX,0x0020
		MOV		ES,AX			; ��Ϊû��ADD ES,0x020ָ�����������΢�Ƹ���
		ADD		CL,1			; ��CL���1
		CMP		CL,18			; �Ƚ�CL��18
		JBE		readloop		; ���CL <= 18������ת��readloop
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; ���DH < 2������ת��readloop
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; ���CH < CYLS������ת��readloop

		MOV		ES,AX

; ����������ת��HelixOS.sys

end:
		MOV		[0x0ff0],CH		; ����IPL�����ĳ̶�
		JMP		0xc200

fin:
		HLT						; ��CPUֹͣ���ȴ�ָ��
		JMP		fin				; ����ѭ��

error:
		MOV		SI,failmsg

putloop3:
		MOV		AL,[SI]
		ADD		SI,1			; ��SI��1
		CMP		AL,0
		JE		end
		MOV		AH,0x0e			; ��ʾһ������
		MOV		BX,15			; ָ���ַ���ɫ
		INT		0x10			; �����Կ�BIOS
		JMP		putloop3

msg:
		DB		0x0a, 0x0a		; ��������
		DB		"Loading HelixOS 1.0 Build 04 (Classic 1)...                                     "
		DB		0


failmsg:
		DB		0x0a		; ��������
		DB		"Loading Data failed!"
		DB		0

		TIMES 510 - ($ - $$) DB 0	; ������0x00

		DB		0x55, 0xaa
