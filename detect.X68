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
                
gr4_skip1:      * MOVEM recognition
                move.w  d7, d6
                andi.w  #%101110000000, d6 * clear all bits but 11, 9-7
                cmpi.w  #%100010000000, d6 * check if bit 11 = 1, bits 9-7 = 001
                bne     gr4_skip2 * if not, skip the MOVEM subroutine
                bsr     op_movem
                bra     read_gr4_x
                
gr4_skip2:      * LEA recognition
                move.w  d7, d6
                andi.w  #%111000000, d6 * clear all bits but 8-6
                cmpi.w  #%111000000, d6 * check if bits 8-6 = 111
                bne     gr4_skip3
                bsr     op_lea
                bra     read_gr4_x

gr4_skip3:      * NOT recognition
                move.w  d7, d6
                andi.w  #%111100000000, d6 * clear all bits but 11-8
                cmpi.w  #%011000000000, d6 * check if bits 11-8 = 0110
                bne     gr4_skip4
                
                move.w  d7, d6
                andi.w  #%11000000, d6 * clear all bits but 7-6
                cmpi.w  #%11000000, d6 * check if bits 7-6 = 11
                * if bits 7-6 are 11, it's not NOT
                beq     gr4_skip4
                
                bsr     op_not
                bra     read_gr4_x

gr4_skip4:      * JSR recognition
                move.w  d7, d6
                andi.w  #%111111000000, d6 * clear all bits but 11-6
                cmpi.w  #%111010000000, d6 * check if bits 11-6 = 111010
                bne     gr4_skip5
                bsr     op_jsr
                bra     read_gr4_x

gr4_skip5:      * RTS recognition
                cmpi.w  #$4e75, d7 * check if the opcode is RTS
                bne     gr4_skip6 * if not, skip the RTS subroutine
                bsr     op_rts
                bra     read_gr4_x
                
gr4_skip6:
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
                
                move.w  (a0), d7
                
                * ADDQ recognition
                btst.l  #8, d7 * test bit 8
                bne     gr5_skip1 * skip to DATA if it's %1
                
                andi.b  #%11000000, d7 * clear all bits but 7-6
                cmpi.b  #%11000000, d7 * check if bits 7-6 = %11
                * if bits 7-6 = %11, it's not ADDQ
                beq     gr5_skip1
                
                bsr     op_addq
                bra     read_gr5_x
                
gr5_skip1:
                bsr     op_notfound
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
                
                move.w  (a0), d7
                
                * BRA recognition
                andi.w  #%0000111100000000, d7 * clear all bits but 11-8
                cmpi.w  #%0, d7 * check if bits 11-8 = 0000
                bne     gr6_skip1
                bsr     op_bcc *bcc handles printing bra as well
                bra     read_gr6_x
                
gr6_skip1:      * Bcc recognition
                cmpi.w  #%0000000100000000, d7 * check if bits 11-8 are = 0001
                * if bits 11-8 are 0001, it's not Bcc but actually BSR
                beq     op_notfound * notice how it's beq, not bne
                bsr     op_bcc
                bra     read_gr6_x
                
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
                
                move.w  (a0), d7
                
                * MOVEQ recognition
                andi.w  #%100000000, d7 * clear all bits but 8
                cmpi.w  #%0, d7 * check if bit 8 = 0
                bne     gr7_skip1
                bsr     op_moveq
                bra     read_gr7_x
                
gr7_skip1:
                bsr     op_notfound
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
                
                move.w  (a0), d7
                
                * OR recognition
                move.w  d7, d6
                andi.w  #%11000000, d6 * clear all bits but 7-6
                cmpi.w  #%11000000, d6 * check if bits 7-6 are = 11
                * if bits 7-6 are 11, it's not OR
                beq     gr8_skip1
                * but wait, there's more!
                
                move.w  d7, d6
                andi.w  #%111110000, d6 * clear all bits but 8-4
                cmpi.w  #%100000000, d6 * check if bits 8-4 are = 10000
                * if bits 8-4 are 10000, it's not OR
                beq     gr8_skip1
                
                * okay, now it is OR for sure
                bsr     op_or
                bra     read_gr8_x
                
