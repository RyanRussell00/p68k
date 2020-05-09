*-----------------------------------------------------------
* Title      : Addressing Mode Detect
* Description: Detects the addressing mode and prints it to screen
*-----------------------------------------------------------
   
 ORG    $1000
START:                  ; first instruction of program

* Put program code here

    move.w   #2200, d1
    move.l   #2200, d1

*Todo:
    *Proposed changes: make these the new parameters for the printer
*    move.w  #%SOURCE, d7 *6 digit binary format (data mode + data reg)
*    move.w  #%DESTIN, d6 * ^^
*    lea     $OPCODE, a0 *address of the opcode we are at. +1 is 8 bits.

    move.w   $4000, $3400
    move.w   #4000, $3400
    add.w    #2382, d0
    move.w   #$6969, (a0)
    move.l   #$11112222, (a0)

    *Tests for data register
    move.b  #%000111, d0    *move 000111 into d0
    bsr     printer
    
    move.b  #%000110, d0
    bsr     printer
    
    move.b  #%000101, d0 
    bsr     printer
    
    move.b  #%000100, d0 
    bsr     printer
    
    move.b  #%000011, d0 
    bsr     printer
    
    move.b  #%000010, d0 
    bsr     printer
    
    move.b  #%000001, d0 
    bsr     printer
    
    move.b  #%000000, d0 
    bsr     printer
    
    *Tests for direct address register
    move.b  #%001111, d0    *move 001111 into d0
    bsr     printer
    
    move.b  #%001110, d0
    bsr     printer
    
    move.b  #%001101, d0 
    bsr     printer
    
    move.b  #%001100, d0 
    bsr     printer
    
    move.b  #%001011, d0 
    bsr     printer
    
    move.b  #%001010, d0 
    bsr     printer
    
    move.b  #%001001, d0 
    bsr     printer
    
    move.b  #%001000, d0 
    bsr     printer
    
    *Tests for INDIRECT address register
    move.b  #%010111, d0
    bsr     printer
    
    move.b  #%010110, d0
    bsr     printer
    
    move.b  #%010101, d0 
    bsr     printer
    
    move.b  #%010100, d0 
    bsr     printer
    
    move.b  #%010011, d0 
    bsr     printer
    
    move.b  #%010010, d0 
    bsr     printer
    
    move.b  #%010001, d0 
    bsr     printer
    
    move.b  #%010000, d0 
    bsr     printer
    
    *Tests for INCREMENT address register
    move.b  #%011111, d0
    bsr     printer
    
    move.b  #%011110, d0
    bsr     printer
    
    move.b  #%011101, d0 
    bsr     printer
    
    move.b  #%011100, d0 
    bsr     printer
    
    move.b  #%011011, d0 
    bsr     printer
    
    move.b  #%011010, d0 
    bsr     printer
    
    move.b  #%011001, d0 
    bsr     printer
    
    move.b  #%011000, d0 
    bsr     printer
    
    *Tests for DECREMENT address register
    move.b  #%100111, d0
    bsr     printer
    
    move.b  #%100110, d0
    bsr     printer
    
    move.b  #%100101, d0
    bsr     printer
    
    move.b  #%100100, d0 
    bsr     printer
    
    move.b  #%100011, d0 
    bsr     printer
    
    move.b  #%100010, d0 
    bsr     printer
    
    move.b  #%100001, d0 
    bsr     printer
    
    move.b  #%100000, d0 
    bsr     printer
    
    *Test for Immediate
    move.b  #%111100, d0
    move.l  #%11001, d1
    bsr     printer
    
    move.b  #%111100, d0
    move.l  #%10111, d1
    bsr     printer
    
    move.b  #%111100, d0
    move.l  #%01111111111111111111111111111111, d1
    bsr     printer
    
    *Test for absolute
    move.b  #%111001, d0
    move.l  #$ABCD, d1
    bsr     printer
    
    SIMHALT             ; halt simulator
    
*-----------------------------------------------------------
* //// Given a 6 bit op string it directs it to the correct printer
* parameters:
*   d7 - 6 bit binary string that holds the SOURCE op mode/register
*   d6 - 6 bit binary string that holds the DESTINATION op mode/register
*   d5 - set to 1 if destination ea exists, set to 0 otherwise
*   a0 - address of the opcode we are looking at
* return:
*   prints to screen



