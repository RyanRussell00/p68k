* 
* Subroutines to handle every opcode.
*

* ==== validation subroutines ====

*-----------------------------------------------------------
* //// validate EA mode against opcode
* parameters:
*   d5 - EA mode (bits 3-5) and register (bits 0-2)
*   d6 - byte for EA mode list, lists all allowed EA modes
* return:
*   d7 - byte is $FF if the EA mode is valid, $00 if invalid
*
rl_v_ea         reg     a0-a6/d0-d6
valid_ea        move.w  sr, -(sp)
                movem.l rl_v_ea, -(sp)
* ---- subroutine code:
                
                andi.b  #%111111, d5 * keep only last 6 bits
                
                cmpi.b  #%111000, d5 * absolute word
                beq     mode_abs_w
                cmpi.b  #%111001, d5 * absolute long
                beq     mode_abs_l
                cmpi.b  #%111100, d5 * immediate data
                beq     mode_imm
                
                lsr.b   #3, d5 * move EA mode to last 3 bits
                
                cmpi.b  #%000, d5 * datareg direct
                beq     mode_dn
                cmpi.b  #%001, d5 * addreg direct
                beq     mode_an
                cmpi.b  #%010, d5 * addreg indirect
                beq     mode_ani
                cmpi.b  #%011, d5 * addreg indirect with postinc
                beq     mode_ani_psi
                cmpi.b  #%100, d5 * addreg indirect with predec
                beq     mode_ani_prd
                
                sf      d7 * set result to invalid
                bra valid_ea_x * valid mode not found
                
mode_dn         lsl.b   #1, d6
                scs     d7
                bra     valid_ea_x
                
mode_an         lsl.b   #2, d6
                scs     d7
                bra     valid_ea_x
                
mode_ani        lsl.b   #3, d6
                scs     d7
                bra     valid_ea_x
                
mode_ani_psi    lsl.b   #4, d6
                scs     d7
                bra     valid_ea_x
                
mode_ani_prd    lsl.b   #5, d6
                scs     d7
                bra     valid_ea_x
                
mode_abs_w      lsl.b   #6, d6
                scs     d7
                bra     valid_ea_x
                
mode_abs_l      lsl.b   #7, d6
                scs     d7
                bra     valid_ea_x
                
mode_imm        lsl.b   #8, d6
                scs     d7
                bra     valid_ea_x
                
* ---- exit        
valid_ea_x      movem.l (sp)+, rl_v_ea
                rtr

*-----------------------------------------------------------
* //// validate two EA modes at once, source and destination
* parameters:
*   d3 - source mode (bits 3-5) and register (bits 0-2)
*   d4 - source mode list, byte
*   d5 - destination mode (bits 3-5) and register (bits 0-2)
*   d6 - destination mode list, byte
* return:
*   d7 - byte is $FF if both valid, $00 if either are invalid
*
rl_valid_both   reg     a0-a6/d0-d6
valid_both      move.w  sr, -(sp)
                movem.l rl_valid_both, -(sp)
* ---- subroutine code:
                
                bsr     valid_ea * validate destination
                move.b  d7, d0 * save first result
                
                move.b  d3, d5 * prepare source mode/reg
                move.b  d4, d5 * prepare source mode list
                
                bsr     valid_ea * validate source
                
                * AND the results of both validations
                and.b    d0, d7 * store result in d7
                
