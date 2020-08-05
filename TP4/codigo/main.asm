;TP2.asm
.EQU PUERTO = PORTB
.EQU BIT_LED_0 = 5 
.EQU BIT_LED_1 = 4
;Boton B en INT0 = PD0 = Digital pin 21
.EQU CONF_PUERTO= DDRB
.EQU BIT_BOTON = 0

.include "m2560def.inc"

.cseg 
.org 0x0000
	jmp MAIN
.org INT0addr
	jmp isr_int0

MAIN:
	ldi	r16,(1 << 0); habilito interrupciones en pcint 0
	out EIMSK, r16
	ldi	r16,(0 << ISC00 | 1 << ISC01); Defino que se hagan por bajada del flanco
	sts	EICRA,r16

	LDI r16, (1 << BIT_LED_0 | 1 << BIT_LED_1 )
	OUT CONF_PUERTO, r16	

	sbi PUERTO, BIT_LED_0
	bset 7; habilito interrupciones en status register 
loop:
	jmp loop

isr_int0:
	cbi PUERTO, BIT_LED_0
	ldi r25, 0x00     
	jmp repeticion_5
demora_terminada:
	sbi PUERTO, BIT_LED_0
	reti

repeticion_5:
	cpi r25, 5
	breq demora_terminada
	inc r25
	ldi r16, 0xff
	sbi PORTB, BIT_LED_1

demora1:
	ldi 	r20,0x00
	ldi 	r21,0x00
	ldi		r22,0x00
	ldi		r23,0x00
ciclo1:		
	inc		r20
	cpi		r20,200
	nop
	brlo	ciclo1
	ldi		r20,0x00
	inc		r21
	cpi		r21, 100
	brlo	ciclo1
	ldi		r21,0x00
	inc		r22
	cpi		r22,100
	brlo	ciclo1
	cbi PUERTO, BIT_LED_1	

demora2:
	ldi 	r20,0x00
	ldi 	r21,0x00
	ldi		r22,0x00
	ldi		r23,0x00
ciclo2:		
	inc		r20
	cpi		r20,200
	nop
	brlo	ciclo2
	ldi		r20,0x00
	inc		r21
	cpi		r21,100
	brlo	ciclo2
	ldi		r21,0x00
	inc		r22
	cpi		r22,100
	brlo	ciclo2
	RJMP	repeticion_5; reinicio el ciclo