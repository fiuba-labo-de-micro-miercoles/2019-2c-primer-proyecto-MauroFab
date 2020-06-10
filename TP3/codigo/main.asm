.include "m2560def.inc"
.EQU CONF_PUERTO_SALIDA = DDRC
.EQU PUERTO_SALIDA = PORTC
.EQU BIT_LED_INICIAL = 1
.EQU BIT_LED_FINAL = 6
.cseg 
.org 0x0000
			jmp		main

.org INT_VECTORS_SIZE
			 
MAIN:
	LDI R22, 0xff
	OUT CONF_PUERTO_SALIDA, R22	
	
prender_led_siguiente_primera_vez:

	LDI R16, BIT_LED_INICIAL

prender_led_siguiente:

	OUT PUERTO_SALIDA,R16
	LSL R16

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

		cpi R16, (1<<BIT_LED_FINAL)
		BREQ prender_led_anterior_primera_vez
		RJMP prender_led_siguiente

prender_led_anterior_primera_vez:
	LDI R16, (1 << BIT_LED_FINAL - 2)

prender_led_anterior:
		OUT PUERTO_SALIDA,R16
		LSR R16

demora2:
		ldi 	r20,0x00
		ldi 	r21,0x00
		ldi		r22,0x00
ciclo2:		
		inc		r20
		cpi		r20,0xff
		brlo	ciclo2
		ldi		r20,0x00
		inc		r21
		cpi		r21,0xff
		brlo	ciclo2
		ldi		r21,0x00
		inc		r22
		cpi		r22,0x20
		brlo	ciclo2

		cpi R16, (1<<BIT_LED_INICIAL - 1)
		BREQ prender_led_siguiente_primera_vez
		RJMP prender_led_anterior