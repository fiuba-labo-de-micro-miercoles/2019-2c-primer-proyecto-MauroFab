.EQU CONF_PUERTO_SALIDA = DDRC
.EQU PUERTO_SALIDA = PORTC
.EQU LED_0 = 0 
.EQU LED_1 = 1 
.EQU LED_2 = 2 
.EQU LED_3 = 3 

.equ FOSC = 16000000 ; Clock prequency
.equ BAUD = 9600 ;Baud/s for usart
.equ DESIRED_BAUD_RATE = (FOSC / (BAUD*16)) - 1 ; p405 Libro AVR Microcontroller

.macro	setStack
	ldi	r16,LOW(RAMEND)
	out	SPL,r16
	ldi	r16,HIGH(RAMEND)
	out	SPH,r16
.endmacro

.org 0x0000
	jmp start
.org 0x0032 //; USART0 RX Complete Handler
	jmp usart0_complete_int

.org INT_VECTORS_SIZE

//Reg 16 se usa para mandar que imprimir, para recibir el dato, y como dummy en la inicializacion
//Reg 17 es temporal

start:
	ldi r22, (1 << LED_0 | 1 << LED_1 | 1 << LED_2 | 1 << LED_3 )
	out CONF_PUERTO_SALIDA, R22	
	ldi r22, 0x00
	out PUERTO_SALIDA, r22

    ldi r16, LOW(DESIRED_BAUD_RATE)
    sts UBRR0L, r16
    ldi r16, HIGH(DESIRED_BAUD_RATE)                     
    sts UBRR0H, r16

	//Habilito emisor y receptor en override. RXCIE0 me habilita la interrupcion en complete
	ldi r16, (1 << RXEN0 | 1 << TXEN0 | 1 << RXCIE0)
    sts UCSR0B,r16    

	//Data frame 8 bits,  Asynchronous USART
    ldi  r16, ( 1 << UCSZ01 | 1 << UCSZ00)             ; 8N1
    sts UCSR0C,r16 

	setStack
	sei

	;call delay
	call print_mensaje_inicial

loop:
	jmp loop

usart0_complete_int:
	call USART_Receive 
	subi r16, 48 ; '1' -> 1
	ldi r17, 1


set_bit_from_register_loop:
	subi r16, 1
	cpi r16, 0
	breq cambiar_estado_led
	lsl r17
	jmp set_bit_from_register_loop

//Tengo un 1 en r17 en el bit que tengo que cambiar
cambiar_estado_led:
	in r19, PUERTO_SALIDA
	//Chequeo en las proximas 3 lineas si el led esta apagado
	mov r18, r17
	and r18, r19
	cpi r18, 0 // Si esta apagado 
	breq prender_led //lo prendo
	//Como tengo un 1 en el bit que quiero cambiar del in, si hago un XOR se mantienen todos iguales, y el que hay un 1 cambia a un 0
	eor r19, r17
	jmp terminar_cambio_estado
prender_led:
	//Como tengo un 1 en el bit que quiero cambiar del in, si hago un OR se mantienen todos iguales, y el que hay un 1 cambia a un 1
	or r19, r17
terminar_cambio_estado:
	out PUERTO_SALIDA, r19
    reti

;Pongo en r16 los datos
USART_Transmit:
	lds      r17, UCSR0A
	andi     r17, (1 << UDRE0)
	breq     USART_Transmit
	sts      UDR0,r16
	ret

;Cargo en r16 lo que quiero
USART_Receive:
    lds     r17, UCSR0A
    andi    r17, (1 << RXC0)
    breq    USART_Receive
    lds     r16, UDR0
    ret

print:                  
    lpm     r16, Z+
    cpi     r16, 0
    breq    terminar_print
    call    USART_Transmit
    jmp     print
terminar_print:           
	ret

print_mensaje_inicial:
	ldi     ZH, high(2*mensaje_inicial)
	ldi     ZL, low(2*mensaje_inicial)
	call    print
	ret

delay:
	//Configuro T3 con un pre escaler para usar de espera
	//T3 es un timer de 16 bits
	//Voy a usarlo manualmente, sin interrupciones, asi que no configuro nada más
	
	//Pre escaler en 1024, lo que da unos 4.2s de delay aproximadamente

	ldi r16, (1 << CS02 | 0 << CS01 | 1 << CS00)

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


	


mensaje_inicial: .db "*** Hola Labo de Micro ***", 10, 13, "Escriba 1, 2, 3 o 4 para controlar los LEDs",  10, 13, 0, 0