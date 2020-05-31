;Version PORTB como salida
.include "m2560def.inc"

.cseg 
.org 0x0000
			jmp		main

.org INT_VECTORS_SIZE

main:
			 
; PORTB como salida
	ldi		r20,0xff	
	out		DDRB,r20

; rutina de encendido y apagado
		
prendo:
			ldi r16, 0xff
			out PORTB,r16

demora1:
			ldi 	r20,0x00
			ldi 	r21,0x00
			ldi		r22,0x00
ciclo1:		inc		r20
			cpi		r20,0xff
			brlo	ciclo1
			ldi		r20,0x00
			inc		r21
			cpi		r21,0xff
			brlo	ciclo1
			ldi		r21,0x00
			inc		r22
			;Al poner el ultimo cpi en Ox20, cuenta menos hasta que apaga la luz
			;que si fuera por ejemplo 0xFF
			;Entonces, la luz pasa poco tiempo prendida
			cpi		r22,0x20
			brlo	ciclo1
			
			;apagado del led
			ldi r16, 0x00
			out PORTB,r16		

demora2:
			ldi 	r20,0x00
			ldi 	r21,0x00
			ldi		r22,0x00
ciclo2:		inc		r20
			cpi		r20,0xff
			brlo	ciclo2
			ldi		r20,0x00
			inc		r21
			cpi		r21,0xff
			brlo	ciclo2
			ldi		r21,0x00
			inc		r22
			;Al poner el ultimo cpi en Oxff, cuenta más hasta prender la luz
			;Entonces, la luz pasa mas tiempo apagada
			cpi		r22,0xff
			brlo	ciclo2


			RJMP	prendo		; reinicio el ciclo
