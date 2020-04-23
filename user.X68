* 
* Subroutines to handle user input.
*

* ==== user subroutines ====

*
* takes user input as string and 
* calls a subroutine that converts it to hex
* returns start and end in d0, d1
get_user_input:
    ; provide start or end
    ; start address
    move.l  #test_start, d1
    lea     input_s, a2
    jsr     print_user_input_msg
input_loop1:
    jsr     get_str_input
    
    move.l  #test_start, d5
    jsr     validate_and_tolower_input
    
    jsr str_to_hex
    move.l  d0, d7
    
    ; check if within bounds
    ; if not within bounds or not even
    ; send error message and get user input again
test_even:
    andi.b  #1, d0
    cmpi.b  #1, d0 ; check if it is odd
    beq     bad_value
    
test_bounds:
    move.l  d7, d0
    cmpi.l  #test_start, d0
    bmi     bad_value
    cmpi.l  #test_end, d0
    ble     input_loop2_setup

bad_value:
    move.l  #test_start, d5
    jsr inpt_err_msg
    
    bra.s   input_loop1
    
input_loop2_setup:
    ; provide start or end
    ; new start address
    move.l  d7, d1
    move.l  d7, -(sp)
    lea     input_e, a2
    jsr     print_user_input_msg
input_loop2:
    jsr     get_str_input
    move.l  d7, d5 ; will be the value given by the user later
    jsr     validate_and_tolower_input

    jsr     str_to_hex
    move.l  d0, d7
    ; check if within bounds
    ; if not within bounds
    ; send error message and get user input
    
test_even2:
    andi.b  #1, d0
    cmpi.b  #1, d0 ; check if it is odd
    beq     bad_value2
    
test_bounds2:
    move.l  d7, d0
    move.l  (sp)+, d5
    cmp.l   d5, d0 ; has to be the start from input1
    bmi     bad_value2
    cmpi.l  #test_end, d0
    ble     user_input_end

bad_value2:
   * move.l  #test_start, D5 ; D5 it is already preloaded
    jsr     inpt_err_msg
    bra.s   input_loop2

user_input_end:
    move.l  d5, d0
    move.l  d7, d1
    rts

* validates and lowers the characters from the input
* params:
* param1 a1 address of string
* param2 d1.w length
* param3 d5 starting address
* end will always be the same
validate_and_tolower_input:
    move.w  d1, d3
    move.w  d1, d4 ; for safekeeping to be implemented with $sp soon
    move.l  a1, a2
    
validation_uinput_loop:
    move.l  a2, a3  ; store address in case we want to lower the char
    move.b  (a2)+, d1
    
    ; if d1 is numeric keep it
    ; if d1 is lowercase alpha keep it
    ; if d1 is uppercase alpha change it to lowercase
    ; also only check the ranges 0-9, a-f, and A-F
    
    ; check if numeric
    cmpi.b  #$30, d1
    bmi     incorrect_input
    cmpi.b  #$40, d1
    bmi     continue_uinput_loop
    ; else check if capital letter
    cmpi.b  #$41, d1
    bmi     incorrect_input
    cmpi.b  #$47, d1
    bmi     to_lower_case
    ; else check if lowercase letter
    cmpi.b  #$61, d1
    bmi     incorrect_input
    cmpi.b  #$67, d1
    bmi     continue_uinput_loop
    bra.w   incorrect_input
to_lower_case:
    add.b   #$20, d1
    move.b  d1, (a3)
continue_uinput_loop:
    ; decrement count
    subi.b  #1, d3
    ; check to see if 0
    cmpi.w  #0, d3
    ; if not keep going
    bne     validation_uinput_loop
    bra.w   correct_input
correct_input:
    ; check to see if the value in d1 is '1' 
    ; if so then the input is incorrect because it is
    ; on an odd boundary
    cmpi.b  #$31, d1
    beq     incorrect_input
    move.w  d4, d1 ; restore the value
    rts
