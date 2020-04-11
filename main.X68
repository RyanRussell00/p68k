*-----------------------------------------------------------
* Title      : Team 68++ Disassembler
* Written by : Boyan Hristov, Phillip Ovanesyan, Ryan Russell
* Date       : April 10th, 2020
* Description: This is a disassembler written for CSS 422 B.
*-----------------------------------------------------------
        ORG     $1000
        START:

* ==== program code ====

* Loading address
        MOVEA.L test_start, A2
        JSR     detect_nop

        SIMHALT             * halt simulator

* ==== subroutines ====
* all opcode-handling subroutines belong in a seperate file
        INCLUDE "sub.X68"
        
        NOP                 * nothing so far


* ==== constants and variables =====

* ==== tests ====

        INCLUDE     "test.X68"
        END         START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