* ---- exit
valid_both_x    movem.l (sp)+, rl_valid_both
                rtr


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
                
                move.b  #14, d0
                lea     msg_move, a1
                trap    #15
                
                * print addressing modes
                
                * get destination. EA Printer parameters expect Mode then Register
                move.w  (a0), d1    * load instruction into data reg
                clr.l   d6
                clr.l   d2          * temp register
                move.w  d1, d6      * prepare destination parameter
                move.w  d1, d2      * copy to temp register
                and.l   #%0000000111000000, d6  * clear everything but destination mode
                lsr.l   #3, d6      * shift right to move the destination mode 3 from the end
                and.l   #%0000111000000000, d2  * get destination register
                move.l  #9, d3
                lsr.l   d3, d2      * shift right to get destination register at end
                add.l   d2, d6      * combine destination mode and regiser
                
                * get source EA
                clr     d7
                move.w  d1, d7      * load instruction into source EA parameter
                and     #%0000000000111111, d7  * get source ea
                
                * At this point: d7 contains source EA and d6 contains destination EA
                * we set d5 = 1 since we have to print destination and source
                move.l  #1, d5
                
                bsr     printer     * execute EA printer
                
                bsr     print_nl    * print line break
                
                addq    #$2, a0     * go to next opcode word
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
                
                move.b  #14, d0
                lea     msg_moveq, a1
                trap    #15
                
                bsr     print_space
                
                *get data register number
                clr     d7
                move.w  (a0), d7
                andi    #%0000111000000000, d7
                rol.w   #7, d7  *rotate to left to get register number at end
              
                bsr     moveq_printer
                
                bsr     print_nl
                
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
                
                move.b  #14, d0
                lea     msg_movem, a1
                trap    #15
                
                clr     d7      *ea printer parameter for ea
                clr     d1      *temp register
                move.w  (a0), d1
                *mask to get effective addressing mode
                move.l  d1, d7  *set parameter
                and     #%0000000000111111, d7  *mask to get ea of movem
                
                *get direction
                clr     d6      *direction parameter
                move.l  d1, d6
                and     #%0000010000000000, d6  *mask to get direction
                rol     #6, d6  *rotate left 6 times to get direction at the end     

                bsr     movem_printer
                
                bsr     print_nl *print line break
                
                addq    #$4, a0 *add 4 to skip after data word
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
                
                move.b  #14, d0
                lea     msg_movea, a1
                trap    #15
                
                *print addressing modes
                
                *get destination. EA Printer parameters expect Mode then Register
                move.w  (a0), d1    *load instruction into data reg
                clr     d2          *temp
                move.l  #%001000, d6 *set destination mode to address register
                move.w  d1, d2     
                and.l   #%0000111000000000, d2  *clear everything but destination register
                move.l  #9, d3
                lsr     d3, d2      *shift right to get destination register at end
                add     d2, d6      *combine destination mode and regiser
                
                *get source EA
                clr     d7
                move.w  d1, d7      *load instruction into source EA parameter
                and     #%0000000000111111, d7  *get source ea
                
                *At this point: d7 contains source EA and d6 contains destination EA
                *we set d5 = 1 since we have to print destination and source
                move.l  #1, d5
                
                bsr     printer     *execute EA printer
                
                bsr     print_nl    *print line break
                
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
                
                move.b  #14, d0
                lea     msg_add, a1
                trap    #15
                
                *if direction is 0, the Dn is destination
                clr     d1  *temp
                clr     d7  *parameters for printer
                clr     d6
                clr     d5
                move.l  #%1, d5 *set printing destination true
                *get source and destination
                *get data register at bits 9-11
                move.w  (a0), d7
                andi.l  #%0000111000000000, d7
                *rotate left 7 times to get data reg bits at end
                rol.w   #7, d7
                
                *get EA bits 0-5
                move.w  (a0), d6
                andi.l  #%0000000000111111, d6
                
                *check direction
                move.w  (a0), d1
                andi.l  #%0000000100000000, d1 *mask to get direction
                cmpi.l  #%0000000000000000, d1 *check if direction is 1
                bne     print_add   *if not 1, go to print add
                       
                *if direction is 1, flip d7 and d6
                clr     d4
                move.l  d7, d4
                move.l  d6, d7
                move.l  d4, d6
                
