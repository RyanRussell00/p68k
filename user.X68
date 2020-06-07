* 
* Subroutines to handle user input.
*

* ==== user subroutines ====

*-----------------------------------------------------------
* //// get start and end addresses from user
* parameters:
*   none
* return:
*   a0 - start address
*   a6 - end address
*
rl_user_input   reg     a1-a5/d0-d7
user_input      move.w  sr, -(sp)
                movem.l rl_user_input, -(sp)
* ---- subroutine code:
                
in_loop1        move.b  #14, d0
                lea     msg_start_in, a1
                trap    #15
                bsr     read_hex_l
                
                tst.b   d6 * if $FF, success
                bne     in_loop1_end
                
                * given string was an invalid start address
                bsr     font_red
                move.b  #13, d0
                lea     msg_input_bad, a1
                trap    #15
                bsr     font_white
                bra     in_loop1
                
in_loop1_end    move.l  d7, a0

in_loop2        move.b  #14, d0
                lea     msg_end_in, a1
                trap    #15
                bsr     read_hex_l
                
                tst.b   d6 * if $FF, success
                beq     bad_end_addr
                cmpa.l  d7, a0 * if end < start, it's invalid
                bls     in_loop2_end
                
                * end was lower than start
                bsr     font_red
                move.b  #13, d0
                lea     msg_end_low, a1
                trap    #15
                bsr     font_white
                bra     in_loop2
                
                * given string was an invalid end address
bad_end_addr    bsr     font_red
                move.b  #13, d0
                lea     msg_input_bad, a1
                trap    #15
                bsr     font_white
                bra     in_loop2
                
in_loop2_end    movea.l d7, a6
                
* ---- exit
user_input_x    movem.l (sp)+, rl_user_input
                rtr

*-----------------------------------------------------------
* //// read hex long value from user
* parameters:
*   none
* return:
*   d6 - $FF for success, $00 for failure
*   d7 - long from user
*
rl_read_hl      reg     a0-a6/d0-d5
read_hex_l      move.w  sr, -(sp)
                movem.l rl_read_hl, -(sp)
* ---- subroutine code:
                
                sf      d6 * set result to $00, failure
                clr.l   d7 * set return long to 0
                
                move.b  #2, d0 * read null-term string from user
                lea     str_buf, a1
                trap    #15
                
                cmpi.w  #8, d1 * if more than 8 chars, fail
                bgt     read_hex_l_x
                
                move.b  (a1), d5 * get first char
                cmpi.b  #0, d5 * if it's null, fail - empty string
                beq     read_hex_l_x
                
rhl_loop        cmpi.b  #0, d5 * if char is null, end loop
                beq     rhl_loop_end
                
                bsr     char_to_nib
                tst.b   d6 * if $00, fail
                beq     read_hex_l_x
                
                lsl.l   #4, d7 * scoot result over by a nibble
                add.b   d5, d7 * hex value inserted into last 4 bits
                
                addq.l  #1, a1 * move to next char in string
                move.b  (a1), d5 * fetch char from string
                bra     rhl_loop
                
rhl_loop_end    st      d6 * set result to $FF, success
                
* ---- exit
read_hex_l_x    movem.l (sp)+, rl_read_hl
                rtr

*-----------------------------------------------------------
* //// convert ascii hex char to nibble
* parameters:
*   d5 - ascii char representing a hex digit
* return:
*   d5 - byte value of hex digit, $0 to $F
*   d6 - $FF for valid hex char, $00 for invalid
*
rl_char_to_nib  reg     a0-a6/d0-d4/d7
char_to_nib     move.w  sr, -(sp)
                movem.l rl_char_to_nib, -(sp)
* ---- subroutine code:
                
                sf      d6 * set result to $00, invalid
                
                cmpi.b  #$30, d5 * if ascii < $30, fail
                blt     char_to_nib_x
                cmpi.b  #$46, d5 * if ascii > $46, fail
                bgt     char_to_nib_x
                
                * if $39 < ascii < $41, fail 
                cmpi.b  #$39, d5
                sgt     d0 * if ascii > $39, d0 = true
                cmpi.b  #$41, d5
                slt     d1 * if ascii < $41, d1 = true
                and.b   d0, d1 * if d0 && d1 == true, fail
                bne     char_to_nib_x
                
                * at this point, it should be a valid hex char
                st      d6 * set result to $FF, valid
                
                subi.b  #$30, d5 * ascii offset for 0 is $30
                tst.b   d0 * if d0 == $00, we have char A-F
                beq     char_to_nib_x
                subi.b  #$7, d5 * need 7 extra offset for A-F
                
* ---- exit
char_to_nib_x   movem.l (sp)+, rl_char_to_nib
                rtr

*-----------------------------------------------------------
* //// print test address bounds (as debugging hints)
* parameters:
*   none
* return:
*   none
*
rl_b_hint       reg     a0-a6/d0-d7
bound_hint      move.w  sr, -(sp)
                movem.l rl_b_hint, -(sp)
* ---- subroutine code:
                
                * REMOVE THIS SUBROUTINE if test.x68 is removed
                
                bsr     font_orange
                move.b  #14, d0
                lea     msg_hint1, a1
                trap    #15
                
                move.l  #test_start, d1
                bsr     print_hex_l
                
                move.b  #14, d0
                lea     msg_hint2, a1
                trap    #15
                
                move.l  #test_end, d1
                bsr     print_hex_l
                
                bsr     print_nl
                bsr     font_white
                
* ---- exit
bound_hint_x    movem.l (sp)+, rl_b_hint
                rtr

* ==== constants and variables ====

msg_start_in    dc.w    'Start address (hex, $0-$FFFFFFFF): $',0
msg_end_in      dc.w    'End address   (hex, $0-$FFFFFFFF): $',0
msg_input_bad   dc.w    'Invalid input, try again.',0
msg_end_low     dc.w    'End address cannot be less than start address, try again.',0

msg_hint1       dc.w    '>>> HINT: test bounds are $',0
msg_hint2       dc.w    ' to $',0


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