rl_printer      reg     a1-a6/d0-d4 * every reg except parameters/return
printer         move.w  sr, -(sp) * save CCR to stack
                movem.l rl_printer, -(sp) * save current regs to stack
* ---- subroutine code:
                
                *DO NOT MODIFY D1 because it holds additional data values
                
                clr     d2          *clear everything in the temp register
                
                *since the original value is untouched, whatever subroutine we call gets the original param
                move.l  d0, d2      *move the parameter into temp register
                
                and.l   #%111000, d2 *mask the temp register
                
                *start comparisons
is_data         cmp.l   #%000000, d2 *data register
                bne     is_addr      *if not equal, try next
                bsr     data_reg
                bra     printer_x
                
is_addr         cmp.l   #%001000, d2 *address register
                bne     is_ind_addr  *if not equal, try next
                bsr     addr_reg
                bra     printer_x
                
is_ind_addr     cmp.l   #%010000, d2 *indirect address register
                bne     is_incrmnt  *if not equal, try next
                bsr     ind_addr_reg
                bra     printer_x
                
is_incrmnt      cmp.l   #%011000, d2 *post increment address register
                bne     is_decrmnt    *if not equal, try next
                bsr     inc_addr_reg
                bra     printer_x
                
is_decrmnt      cmp.l   #%100000, d2 *pre decrement address register
                bne     is_immdte    *if not equal, try next
                bsr     dec_addr_reg
                bra     printer_x
                 
is_immdte       *Use entire 6 bits for absolute and immediate since we need last 3 bits
                move.l  d0, d2      *reset the temp variable with original value
                cmp     #%111100, d2 *immediate
                bne     is_abs_w     *if not equal, try next
                bsr     immdte       
                bra     printer_x

is_abs_w        cmp.l   #%111000, d2 *absolute word
                bne     is_abs_l     *if not equal, try next
                bsr     abs *TODO: Write subroutine
                bra     printer_x

is_abs_l        cmp.l   #%00111001, d2 *absolute long
                beq     abs *TODO: Write subroutine              
                
* ---- exit        
printer_x   	   
                *Check if we have second EA to print
                cmpi    #1, d5 *if d5 is 1 we have another ea to print
                clr     d5     *clear d5 to prevent infinite loop
                beq     printer

                movem.l (sp)+, rl_printer *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------
    
*-----------------------------------------------------------
* //// Read data register addressing mode
* parameters:
*   d0 - 6 bit binary string that holds the data mode and data register
*
rl_data_reg      reg     a0-a6/d1-d7 * every reg except parameters/return

data_reg        move.w  sr, -(sp) * save CCR to stack
                movem.l rl_data_reg, -(sp) * save current regs to stack
* ---- subroutine code:
                
                move.b  d0, d1          *Save the contents of d0 in a temp registry
                and.b   #%111000, d0    *if the first 3 bits of d0 is 000 it will save 000000 in d0
                cmp     #%0, d0         *if 0 then we have a data register addressing mode
                bne     data_reg_x      *if first 3 bits not 000, exit subroutine
       
print_d0        cmp     #%000000, d1    *compare to see if d0
                bne     print_d1        *if not d0 try d1
                lea     direct_data_0, a1   *load the message for d0
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_reg_x  *exit the subroutine
 
print_d1        cmp     #%000001, d1    *compare to see if d1
                bne     print_d2        *if not, try next
                lea     direct_data_1, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_reg_x  *exit the subroutine
                
print_d2        cmp     #%000010, d1    *compare to see if d2
                bne     print_d3        *if not, try next
                lea     direct_data_2, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_reg_x  *exit the subroutine
                
print_d3        cmp     #%000011, d1    *compare to see if d3
                bne     print_d4        *if not, try next
                lea     direct_data_3, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_reg_x  *exit the subroutine

print_d4        cmp     #%000100, d1    *compare to see if d4
                bne     print_d5        *if not, try next
                lea     direct_data_4, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_reg_x  *exit the subroutine
                
print_d5        cmp     #%000101, d1    *compare to see if d5
                bne     print_d6        *if not, try next
                lea     direct_data_5, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     data_reg_x  *exit the subroutine
                
