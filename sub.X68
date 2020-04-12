* 
* Subroutines to handle every opcode.
*

* ==== opcode subroutines ====

*-----------------------------------------------------------
* //// opcode not found
* parameters:
*   A0 - address of opcode's first word
* return:
*   A0 - address of next opcode word
*
reglist_notf    REG     A1-A7/D0-D7 * every reg except parameters/return
op_notfound     MOVEM.L reglist_notf, -(SP) * save current regs to stack
* ---- handle the opcode:
                
                MOVE.B  #14, D0
                LEA     msg_data, A1
                TRAP    #15
                LEA     newline, A1 * yes, trap 15 mode 13 allows newline
                * but there will be more than just msg_data in the future
                TRAP    #15
                
* ---- exit
op_notfound_x   ADDQ    #$2, A0 * move to next opcode word
                MOVEM.L (SP)+, reglist_notf * bring back old registers
                RTS * exit subroutine
*-----------------------------------------------------------
* //// opcode NOP
* parameters:
*   A0 - address of opcode's first word
* return:
*   A0 - address of next opcode word
*
reglist_nop     REG     A1-A7/D0-D7
op_nop          MOVEM.L reglist_nop, -(SP)
* ---- handle the opcode:
                
                MOVE.B  #14, D0
                LEA     msg_nop, A1
                TRAP    #15
                LEA     newline, A1
                TRAP    #15

* ---- exit
op_nop_x        ADDQ    #$2, A0
                MOVEM.L (SP)+, reglist_nop
                RTS
*-----------------------------------------------------------

* ==== constants and variables ====

msg_data        DC.B    'DATA',0
msg_nop         DC.B  'NOP',0

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
