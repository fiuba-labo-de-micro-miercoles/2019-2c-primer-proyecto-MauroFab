.EQU CONF_PUERTO_SALIDA = DDRB
.EQU BIT_LED_0 = 5 
;Boton 0 en INT0 = PD0 = Digital pin 21
;Boton 0 en INT1 = PD1 = Digital pin 20
.EQU CONF_PUERTO_ENTRADA= DDRD
.EQU PUERTO_ENTRADA= PIND
.EQU BIT_BOTON_0 = 0
.EQU BIT_BOTON_1 = 1
.include "m2560def.inc"
.org 0x0000
	jmp MAIN
.org INT0addr
	jmp isr_int0
.org INT1addr
	jmp isr_int1                 

MAIN:
	ldi	r16,(1 << 0 | 1 << 1); habilito interrupciones en pcint 0
	out EIMSK, r16
	ldi	r16,(1 << ISC01 | 0 << ISC00 | 1 << ISC11 | 0 << ISC10); Defino que se hagan por flanco descendente
	sts	EICRA,r16

	sbi CONF_PUERTO_SALIDA, BIT_LED_0

	LDI r16, (1 << BIT_LED_0 | 1 << BIT_LED_0 )
	OUT CONF_PUERTO_SALIDA, r16	
	// Configuro timer 1 con fast pwm
	LDI r16, (0 << CS12 | 0 << CS11 | 1 << CS10 | 1<<WGM12); 
	sts TCCR1B,r16
	ldi	r16, ( 1<<COM1A1 | 1<<WGM10)
	sts	TCCR1A, R16

	// Pongo un ciclo de trabajo alto
	ldi r16, 0xf0
	sts	OCR1AL, R16
	bset 7; habilito interrupciones en status register 

loop:
	jmp loop

isr_int0:
	ldi r17, 0
	cpse r17, r16
	subi r16, 0x10
	sts	OCR1AL, R16
	reti
isr_int1:
	ldi r17, 0xf0
	cpse r17, r16
	subi r16, -0x10
	sts	OCR1AL, R16
	reti