print_add       
                bsr     printer
                
                bsr     print_nl    *print line break
                
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
                
                move.b  #14, d0
                lea     msg_adda, a1
                trap    #15
                              
                clr     d7  *parameters for printer
                clr     d6
                clr     d5
                move.l  #%1, d5 *set printing destination true
                *get source and destination
                *get data register at bits 9-11
                move.w  (a0), d6
                andi.l  #%0001111000000000, d6 *get the 3 bits of the address reg
                * and the last bit of the instruction group to identify it as An
                
                *rotate left 7 times to get data reg bits at end
                rol.w   #7, d6                
                
                *get EA bits 0-5
                move.w  (a0), d7
                andi.l  #%0000000000111111, d7

                bsr     printer
                
                bsr     print_nl
                
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
                
                move.b  #14, d0
                lea     msg_addq, a1
                trap    #15
                
                bsr     print_space
                
                clr     d7
                move.w  (a0), d7
                andi    #%0000000000111111, d7
                
                bsr     addq_printer
                
                bsr     print_nl
                
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
                
                move.b  #14, d0
                lea     msg_sub, a1
                trap    #15
                
                *if direction is 0, the Dn is destination
                clr     d1  *temp
                clr     d7  *parameters for printer
                clr     d6
                clr     d5
                move.l  #%1, d5 *set printing destination true
                *get source and destination
                *get data register at bits 9-11
                move.w  (a0), d7
                andi.l  #%0000111000000000, d7
                *rotate left 7 times to get data reg bits at end
                rol.w   #7, d7
                
                *get EA bits 0-5
                move.w  (a0), d6
                andi.l  #%0000000000111111, d6
                
                *check direction
                move.w  (a0), d1
                andi.l  #%0000000100000000, d1 *mask to get direction
                cmpi.l  #%0000000000000000, d1 *check if direction is 1
                bne     print_sub   *if not 1, go to print add
                       
                *if direction is 1, flip d7 and d6
                clr     d4
                move.l  d7, d4
                move.l  d6, d7
                move.l  d4, d6
                
print_sub       
                bsr     printer
                bsr     print_nl    *print line break
                
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
                
                move.b  #14, d0
                lea     msg_lea, a1
                trap    #15
                
                clr     d7
                clr     d6
                clr     d5
                move.l  #1, d5 *set destination print = true
                
                *get source (bits 0 - 5)
                move.w  (a0), d7
                andi    #%0000000000111111, d7
                
                *get destination (bits 9-11)
                *since it always address register we need to manually set reg mode
                move.w  (a0), d6
                andi    #%0000111000000000, d6
                rol.w   #4, d6  *rotate to get the reg bits as MSB
                add     #%1, d6 *add 1 to indicate An reg mode
                rol.w   #3, d6  *rotate to get the reg bits as LSB
                
                bsr     printer
                bsr     print_nl
                
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
                
                move.b  #14, d0
                lea     msg_and, a1
                trap    #15
                
                *if direction is 0, the Dn is destination
                clr     d1  *temp
                clr     d7  *parameters for printer
                clr     d6
                clr     d5
                move.l  #%1, d5 *set printing destination true
                *get source and destination
                *get data register at bits 9-11
                move.w  (a0), d7
                andi.l  #%0000111000000000, d7
                *rotate left 7 times to get data reg bits at end
                rol.w   #7, d7
                
                *get EA bits 0-5
                move.w  (a0), d6
                andi.l  #%0000000000111111, d6
                
                *check direction
                move.w  (a0), d1
                andi.l  #%0000000100000000, d1 *mask to get direction
                cmpi.l  #%0000000000000000, d1 *check if direction is 0
                bne     print_and   *if not 1, go to print and
                       
                *if direction is 1, flip d7 and d6
                clr     d4
                move.l  d7, d4
                move.l  d6, d7
                move.l  d4, d6
                
print_and       
                bsr     printer
                
                bsr     print_nl    *print line break

                
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
                
                move.b  #14, d0
                lea     msg_or, a1
                trap    #15
                
                clr     d1  *temp
                clr     d7  *parameters for printer
                clr     d6
                clr     d5
                move.l  #%1, d5 *set printing destination true
                *get source and destination
                *get data register at bits 9-11
                move.w  (a0), d7
                andi.l  #%0000111000000000, d7
                *rotate left 7 times to get data reg bits at end
                rol.w   #7, d7
                
                *get EA bits 0-5
                move.w  (a0), d6
                andi.l  #%0000000000111111, d6
                
                *check direction
                move.w  (a0), d1
                andi.l  #%0000000100000000, d1 *mask to get direction
                cmpi.l  #%0000000000000000, d1 *check if direction is 1
                bne     print_or   *if not 1, go to print add
                       
                *if direction is 1, flip d7 and d6
                clr     d4
                move.l  d7, d4
                move.l  d6, d7
                move.l  d4, d6
                