print_d6        cmp     #%000110, d1    *compare to see if d6
                bne     print_d7        *if not, try next
                lea     direct_data_6, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen     
                bra     data_reg_x  *exit the subroutine

print_d7        cmp     #%000111, d1    *compare to see if d7
                bne     data_reg_x  *if not, try next
                lea     direct_data_7, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                
* ---- exit        
data_reg_x  movem.l (sp)+, rl_data_reg *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Read address register addressing mode
* parameters:
*   d0 - 6 bit binary string that holds the address mode and address register
*
rl_addr_reg      reg     a0-a6/d1-d7 * every reg except parameters/return

addr_reg        move.w  sr, -(sp)    * save CCR to stack
                movem.l rl_addr_reg, -(sp) * save current regs to stack
* ---- subroutine code:
                
                move.b  d0, d1          *Save the contents of d0 in a temp registry
                and.b   #%111000, d0    *mask opmode to expected opmode
                cmp     #%001000, d0    *check mask result to make its expected
                bne     addr_reg_x      *if not expected, exit subroutine
       
print_a0        cmp     #%001000, d1    *compare to see if d0
                bne     print_a1        *if not d0 try d1
                lea     direct_addr_0, a1   *load the message for d0
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     addr_reg_x  *exit the subroutine
 
print_a1        cmp     #%001001, d1    *compare to see if d1
                bne     print_a2        *if not, try next
                lea     direct_addr_1, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     addr_reg_x  *exit the subroutine
                
print_a2        cmp     #%001010, d1    *compare to see if d2
                bne     print_a3        *if not, try next
                lea     direct_addr_2, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     addr_reg_x  *exit the subroutine
                
print_a3        cmp     #%001011, d1    *compare to see if d3
                bne     print_a4        *if not, try next
                lea     direct_addr_3, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     addr_reg_x  *exit the subroutine

print_a4        cmp     #%001100, d1    *compare to see if d4
                bne     print_a5        *if not, try next
                lea     direct_addr_4, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     addr_reg_x  *exit the subroutine
                
print_a5        cmp     #%001101, d1    *compare to see if d5
                bne     print_a6        *if not, try next
                lea     direct_addr_5, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     addr_reg_x  *exit the subroutine
                
print_a6        cmp     #%001110, d1    *compare to see if d6
                bne     print_a7        *if not, try next
                lea     direct_addr_6, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen     
                bra     addr_reg_x  *exit the subroutine

print_a7        cmp     #%001111, d1    *compare to see if d7
                bne     addr_reg_x  *if not, try next
                lea     direct_addr_7, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                
* ---- exit        
addr_reg_x      movem.l (sp)+, rl_addr_reg *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Read INDIRECT address register addressing mode
* parameters:
*   d0 - 6 bit binary string that holds the address mode and address register
*
rl_ind_addr_reg      reg     a0-a6/d1-d7 * every reg except parameters/return

ind_addr_reg    move.w  sr, -(sp)    * save CCR to stack
                movem.l rl_ind_addr_reg, -(sp) * save current regs to stack
* ---- subroutine code:
                
                move.b  d0, d1          *Save the contents of d0 in a temp registry
                and.b   #%111000, d0    *mask opmode to expected opmode
                cmp     #%010000, d0    *check mask result to make its expected
                bne     ind_addr_reg_x      *if not expected, exit subroutine
       
print_ind_a0    cmp     #%010000, d1    *compare to see if d0
                bne     print_ind_a1        *if not d0 try d1
                lea     indirect_addr_0, a1   *load the message for d0
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     ind_addr_reg_x  *exit the subroutine
 
print_ind_a1    cmp     #%010001, d1    *compare to see if d1
                bne     print_ind_a2        *if not, try next
                lea     indirect_addr_1, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     ind_addr_reg_x  *exit the subroutine
                
print_ind_a2    cmp     #%010010, d1    *compare to see if d2
                bne     print_ind_a3        *if not, try next
                lea     indirect_addr_2, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     ind_addr_reg_x  *exit the subroutine
                
print_ind_a3    cmp     #%010011, d1    *compare to see if d3
                bne     print_ind_a4        *if not, try next
                lea     indirect_addr_3, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     ind_addr_reg_x  *exit the subroutine

