/*
* Laboratorio1.asm
*
* Creado: 6/02/2025 20:44:19
* Autor : Alma Mata
* Descripcion: Laboratorio 1, contador de 4 bits.
*/
// Encabezado
.include "M328PDEF.inc"
.cseg
.org 0x0000
// Configurar de PILA
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R16, HIGH(RAMEND)
OUT SPH, R16

// Configuración MCU
SETUP:
	// Configurar pines de entrada y salida (DDRx, PORTx, PINx)
	// PORTC como entrada con pull-up habilitado
	LDI		R16, 0x00
	OUT		DDRC, R16	// Establecer puerto C como entrada
	LDI		R16, 0xFF
	OUT		PORTC, R16	// Habilitar pull-ups en puerto C

	// PORTB como salida inicialmente apagado
	LDI		R16, 0xFF
	OUT		DDRB, R16	// Establecer puerto B como salida
	LDI		R16, 0x00 
	OUT		PORTB, R16	// Todos los bits del puerto B están apagados

	// PORTD como salida inicialmente apagada
	LDI		R16, 0xFF
	OUT		DDRD, R16	// Establecer puerto D como salida
	LDI		R16, 0x00 
	OUT		PORTD, R16	// Todos los bits del puerto D están apagados

	LDI		R17, 0xFF	// Variable que guarda el estado de los botones
	LDI		R18, 0x00	// Variable para llevar el contador 1
	LDI		R20, 0x00	// Variable para llevar el contador 2

// Loop infinito
MAIN:
	// Lógica del antirebote
	IN		R16, PINC	// Lectura de PINC
	CP		R17, R16	// Comparación entre estado nuevo y estado viejo
	BREQ	MAIN		// Regresa al inicio
	CALL	DELAY		// Pequeño delay de confirmación
	IN		R16, PINC	// Se repite para confirmar el cambío de estado
	CP		R17, R16	
	BREQ	MAIN		// Regresa al inicio

	MOV		R17, R16	// Guarda el estado viejo para futura comparación

	// Lógica para aumento o decremento del contador
	CALL	CONTADOR_1
	CALL	CONTADOR_2
	RJMP	MAIN


CONTADOR_1:
	SBRS	R16, 2			// Salta si Bit 2 de PORTC esta en 1 (apagado)
	INC		R18				// Incrementa en 1 al contador
	CPI		R18, 0x10		// Comparación para identificar Overflow
	BREQ	OVERFLOW_1		// Salta al bloque del overflow
	SBRS	R16, 3			// Salta si Bit 3 de PORTC esta en 1 (apagado)
	DEC		R18				// Resta 1 al contador
	CPI		R18, 0xFF		// Comparación para identificar Underflow
	BREQ	UNDERFLOW_1		// Salta al bloque del underflow
	OUT		PORTB, R18		// Salida del contador
	RET						// Regresa al llamado de CONTADOR_1

OVERFLOW_1:
	LDI		R18, 0x00		// Asigna valor 0 al contador
	OUT		PORTB, R18		// Muestra valor en la salida
	RET						// Regresa al llamado de CONTADOR_1

UNDERFLOW_1:
	LDI		R18, 0x0F		// Asigna valor 15 al contador
	OUT		PORTB, R18		// Muestra valor en la salida
	RET						// Regresa al llamado de CONTADOR_1

CONTADOR_2:					//Misma lógica que CONTADOR_1
	SBRS	R16, 4			// Salta si Bit 4 de PORTC esta en 1 (apagado)
	INC		R20				// Salta al bloque aumento
	CPI		R20, 0x10		
	BREQ	OVERFLOW_2
	SBRS	R16, 5			// Salta si Bit 5 de PORTC esta en 1 (apagado)
	DEC		R20				// Salta al bloque decremento
	CPI		R20, 0xFF
	BREQ	UNDERFLOW_2
	OUT		PORTD, R20
	RET						// Regresa al inicio

OVERFLOW_2:					// Hace lo mismo que OVERFLOW_1
	LDI		R20, 0x00
	OUT		PORTB, R18
	RET

UNDERFLOW_2:				// Hace lo mismo que UNDERFLOW_1
	LDI		R20, 0x0F
	OUT		PORTB, R18
	RET

// Rutina de interrupción
DELAY:
	LDI		R19, 0xFF
SUB_DELAY1:
	DEC		R19
	CPI		R19, 0
	BRNE	SUB_DELAY1
	LDI		R19, 0xFF
SUB_DELAY2:
	DEC		R19
	CPI		R19, 0
	BRNE	SUB_DELAY2
	LDI		R19, 0xFF
SUB_DELAY3:
	DEC		R19
	CPI		R19, 0
	BRNE	SUB_DELAY3
	RET					// Regrea a donde fue llamado