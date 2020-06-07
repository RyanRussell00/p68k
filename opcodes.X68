* 
* Subroutines to handle every opcode.
*

* ==== EA pre-processing subroutines ====

*-----------------------------------------------------------
* //// handle EA mode
* parameters:
*   d7 - 6 bit binary string that holds the SOURCE op mode/register
*   d6 - 6 bit binary string that holds the DESTINATION op mode/register
*   d5 - set to 1 if destination ea exists, set to 0 otherwise
*   d4 - instruction size: 0 for byte, 1 for word, 2 for long
*   d3 - valid EA source list
*   d2 - valid EA destination list
*   a0 - address of the opcode we are looking at
* return:
*   a0 - address offset from original opcode in case of extra words
*
rl_handle_ea    reg     a1-a6/d0-d7
handle_ea       move.w  sr, -(sp)
                movem.l rl_handle_ea, -(sp)
* ---- subroutine code:
                
                bsr     valid_both
                bsr     printer
                bsr     print_nl
                
* ---- exit                
handle_ea_x     movem.l (sp)+, rl_handle_ea
                rtr
                
*-----------------------------------------------------------
* //// validate EA mode against opcode
* parameters:
*   d7 - EA mode (bits 3-5) and register (bits 0-2)
*   d3 - byte for EA mode list, lists all allowed EA modes
* return:
*   d1 - byte is $FF if the EA mode is valid, $00 if invalid
*
rl_v_ea         reg     a0-a6/d0/d2-d7
valid_ea        move.w  sr, -(sp)
                movem.l rl_v_ea, -(sp)
* ---- subroutine code:
                
                andi.b  #%111111, d7 * keep only last 6 bits
                
                cmpi.b  #%111000, d7 * absolute word
                beq     mode_abs_w
                cmpi.b  #%111001, d7 * absolute long
                beq     mode_abs_l
                cmpi.b  #%111100, d7 * immediate data
                beq     mode_imm
                
                lsr.b   #3, d7 * move EA mode to last 3 bits
                
                cmpi.b  #%000, d7 * datareg direct
                beq     mode_dn
                cmpi.b  #%001, d7 * addreg direct
                beq     mode_an
                cmpi.b  #%010, d7 * addreg indirect
                beq     mode_ani
                cmpi.b  #%011, d7 * addreg indirect with postinc
                beq     mode_ani_psi
                cmpi.b  #%100, d7 * addreg indirect with predec
                beq     mode_ani_prd
                
                sf      d1 * set result to invalid
                bra valid_ea_x * valid mode not found
                
mode_dn         lsl.b   #1, d3
                scs     d1
                bra     valid_ea_x
                
mode_an         lsl.b   #2, d3
                scs     d1
                bra     valid_ea_x
                
mode_ani        lsl.b   #3, d3
                scs     d1
                bra     valid_ea_x
                
mode_ani_psi    lsl.b   #4, d3
                scs     d1
                bra     valid_ea_x
                
mode_ani_prd    lsl.b   #5, d3
                scs     d1
                bra     valid_ea_x
                
mode_abs_w      lsl.b   #6, d3
                scs     d1
                bra     valid_ea_x
                
mode_abs_l      lsl.b   #7, d3
                scs     d1
                bra     valid_ea_x
                
mode_imm        lsl.b   #8, d3
                scs     d1
                bra     valid_ea_x
                
* ---- exit        
valid_ea_x      movem.l (sp)+, rl_v_ea
                rtr

*-----------------------------------------------------------
* //// validate two EA modes at once, source and destination
* parameters:
*   d7 - source mode (bits 3-5) and register (bits 0-2)
*   d6 - destination mode (bits 3-5) and register (bits 0-2)
*   d5 - set to 1 if destination ea exists, set to 0 otherwise
*   d3 - source mode list, byte
*   d2 - destination mode list, byte
* return:
*   d7 - original source mode or %111111 if invalid
*   d6 - original dest mode or %111111 if invalid
*
rl_valid_both   reg     a0-a6/d0-d5
valid_both      move.w  sr, -(sp)
                movem.l rl_valid_both, -(sp)
* ---- subroutine code:
                
                bsr     valid_ea * validate source
                cmpi.b  #$FF, d1
                beq     source_good
                move.b  #%111111, d7 * invalid EA, set mode/reg to all 1s
                
