* 
* Subroutines to handle every opcode.
*

* ==== opcode subroutines ====

*-----------------------------------------------------------
* //// opcode not found
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_notf    reg     a1-a6/d0-d7 * every reg except parameters/return
op_notfound     move.w  sr, -(sp)
                movem.l reglist_notf, -(sp) * save current regs to stack
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_data, a1
                trap    #15
                
                addq    #$2, a0 * move to next opcode word
                
* ---- exit        
op_notfound_x   movem.l (sp)+, reglist_notf * bring back old registers
                rtr * exit subroutine
                
*-----------------------------------------------------------
* //// opcode NOP
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_nop     reg     a1-a6/d0-d7
op_nop          move.w  sr, -(sp)
                movem.l reglist_nop, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_nop, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_nop_x        movem.l (sp)+, reglist_nop
                rtr

*-----------------------------------------------------------
* //// opcode MOVE
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_move    reg     a1-a6/d0-d7
op_move         move.w  sr, -(sp)
                movem.l reglist_move, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_move, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_move_x       movem.l (sp)+, reglist_move
                rtr

*-----------------------------------------------------------
* //// opcode MOVEQ
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_moveq   reg     a1-a6/d0-d7
op_moveq        move.w  sr, -(sp)
                movem.l reglist_moveq, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_moveq, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_moveq_x      movem.l (sp)+, reglist_moveq
                rtr

*-----------------------------------------------------------
* //// opcode MOVEM
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_movem   reg     a1-a6/d0-d7
op_movem        move.w  sr, -(sp)
                movem.l reglist_movem, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_movem, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_movem_x      movem.l (sp)+, reglist_movem
                rtr

*-----------------------------------------------------------
* //// opcode MOVEA
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_movea   reg     a1-a6/d0-d7
op_movea        move.w  sr, -(sp)
                movem.l reglist_movea, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_movea, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_movea_x      movem.l (sp)+, reglist_movea
                rtr

*-----------------------------------------------------------
* //// opcode ADD
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_add     reg     a1-a6/d0-d7
op_add          move.w  sr, -(sp)
                movem.l reglist_add, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_add, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_add_x        movem.l (sp)+, reglist_add
                rtr

*-----------------------------------------------------------
* //// opcode ADDA
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_adda    reg     a1-a6/d0-d7
op_adda         move.w  sr, -(sp)
                movem.l reglist_adda, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_adda, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_adda_x       movem.l (sp)+, reglist_adda
                rtr

*-----------------------------------------------------------
* //// opcode ADDQ
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_addq    reg     a1-a6/d0-d7
op_addq         move.w  sr, -(sp)
                movem.l reglist_addq, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_addq, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_addq_x       movem.l (sp)+, reglist_addq
                rtr

*-----------------------------------------------------------
* //// opcode SUB
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_sub     reg     a1-a6/d0-d7
op_sub          move.w  sr, -(sp)
                movem.l reglist_sub, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_sub, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_sub_x        movem.l (sp)+, reglist_sub
                rtr

*-----------------------------------------------------------
* //// opcode LEA
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_lea     reg     a1-a6/d0-d7
op_lea          move.w  sr, -(sp)
                movem.l reglist_lea, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_lea, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_lea_x        movem.l (sp)+, reglist_lea
                rtr

*-----------------------------------------------------------
* //// opcode AND
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_and     reg     a1-a6/d0-d7
op_and          move.w  sr, -(sp)
                movem.l reglist_and, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_and, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_and_x        movem.l (sp)+, reglist_and
                rtr

*-----------------------------------------------------------
* //// opcode OR
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_or      reg     a1-a6/d0-d7
op_or           move.w  sr, -(sp)
                movem.l reglist_or, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_or, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_or_x         movem.l (sp)+, reglist_or
                rtr

*-----------------------------------------------------------
* //// opcode NOT
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_not     reg     a1-a6/d0-d7
op_not          move.w  sr, -(sp)
                movem.l reglist_not, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_not, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_not_x        movem.l (sp)+, reglist_not
                rtr

*-----------------------------------------------------------
* //// opcodes xSd - LSL, LSR, ASL, ASR
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_xsd     reg     a1-a6/d0-d7
op_xsd          move.w  sr, -(sp)
                movem.l reglist_xsd, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_xsd, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_xsd_x        movem.l (sp)+, reglist_xsd
                rtr

*-----------------------------------------------------------
* //// opcodes ROd - ROL, ROR
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_rod     reg     a1-a6/d0-d7
op_rod          move.w  sr, -(sp)
                movem.l reglist_rod, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_rod, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_rod_x        movem.l (sp)+, reglist_rod
                rtr

*-----------------------------------------------------------
* //// opcodes Bcc - BGT, BLE, BEQ
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_bcc     reg     a1-a6/d0-d7
op_bcc          move.w  sr, -(sp)
                movem.l reglist_bcc, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_bcc, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_bcc_x        movem.l (sp)+, reglist_bcc
                rtr

*-----------------------------------------------------------
* //// opcode JSR
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_jsr     reg     a1-a6/d0-d7
op_jsr          move.w  sr, -(sp)
                movem.l reglist_jsr, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_jsr, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_jsr_x        movem.l (sp)+, reglist_jsr
                rtr

*-----------------------------------------------------------
* //// opcode RTS
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_rts     reg     a1-a6/d0-d7
op_rts          move.w  sr, -(sp)
                movem.l reglist_rts, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_rts, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_rts_x        movem.l (sp)+, reglist_rts
                rtr

*-----------------------------------------------------------
* //// opcode BRA
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
reglist_bra     reg     a1-a6/d0-d7
op_bra          move.w  sr, -(sp)
                movem.l reglist_bra, -(sp)
* ---- handle the opcode:
                
                move.b  #13, d0
                lea     msg_bra, a1
                trap    #15
                
                addq    #$2, a0
* ---- exit                
op_bra_x        movem.l (sp)+, reglist_bra
                rtr

* ==== constants and variables ====

msg_data        dc.b    'DATA',0
msg_nop         dc.b    'NOP',0
msg_move        dc.b    'MOVE',0
msg_moveq       dc.b    'MOVEQ',0
msg_movem       dc.b    'MOVEM',0
msg_movea       dc.b    'MOVEA',0
msg_add         dc.b    'ADD',0
msg_adda        dc.b    'ADDA',0
msg_addq        dc.b    'ADDQ',0
msg_sub         dc.b    'SUB',0
msg_lea         dc.b    'LEA',0
msg_and         dc.b    'AND',0
msg_or          dc.b    'OR',0
msg_not         dc.b    'NOT',0
msg_xsd         dc.b    'xSd',0
msg_rod         dc.b    'ROd',0
msg_bcc         dc.b    'Bcc',0
msg_jsr         dc.b    'JSR',0
msg_rts         dc.b    'RTS',0
msg_bra         dc.b    'BRA',0



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
