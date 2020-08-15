.EQU CONF_PUERTO_SALIDA = DDRC
.EQU PUERTO_SALIDA = PORTC
.EQU LED_0 = 0 
.EQU LED_1 = 1 
.EQU LED_2 = 2 
.EQU LED_3 = 3 
.EQU LED_4 = 4 
.EQU LED_5 = 5 
.EQU PUERTO_ENTRADA = PORTF
.EQU CONF_PUERTO_ENTRADA = DDRF
.ORG 0x003A  // ADC conversion complete handler
	rjmp adc_isr
.ORG 0

start:
	ldi r22, (1 << LED_0 | 1 << LED_1 | 1 << LED_2 | 1 << LED_3 | 1 << LED_4 | 1 << LED_5)
	out CONF_PUERTO_SALIDA, R22	
	ldi r22, 0x00
	out PUERTO_SALIDA, r22

	ldi r22, 0xFE // A0 como input
	out DDRF, r22
	ldi r22, 0xAF // 10101111
	sts ADCSRA, r22
	ldi r22, 0x60 
	sts ADMUX, r22
	sei

	lds R22, ADCSRA
	ori R22, 0x40
	sts ADCSRA, r22

	ldi r20, 0
loop:
    rjmp loop

adc_isr:
	lds r20, ADCH
	out PUERTO_SALIDA, r20
	reti
apagar:
	ldi r20, 0x00
	out PUERTO_SALIDA, r20
	reti
