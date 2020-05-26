.include "m2560def.inc"

.cseg 
.org 0x0000
			jmp		main

.org INT_VECTORS_SIZE
main:
			
; Led en PB5 
; Configuro puerto B
; PORTB como salida
			ldi		r20,0xff	
;Si quisiera uso PORTB0 como salida
;			ldi		r20,0x01	
			out		DDRB,r20

; rutina de encendido y apagado
		
prendo:		sbi		PORTB,0 	; encendido del led
	

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
			
			
			cbi		PORTB,0		; apagado del led

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
