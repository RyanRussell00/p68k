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
                
* 16 groups, one group for every combo of the first 4 bits of an opcode
* example: if the opcode starts with 0011, it belongs in group 3
* need to jump to the subroutine for a specific group
* a jump table stores locations of the subroutines for every group

                move.w  (a0), d7 * get the opcode data itself
                rol.w   #$4, d7 * move bits 15-12 to bits 3-0
                andi.w  #%1111, d7 * clear bits 15-4
                
                * multiply by 4 because each index is 4 bytes apart
                mulu    #$4, d7
                lea     groups, a6 * load jump table first index
                
                * not using bsr because jsr allows EA modes
                jsr     $0(a6,d7.w) * table->(group number x 4)
                
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
                
                bsr     op_move * MOVE.B
                
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
                
                move.w  (a0), d7 * get the opcode data itself
                andi.w  #%111000000, d7 * clear all bits except 8-6
                cmpi.w  #%001000000, d7 * check if bits 8-6 are 001
                bne     gr2_skip1 * if not equal, skip to MOVE opcode
                
                bsr     op_movea * if equal, it is MOVEA.L
                bra     read_gr2_x * after MOVEA, go to subroutine exit
                
gr2_skip1       bsr     op_move * if not equal, it is MOVE.L
                
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
                
                move.w  (a0), d7 * get the opcode data itself
                andi.w  #%111000000, d7 * clear all bits except 8-6
                cmpi.w  #%001000000, d7 * check if bits 8-6 are 001
                bne     gr3_skip1 * if not equal, skip to MOVE opcode
                
                bsr     op_movea * if equal, it is MOVEA.W
                bra     read_gr3_x * after MOVEA, go to subroutine exit
                
gr3_skip1       bsr     op_move * if not equal, it is MOVE.W
                
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
                
                * NOP recognition
                cmpi.w  #$4e71, d7 * check if the opcode is NOP
                bne     gr4_skip1 * if not, skip the NOP subroutine
                bsr     op_nop
                bra     read_gr4_x * leave after detecting NOP
                
gr4_skip1:      * RTS recognition
                cmpi.w  #$4e75, d7 * check if the opcode is RTS
                bne     gr4_skip2 * if not, skip the RTS subroutine
                bsr     op_rts
                bra     read_gr4_x * leave after detecting RTS
                
gr4_skip2:      
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


* ==== jump tables ====

jump_notfound   jmp     op_notfound
* jumping direcctly to op_notfound will ruin the table address alignment
* it seems that jumping forward adds 4 extra bytes to the opcode
* but jumping backwards only adds 2 extra bytes

groups:         jmp     jump_notfound   * group 0 not needed
                jmp     read_gr1        * group 1
                jmp     read_gr2        * group 2
                jmp     read_gr3        * group 3
                jmp     read_gr4        * group 4
                jmp     read_gr5        * group 5
                jmp     read_gr6        * group 6
                jmp     read_gr7        * group 7
                jmp     read_gr8        * group 8
                jmp     read_gr9        * group 9
                jmp     jump_notfound   * group A not needed
                jmp     jump_notfound   * group B not needed
                jmp     read_grc        * group C
                jmp     read_grd        * group D
                jmp     read_gre        * group E
                jmp     jump_notfound   * group F not needed
                
* ==== constants and variables ====

msg_group_4     dc.b    'group 4',0









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
