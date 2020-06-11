.include "m2560def.inc"
.EQU CONF_PUERTO_SALIDA = DDRC
.EQU PUERTO_SALIDA = PORTC
.EQU BIT_LED_INICIAL = 0
.EQU BIT_LED_FINAL = 5
.macro	setStack
	ldi	r16,LOW(RAMEND)
	out	SPL,r16
	ldi	r16,HIGH(RAMEND)
	out	SPH,r16
.endmacro
.cseg

.org 0x0000
			jmp		main

.org INT_VECTORS_SIZE
			 
MAIN:
	LDI R22, 0xff
	OUT CONF_PUERTO_SALIDA, R22	
	LDI R16, (1 << BIT_LED_INICIAL)

prender_led_siguiente:
	OUT PUERTO_SALIDA,R16
	call demora
	LSL R16
	cpi R16, (1<<BIT_LED_FINAL)
	BREQ prender_led_anterior
	RJMP prender_led_siguiente

prender_led_anterior:
	OUT PUERTO_SALIDA,R16
	call demora
	LSR R16
	cpi R16, (1<<BIT_LED_INICIAL)
	BREQ prender_led_siguiente
	RJMP prender_led_anterior

demora:
		ldi 	r20,0x00
		ldi 	r21,0x00
		ldi		r22,0x00
ciclo1:		
		inc		r20
		cpi		r20,0xff
		brlo	ciclo1
		ldi		r20,0x00
		inc		r21
		cpi		r21,0xff
		brlo	ciclo1
		ldi		r21,0x00
		inc		r22
		cpi		r22,0x20
		brlo	ciclo1
		ret