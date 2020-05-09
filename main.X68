*-----------------------------------------------------------
* Title      : Team 68++ Disassembler
* Written by : Boyan Hristov, Phillip Ovanesyan, Ryan Russell
* Date       : April 10th, 2020
* Description: This is a disassembler written for CSS 422 B.
*-----------------------------------------------------------
org_main        equ     $1000
org_stack       equ     $A000
                org     org_main
start:
                lea     org_stack, sp * initialize stack

* ==== program code ====
                
* Take user input for start and end address
                jsr     get_user_input
                
* Loading address
                move.l  d0, a0
                move.l  d1, a1

* while current address <= end address                
read_loop       cmpa.l  a1, a0
                bgt     read_loop_x
                
                move.w  a0, d1
                bsr     print_hex_w
                bsr     print_space
                
                bsr     read_opcode
                
                bra     read_loop * loop again
read_loop_x * loop exit

                simhalt * code is done
        
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
* //// print word (16 bits) as hex digit
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

* ==== included files ====
                include "user.X68"
                include "detect.X68"
                include "opcodes.X68"

* ==== constants and variables =====

input_pt1       dc.w    'Please enter an even ',0
input_pt2       dc.w    ' address between (',0
input_pt3       dc.w    ') and (',0
input_pt4       dc.w    '): ',0

input_inc_pt1   dc.w    'Input is incorrect.',0
input_inc_pt2   dc.w    'Please enter an even value',0
input_inc_pt3   dc.w    'within the range (',0
input_inc_pt4   dc.w    ') and (',0
input_inc_pt5   dc.w    '): ',0

input_s         dc.w    'start',0
input_e         dc.w    'end',0

CR              equ     $0d
LF              equ     $0a
HT              equ     $09

null            dc.w    0
space           dc.w    ' ',0
newline         dc.w    CR,LF,0
indent          dc.w    HT,HT,0

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
