; HelixOS
; 2025.4.8

		ORG		0x7c00			; �w�������I��?�n��

; �ȉ�?�i��?�yFAT12�i��???�p�I��?

		JMP		entry
		DB		0x90
		DB		"HELIXIPL"		; ??��I���̉Ȑ��C�ӓI�������i8��?�j
		DW		512				; ?�����isector�j�I�召�i�K??512��?�j
		DB		1				; �Ɓicluster�j�I�召�i�K??1�����j
		DW		1				; FAT�I�N�n�ʒu�i��ʘ���꘢���?�n�j
		DB		2				; FAT�I�����i�K??2�j
		DW		224				; ����?�I�召�i���?��224?�j
		DW		2880			; ?��?�I�召�i�K??2880���j
		DB		0xf0			; ��?�I??�i�K?��0xf0�j
		DW		9				; FAT�I?�x�i�K?��9���j
		DW		18				; 1�������itrack�j�L�{�����i�K?��18�j
		DW		2				; ��?���i�K?��2�j
		DD		0				; �s�g�p����C�K?��0
		DD		2880			; �d�ʈꎟ��?�召
		DB		0,0,0x29		; ��?�s���C�Œ�
		DD		0xffffffff		; �i�\���j��?��?
		DB		"HELIXOS    "	; ��?�I���́i11��?�j
		DB		"FAT12   "		; ��?�I�i�����́i8��?�j
		TIMES 18 DB 0			; ���o18��?

; �����j�S

entry:
		MOV		AX,0			; ���n���񑶊�
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX
		MOV		ES,AX

		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; ?SI��1
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; ?���꘢����
		MOV		BX,15			; �w�莚��?�F
		INT		0x10			; ?�p??BIOS
		JMP		putloop
fin:
		HLT						; ?CPU��~�C���Ҏw��
		JMP		fin				; �ٌ��z?

msg:
		DB		0x0a, 0x0a		; ?�s?��
		DB		"Loading HelixOS..."
		DB		0

		TIMES 510 - ($ - $$) DB 0	; �ō@�U�[0x00

		DB		0x55, 0xaa
