; Endereços de memória
JOYSTICK1_ADDR EQU 0x0000
JOYSTICK2_ADDR EQU 0x0001
VGA_BASE      EQU 0x1000

; Dimensões do jogo
WIDTH  EQU 40
HEIGHT EQU 20

; Variáveis
ball_x      EQU 0x10
ball_y      EQU 0x11
ball_dx     EQU 0x12
ball_dy     EQU 0x13
left_y      EQU 0x14
right_y     EQU 0x15
left_length EQU 4
right_length EQU 4

; Inicialização
START:
    LI R0, WIDTH / 2  ; Inicializar a posição da bola
    ST R0, ball_x
    LI R0, HEIGHT / 2
    ST R0, ball_y
    LI R0, 1          ; Inicializar direção da bola
    ST R0, ball_dx
    ST R0, ball_dy
    LI R0, HEIGHT / 2 - left_length / 2 ; Inicializar posição das barras
    ST R0, left_y
    ST R0, right_y

MAIN_LOOP:
    CALL DRAW         ; Desenhar o jogo
    CALL UPDATE       ; Atualizar o estado do jogo
    CALL DELAY        ; Pequeno atraso para controle de velocidade
    B MAIN_LOOP

; Função para desenhar o jogo
DRAW:
    ; Limpar a tela
    LI R0, VGA_BASE
    LI R1, 0
CLEAR_LOOP:
    ST R1, [R0]
    ADDI R0, R0, 1
    LI R2, WIDTH * HEIGHT
    SUB R2, R2, R0
    BNZ R2, CLEAR_LOOP

    ; Desenhar a bola
    LD R0, ball_x
    LD R1, ball_y
    CALL DRAW_PIXEL

    ; Desenhar a barra esquerda
    LD R0, left_y
    LI R1, 1
DRAW_LEFT_LOOP:
    CALL DRAW_PIXEL
    ADDI R0, R0, 1
    SUBI R2, R0, left_y
    LI R3, left_length
    SUB R3, R3, R2
    BNZ R3, DRAW_LEFT_LOOP

    ; Desenhar a barra direita
    LD R0, right_y
    LI R1, WIDTH - 2
DRAW_RIGHT_LOOP:
    CALL DRAW_PIXEL
    ADDI R0, R0, 1
    SUBI R2, R0, right_y
    LI R3, right_length
    SUB R3, R3, R2
    BNZ R3, DRAW_RIGHT_LOOP

    RET

; Função para desenhar um pixel na tela
DRAW_PIXEL:
    ; Assumindo R0 = y e R1 = x
    LI R2, VGA_BASE
    MUL R0, R0, WIDTH
    ADD R0, R0, R1
    ADD R2, R2, R0
    LI R3, 1
    ST R3, [R2]
    RET

; Função para atualizar o estado do jogo
UPDATE:
    ; Atualizar a posição da bola
    LD R0, ball_x
    LD R1, ball_dx
    ADD R0, R0, R1
    ST R0, ball_x

    LD R0, ball_y
    LD R1, ball_dy
    ADD R0, R0, R1
    ST R0, ball_y

    ; Colisões com as paredes superior e inferior
    LD R0, ball_y
    LI R1, 0
    BZ R0, R1, INVERT_DY
    LI R1, HEIGHT - 1
    SUB R1, R1, R0
    BZ R1, R0, INVERT_DY

    ; Colisões com as barras
    LD R0, ball_x
    LI R1, 1
    SUB R1, R0, R1
    BZ R1, R0, COLLIDE_LEFT

    LI R1, WIDTH - 2
    SUB R1, R0, R1
    BZ R1, R0, COLLIDE_RIGHT

    B UPDATE_END

INVERT_DY:
    LD R0, ball_dy
    XORI R0, R0, 0xFFFF  ; Inverter sinal
    ADDI R0, R0, 1
    ST R0, ball_dy
    B UPDATE_END

COLLIDE_LEFT:
    LD R0, ball_y
    LD R1, left_y
    SUB R1, R1, R0
    BNZ R1, UPDATE_END
    LD R1, left_y
    ADDI R1, R1, left_length
    SUB R0, R0, R1
    BNZ R0, UPDATE_END
    ; Colisão detectada
    LD R0, ball_dx
    XORI R0, R0, 0xFFFF
    ADDI R0, R0, 1
    ST R0, ball_dx
    B UPDATE_END

COLLIDE_RIGHT:
    LD R0, ball_y
    LD R1, right_y
    SUB R1, R1, R0
    BNZ R1, UPDATE_END
    LD R1, right_y
    ADDI R1, R1, right_length
    SUB R0, R0, R1
    BNZ R0, UPDATE_END
    ; Colisão detectada
    LD R0, ball_dx
    XORI R0, R0, 0xFFFF
    ADDI R0, R0, 1
    ST R0, ball_dx
    B UPDATE_END

UPDATE_END:
    ; Atualizar as posições das barras baseado nos joysticks
    LI R0, JOYSTICK1_ADDR
    LD R1, [R0]
    LI R0, 1
    SUB R0, R1, R0
    BZ R0, R1, MOVE_LEFT_UP
    LI R0, 2
    SUB R0, R1, R0
    BZ R0, R1, MOVE_LEFT_DOWN

    LI R0, JOYSTICK2_ADDR
    LD R1, [R0]
    LI R0, 1
    SUB R0, R1, R0
    BZ R0, R1, MOVE_RIGHT_UP
    LI R0, 2
    SUB R0, R1, R0
    BZ R0, R1, MOVE_RIGHT_DOWN

    RET

MOVE_LEFT_UP:
    LD R0, left_y
    SUBI R0, R0, 1
    ST R0, left_y
    RET

MOVE_LEFT_DOWN:
    LD R0, left_y
    ADDI R0, R0, 1
    ST R0, left_y
    RET

MOVE_RIGHT_UP:
    LD R0, right_y
    SUBI R0, R0, 1
    ST R0, right_y
    RET

MOVE_RIGHT_DOWN:
    LD R0, right_y
    ADDI R0, R0, 1
    ST R0, right_y
    RET

; Função de delay para controle da velocidade do jogo
DELAY:
    ; Implementação do delay aqui
    ; Pode ser um simples laço de NOPs
    LI R0, 1000
DELAY_LOOP:
    NOP
    SUBI R0, R0, 1
    BNZ R0, DELAY_LOOP
    RET