gr8_skip1:
                bsr     op_notfound
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
                
                move.w  (a0), d7
                
                * SUB recognition
                move.w  d7, d6
                andi.w  #%100110000, d6 * clear all bits but 8, 5-4
                cmpi.w  #%100000000, d6 * check if bit 8 = 1, bits 5-4 = 00
                * if bit 8 = 1 and bits 5-4 = 00, it's not SUB
                beq     gr9_skip1
                
                move.w  d7, d6
                andi.w  #%11000000, d6 * clear all bits but 7-6
                cmpi.w  #%11000000, d6 * check if bits 7-6 = 11
                * if bits 7-6 = 11, it's not SUB
                beq     gr9_skip1
                
                bsr     op_sub
                bra     read_gr9_x
                
gr9_skip1:
                bsr     op_notfound
                
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
                
                move.w  (a0), d7
                
                * AND recognition
                move.w  d7, d6
                andi.w  #%11000000, d6 * clear all bits but 7-6
                cmpi.w  #%11000000, d6 * check if bits 7-6 are = 11
                * if bits 7-6 are 11, it's not AND
                beq     grc_skip1
                * but wait, there's more!
                
                move.w  d7, d6
                andi.w  #%100110000, d6 * clear all bits but 8, 5-4
                cmpi.w  #%100000000, d6 * check if bit 8 = 1, bits 5-4 = 00
                * if bit 8 = 1 and bits 5-4 = 00, it's not AND
                beq     grc_skip1
                
                bsr     op_and
                bra     read_grc_x
                
grc_skip1:
                bsr     op_notfound
                
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
                
                move.w  (a0), d7
                
                * ADDA recognition
                move.w  d7, d6
                andi.w  #%11000000, d6 * clear all bits but 7-6
                cmpi.w  #%11000000, d6 * check if bits 7-6 are = 11
                bne     grd_skip1
                bsr     op_adda * it's ADDA
                bra     read_grd_x
                
grd_skip1:      * ADD recognition
                move.w  d7, d6
                andi.w  #%100110000, d6 * clear all bits but 8, 5-4
                cmpi.w  #%100000000, d6 * check if bit 8 = 1, bits 5-4 = 00
                * if bit 8 = 1 and bits 5-4 = 00, it's not ADD
                beq     grd_skip2
                
                bsr     op_add
                bra     read_grd_x
                
grd_skip2:
                bsr     op_notfound
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
                
                move.w  (a0), d7
                
                * ROXd rejection
                move.w  d7, d6
                andi.w  #%0000111011000000, d6 * clear all bits but 11-9, 7-6
                cmpi.w  #%0000010011000000, d6 * check if bits 11-9 = 010, bits 7-6 = 11
                * if bits 11-9 = 010 and bits 7-6 = 11,
                * ignore because it's ROXd which is unsupported
                beq     gre_skip3
                *second condition that could be ROXd when bits 7-6 != 11 and bits 4-3 = 10
                move.w  d7, d6
                *check for bits 7-6 != 11 first
                andi.w  #%0000000011000000, d6 * clear all bits but 7-6
                cmpi.w  #%0000000011000000, d6 *if 11, it is not ROXd
                beq     gre_skip0   *since it is 11, it can not be ROXd
                *if not 11, then check bits 4-3 for 10
                move.w  d7, d6
                andi.w  #%0000000000011000, d6
                cmpi.w  #%0000000000010000, d6
                beq     gre_skip3   *if bits 3-4 are 10, then we have ROXd which is not supported
gre_skip0:
                * ROd detection
                move.w  d7, d6
                andi.w  #%111011000000, d6 * clear all bits but 11-9, 7-6
                cmpi.w  #%011011000000, d6 * check if bits 11-9 = 011, bits 7-6 = 11
                bne     gre_skip1
                bsr     op_rod * it's ROd
                bra     read_gre_x
                
gre_skip1:      
                * Second ROd detection
                * ROd happens when bits 7-6 != 11 and 4-3 = 11
                move.w  d7, d6
                andi.w  #%11000000, d6 * clear all bits but 7-6
                cmpi.w  #%11000000, d6 * check if bits 4-3 = 11
                beq     gre_skip2 *since bits 7-6 = 11 and it didnt meet ROd first test above, its shift
                
                *if bits 7-6 != 11, check if bits 4-3 = 11
                move.w  d7, d6
                andi.w  #%11000, d6
                cmpi.w  #%11000, d6
                *if bits 4-3 = 11 we have ROd, else: shift
                bne     gre_skip2   *if 4-3 != 11, go to shift
                bsr     op_rod * it's ROd
                bra     read_gre_x

gre_skip2:                
                bsr     op_xsd
                bra     read_gre_x
                
gre_skip3:
                bsr     op_notfound
                
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
