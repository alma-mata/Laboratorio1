/*
* UNIVERSIDAD DEL VALLE DE GUATEMALA
* IE2023 - Programacion de Microcontroladores
* Laboratorio1.asm

* Creado: 6/02/2025 20:44:19
* Autor : Alma Mata Ixcayau
* Descripcion: Pre-Lab 1, contador de 4 bits. Se agrega el trabajo del Lab y Post-Lab.
* Hardware: ATmega328P
*/

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
	// Configuración del CLOCK en 1 MHz
	LDI		R16, (1 << CLKPCE)		// El valor habilita cambios en CLKPR
	STS		CLKPR, R16		// CLKPR divide el oscilador
	LDI		R16, 0x04
	STS		CLKPR, R16		// Se carga el valor para obtener 1MHz

	// Configurar pines de entrada y salida (DDRx, PORTx, PINx)
	// PORTC como entrada con pull-up habilitado
	LDI		R16, 0x00
	OUT		DDRC, R16	// Establecer puerto C como entrada
	LDI		R16, 0xFF
	OUT		PORTC, R16	// Habilitar pull-ups en puerto C

// Modificar PORT D como unica salida de contadores y PORT B como salida de sumador.
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
	LDI		R21, 0x00	// Guarda combinacion de R18 y R20
	LDI		R22, 0x00	// Variable para la sumatoria

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
	CALL	COMBINACION		// Subrutina para combinar ambos contadores en una salida

	// Sumador de contadores
	SBRS	R16, 0		// Salta si Bit 0 de PORTC esta en 1 (apagado)
	CALL	SUMADOR		// Llama al sumador

	RJMP	MAIN

// SUB-RUTINAS
CONTADOR_1:
	SBRS	R16, 2			// Salta si Bit 2 de PORTC esta en 1 (apagado)
	INC		R18				// Incrementa en 1 al contador
	SBRS	R16, 3			// Salta si Bit 3 de PORTC esta en 1 (apagado)
	DEC		R18				// Resta 1 al contador
	ANDI	R18, 0x0F		// Mascara para evitar Overflow
	RET						// Regresa al CALL

CONTADOR_2:					//Misma lógica que CONTADOR_1
	SBRS	R16, 4			// Salta si Bit 4 de PORTC esta en 1 (apagado)
	INC		R20				// Salta al bloque aumento
	SBRS	R16, 5			// Salta si Bit 5 de PORTC esta en 1 (apagado)
	DEC		R20				// Resta 1 al contador
	ANDI	R20, 0x0F		// Mascara para evitar Overflow
	RET						// Regresa al CALL

COMBINACION:	// Sub rutina para combinar contadores
	SWAP	R20				// Intercambia los 4 bits más y menos significativos
	MOV		R21, R18		// Guarda R18 en R21
	OR		R21, R20		// Combina ambos contadores con la operación OR
	SWAP	R20				// Regresa R20 a su estado original
	OUT		PORTD, R21		// Muestra R21 en PORT D
	RET						// Regresa a donde fue llamado

SUMADOR:			// Sumatoria de ambos contadores
	MOV		R22, R18		// Copia R18 en R22
	ADD		R22, R20		// Suma Contador 1 y 2
	ANDI	R22, 0x1F		// Mascara para evitar Overflow
	OUT		PORTB, R22		// Muestra la salida
	RET						// Regresa al CALL

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