incorrect_input:
    ; print error message and get user input
    jsr     inpt_err_msg
    jsr     get_str_input
    jmp     validate_and_tolower_input
    
* 
* converts a string to hex number
* if conversion fails notifies the caller
* param a1 - address of string
* param d1.w - length of string
* returns number in d0
* 
* Registers in use
* d4 accumulator
* d2 pow index
*
str_to_hex:
    clr.l   d4  
    clr.l   d2 ; pow
    clr.l   d3 ; extracted char
    
    move.l  d1, d2
    subi.l  #1, d2
   * add.l   d1, a1 ; move the address to the back  
    
convert_loop:
    cmpi.b  #$f, d2
    beq     end_to_hex
    
    move.b  (a1)+, d3
    
    cmpi.b  #$40, d3 ; if this is + we are looking at a letter
    bpl     hex_handler
    
    subi.l  #$30, d3
    move.l  #16, d5 ; load base
    move.l  d2, d6 ; load power
    jsr pow
    mulu.w  d7, d3 ; multiply num*16^pow
    add.l   d3, d4 ; add to accumulator
    clr.l   d3
    subi.b  #1, d2 ; dec power

    bra.s   convert_loop

hex_handler:
    subi.l  #$57, d3
    move.l  #16, d5 ; load base
    move.l  d2, d6 ; load power
    jsr pow
    mulu.w  d3, d7 ; multiply num*16^pow
    add.l   d7, d4 ; add to accumulator
    
    subi.b  #1, d2 ; dec power
    bra.s   convert_loop
end_to_hex:
    move.l  d4, d0
    rts


* pow: power
* raise a num in d5 to a power of d6
* returns result in d7
pow:
    move.l  d5, d7
    cmpi.b  #0, d6
    bne     pow_loop
zero_pow:
    move.l  #1, d7
    bra.s   end_pow
pow_loop:
    cmpi.b  #1, d6
    beq     end_pow
    mulu.w  d5, d7
    subi.l  #1, d6
    bra.s   pow_loop

end_pow:
    rts
    
* params void
* gets user input
* returns str address a1, str length d1.w
get_str_input:
    move.l  #0, a1
    move.b  #2, d0
    trap    #15
    rts

*
* S1
* parameters para1 start d1
* para2 start/end word a2
* return void
print_user_input_msg:
    move.l  #0, a1
    lea     input_pt1, a1
    move.b  #14, d0
    trap    #15
    
    move.l  a2, a1
    move.b  #14, d0
    trap    #15
    
    lea     input_pt2, a1
    move.b  #14, d0
    trap    #15
    
    moveq   #15, d0
    moveq   #16, d2
    *move.l  #test_start, d1 ; passed in as an argument
    trap    #15
    
    lea     input_pt3, a1
    move.b  #14, d0
    trap    #15
    
    moveq   #15, d0
    moveq   #16, d2
    move.l  #test_end, d1 ; always remains the same
    trap    #15

    lea     input_pt4, a1
    move.b  #14, d0
    trap    #15
    
    move.l  #0, a1
    
    rts


*
* displays error msg for the input
* params d5 - start
* return void
inpt_err_msg:
    move.l  #0, a1
    lea     input_inc_pt1, a1
    move.b  #13, d0
    trap    #15
    
    lea     input_inc_pt2, a1
    move.b  #13, d0
    trap    #15

    lea     input_inc_pt3, a1
    move.b  #14, d0
    trap    #15
    
    moveq   #15, d0
    moveq   #16, d2
    move.l  d5, d1
    trap    #15
    
    lea     input_inc_pt4, a1
    move.b  #14, d0
    trap    #15
    
    moveq   #15, d0
    moveq   #16, d2
    move.l  #test_end, d1
    trap    #15
   
    lea     input_inc_pt5, a1
    move.b  #13, d0
    trap    #15
    
    move.l  #0, a1
    
    rts

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