print_ind_a4    cmp     #%010100, d1    *compare to see if d4
                bne     print_ind_a5        *if not, try next
                lea     indirect_addr_4, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     ind_addr_reg_x  *exit the subroutine
                
print_ind_a5    cmp     #%010101, d1    *compare to see if d5
                bne     print_ind_a6        *if not, try next
                lea     indirect_addr_5, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     ind_addr_reg_x  *exit the subroutine
                
print_ind_a6    cmp     #%010110, d1    *compare to see if d6
                bne     print_ind_a7        *if not, try next
                lea     indirect_addr_6, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen     
                bra     ind_addr_reg_x  *exit the subroutine

print_ind_a7    cmp     #%010111, d1    *compare to see if d7
                bne     ind_addr_reg_x  *if not, try next
                lea     indirect_addr_7, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                
* ---- exit        
ind_addr_reg_x  movem.l (sp)+, rl_ind_addr_reg *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Read post-increment address register addressing mode
* parameters:
*   d0 - 6 bit binary string that holds the address mode and address register
*
rl_inc_addr_reg      reg     a0-a6/d1-d7 * every reg except parameters/return

inc_addr_reg    move.w  sr, -(sp)    * save CCR to stack
                movem.l rl_inc_addr_reg, -(sp) * save current regs to stack
* ---- subroutine code:
                
                move.b  d0, d1          *Save the contents of d0 in a temp registry
                and.b   #%111000, d0    *mask opmode to expected opmode
                cmp     #%011000, d0    *check mask result to make its expected
                bne     inc_addr_reg_x      *if not expected, exit subroutine
       
print_inc_a0    cmp     #%011000, d1    *compare to see if d0
                bne     print_inc_a1        *if not d0 try d1
                lea     incrmnt_addr_0, a1   *load the message for d0
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     inc_addr_reg_x  *exit the subroutine
 
print_inc_a1    cmp     #%011001, d1    *compare to see if d1
                bne     print_inc_a2        *if not, try next
                lea     incrmnt_addr_1, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     inc_addr_reg_x  *exit the subroutine
                
print_inc_a2    cmp     #%011010, d1    *compare to see if d2
                bne     print_inc_a3        *if not, try next
                lea     incrmnt_addr_2, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     inc_addr_reg_x  *exit the subroutine
                
print_inc_a3    cmp     #%011011, d1    *compare to see if d3
                bne     print_inc_a4        *if not, try next
                lea     incrmnt_addr_3, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     inc_addr_reg_x  *exit the subroutine

print_inc_a4    cmp     #%011100, d1    *compare to see if d4
                bne     print_inc_a5        *if not, try next
                lea     incrmnt_addr_4, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     ind_addr_reg_x  *exit the subroutine
                
print_inc_a5    cmp     #%011101, d1    *compare to see if d5
                bne     print_inc_a6        *if not, try next
                lea     incrmnt_addr_5, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     ind_addr_reg_x  *exit the subroutine
                
print_inc_a6    cmp     #%011110, d1    *compare to see if d6
                bne     print_inc_a7        *if not, try next
                lea     incrmnt_addr_6, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen     
                bra     ind_addr_reg_x  *exit the subroutine

print_inc_a7    cmp     #%011111, d1    *compare to see if d7
                bne     inc_addr_reg_x  *if not, try next
                lea     incrmnt_addr_7, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                
* ---- exit        
inc_addr_reg_x  movem.l (sp)+, rl_inc_addr_reg *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Read pre-decrement address register addressing mode
* parameters:
*   d0 - 6 bit binary string that holds the address mode and address register
*
rl_dec_addr_reg      reg     a0-a6/d1-d7 * every reg except parameters/return

dec_addr_reg    move.w  sr, -(sp)    * save CCR to stack
                movem.l rl_dec_addr_reg, -(sp) * save current regs to stack
* ---- subroutine code:
                
                move.b  d0, d1          *Save the contents of d0 in a temp registry
                and.b   #%111000, d0    *mask opmode to expected opmode
                cmp     #%100000, d0    *check mask result to make its expected
                bne     dec_addr_reg_x      *if not expected, exit subroutine
       
