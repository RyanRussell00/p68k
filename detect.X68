*
* Subroutines to detect opcodes.
*

* ==== subroutines ====

*-----------------------------------------------------------
* //// read opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_read_op      reg     a1-a6/d0-d7
read_opcode     move.w  sr, -(sp)
                movem.l rl_read_op, -(sp)
* ---- read the opcode:
                
                move.w  (a0), d7 * get the opcode data itself
                rol.w   #$4, d7 * move bits 15-12 to bits 0-3
                andi.b  #$f, d7 * clear bits 4-7 so cmpi.b doesn't see them

* opcode group means the first four bits of any opcode
* to narrow down the options, it picks 1 of 16 possible groups
* however, we don't have to check every instruction
* so groups 0, A, B, and F are not checked

* check first 4 bits -> check the other bits in another subroutine

op_group_1      cmpi.b  #$1, d7 * compare first four bits of given opcode
                bne     op_group_2 * move to next opcode group
                
                * handle group
                
                addq    #$2, a0 * move to next opcode word
                * probably have to give addq duty to another subroutine
                bra     read_opcode_x * done, exit subroutine
                
op_group_2      cmpi.b  #$2, d7
                bne     op_group_3
                
                * handle group
                
                addq    #$2, a0
                bra     read_opcode_x

op_group_3      cmpi.b  #$3, d7
                bne     op_group_4
                
                * handle group
                
                addq    #$2, a0
                bra     read_opcode_x
                
op_group_4      cmpi.b  #$4, d7
                bne     op_group_5
                
                * handle group
                
                addq    #$2, a0
                bra     read_opcode_x

op_group_5      cmpi.b  #$5, d7
                bne     op_group_6
                
                * handle group
                
                addq    #$2, a0
                bra     read_opcode_x

op_group_6      cmpi.b  #$6, d7
                bne     op_group_7
                
                * handle group
                
                addq    #$2, a0
                bra     read_opcode_x

op_group_7      cmpi.b  #$7, d7
                bne     op_group_8
                
                * handle group
                
                addq    #$2, a0
                bra     read_opcode_x

op_group_8      cmpi.b  #$8, d7
                bne     op_group_9
                
                * handle group
                
                addq    #$2, a0
                bra     read_opcode_x

op_group_9      cmpi.b  #$9, d7
                bne     op_group_C
                
                * handle group
                
                addq    #$2, a0
                bra     read_opcode_x

op_group_C      cmpi.b  #$C, d7
                bne     op_group_D
                
                * handle group
                
                addq    #$2, a0
                bra     read_opcode_x

op_group_D      cmpi.b  #$D, d7
                bne     op_group_E
                
                * handle group
                
                addq    #$2, a0
                bra     read_opcode_x

op_group_E      cmpi.b  #$E, d7
                bne     no_group * doesn't match any valid group
                
                * handle group
                
                addq    #$2, a0
                bra     read_opcode_x

no_group        bsr     op_notfound * it's just gonna read out DATA
                
* ---- exit        
read_opcode_x   movem.l (sp)+, rl_read_op
                rtr
                
* ==== constants and variables ====

msg_group_4     dc.b    'group 4',0

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
