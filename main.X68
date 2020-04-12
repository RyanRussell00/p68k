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
            MOVEA.L org_stack, SP * initialize stack

* ==== program code ====

* put program code here

        NOP                 * nothing so far

        SIMHALT             * code is done
        

* ==== subroutines ====
* all opcode-handling subroutines belong in a seperate file
        INCLUDE "sub.X68"
        
        NOP                 * nothing so far


* ==== constants and variables =====

newline         DC.B    CR,LF,0
indent          DC.B    HT,HT,0

* ==== tests ====
        INCLUDE     "test.X68"
* ==== end ====
        END         START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
