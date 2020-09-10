.EQU PUERTO_SALIDA = PORTC
.EQU CONF_PUERTO_SALIDA = DDRC
.EQU BIT_LED_0 = 0 
.EQU BIT_LED_1 = 1
;Boton 0 en INT0 = PD0 = Digital pin 21
;Boton 0 en INT1 = PD1 = Digital pin 20
.EQU CONF_PUERTO_ENTRADA= DDRD
.EQU PUERTO_ENTRADA= PIND
.EQU BIT_BOTON_0 = 0
.EQU BIT_BOTON_1 = 1
.macro	setStack
	ldi	r16,LOW(RAMEND)
	out	SPL,r16
	ldi	r16,HIGH(RAMEND)
	out	SPH,r16
.endmacro
.include "m2560def.inc"
.org 0x0000
	jmp MAIN
.org INT0addr
	jmp isr_int0
.org INT1addr
	jmp isr_int1                 
.org 0x0028 // Timer1 Overflow Handler
	jmp timer_int
.org INT_VECTORS_SIZE

MAIN:
	ldi	r16,(1 << 0 | 1 << 1); habilito interrupciones en pcint 0
	out EIMSK, r16
	ldi	r16,(0 << ISC01 | 1 << ISC00 | 0 << ISC11 | 1 << ISC10); Defino que se hagan por cambio de estado
	sts	EICRA,r16

	LDI r16, (1 << BIT_LED_0 | 1 << BIT_LED_1 )
	OUT CONF_PUERTO_SALIDA, r16	
	// Mantengo apagado el tuner
	LDI r16, (0 << CS02 | 0 << CS01 | 0 << CS00); 
	sts TCCR1B,r16
	//Habilito el interrupt del timer overflow
	LDI r16, 0b0000_0010
	sts TIMSK1, r16

	ldi r28, 1 // flag led prendido
	ldi r29, 1 // flag mantener interrupciones prendidas
	sbi PUERTO_SALIDA, BIT_LED_0

	setStack

	bset 7; habilito interrupciones en status register 
loop:
	cpi r29, 0
	breq apagar_momentaneamente_interrupciones
	jmp loop

apagar_momentaneamente_interrupciones:
	ldi	r16,0; Deshabilito las interrupciones del int 0 e int 1
	out EIMSK, r16
	call delay ; espero
	ldi	r16,(1 << 0 | 1 << 1);Habilito las interrupciones del int 0 e int 1
	ldi r29, 1;Pongo el flag para que no vuelva a apagar las interrupciones
	out EIMSK, r16
	jmp loop
	
timer_int:
	cpi r28, 1
	breq apagar
	ldi r28, 1
	sbi PUERTO_SALIDA, BIT_LED_0
	reti
apagar:
	ldi r28, 0
	cbi PUERTO_SALIDA, BIT_LED_0
	reti

isr_int1:
isr_int0:
	ldi r29, 0;Flag para apagar interrupciones por un tiempo corto
	in r20, PUERTO_ENTRADA
	// Esta mascara no deberia ser necesaria porque no hay nada mas conectado
	// la uso por claridad que me interesan esos bits
	andi r20, (1 << BIT_BOTON_0 | 1 << BIT_BOTON_1)
	//1 1 es fijo
	//1 0 es pre escaler 64
	//0 1 es pre escaler 256
	//0 0 es pre escaler 1024 
	cpi r20, (0 << BIT_BOTON_0 | 0 << BIT_BOTON_1)
	breq pre_escaler_1024
	cpi r20, (1 << BIT_BOTON_0 | 0 << BIT_BOTON_1)
	breq pre_escaler_64
	cpi r20, (0 << BIT_BOTON_0 | 1 << BIT_BOTON_1)
	breq pre_escaler_256
	cpi r20, (1 << BIT_BOTON_0 | 1 << BIT_BOTON_1)
	breq stop_timer
fin_isr:
	reti

stop_timer:
	LDI r16, (0 << CS02 | 0 << CS01 | 0 << CS00)
	sts TCCR1B,r16
	sbi PUERTO_SALIDA, BIT_LED_0
	rjmp fin_isr

pre_escaler_64:
	LDI r16, (0 << CS02 | 1 << CS01 | 1 << CS00)    ;SET TIMER PRESCALER
	sts TCCR1B,r16
	rjmp fin_isr

pre_escaler_256:
	LDI r16, (1 << CS02 | 0 << CS01 | 0 << CS00)    ;SET TIMER PRESCALER
	sts TCCR1B,r16
	rjmp fin_isr

pre_escaler_1024:
	LDI r16, (1 << CS02 | 0 << CS01 | 1 << CS00)    ;SET TIMER PRESCALER
	sts TCCR1B,r16
	rjmp fin_isr

delay:
	//Configuro T3 con un pre escaler para usar de espera y evitar captar rebotes
	//T3 es un timer de 16 bits
	//Voy a usarlo manualmente, sin interrupciones, asi que no configuro nada más
	
	//Pre escaler en 1024, lo que da unos 4.2s de delay aproximadamente
	//Esto es para mostrarlo andando y testear

	//ldi r16, (1 << CS02 | 0 << CS01 | 1 << CS00)

	//En una situación mas realista
	//el pre escaler de 8 que da unos 32 ms de delay sería mas adecuado
	//También se podria usar el timer de 256 bits y un pre escaler de 1024
	//Para usar el pre escaler de 8

	ldi r16, (0 << CS02 | 1 << CS01 | 0 << CS00 )

	//Por si se uso antes, limpio el flag del overflow
	sts TCCR3B,r16
	sbi TIFR3, TOV0
	//Pongo el contador en 0, si no los tiempos varían
	ldi r16, 0
	sts TCNT3l, r16
	sts TCNT3h, r16

esperar_timer:
	in   r16,TIFR3
	andi r16, (1 << TOV0) ;overflow flag
	cpi r16, 1
	brne esperar_timer
	ret

	