source_good     cmpi.b  #1, d5
                bne     valid_both_x
                
                exg     d6, d7 * swap source and dest modes/regs
                exg     d2, d3 * swap source and dest mode lists
                
                bsr     valid_ea * validate dest
                cmpi.b  #$FF, d1
                beq     dest_good
                move.b  #%111111, d7 * invalid EA, set mode/reg to all 1s
                
dest_good       exg     d6, d7 * swap back parameters
                exg     d2, d3
                
* ---- exit
valid_both_x    movem.l (sp)+, rl_valid_both
                rtr

* ==== utility subroutines ====

*-----------------------------------------------------------
* //// print instruction size
* parameters:
*   d4 - %00 for B, %01 for W, %10 for L
* return:
*   none
*
rl_print_size   reg     a0-a6/d0-d7
print_size      move.w  sr, -(sp)
                movem.l rl_print_size, -(sp)
* ---- subroutine code:
                
                move.b  #14, d0 * for printing without newline
                andi.b  #%11, d4 * keep only last 2 bits
                
                cmpi.b  #%10, d4
                bne     size_not_long
                
                lea     msg_size_l, a1 * print .L
                trap    #15
                bra     print_size_x
                
size_not_long   cmpi.b  #%01, d4
                bne     size_not_word
                
                lea     msg_size_w, a1 * print .W
                trap    #15
                bra     print_size_x
                
size_not_word   lea     msg_size_b, a1 * print .B
                trap    #15
                
* ---- exit
print_size_x    movem.l (sp)+, rl_print_size
                rtr

*-----------------------------------------------------------
* //// print instruction size for MOVE
* parameters:
*   d4 - %01 for B, %11 for W, %10 for L
* return:
*   d4 - translated size: %00 for B, %01 for W, %10 for L
*
rl_print_m_s    reg     a0-a6/d0-d3/d5-d7
print_mv_size   move.w  sr, -(sp)
                movem.l rl_print_m_s, -(sp)
* ---- subroutine code:
                
                andi.b  #%11, d4 * leave only last 2 bits
                
                cmpi.b  #%10, d4
                beq     go_print_size * size is MOVE.L
                
                cmpi.b  #%11, d4
                bne     mv_size_b
                
                move.b  #%01, d4 * size is MOVE.W
                bra     go_print_size
                
mv_size_b       move.b  #%00, d4 * size is MOVE.B
                
                * note: MOVE will never send a bad size
                * because opcode detection would not allow it
                
go_print_size   bsr     print_size
                
* ---- exit
print_mv_size_x movem.l (sp)+, rl_print_m_s
                rtr

*-----------------------------------------------------------
* //// print Bcc operator: BGT, BLE, BEQ, or BRA
* parameters:
*   d4 - entire Bcc instruction word
* return:
*   d3 - byte is $00 if success, $FF for failure
*
rl_pr_bcc_op    reg     a0-a6/d0-d2/d4-d7
print_bcc_op    move.w  sr, -(sp)
                movem.l rl_pr_bcc_op, -(sp)
* ---- subroutine code:
                
                sf      d3 * set result to valid
                move.b  #14, d0 * setup printing without newline
                
                rol.w   #8, d4 * move condition to last 4 bits
                andi.b  #%1111, d4 * keep only last 4 bits
                
                cmpi.b  #%0000, d4 * BRA
                bne     try_bgt
                lea     msg_bra, a1
                bra     bcc_trap
                
try_bgt         cmpi.b  #%1110, d4 * BGT
                bne     try_ble
                lea     msg_bgt, a1
                bra     bcc_trap
                
try_ble         cmpi.b  #%1111, d4 * BLE
                bne     try_beq
                lea     msg_ble, a1
                bra     bcc_trap
                
try_beq         cmpi.b  #%0111, d4 * BEQ
                bne     bcc_invalid
                lea     msg_beq, a1
                bra     bcc_trap

bcc_invalid     st      d3 * set result to invalid
                bra     print_bcc_op_x

bcc_trap        trap    #15
                
