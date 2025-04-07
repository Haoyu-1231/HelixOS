; HelixOS
; 2025.4.8

		ORG		0x7c00			; wพ๖I?nฌ

; ศบ?iฅ?yFAT12iฎ???pIใ?

		JMP		entry
		DB		0x90
		DB		"HELIXIPL"		; ??ๆIผฬยศฅCำI๘i8?j
		DW		512				; ?ข๎ๆisectorjIๅฌiK??512?j
		DB		1				; โฦiclusterjIๅฌiK??1ข๎ๆj
		DW		1				; FATINnสui๊สธๆ๊ข๎ๆ?nj
		DB		2				; FATIขiK??2j
		DW		224				; ชฺ?Iๅฌi๊ส?ฌ224?j
		DW		2880			; ?ฅ?IๅฌiK??2880๎ๆj
		DB		0xf0			; ฅ?I??iK?ฅ0xf0j
		DW		9				; FATI?xiK?ฅ9๎ๆj
		DW		18				; 1ขฅนitrackjL{ข๎ๆiK?ฅ18j
		DW		2				; ฅ?iK?ฅ2j
		DD		0				; sgpชๆCK?ฅ0
		DD		2880			; dส๊ฅ?ๅฌ
		DB		0,0,0x29		; ำ?sพCล่
		DD		0xffffffff		; iย\ฅjษ??
		DB		"HELIXOS    "	; ฅ?Iผฬi11?j
		DB		"FAT12   "		; ฅ?Iiฎผฬi8?j
		TIMES 18 DB 0			; ๆ๓o18?

; ๖jS

entry:
		MOV		AX,0			; nป๑ถํ
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX
		MOV		ES,AX

		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; ?SIม1
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; ?ฆ๊ขถ
		MOV		BX,15			; w่?F
		INT		0x10			; ?p??BIOS
		JMP		putloop
fin:
		HLT						; ?CPUโ~Cาw฿
		JMP		fin				; ูภz?

msg:
		DB		0x0a, 0x0a		; ?s?
		DB		"Loading HelixOS..."
		DB		0

		TIMES 510 - ($ - $$) DB 0	; ล@U[0x00

		DB		0x55, 0xaa
