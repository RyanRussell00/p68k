*-----------------------------------------------------------
* Title      : Team 68++ Disassembler
* Written by : Boyan Hristov, Phillip Ovanesyan, Ryan Russell
* Date       : April 10th, 2020
* Description: This is a disassembler written for CSS 422 B.
*-----------------------------------------------------------
org_main    EQU     $1000
org_stack   EQU     $5000
org_test    EQU     $A000 * remove before final submission
            ORG     org_main
START:
        MOVEA.L #000100000, SP * initialize stack

* ==== program code ====

* Take user input for start and end address
        JSR     get_user_input

* Loading address
       * MOVE.L  #test_start, A2
       * MOVE.L  #test_end, A3
       * JSR     reglist_nop

* put program code here

        NOP                 * nothing so far

        SIMHALT             * code is done
        

* ==== subroutines ====
* all opcode-handling subroutines belong in a seperate file
      *  INCLUDE "sub.X68"
* all user input subroutines belong in a separate file
        INCLUDE "user.X68"

        NOP                 * nothing so far


* ==== constants and variables =====

input_pt1       DC.W    'Please enter an even ',0
input_pt2       DC.W    ' address between (',0
input_pt3       DC.W    ') and (',0
input_pt4       DC.W    '):',0

input_inc_pt1   DC.W    'Input is incorrect.',0
input_inc_pt2   DC.W    'Please enter an even value',0
input_inc_pt3   DC.W    'within the range (',0
input_inc_pt4   DC.W    ') and (',0
input_inc_pt5   DC.W    '):',0

input_s         DC.W    'start',0
input_e         DC.W    'end',0

*newline         DC.B    CR,LF,0
*indent          DC.B    HT,HT,0

* ==== tests ====
        INCLUDE     "test.X68"
* ==== end ====
        END         START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