* ---- exit
print_bcc_op_x  movem.l (sp)+, rl_pr_bcc_op
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
                
                bsr     font_blue
                move.b  #14, d0
                lea     msg_data, a1
                trap    #15
                bsr     font_white
                
                bsr     print_space
                move.b  #14, d0
                lea     dollar_sign, a1
                trap    #15
                
                move.w  (a0), d1 * prepare data word for printing
                bsr     print_hex_w
                bsr     print_nl
                
                addq.w  #$2, a0 * move to next opcode word
                
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
                
                addq.w  #$2, a0
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
                
                * printing the size of MOVE
                move.w  (a0), d4
                rol.w   #4, d4 * rotate size bits to the last 2 bits
                bsr     print_mv_size
                
                * get destination. EA Printer parameters expect Mode then Register
                move.w  (a0), d1    * load instruction into data reg
                move.w  d1, d6      * prepare destination parameter
                move.w  d1, d2      * copy to temp register
                and.w   #%0000000111000000, d6  * clear everything but destination mode
                lsr.w   #3, d6      * shift right to move the destination mode 3 from the end
                and.w   #%0000111000000000, d2  * get destination register
                lsr.w   #1, d2
                lsr.w   #8, d2      * shift right to get destination register at end
                add.w   d2, d6      * combine destination mode and register
                
                * get source EA
                move.w  d1, d7      * load instruction into source EA parameter
                and.w   #%0000000000111111, d7  * get source EA
                
                * At this point: d7 contains source EA and d6 contains destination EA
                * we set d5 = 1 since we have to print destination and source
                move.l  #1, d5
                
                move.b  (ea_move_s), d3
                move.b  (ea_move_d), d2
                bsr     handle_ea
                
                addq.w  #$2, a0     * go to next opcode word
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
                
                addq.w  #$2, a0
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
                
                * size printing:
                move.w  (a0), d1
                btst.l  #6, d1 * test bit 6 for size
                bne     movem_l
                * bit 6 is %0 for .W, %1 for .L
                moveq   #%01, d4 * MOVEM.W
                bsr     print_size
                bra     movem_skip1
                
movem_l         moveq   #%10, d4 * MOVEM.L
                bsr     print_size
                
                * ea printing:
movem_skip1     clr.l   d7      *ea printer parameter for ea
                clr.l   d1      *temp register
                move.w  (a0), d1
                *mask to get effective addressing mode
                move.l  d1, d7  *set parameter
                andi.l  #%0000000000111111, d7  *mask to get ea of movem
                
                *get direction
                move.l  d1, d6 * move into direction parameter
                andi.l  #%0000010000000000, d6  *mask to get direction
                rol.w   #6, d6  *rotate left 6 times to get direction at the end     

                bsr     movem_printer
                bsr     print_nl
                
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
                
                * printing the size of MOVEA
                move.w  (a0), d4
                rol.w   #4, d4 * rotate size bits to the last 2 bits
                bsr     print_mv_size
                
                *print addressing modes
                
                *get destination. EA Printer parameters expect Mode then Register
                move.w  (a0), d1    *load instruction into data reg
                clr.l   d2          *temp
                move.l  #%001000, d6 *set destination mode to address register
                move.w  d1, d2     
                and.l   #%0000111000000000, d2  *clear everything but destination register
                move.l  #9, d3
                lsr.w   d3, d2      *shift right to get destination register at end
                add.w   d2, d6      *combine destination mode and regiser
                
                *get source EA
                clr.l   d7
                move.w  d1, d7      *load instruction into source EA parameter
                and.w   #%0000000000111111, d7  *get source ea
                
                *At this point: d7 contains source EA and d6 contains destination EA
                *we set d5 = 1 since we have to print destination and source
                move.l  #1, d5
                
                move.b  (ea_movea_s), d3
                move.b  (ea_movea_d), d2
                bsr     handle_ea
                
                addq.w  #$2, a0
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
                
                * print size
                move.w  (a0), d4
                lsr.b   #6, d4 * shift size bits to last 2
                bsr     print_size
                
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
                
                move.b  (ea_add_s), d3 * pre-emptively load validation params
                move.b  (ea_add_d), d2
                
                *check direction
                move.w  (a0), d1
                andi.l  #%0000000100000000, d1 *mask to get direction
                cmpi.l  #%0000000000000000, d1 *check if direction is 1
                bne     print_add   *if not 1, go to print add
                       
                *if direction is 1, flip d7 and d6
                exg     d7, d6
                exg     d3, d2 * flip validation params too
                
print_add       bsr     handle_ea
                
                addq.w  #$2, a0
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
                
                * size printing:
                move.w  (a0), d1
                btst.l  #8, d1 * test bit 8 for size
                bne     adda_l
                * bit 8 is %0 for .W, %1 for .L
                moveq   #%01, d4 * ADDA.W
                bsr     print_size
                bra     adda_skip1
                
