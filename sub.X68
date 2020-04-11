* 
* Subroutines to handle every opcode.
*

* ==== opcode subroutines ====

*
* S1
* parameters a2 is the start address
* TODO add an end address that is specified by the user
* return void
detect_nop:
    CMPI.W  #$4E71, (A2)+
    BEQ     print_nop
    BNE     print_not_nop
cont_detect_nop:
    CMPI.L  #$00001010, (A2)
    BPL.S   detect_nop
    
    RTS

*
* S2
* parameters none
* return void   
print_nop:
    lea     isNop, A1
    move.b  #13, D0
    trap    #15
    jmp     cont_detect_nop

*
* S2
* parameters none
* return void   
print_not_nop:
    LEA     notNop, A1
    MOVE.B  #13, D0
    TRAP    #15
    JMP     cont_detect_nop

* === constants and variables ====

isNop       DC.B    'Operation is nop',0
notNop      DC.B    'Operation is not nop',0

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
