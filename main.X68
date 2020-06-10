*-----------------------------------------------------------
* Title      : Team 68++ Disassembler
* Written by : Boyan Hristov, Phillip Ovanesyan, Ryan Russell
* Date       : April 10th, 2020
* Description: This is a disassrembler written for CSS 422 B.
*-----------------------------------------------------------
org_main        equ     $1000
org_stack       equ     $F000
                org     org_main
start:
                lea     org_stack, sp * initialize stack

* ==== program code ====
                
intro           bsr     print_logo
                bsr     print_nl
main            bsr     bound_hint * for testing only, REMOVE FOR SUBMISSION
                bsr     user_input
                
                * counter for lines printed out
                clr.l   d2

* while current address <= end address                
read_loop       cmpa.l  a6, a0
                bhi     read_loop_x
                
                cmpi.l  #screen_limit, d2 * if printed too many lines
                bge     limit_reached
                
                move.l  a0, d1
                bsr     print_hex_l
                bsr     print_space
                bsr     read_opcode
                
                addq.l  #1, d2
                bra     read_loop
                
limit_reached   bsr     wait_continue * wait for user to press enter
                clr.l   d2 * reset counter
                bra     read_loop
                
read_loop_x     bsr     wait_again * ask user if they want to go again
                tst.b   d3 * check if user said yes or no
                bne     main
                
                bsr     print_finish
                
program_end     simhalt * code is done
        
* ==== utility subroutines ====

*-----------------------------------------------------------
* //// print newline
* parameters:
*   none
* return:
*   none
*
rl_print_nl     reg     a0-a6/d0-d7
print_nl        move.w  sr, -(sp)
                movem.l rl_print_nl, -(sp)
* ---- subroutine code:
                
                move.b  #13, d0 * print null-term string with CR, LF
                lea     nullterm, a1 * literally point a1 to null (0)
                trap    #15
                
* ---- exit
print_nl_x      movem.l (sp)+, rl_print_nl
                rtr

*-----------------------------------------------------------
* //// print space
* parameters:
*   none
* return:
*   none
*
rl_print_space  reg     a0-a6/d0-d7
print_space     move.w  sr, -(sp)
                movem.l rl_print_space, -(sp)
* ---- subroutine code:
                
                move.b  #14, d0 * print null-term string, no CR, LF
                lea     space, a1
                trap    #15
                
* ---- exit
print_space_x   movem.l (sp)+, rl_print_space
                rtr

*-----------------------------------------------------------
* //// print long (32 bits) as hex digits
* parameters:
*   d1 - contains word to print as hex
* return:
*   none
*
rl_print_hex_l  reg     a0-a6/d0-d7
print_hex_l     move.w  sr, -(sp)
                movem.l rl_print_hex_l, -(sp)
* ---- subroutine code:
                
                swap    d1              *flip long or else it prints in reverse
                bsr     print_hex_w     *print first half of long
                swap    d1              *flip first half of register to second half
                bsr     print_hex_w     *print rest of long
                
* ---- exit
print_hex_l_x   movem.l (sp)+, rl_print_hex_l
                rtr
*-----------------------------------------------------------   

*-----------------------------------------------------------
* //// print word (16 bits) as hex digits
* parameters:
*   d1 - contains word to print as hex
* return:
*   none
*
rl_print_hex_w  reg     a0-a6/d0-d7
print_hex_w     move.w  sr, -(sp)
                movem.l rl_print_hex_w, -(sp)
* ---- subroutine code:
                
                rol.w   #$4, d1 * rotate first 4 bits to last 4 bits
                bsr     print_hex_n
                rol.w   #$4, d1
                bsr     print_hex_n
                rol.w   #$4, d1
                bsr     print_hex_n
                rol.w   #$4, d1
                bsr     print_hex_n
                
* ---- exit
print_hex_w_x   movem.l (sp)+, rl_print_hex_w
                rtr

*-----------------------------------------------------------
* //// print byte (8 bits) as hex digits
* parameters:
*   d1 - contains byte to print as hex
* return:
*   none
*
rl_print_hex_b  reg     a0-a6/d0-d7
print_hex_b     move.w  sr, -(sp)
                movem.l rl_print_hex_b, -(sp)