adda_l          moveq   #%10, d4 * ADDA.L
                bsr     print_size
                
adda_skip1      move.l  #%1, d5 *set printing destination true
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
                
                move.b  (ea_adda_s), d3
                move.b  (ea_adda_d), d2
                bsr     handle_ea
                
                addq.w  #$2, a0
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
                
                * print size
                move.w  (a0), d4
                lsr.b   #6, d4 * shift size bits to last 2
                bsr     print_size
                bsr     print_space
                
                clr     d7
                move.w  (a0), d7
                andi    #%0000000000111111, d7
                
                bsr     addq_printer
                bsr     print_nl
                
                addq.w  #$2, a0
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
                
                * print size
                move.w  (a0), d4
                lsr.b   #6, d4 * shift size bits to last 2
                bsr     print_size
                
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
                
                move.b  (ea_sub_s), d3 * pre-emptively load validation params
                move.b  (ea_sub_d), d2
                
                *check direction
                move.w  (a0), d1
                andi.l  #%0000000100000000, d1 *mask to get direction
                cmpi.l  #%0000000000000000, d1 *check if direction is 1
                bne     print_sub   *if not 1, go to print add
                       
                *if direction is 1, flip d7 and d6
                exg     d7, d6
                exg     d3, d2 * flip validation params
                
print_sub       bsr     handle_ea
                
                addq.w  #$2, a0
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
                
                move.b  (ea_lea_s), d3
                move.b  (ea_lea_d), d2
                bsr     handle_ea
                
                addq.w  #$2, a0
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
                
                move.w  (a0), d4
                lsr.b   #6, d4
                bsr     print_size
                
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
                
                move.b  (ea_and_s), d3
                move.b  (ea_and_d), d2
                
                *check direction
                move.w  (a0), d1
                andi.l  #%0000000100000000, d1 *mask to get direction
                cmpi.l  #%0000000000000000, d1 *check if direction is 0
                bne     print_and   *if not 1, go to print and
                       
                *if direction is 1, flip d7 and d6
                exg     d7, d6
                exg     d3, d2
                
print_and       bsr     handle_ea
                
                addq.w  #$2, a0
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
                
                move.w  (a0), d4
                lsr.b   #6, d4
                bsr     print_size
                
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
                
                move.b  (ea_or_s), d3
                move.b  (ea_or_d), d2
                
                *check direction
                move.w  (a0), d1
                andi.l  #%0000000100000000, d1 *mask to get direction
                cmpi.l  #%0000000000000000, d1 *check if direction is 1
                bne     print_or   *if not 1, go to print add
                       
                *if direction is 1, flip d7 and d6
                exg     d7, d6
                exg     d3, d2
                
print_or        bsr     handle_ea
                
                addq.w  #$2, a0
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
                
                move.w  (a0), d4
                lsr.b   #6, d4
                bsr     print_size
                
                clr     d7
                clr     d5  *set print destination = false
                move.w  (a0), d7
                andi    #%0000000000111111, d7 *mask to get bits 0-5
                
                move.b  (ea_not_s), d3
                bsr     handle_ea
                
                addq.w  #$2, a0
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
              
                *get direction of shift (0 = Right, 1 = Left)
                clr     d2 *temp
                clr     d3 *store direction
                
                move.w  (a0), d3
                andi.w  #%0000000100000000, d3
                *rotate right 8 times to get direction bit as LSB
                asr.w   #8, d3
                *d3 now holds the direction bit
                
                *get type of shift (ASd or LSd)
                move.w  (a0), d2
                move.b  #14, d0 *prepare task trigger
                
                andi.w  #%0000111000000000, d2

print_asd_right
                cmpi.w  #%0, d2 *if 0, printing ASd
                bne     print_lsd_left                
                cmpi.b  #0, d3  *if direction = Right
                bne     print_asd_left
                *print ASR
                lea     msg_asr, a1
                trap    #15
                bra     shift_ea
print_asd_left
                *print ASL
                lea     msg_asl, a1
                trap    #15
                bra     shift_ea
                
print_lsd_left
                cmpi.b  #1, d3  *if direction = Right
                bne     print_lsd_right
                *print LSL
                lea     msg_lsl, a1
                trap    #15
                bra     shift_ea