print_dec_a0    cmp     #%100000, d1    *compare to see if d0
                bne     print_dec_a1        *if not d0 try d1
                lea     decrmnt_addr_0, a1   *load the message for d0
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     dec_addr_reg_x  *exit the subroutine
 
print_dec_a1    cmp     #%100001, d1    *compare to see if d1
                bne     print_dec_a2        *if not, try next
                lea     decrmnt_addr_1, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     inc_addr_reg_x  *exit the subroutine
                
print_dec_a2    cmp     #%100010, d1    *compare to see if d2
                bne     print_dec_a3        *if not, try next
                lea     decrmnt_addr_2, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     dec_addr_reg_x  *exit the subroutine
                
print_dec_a3    cmp     #%100011, d1    *compare to see if d3
                bne     print_dec_a4        *if not, try next
                lea     decrmnt_addr_3, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     dec_addr_reg_x  *exit the subroutine

print_dec_a4    cmp     #%100100, d1    *compare to see if d4
                bne     print_dec_a5        *if not, try next
                lea     decrmnt_addr_4, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     dec_addr_reg_x  *exit the subroutine
                
print_dec_a5    cmp     #%100101, d1    *compare to see if d5
                bne     print_dec_a6        *if not, try next
                lea     decrmnt_addr_5, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     dec_addr_reg_x  *exit the subroutine
                
print_dec_a6    cmp     #%100110, d1    *compare to see if d6
                bne     print_dec_a7        *if not, try next
                lea     decrmnt_addr_6, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen     
                bra     dec_addr_reg_x  *exit the subroutine

print_dec_a7    cmp     #%100111, d1    *compare to see if d7
                bne     dec_addr_reg_x  *if not, try next
                lea     decrmnt_addr_7, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                
* ---- exit        
dec_addr_reg_x  movem.l (sp)+, rl_dec_addr_reg *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Prints immediate data as decimal
* parameters:
*   d7 - op mode and op register
*   a0 - address of additional data to print
* return:
*   prints to screen the decimal value of the hex value

rl_immdte       reg     a1-a6/d0-d6      * every reg except parameters/return
immdte          move.w  sr, -(sp)        * save CCR to stack
                movem.l rl_immdte, -(sp) * save current regs to stack
* ---- subroutine code:
                
                cmp     #%111100, d0     *check op to ensure its expected
                bne     immdte_x         *if not expected, exit subroutine
                
                lea     pound_sign, a1  *load the pound sign to print
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                
                *Todo: Print the data from the address in a0. Increment a0 to next word/long/waaat?
                
                
                
*                *Print value in d1.L as decimal
*                move.b  #3, d0          *set trap
*                trap    #15             *print to screen   
*                
*                lea     break, a1   *load the message for d0
*                move.b  #14, d0         *set trap
*                trap    #15             *print to screen

                
* ---- exit        
immdte_x   		movem.l (sp)+, rl_immdte *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Prints absolute value of the data as ASCII
* parameters:
*   d0 - op mode and op register
*   d1 - hex value of the absolute data (MUST BE LONG)
* return:
*   prints to screen the decimal value of the hex value

rl_abs          reg     a0-a6/d2-d7     * every reg except parameters/return
abs             move.w  sr, -(sp)       * save CCR to stack
                movem.l rl_abs, -(sp)   * save current regs to stack

* ---- subroutine code:
                
                cmp     #%111000, d0    *check op to see if abs short
                beq     abs_short
                
                cmp     #%111001, d0    *check op to see if abs long
                bne     abs_x           *if not, exit
                
abs_long        
                clr     d2              *clear temp register
                move.l  d1, d2          *load long data into temp
                bsr     hex_ascii       *print data
                bra     abs_x                

abs_short       
                clr     d2              *clear temp register
                move.w  d1, d2          *load word data into temp
                bsr     hex_ascii       *print data
                bra     abs_x   

                
* ---- exit        
abs_x   		movem.l (sp)+, rl_abs *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Print hex value
* parameters:
*   d2 - ascii value
* return:
*   print ascii
*
rl_hex_ascii    reg     a0-a6/d0/d1/d3-d6
hex_ascii       move.w  sr, -(sp) *save the ccr
                movem.l rl_hex_ascii, -(sp) *save the registers
                
