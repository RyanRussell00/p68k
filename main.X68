*-----------------------------------------------------------
* Title      : Team 68++ Disassembler
* Written by : Boyan Hristov, Phillip Ovanesyan, Ryan Russell
* Date       : April 10th, 2020
* Description: This is a disassrembler written for CSS 422 B.
*-----------------------------------------------------------
org_main        equ     $1000
org_stack       equ     $A000
                org     org_main
start:
                lea     org_stack, sp * initialize stack

* ==== program code ====
                clr.l   d4
                tas     d4
                bsr     print_logo
                bsr     print_nl
                bsr     bound_hint * for testing only, REMOVE FOR SUBMISSION
                bsr     user_input
                
* Run main loop
                * counter for lines printed out
                clr.l   d2

* while current address <= end address                
read_loop       cmpa.l  a6, a0
                bhi     read_loop_x
                
                cmpi.l  #screen_limit, d2 * if printed too many lines
                bge     limit_reached
                * bge instead of bgt because an extra message is printed
                * at the bottom every time the limit is reached
                
                move.l  a0, d1
                bsr     print_hex_l
                bsr     print_space
                bsr     read_opcode
                
                addq.l  #1, d2 * increment counter
                bra     read_loop * loop again
                
limit_reached   bsr     wait_user * wait for user to press any key
                clr.l   d2 * reset counter
                bra     read_loop
                
read_loop_x * loop exit

program_end     simhalt * code is done
        
* ==== utility subroutines ====

*-----------------------------------------------------------
* //// wait for user to press enter
* parameters:
*   none
* return:
*   none
*
rl_wait_user    reg     a0-a6/d0-d7
wait_user       move.w  sr, -(sp)
                movem.l rl_wait_user, -(sp)
* ---- subroutine code:
                
                bsr     font_orange
                move.b  #14, d0 * print null-term string without CR, LF
                lea     msg_wait, a1
                trap    #15
                bsr     font_white
                
                move.b  #5, d0 * read character from keyboard
                trap    #15
                bsr     print_nl
                
* ---- exit
wait_user_x     movem.l (sp)+, rl_wait_user
                rtr

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
                lea     null, a1 * literally point a1 to null (0)
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

*-----------------------------------------------------------
* //// print Team 68++ logo
* parameters:
*   none
* return:
*   none
*
rl_print_logo   reg     a0-a6/d0-d7
print_logo      move.w  sr, -(sp)
                movem.l rl_print_logo, -(sp)
* ---- subroutine code:
                
                clr.b   d2
                bsr     font_red * red
                move.b  #13, d0
                lea     logo_1, a1
                trap    #15
                
                move.b  #21, d0
                move.l  #$0000A5FF, d1 * orange
                trap    #15
                move.b  #13, d0
                lea     logo_2, a1
                trap    #15
                
                move.b  #21, d0
                move.l  #$0000FFFF, d1 * yellow
                trap    #15
                move.b  #13, d0
                lea     logo_3, a1
                trap    #15
                
                move.b  #21, d0
                move.l  #$0000FF00, d1 * green
                trap    #15
                move.b  #13, d0
                lea     logo_4, a1
                trap    #15
                
                move.b  #21, d0
                move.l  #$00FF0000, d1 * blue
                trap    #15
                move.b  #13, d0
                lea     logo_5, a1
                trap    #15
                
                move.b  #21, d0
                move.l  #$00800080, d1 * purple
                trap    #15
                move.b  #13, d0
                lea     logo_6, a1
                trap    #15
                
                bsr     font_white * back to white
                
* ---- exit
print_logo_x    movem.l (sp)+, rl_print_logo
                rtr

* ==== included files ====
                include "user.X68"
                include "detect.X68"
                include "opcodes.X68"
                include "addressing.X68"

* ==== constants and variables =====

screen_limit    equ     31 * lines that can fit on the screen

msg_wait        dc.w    '>>> Press [Enter] to continue... ',0

logo_1          dc.w    '  _______                       __   ___',0
logo_2          dc.w    ' |__   __|                     / /  / _ \  _     _',0
logo_3          dc.w    '    | | ___  __ _ _ __ ___    / /_ | (_) || |_ _| |_',0
logo_4          dc.w    '    | |/ _ \/ _` | `_ ` _ \  | `_ \ > _ <_   _|_   _|',0
logo_5          dc.w    '    | |  __/ (_| | | | | | | | (_) | (_) ||_|   |_|',0
logo_6          dc.w    '    |_|\___|\__,_|_| |_| |_|  \___/ \___/ ',0

CR              equ     $0d
LF              equ     $0a
HT              equ     $09

null            dc.w    0
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
