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
                
                move.b  #14, d0
                lea     msg_data, a1
                trap    #15
                lea     newline, a1 * yes, trap 15 mode 13 allows newline
                * but there will be more than just msg_data in the future
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
                
                move.b  #14, d0
                lea     msg_nop, a1
                trap    #15
                lea     newline, a1
                trap    #15
                
                addq    #$2, a0
                
* ---- exit                
op_nop_x        movem.l (sp)+, reglist_nop
                rtr

* ==== constants and variables ====

msg_data        dc.b    'DATA',0
msg_nop         dc.b    'NOP',0

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
