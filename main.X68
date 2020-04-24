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
                
                bsr     read_opcode
                
                bra     read_loop * loop again
read_loop_x * loop exit

                simhalt * code is done
        

* ==== included files ====
                include "user.X68"
                include "detect.X68"
                include "opcodes.X68"

* ==== constants and variables =====

input_pt1       dc.w    'Please enter an even ',0
input_pt2       dc.w    ' address between (',0
input_pt3       dc.w    ') and (',0
input_pt4       dc.w    '):',0

input_inc_pt1   dc.w    'Input is incorrect.',0
input_inc_pt2   dc.w    'Please enter an even value',0
input_inc_pt3   dc.w    'within the range (',0
input_inc_pt4   dc.w    ') and (',0
input_inc_pt5   dc.w    '):',0

input_s         dc.w    'start',0
input_e         dc.w    'end',0

CR              equ     $0d
LF              equ     $0a
HT              equ     $09

newline         dc.w    CR,LF,0
indent          dc.w    HT,HT,0

* ==== tests ====
                include "test.X68"
* ==== end ====
                end     start





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
