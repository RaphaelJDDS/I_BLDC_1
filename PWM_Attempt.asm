#include "p10f200.inc"
__CONFIG _WDT_OFF _CP_OFF _MCLRE_OFF

i EQU 10 ;"i" refers to mem. adress 0x10
limit EQU 11 ;And so on
j EQU 12 ;and so forth
up EQU 13
ORG 0x0000 ;Mem. origin is at 0x0000

INIT
    MOVLW ~(1<<GP1) ;GPI1 is an output
    TRIS GPIO ;GPIO is a tri-state
    CLRF limit ; Clear "limit"
LOOP
    MOVLW 0XFF ;255 = i
    MOVWF i ; = i
    BSF GPIO, GP1
INT_LOOP ; Remember duty cycle is directly proportional to the size of "limit"
    MOVF limit, W ; Copy to W
    SUBWF i, W ; Subtract words: i-W
    BTFSS STATUS, Z ; If i = W, skip next line
    GOTO $ + 2
    BCF GPIO, GP1 ;Clear GP1
    CALL DELAY ;Starts Delay subroutine
    DECFSZ i, F ; Decrement i, and skip next line if 0
    GOTO INT_LOOP
    MOVF up, W ;Load up to W
    BTFFS STATUS, Z ; If W == up = 0, skip
    GOTO $ + 3 ;If up isn't 0, it'll trigger increments to limit
    DECF limit, F ; limit-1
    GOTO $ + 2
    INCFSZ limit, F ; If F + 1 = 0 (int. overflow), skip
    GOTO $ + 3
    MOVLW 0x00 ;If it's increased all the way to an overflow, up = 0
    MOVWF up
    GOTO LOOP
    MOVLW 0x01
    MOVWF up
    GOTO LOOP
DELAY
    MOVLW 10
    MOVWF j
DELAY_LOOP
    DECFSZ i, F
    GOTO DELAY_LOOP
    RETLW 0

    END