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
                
                bsr     read_gr1
                bra     read_opcode_x * done, exit subroutine
                
op_group_2      cmpi.b  #$2, d7
                bne     op_group_3
                
                bsr     read_gr2
                bra     read_opcode_x

op_group_3      cmpi.b  #$3, d7
                bne     op_group_4
                
                bsr     read_gr3
                bra     read_opcode_x
                
op_group_4      cmpi.b  #$4, d7
                bne     op_group_5
                
                bsr     read_gr4
                bra     read_opcode_x

op_group_5      cmpi.b  #$5, d7
                bne     op_group_6
                
                bsr     read_gr5
                bra     read_opcode_x

op_group_6      cmpi.b  #$6, d7
                bne     op_group_7
                
                bsr     read_gr6
                bra     read_opcode_x

op_group_7      cmpi.b  #$7, d7
                bne     op_group_8
                
                bsr     read_gr7
                bra     read_opcode_x

op_group_8      cmpi.b  #$8, d7
                bne     op_group_9
                
                bsr     read_gr8
                bra     read_opcode_x

op_group_9      cmpi.b  #$9, d7
                bne     op_group_C
                
                bsr     read_gr9
                bra     read_opcode_x

op_group_C      cmpi.b  #$C, d7
                bne     op_group_D
                
                bsr     read_grc
                bra     read_opcode_x

op_group_D      cmpi.b  #$D, d7
                bne     op_group_E
                
                bsr     read_grd
                bra     read_opcode_x

op_group_E      cmpi.b  #$E, d7
                bne     no_group
                
                bsr     read_gre
                bra     read_opcode_x

* doesn't match any valid group
no_group        bsr     op_notfound * it's just gonna read out DATA
                
* ---- exit        
read_opcode_x   movem.l (sp)+, rl_read_op
                rtr

*-----------------------------------------------------------
* //// read group 1 opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_gr1          reg     a1-a6/d0-d7
read_gr1        move.w  sr, -(sp)
                movem.l rl_gr1, -(sp)
* ---- subroutine code:
                
                addq    #$2, a0
                
* ---- exit        
read_gr1_x      movem.l (sp)+, rl_gr1
                rtr

*-----------------------------------------------------------
* //// read group 2 opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_gr2          reg     a1-a6/d0-d7
read_gr2        move.w  sr, -(sp)
                movem.l rl_gr2, -(sp)
* ---- subroutine code:
                
                addq    #$2, a0
                
* ---- exit        
read_gr2_x      movem.l (sp)+, rl_gr2
                rtr

*-----------------------------------------------------------
* //// read group 3 opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_gr3          reg     a1-a6/d0-d7
read_gr3        move.w  sr, -(sp)
                movem.l rl_gr3, -(sp)
* ---- subroutine code:
                
                addq    #$2, a0
                
* ---- exit        
read_gr3_x      movem.l (sp)+, rl_gr3
                rtr

*-----------------------------------------------------------
* //// read group 4 opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_gr4          reg     a1-a6/d0-d7
read_gr4        move.w  sr, -(sp)
                movem.l rl_gr4, -(sp)
* ---- subroutine code:
                
                move.w  (a0), d7 * get the opcode data itself
                
                cmpi.w  #$4e71, d7 * check if the opcode is NOP
                bne     *+4 * if not, skip past branch to NOP subroutine
                bsr     op_nop
                
                bsr     op_notfound
* ---- exit        
read_gr4_x      movem.l (sp)+, rl_gr4
                rtr

*-----------------------------------------------------------
* //// read group 5 opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_gr5          reg     a1-a6/d0-d7
read_gr5        move.w  sr, -(sp)
                movem.l rl_gr5, -(sp)
* ---- subroutine code:
                
                addq    #$2, a0
                
* ---- exit        
read_gr5_x      movem.l (sp)+, rl_gr5
                rtr

*-----------------------------------------------------------
* //// read group 6 opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_gr6          reg     a1-a6/d0-d7
read_gr6        move.w  sr, -(sp)
                movem.l rl_gr6, -(sp)
* ---- subroutine code:
                
                addq    #$2, a0
                
* ---- exit        
read_gr6_x      movem.l (sp)+, rl_gr6
                rtr

*-----------------------------------------------------------
* //// read group 7 opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_gr7          reg     a1-a6/d0-d7
read_gr7        move.w  sr, -(sp)
                movem.l rl_gr7, -(sp)
* ---- subroutine code:
                
                addq    #$2, a0
                
* ---- exit        
read_gr7_x      movem.l (sp)+, rl_gr7
                rtr

*-----------------------------------------------------------
* //// read group 8 opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_gr8          reg     a1-a6/d0-d7
read_gr8        move.w  sr, -(sp)
                movem.l rl_gr8, -(sp)
* ---- subroutine code:
                
                addq    #$2, a0
                
* ---- exit        
read_gr8_x      movem.l (sp)+, rl_gr8
                rtr

*-----------------------------------------------------------
* //// read group 9 opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_gr9          reg     a1-a6/d0-d7
read_gr9        move.w  sr, -(sp)
                movem.l rl_gr9, -(sp)
* ---- subroutine code:
                
                addq    #$2, a0
                
* ---- exit        
read_gr9_x      movem.l (sp)+, rl_gr9
                rtr

*-----------------------------------------------------------
* //// read group C opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_grc          reg     a1-a6/d0-d7
read_grc        move.w  sr, -(sp)
                movem.l rl_grc, -(sp)
* ---- subroutine code:
                
                addq    #$2, a0
                
* ---- exit        
read_grc_x      movem.l (sp)+, rl_grc
                rtr

*-----------------------------------------------------------
* //// read group D opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_grd          reg     a1-a6/d0-d7
read_grd        move.w  sr, -(sp)
                movem.l rl_grd, -(sp)
* ---- subroutine code:
                
                addq    #$2, a0
                
* ---- exit        
read_grd_x      movem.l (sp)+, rl_grd
                rtr

*-----------------------------------------------------------
* //// read group E opcode
* parameters:
*   a0 - address of opcode's first word
* return:
*   a0 - address of next opcode word
*
rl_gre          reg     a1-a6/d0-d7
read_gre        move.w  sr, -(sp)
                movem.l rl_gre, -(sp)
* ---- subroutine code:
                
                addq    #$2, a0
                
* ---- exit        
read_gre_x      movem.l (sp)+, rl_gre
                rtr


                
* ==== constants and variables ====

msg_group_4     dc.b    'group 4',0


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
