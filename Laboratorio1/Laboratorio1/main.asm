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

	LDI		R17, 0xFF	// Variable que guarda el estado de los botones
	LDI		R18, 0x00	// Variable para llevar el contador

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
	CPI		R16, 0x01	// Comparación para saber si se presiono el botón 1 (aumento)
	BREQ	AUMENTO		// Salta al bloque aumento
	CPI		R16, 0x02	// Comparación para saber si se presiono el botón 1 (aumento)
	BREQ	DECREMENTO	// Salta al bloque decremento
	RJMP	MAIN		// Regresa al inicio

AUMENTO:
	INC		R18			// Aumenta el contador
	OUT		PORTB, R18	// Muestra la salida
	RJMP	MAIN		// Regresa al inicio

DECREMENTO:
	DEC		R18			// Decrece el contador
	OUT		PORTB, R18	// Muestra la salida
	RJMP	MAIN		// Regresa al inicio

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