* ---- subroutine code:
                
                rol.w   #$4, d1 * rotate first 4 bits to last 4 bits
                bsr     print_hex_n
                rol.w   #$4, d1
                bsr     print_hex_n
                
* ---- exit
print_hex_b_x   movem.l (sp)+, rl_print_hex_b
                rtr

*-----------------------------------------------------------
* //// print nibble (4 bits) as hex digit
* parameters:
*   d1 - contains nibble to print as hex
* return:
*   none
*
rl_print_hex_n  reg     a0-a6/d0-d7
print_hex_n     move.w  sr, -(sp)
                movem.l rl_print_hex_n, -(sp)
* ---- subroutine code:
                
                andi.b  #%00001111, d1 * clear first 4 bits
                addi.b  #$30, d1 * ASCII offset to start at char 0
                cmpi.b  #$39, d1 * check if above ASCII $39
                ble     pr_hn_skip1 * hex $0-9 can be safely printed
                addi.b  #$7, d1 * hex $A-F needs another ASCII offset
                
pr_hn_skip1     move.b  #6, d0 * display char at d1.b
                trap    #15
                
* ---- exit
print_hex_n_x   movem.l (sp)+, rl_print_hex_n
                rtr

*-----------------------------------------------------------
* //// set font color to white
* parameters:
*   none
* return:
*   none
*
rl_f_white      reg     a0-a6/d0-d7
font_white      move.w  sr, -(sp)
                movem.l rl_f_white, -(sp)
* ---- subroutine code:
                
                clr.b   d2 * avoid font styling
                move.b  #21, d0 * change font color
                move.l  #$00FFFFFF, d1 * white
                trap    #15
                
* ---- exit
font_white_x    movem.l (sp)+, rl_f_white
                rtr

*-----------------------------------------------------------
* //// set font color to red
* parameters:
*   none
* return:
*   none
*
rl_f_red        reg     a0-a6/d0-d7
font_red        move.w  sr, -(sp)
                movem.l rl_f_red, -(sp)
* ---- subroutine code:
                
                clr.b   d2 * avoid font styling
                move.b  #21, d0 * change font color
                move.l  #$000000FF, d1 * red
                trap    #15
                
* ---- exit
font_red_x      movem.l (sp)+, rl_f_red
                rtr

*-----------------------------------------------------------
* //// set font color to orange
* parameters:
*   none
* return:
*   none
*
rl_f_orange     reg     a0-a6/d0-d7
font_orange     move.w  sr, -(sp)
                movem.l rl_f_orange, -(sp)
* ---- subroutine code:
                
                clr.b   d2 * avoid font styling
                move.b  #21, d0 * change font color
                move.l  #$0000A5FF, d1 * orange
                trap    #15
                
* ---- exit
font_orange_x   movem.l (sp)+, rl_f_orange
                rtr

*-----------------------------------------------------------
* //// set font color to blue
* parameters:
*   none
* return:
*   none
*
rl_f_blue       reg     a0-a6/d0-d7
font_blue       move.w  sr, -(sp)
                movem.l rl_f_blue, -(sp)
* ---- subroutine code:
                
                clr.b   d2 * avoid font styling
                move.b  #21, d0 * change font color
                move.l  #$00D1CE00, d1 * actually dark turquoise
                trap    #15
                
* ---- exit
font_blue_x     movem.l (sp)+, rl_f_blue
                rtr

* ==== included files ====
                include "user.X68"
                include "detect.X68"
                include "opcodes.X68"
                include "addressing.X68"

* ==== constants and variables =====

screen_limit    equ     31 * lines that can fit on the screen

CR              equ     $0d
LF              equ     $0a
HT              equ     $09
null            equ     $00

nullterm        dc.w    0
space           dc.w    ' ',0
newline         dc.w    CR,LF,0
indent          dc.w    HT,HT,0

* 80 bytes of string buffer space
* prevents other memory from being overwritten
str_buf         dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
code_end
* ==== tests ====
                include "test.X68"
                * don't move this any higher than end start
                * or else the ORGs get screwed up
* ==== end ====
                end     start

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
