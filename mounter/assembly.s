;IRQ 00

ST R6 R5
SUBI R5 R5 2
ST R4 R5
SUBI R5 R5 2
LI R4 [Endereço do tratamento 00]
BZ R4 R0
ADDI R5 R5 2
LD R6 R5

;IRQ 01

ST R6 R5
SUBI R5 R5 2
ST R4 R5
SUBI R5 R5 2
LI R4 [Endereço do tratamento 01]
BZ R4 R0
ADDI R5 R5 2
LD R6 R5

;IRQ 10

ST R6 R5
SUBI R5 R5 2
ST R4 R5
SUBI R5 R5 2
LI R4 [Endereço do tratamento 10]
BZ R4 R0
ADDI R5 R5 2
LD R6 R5

;IRQ 11

ST R6 R5
SUBI R5 R5 2
ST R4 R5
SUBI R5 R5 2
LI R4 [Endereço do tratamento 11]
BZ R4 R0
ADDI R5 R5 2
LD R6 R5