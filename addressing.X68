*-----------------------------------------------------------
* Title      : Addressing Mode Detect
* Written by : Ryan Russell
* Date       : April 27, 2020
* Description: Detects the addressing mode and prints it to screen
*-----------------------------------------------------------

CR  EQU     $0D
LF  EQU     $0A
   
 ORG    $1000
START:                  ; first instruction of program

* Put program code here

    move.b  #%000111, d0    *move 000111 into d0
    bsr     data_address
    
    move.b  #%000110, d0
    bsr     data_address
    
    move.b  #%000101, d0 
    bsr     data_address
    
    move.b  #%000100, d0 
    bsr     data_address
    
    move.b  #%000011, d0 
    bsr     data_address
    
    move.b  #%000010, d0 
    bsr     data_address
    
    move.b  #%000001, d0 
    bsr     data_address
    
    move.b  #%000000, d0 
    bsr     data_address
    
    SIMHALT             ; halt simulator
    
    *-----------------------------------------------------------
* //// Read data register addressing mode
* parameters:
*   d0 - the addresing mode
*
rl_datareg      reg     a0-a6/d1-d7 * every reg except parameters/return
data_address    move.w  sr, -(sp) * save CCR to stack
                movem.l rl_datareg, -(sp) * save current regs to stack
* ---- subroutine code:
                
                move.b  d0, d1          *Save the contents of d0 in a temp registry
                and.b   #%111000, d0    *if the first 3 bits of d0 is 000 it will save 000000 in d0
                cmp     #%0, d0         *if 0 then we have a data register addressing mode
                beq     print_d0
       
print_d0        cmp     #%000000, d1    *compare to see if d0
                bne     print_d1        *if not d0 try d1
                lea     direct_data_0, a1   *load the message for d0
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_address_x  *exit the subroutine
 
print_d1        cmp     #%000001, d1    *compare to see if d1
                bne     print_d2        *if not, try next
                lea     direct_data_1, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_address_x  *exit the subroutine
                
print_d2        cmp     #%000010, d1    *compare to see if d2
                bne     print_d3        *if not, try next
                lea     direct_data_2, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_address_x  *exit the subroutine
                
print_d3        cmp     #%000011, d1    *compare to see if d3
                bne     print_d4        *if not, try next
                lea     direct_data_3, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_address_x  *exit the subroutine

print_d4        cmp     #%000100, d1    *compare to see if d4
                bne     print_d5        *if not, try next
                lea     direct_data_4, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_address_x  *exit the subroutine
                
print_d5        cmp     #%000101, d1    *compare to see if d5
                bne     print_d6        *if not, try next
                lea     direct_data_5, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_address_x  *exit the subroutine
                
print_d6        cmp     #%000110, d1    *compare to see if d6
                bne     print_d7        *if not, try next
                lea     direct_data_6, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen     
                bra     data_address_x  *exit the subroutine

print_d7        cmp     #%000111, d1    *compare to see if d7
                bne     data_address_x        *if not, try next
                lea     direct_data_7, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                
* ---- exit        
data_address_x  movem.l (sp)+, rl_datareg * restore old registers
                rtr * restore CCR, exit subroutine

* Put variables and constants here

direct_data_0 dc.b    'd0', CR, LF, 0
direct_data_1 dc.b    'd1', CR, LF, 0
direct_data_2 dc.b    'd2', CR, LF, 0
direct_data_3 dc.b    'd3', CR, LF, 0
direct_data_4 dc.b    'd4', CR, LF, 0
direct_data_5 dc.b    'd5', CR, LF, 0
direct_data_6 dc.b    'd6', CR, LF, 0
direct_data_7 dc.b    'd7', CR, LF, 0

    END    START        ; last line of source



*-----------------------------------------------------------
* //// my subroutine name
* parameters:
*   d0 - description of whatever you pass to the subroutine
*   d1 - description of whatever you pass to the subroutine
* return:
*   a0 - description of whatever you return from the subroutine
*   a1 - description of whatever you return from the subroutine
*
* rl_mysub    	reg     a2-a6/d2-d7 * every reg except parameters/return
* my_sub_name     move.w  sr, -(sp) * save CCR to stack
*                movem.l rl_mysub, -(sp) * save current regs to stack
* ---- subroutine code:
                
                * do shit
                
* ---- exit        
* my_sub_x   		movem.l (sp)+, rl_mysub * restore old registers
*                rtr * restore CCR, exit subroutine
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