* ---- function ----

        cmpi.l  #$30, d2
        blt.b   hex_ascii_x    *exit the subroutine if invalid num
        cmp.b   #$39, d2
        bgt.b   letter      *branch if greater than 39, meaning its a letter
        addi.b  #$30, d2    *subtract 30 from the number
        bra     ascii_print *branch to concatenate value
        
letter  cmpi.b  #$41, d2
        blt.b   hex_ascii_x *exit if invalid capital char
        cmpi.b  #$46, d2
        bgt.b   hex_ascii_x *exit if invalid capital char
        addi.b  #$37, d2    *subtract 37 from letter
        
ascii_print
        move.l   d2, (a1)      *load the message for data
        move.b  #14, d0        *set trap
        trap    #15            *print to screen
                
* ---- exit        
hex_ascii_x   movem.l (sp)+, rl_hex_ascii   
                rtr

*-----------------------------------------------------------

* Put variables and constants here
CR  EQU     $0D
LF  EQU     $0A

*direct data registers print
direct_data_0 dc.b    'd0', CR, LF, 0
direct_data_1 dc.b    'd1', CR, LF, 0
direct_data_2 dc.b    'd2', CR, LF, 0
direct_data_3 dc.b    'd3', CR, LF, 0
direct_data_4 dc.b    'd4', CR, LF, 0
direct_data_5 dc.b    'd5', CR, LF, 0
direct_data_6 dc.b    'd6', CR, LF, 0
direct_data_7 dc.b    'd7', CR, LF, 0

*direct address registers print
direct_addr_0 dc.b    'a0', CR, LF, 0
direct_addr_1 dc.b    'a1', CR, LF, 0
direct_addr_2 dc.b    'a2', CR, LF, 0
direct_addr_3 dc.b    'a3', CR, LF, 0
direct_addr_4 dc.b    'a4', CR, LF, 0
direct_addr_5 dc.b    'a5', CR, LF, 0
direct_addr_6 dc.b    'a6', CR, LF, 0
direct_addr_7 dc.b    'a7', CR, LF, 0

*INDIRECT address registers print
indirect_addr_0 dc.b  '(a0)', CR, LF, 0
indirect_addr_1 dc.b  '(a1)', CR, LF, 0
indirect_addr_2 dc.b  '(a2)', CR, LF, 0
indirect_addr_3 dc.b  '(a3)', CR, LF, 0
indirect_addr_4 dc.b  '(a4)', CR, LF, 0
indirect_addr_5 dc.b  '(a5)', CR, LF, 0
indirect_addr_6 dc.b  '(a6)', CR, LF, 0
indirect_addr_7 dc.b  '(a7)', CR, LF, 0

*INCREMENT address registers print
incrmnt_addr_0 dc.b  '(a0)+', CR, LF, 0
incrmnt_addr_1 dc.b  '(a1)+', CR, LF, 0
incrmnt_addr_2 dc.b  '(a2)+', CR, LF, 0
incrmnt_addr_3 dc.b  '(a3)+', CR, LF, 0
incrmnt_addr_4 dc.b  '(a4)+', CR, LF, 0
incrmnt_addr_5 dc.b  '(a5)+', CR, LF, 0
incrmnt_addr_6 dc.b  '(a6)+', CR, LF, 0
incrmnt_addr_7 dc.b  '(a7)+', CR, LF, 0

*DECREMENT address registers print
decrmnt_addr_0 dc.b  '-(a0)', CR, LF, 0
decrmnt_addr_1 dc.b  '-(a1)', CR, LF, 0
decrmnt_addr_2 dc.b  '-(a2)', CR, LF, 0
decrmnt_addr_3 dc.b  '-(a3)', CR, LF, 0
decrmnt_addr_4 dc.b  '-(a4)', CR, LF, 0
decrmnt_addr_5 dc.b  '-(a5)', CR, LF, 0
decrmnt_addr_6 dc.b  '-(a6)', CR, LF, 0
decrmnt_addr_7 dc.b  '-(a7)', CR, LF, 0

*Immediate values prints
pound_sign     dc.b  '#', 0
break          dc.b  CR, LF, 0

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
*-----------------------------------------------------------







*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
