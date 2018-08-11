;
; iLove.asm
;
; Created: 06.11.2015 12:26:14
; Author : Cthulhu
;


.device	ATtiny2313A
.include "tn2313Adef.inc"

.def temp = r16

.set		PIN_A1			= PINA0 ; 5
.set		PORT_A1			= PORTA
.set		PIN_B1			= PIND2 ; 6
.set		PORT_B1			= PORTD
.set		PIN_M1			= PINA1 ; 4
.set		PORT_M1			= PORTA

.set		PIN_A2			= PIND3 ; 7
.set		PORT_A2			= PORTD
.set		PIN_B2			= PIND4 ; 8
.set		PORT_B2			= PORTD
.set		PIN_M2			= PIND5 ; 9
.set		PORT_M2			= PORTD

.set		PIN_UP_DOWN		= PINB1 ; 13
.set		PORT_UP_DOWN	= PORTB

.set		PIN_SHUTDOWN1	= PINB3 ; 15
.set		PORT_SHUTDOWN1	= PORTB

.set		PIN_SHUTDOWN2	= PINB0 ; 12
.set		PORT_SHUTDOWN2	= PORTB

.set		PIN_CLOCK1		= PINB4 ; 16
.set		PORT_CLOCK1		= PORTB

.set		PIN_CLOCK2		= PINB2 ; 14
.set		PORT_CLOCK2		= PORTB

.set		PIN_LED			= PIND6 ; 11
.set		PORT_LED		= PORTD


; EEPROM
.eseg


.dseg
.org	SRAM_START


.cseg
.org 0
									; Таблица векторов прерываний
			rjmp	RESET			; External Pin, Power-on Reset, Brown-out Reset, and Watchdog Reset
			reti					; INT0 External Interrupt Request 0
			reti					; INT1 External Interrupt Request 1
			reti					; TIMER1 CAPT Timer/Counter1 Capture Event
			reti					; TIMER1 COMPA Timer/Counter1 Compare Match A
			reti					; TIMER1 OVF Timer/Counter1 Overflow
			reti					; TIMER0 OVF Timer/Counter0 Overflow
			reti					; USART0, RX  USART0, Rx Complete
			reti					; USART0, UDRE USART0 Data Register Empty
			reti					; USART0, TX USART0, Tx Complete
			reti					; ANALOG COMP Analog Comparator
			reti					; PCINT0 Pin Change Interrupt Request 0
			reti					; TIMER1 COMPB Timer/Counter1 Compare Match B
			reti					; TIMER0 COMPA Timer/Counter0 Compare Match A
			reti					; TIMER0 COMPB Timer/Counter0 Compare Match B
			reti					; USI START USI Start Condition
			reti					; USI OVERFLOW USI Overflow
			reti					; EE READY EEPROM Ready
			reti					; WDT OVERFLOW Watchdog Timer Overflow
			rjmp	PCINT1_INT		; PCINT1 Pin Change Interrupt Request 1
			rjmp	PCINT2_INT		; PCINT2 Pin Change Interrupt Request 2

.org	INT_VECTORS_SIZE

; Прерывание 1 энкодера
PCINT1_INT:
			cbi		PORT_LED, PIN_LED

ENCODER1_M1:
			sbic	PINA, PIN_M1
			rjmp	ENCODER1_END

			sbi		PINB, PIN_SHUTDOWN1

EN1_M1_L:
			nop
			nop
			nop
			nop
			nop

			sbis	PINA, PIN_M1
			rjmp	EN1_M1_L


			rjmp	ENCODER1_END

ENCODER1_END:
			sbi		PORT_LED, PIN_LED
			reti

; Прерывание 2 энкодера
PCINT2_INT:
			sbi		PORT_UP_DOWN, PIN_UP_DOWN
			cbi		PORT_LED, PIN_LED

ENCODER2_B1:

			sbic	PIND, PIN_B1
			rjmp	ENCODER2_B2
			
			sbic	PINA, PIN_A1
			cbi		PORT_UP_DOWN, PIN_UP_DOWN

			sbi		PORT_CLOCK1, PIN_CLOCK1
			nop
			nop
			nop
			nop
			nop
			cbi		PORT_CLOCK1, PIN_CLOCK1
			nop
			nop
			nop
			nop
			nop

			rjmp	ENCODER2_END

ENCODER2_B2:
			sbic	PIND, PIN_B2
			rjmp	ENCODER2_M2

			sbic	PIND, PIN_A2
			cbi		PORT_UP_DOWN, PIN_UP_DOWN

			sbi		PORT_CLOCK2, PIN_CLOCK2
			nop
			nop
			nop
			nop
			nop
			cbi		PORT_CLOCK2, PIN_CLOCK2
			nop
			nop
			nop
			nop
			nop

			rjmp	ENCODER2_END
			
ENCODER2_M2:
			sbis	PIND, PIN_M2
			rjmp	ENCODER2_END

			sbi		PINB, PIN_SHUTDOWN2
			nop
			nop
			nop
			nop
			nop
			rjmp	ENCODER2_END

ENCODER2_END:
			sbi		PORT_LED, PIN_LED

			reti




RESET:

; Инициализация стека
			cli
			ldi		temp, RAMEND
			out		SPL, temp

; Инициализация портов

			ldi		temp, (1<<PIN_A1)|(1<<PIN_M1)
			out		PORTA, temp

			clr		temp
			out		PORTB, temp

			ldi		temp, (1<<PIN_B1)|(1<<PIN_A2)|(1<<PIN_B2)|(1<<PIN_M2)
			out		PORTD, temp

			ldi		temp, (1<<PIN_UP_DOWN)|(1<<PIN_SHUTDOWN1)|(1<<PIN_SHUTDOWN2)|(1<<PIN_CLOCK1)|(1<<PIN_CLOCK2)
			out		DDRB, temp

			ldi		temp, (1<<PIN_LED)
			out		DDRD, temp

; Инициализация прерываний
			
			ldi		temp, (1<<PCIE1)|(1<<PCIE2)
			out		GIMSK, temp

			ldi		temp, (1<<PCINT13)|(1<<PCINT15)|(1<<PCINT16)
			out		PCMSK2, temp

			ldi		temp, (1<<PCINT9)
			out		PCMSK1, temp

			sei

			sbi		PORT_LED, PIN_LED


MAIN:
			nop
			nop
			nop

			rjmp	MAIN