print_lsd_right
                *print LSR
                lea     msg_lsr, a1
                trap    #15
                bra     shift_ea                
                
shift_ea        
                * before printing EA, print size
                move.w  (a0), d4
                lsr.b   #6, d4 * shift size bits to the last 2
                move.w  d4, d5
                
                andi.b  #%11, d5 * keep only last 2 bits
                cmpi.b  #%11, d5 * check if size = %11, EA shift, .W only
                bne     xsd_datareg
                
                * xSd is shifting an EA, which is .W only
                moveq   #%01, d4 * force print_size to print .W
                bsr     print_size
                bra     xsd_go_print
                
                * otherwise, it's shifting a data register
xsd_datareg     bsr     print_size * called with sizes B, W, L
                
                
                * now EA can be printed
xsd_go_print    bsr     shift_rotate_printer
* ---- exit                
op_xsd_x        addq.w  #$2, a0
                movem.l (sp)+, reglist_xsd
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
                
                move.b  #14, d0 *prepare task trigger
                
                *store direction
                clr     d3
                move.w  (a0), d3
                andi.w  #%0000000100000000, d3
                asr.w   #8, d3
                
                *if 0, print right
                cmpi.b  #0, d3
                bne     rod_left
                lea     msg_ror, a1
                trap    #15
                bra     ror_ea
                
rod_left
                * before printing EA, print size
                lea     msg_rol, a1
                trap    #15
                bra     ror_ea
                
ror_ea          
                move.w  (a0), d4
                lsr.b   #6, d4 * shift size bits to the last 2
                move.w  d4, d5
                
                andi.b  #%11, d5 * keep only last 2 bits
                cmpi.b  #%11, d5 * check if size = %11, EA rotation, .W only
                bne     rod_datareg
                
                * ROd is rotating an EA, which is .W only
                moveq   #%01, d4 * force print_size to print .W
                bsr     print_size
                bra     rod_go_print
                
                * otherwise, it's rotating a data register
rod_datareg     bsr     print_size * called with sizes B, W, L

rod_go_print    bsr     shift_rotate_printer
                
* ---- exit                
op_rod_x        addq.w  #$2, a0
                movem.l (sp)+, reglist_rod
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
                
                * print Bcc operator
                move.w  (a0), d4
                bsr     print_bcc_op * returns valid = %00 in d3.b
                
                tst.b   d3 * check if Bcc condition was valid
                beq     bcc_valid
                
                * invalid condition, print DATA
                bsr     op_notfound 
                bra     op_bcc_x
                
bcc_valid       bsr     bcc_printer
                bsr     print_nl
                
                addq.w  #$2, a0
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
                
                move.b  (ea_jsr_s), d3
                bsr     handle_ea
                
                addq.w  #$2, a0
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
                
                addq.w  #$2, a0
* ---- exit
op_rts_x        movem.l (sp)+, reglist_rts
                rtr

* ==== constants and variables ====

* size messages
msg_size_b      dc.w    '.B',0
msg_size_w      dc.w    '.W',0
msg_size_l      dc.w    '.L',0
msg_size_bad    dc.w    '.[invalid size]',0

* instruction messages
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
msg_asr         dc.w    'ASR',0
msg_asl         dc.w    'ASL',0
msg_lsr         dc.w    'LSR',0
msg_lsl         dc.w    'LSL',0
msg_rol         dc.w    'ROL',0
msg_ror         dc.w    'ROR',0
msg_bgt         dc.w    'BGT',0
msg_ble         dc.w    'BLE',0
msg_beq         dc.w    'BEQ',0
msg_bra         dc.w    'BRA',0
msg_jsr         dc.w    'JSR',0
msg_rts         dc.w    'RTS',0

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
ea_movea_d      dc.b    %01000000
ea_movem_d      dc.b    %00101110
ea_lea_d        dc.b    %01000000
ea_addq_d       dc.b    %11111110
ea_or_d         dc.b    %10111110
ea_sub_d        dc.b    %10111110
ea_and_d        dc.b    %10111110
ea_add_d        dc.b    %10111110
ea_adda_d       dc.b    %01000000
ea_lsd_d        dc.b    %10111110
ea_asd_d        dc.b    %10111110
ea_rod_d        dc.b    %10111110

* ==== included files ====
                include "addressing.X68"









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