print_or       
                bsr     printer
                bsr     print_nl    *print line break
                
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
                
                move.b  #14, d0
                lea     msg_not, a1
                trap    #15
                
                clr     d7
                clr     d5  *set print destination = false
                move.w  (a0), d7
                andi    #%0000000000111111, d7 *mask to get bits 0-5
                
                bsr     printer
                bsr     print_nl
                
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
                
                move.b  #14, d0
                lea     msg_xsd, a1
                trap    #15
                
                * ToDo: Op printing and EA printing
                
                *if bits 3 and 4 hold 1 and 0, respectively, we are shifting immediate
                clr     d7 *print param
                clr     d5 *print param
                clr     d3 *temp
                move.w  (a0), d3
                *if bits 7-6 = 11 then we are only printing 1 EA
                andi.b  #%11000000, d3
                cmpi.b  #%11000000, d3
                beq     xsd_one_bit
                
                *if not printing shift by 1, go to printer subroutine to handle printing
                bsr     shift_rotate_printer
                bsr     print_nl
                
xsd_one_bit     *print only 1 EA since shifting by 1 bit
                move.w  (a0), d7
                andi.b  #%00111111, d7 *only get last 6 bits
                bra     printer
                bsr     print_nl
                
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
                
                * ToDo: Op printing and EA printing
                
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
                
                move.b  #14, d0
                lea     msg_bcc, a1
                trap    #15
                
                * ToDo: Op printing
                
                bsr     bcc_printer
                bsr     print_nl
                
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
                
                move.b  #14, d0
                lea     msg_jsr, a1
                trap    #15
                
                clr     d7
                move.w  (a0), d7
                andi.w  #%0000000000111111, d7 *get EA mode and reg
                
                bsr     printer
                
                bsr     print_nl
                
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
*reglist_bra     reg     a1-a6/d0-d7
*op_bra          move.w  sr, -(sp)
*                movem.l reglist_bra, -(sp)
** ---- handle the opcode:
*                
*                *ToDo: BRA should be incorporated into the BCC subroutine
*
*                move.b  #13, d0
*                lea     msg_bra, a1
*                trap    #15
*                
*                addq    #$2, a0
** ---- exit                
*op_bra_x        movem.l (sp)+, reglist_bra
*                rtr

* ==== constants and variables ====

* messages
msg_data        dc.w    'DATA',0
msg_nop         dc.w    'NOP',0
msg_move        dc.w    'MOVE',0
msg_moveq       dc.w    'MOVEQ',0
msg_movem       dc.w    'MOVEM',0
msg_movea       dc.w    'MOVEA',0
msg_add         dc.w    'ADD',0
msg_adda        dc.w    'ADDA',0
msg_addq        dc.w    'ADDQ',0
msg_sub         dc.w    'SUB',0
msg_lea         dc.w    'LEA',0
msg_and         dc.w    'AND',0
msg_or          dc.w    'OR',0
msg_not         dc.w    'NOT',0
msg_xsd         dc.w    'xSd',0
msg_rod         dc.w    'ROd',0
msg_bcc         dc.w    'Bcc',0
msg_jsr         dc.w    'JSR',0
msg_rts         dc.w    'RTS',0
msg_bra         dc.w    'BRA',0

* EA validation list style, byte bits 7->0:
*   bit 7: Dn
*   bit 6: An
*   bit 5: (An)
*   bit 4: (An)+
*   bit 3: -(An)
*   bit 2: abs.W
*   bit 1: abs.L
*   bit 0: #imm

* EA validation source lists
ea_move_s       dc.b    %11111111
ea_movea_s      dc.b    %11111111
ea_movem_s      dc.b    %00110110
ea_lea_s        dc.b    %00100110
ea_not_s        dc.b    %10111110
ea_jsr_s        dc.b    %00100110
ea_or_s         dc.b    %10111111
ea_sub_s        dc.b    %11111111
ea_and_s        dc.b    %10111111
ea_add_s        dc.b    %11111111
ea_adda_s       dc.b    %11111111

* EA validation destination lists
ea_move_d       dc.b    %10111110
ea_movem_d      dc.b    %00101110
ea_addq_d       dc.b    %11111110
ea_or_d         dc.b    %10111110
ea_sub_d        dc.b    %10111110
ea_and_d        dc.b    %10111110
ea_add_d        dc.b    %10111110
ea_lsd_d        dc.b    %10111110
ea_asd_d        dc.b    %10111110
ea_rod_d        dc.b    %10111110

* ==== included files ====
                include "addressing.X68"













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
