*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* code to translate
    nop
    nop
    nop
    
    INCLUDE "bin.h"
* end of code to translate

* Loading address
    movea.l #$00001000, a2
    jsr     detect_nop

    SIMHALT             ; halt simulator

*
* S1
* parameters a2 is the start address
* TODO add an end address that is specified by the user
* return void
detect_nop:
    cmpi.w  #$4E71, (a2)+
    beq     print_nop
    bne     print_not_nop
cont_detect_nop:
    cmpi.l  #$00001010, (a2)
    bpl.s   detect_nop
    
    rts

*
* S2
* parameters none
* return void   
print_nop:
    lea     isNop, a1
    move.b  #13, d0
    trap    #15
    jmp     cont_detect_nop

*
* S2
* parameters none
* return void   
print_not_nop:
    lea     notNop, a1
    move.b  #13, d0
    trap    #15
    jmp     cont_detect_nop

* Put variables and constants here
isNop       dc.b    'Operation is nop',0
notNop      dc.b    'Operation is not nop',0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
