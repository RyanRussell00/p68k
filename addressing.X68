*-----------------------------------------------------------
* Title      : Addressing Mode Detect
* Descr iption: Detects the addressing mode and prints it to screen
*-----------------------------------------------------------
                
*-----------------------------------------------------------
* //// Given a 6 bit op string it directs it to the correct printer. DOES NOT PRINT MOVEM.
* parameters:
*   d7 - 6 bit binary string that holds the SOURCE op mode/register
*   d6 - 6 bit binary string that holds the DESTINATION op mode/register
*   d5 - set to 1 if destination ea exists, set to 0 otherwise
*   a0 - address of the opcode we are looking at
* return:
*   prints the EA to screen as: [space] SOURCE, [space] DESTINATION

rl_printer      reg     a1-a6/d0-d4 * every reg except parameters/return
printer         move.w  sr, -(sp) * save CCR to stack
                movem.l rl_printer, -(sp) * save current regs to stack
* ---- subroutine code:
                
start_printer   
                clr     d2          *clear everything in the temp register
                
                *print space
                lea     space, a1
                move.b  #14, d0
                trap    #15
                
                *since the original value is untouched, whatever subroutine we call gets the original param
                move.l  d7, d2      *move the parameter into temp register
                
                and.l   #%111000, d2 *mask the temp register to get addressing mode
                
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
                bne     is_incrmnt   *if not equal, try next
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
                move.l  d7, d2      *reset the temp variable with original value
                cmp     #%111100, d2 *immediate
                bne     is_abs_w     *if not equal, try next
                bsr     immdte       
                bra     printer_x

is_abs_w        cmp.l   #%111000, d2 *absolute word
                bne     is_abs_l     *if not equal, try next
                bsr     abs
                bra     printer_x

is_abs_l        cmp.l   #%00111001, d2 *absolute long
                bne     invalid_ea
                bsr     abs
                
invalid_ea     
               lea     invalid, a1 *load message for invalid
               move.b  #14, d0     
               trap    #15         *print to screen
               bra     printer_x

printer_loop    *Check if we have second EA to print
                clr     d5          *clear d5 to prevent infinite loop
                move.l  d6, d7      *move the destination ea to the ea the subroutine looks at
                bsr     print_comma
                bra     start_printer *print second ea
* ---- exit        
printer_x   	   
                cmpi    #1, d5          *if d5 is 1 we have another ea to print
                beq     printer_loop        

                movem.l (sp)+, rl_printer *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Prints EA for MOVEM ONLY!
* parameters:
*   d7 - 6 bit binary string that holds the effective address
*   d6 - 1 bit binary that indicates direction ; Reg to Mem = 0 ; Mem to Reg = 1 ;
*   a0 - address of the opcode we are looking at
* return:
*   prints to screen

rl_movem_printer  reg     a0-a6/d0-d7
movem_printer   move.w  sr, -(sp)
                movem.l rl_movem_printer, -(sp)
* ---- subroutine code:
                
                *Check direction bit to see which way we are going
                cmpi.b  #0, d6      *if direction is reg to mem
                beq     reg_to_mem  *if reg_to_mem go to branch
mem_to_reg
                *print register to save in first, followed by list of registers
                *set d5 to 0 so printer doesnt print source
                clr      d5
                bsr      printer
                bsr      print_comma
                bsr      print_space
                bra      print_registers_list

reg_to_mem
                *print register list first followed by register to save in
                clr     d3
                move.l  #1, d3          *set a flag to print the memory after printing register list
                bsr     print_space
                bra     print_registers_list *print reg list first
                
print_registers_list
                move.l  d7, d1              *save into temp
                andi    #%0000000000100000, d1 *mask to check if precedrement
                cmpi.b  #%00100000, d1       *check mask
                bne     setup_reg_print     *if not predecrement, go to printing
                *if predecrement, set d4 to 1 to tell printer it is predecrement
                clr     d4
                move    #1, d4
                
setup_reg_print
                move.l  #1, d1      *clear the flag to prevent extra slashes from printing
                clr     d5          *clear counter
                addq    #$2, a0     *go to word after opcode
                move.w  (a0), d2    *save the register list mask into data register  
                
                *rotate left 15 times and print if last rotated was 1
print_reg       
                cmpi    #16, d5     *check counter
                bge     movem_printer_x *exit loop if counter >= 16
                rol.w   #1,  d2     *rotate temp to the left by 1
                bcs     reg_found   *print if last carried bit was 1
                addq.b  #1, d5      *increment counter
                bra     print_reg   *repeat loop
                
reg_found       *print register
                cmpi.b  #1, d1      *check if first value. 1 = first value
                beq     no_slash    *if first value, print NO slash
                bsr     print_slash *if not first value, print slash BEFORE register
                bsr     reg_list_printer
                addq.b  #1, d5      *increment counter
                bra     print_reg   *repeat loop
                
no_slash
                clr     d1
                bsr     reg_list_printer
                addq.b  #1, d5      *increment counter
                bra     print_reg   *repeat loop
           
print_mem       
                clr     d4
                clr     d5  *set d5 to 0 so printer doesnt print source
                bsr     print_comma
                bsr     printer
                bra     movem_printer_x     
* ---- exit
movem_printer_x 
                cmpi    #1,d4       *check if flag is set for printing memory
                beq     print_mem
                movem.l (sp)+, rl_movem_printer
                rtr
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Prints data register for MOVEM ONLY!
* parameters:
*   d5 - counter
*   d4 - is predecrement? 1 = true ; 0 = false
* return:
*   prints to screen

rl_reg_list_printer  reg     a0-a6/d0-d7
reg_list_printer move.w  sr, -(sp)
                movem.l rl_reg_list_printer, -(sp)
* ---- subroutine code:

                move.l  d5, d1      *copy counter to d1 cause Im too lazy to change the code below

                cmpi.b  #1, d4      *if predecrement do 15 - counter
                bne     print_a0_list
                *for predecrement only:
                *subtract 15 from d1
                move.l  #15, d3
                sub     d1, d3
                move.l  d3, d1
                
                *For NON predecrement, counter = 0 is A7 and counter = 15 is D0
                *For PREDECREMENT: We do 15 - counter, so we get: counter = 0 is A7 and counter = 15 = D0
                
print_a0_list   cmp     #7, d1        *compare to see if a0
                bne     print_a1_list   *if not d0 try d1
                lea     direct_addr_0, a1   *load the message for d0
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine
 
print_a1_list   cmp     #6, d1    *compare to see if a1
                bne     print_a2_list        *if not, try next
                lea     direct_addr_1, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine
                
print_a2_list   cmp     #5, d1    *compare to see if a2
                bne     print_a3_list       *if not, try next
                lea     direct_addr_2, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine
                
print_a3_list   cmp     #4, d1    *compare to see if a3
                bne     print_a4_list       *if not, try next
                lea     direct_addr_3, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine

print_a4_list   cmp     #3, d1    *compare to see if a4
                bne     print_a5_list        *if not, try next
                lea     direct_addr_4, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine
                
print_a5_list   cmp     #2, d1    *compare to see if a5
                bne     print_a6_list        *if not, try next
                lea     direct_addr_5, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine
                
print_a6_list   cmp     #1, d1    *compare to see if a6
                bne     print_a7_list        *if not, try next
                lea     direct_addr_6, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen     
                bra     reg_list_printer_x  *exit the subroutine

print_a7_list   cmp     #0, d1    *compare to see if a7
                bne     print_d0_list  *if not, try next
                lea     direct_addr_7, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen

print_d0_list   cmp     #15, d1   *compare to see if d0
                bne     print_d1_list        *if not d0 try d1
                lea     direct_data_0, a1   *load the message for d0
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine
 
print_d1_list   cmp     #14, d1    *compare to see if d1
                bne     print_d2_list        *if not, try next
                lea     direct_data_1, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine
                
print_d2_list   cmp     #13, d1    *compare to see if d2
                bne     print_d3_list        *if not, try next
                lea     direct_data_2, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine
                
print_d3_list   cmp     #12, d1    *compare to see if d3
                bne     print_d4_list        *if not, try next
                lea     direct_data_3, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine

print_d4_list   cmp     #11, d1    *compare to see if d4
                bne     print_d5_list        *if not, try next
                lea     direct_data_4, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine
                
print_d5_list   cmp     #10, d1    *compare to see if d5
                bne     print_d6_list        *if not, try next
                lea     direct_data_5, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                bra     reg_list_printer_x  *exit the subroutine
                
print_d6_list   cmp     #9, d1    *compare to see if d6
                bne     print_d7_list        *if not, try next
                lea     direct_data_6, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen     
                bra     reg_list_printer_x  *exit the subroutine

print_d7_list   cmp     #8, d1    *compare to see if d7
                bne     reg_list_printer_x  *if not, try next
                lea     direct_data_7, a1   *load the message
                move.b  #14, d0         *set trap
                trap    #15             *print to screen                
                
* ---- exit
reg_list_printer_x 
                
                movem.l (sp)+, rl_reg_list_printer
                rtr
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Prints immediate data as decimal
* parameters:
*   d7 - 6 bit data register mode and register number (must always be Data Register) 
*   a0 - address of instruction
* return:
*   prints to screen the decimal value of the hex value

rl_moveq_printer       reg     a1-a6/d0-d6      * every reg except parameters/return
moveq_printer   move.w  sr, -(sp)        * save CCR to stack
                movem.l rl_moveq_printer, -(sp) * save current regs to stack
* ---- subroutine code:
                               
                lea     pound_sign, a1  *load the pound sign to print
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                
                lea     dollar_sign, a1 *print hex dollar sign
                move.b  #14, d0 
                trap    #15        

                clr     d1
                move.w  (a0), d1 *move instruction into register
                andi    #%0000000011111111, d1
                *since we get a byte, we only get the data (8 bits) at the front
                bsr     print_hex_w     *print value as hex word  
                
                bsr     print_comma
                bsr     print_space
                
                *print data register
                bsr     data_reg
                
* ---- exit        
moveq_printer_x   		movem.l (sp)+, rl_moveq_printer *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------
    
*-----------------------------------------------------------
* //// Read data register addressing mode
* parameters:
*   d7 - 6 bit binary string that holds the data mode and data register
*
rl_data_reg      reg     a0-a6/d0-d7 * every reg except parameters/return

data_reg        move.w  sr, -(sp) * save CCR to stack
                movem.l rl_data_reg, -(sp) * save current regs to stack
* ---- subroutine code:
                
                move.l  d7, d1          *Save the contents of original val in a temp registry
                and.b   #%111000, d7    *if the first 3 bits is 000 it will save 000000
                cmp     #%0, d7         *if 0 then we have a data register addressing mode
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
*   d7 - 6 bit binary string that holds the address mode and address register
*
rl_addr_reg      reg     a0-a6/d0-d7 * every reg except parameters/return

addr_reg        move.w  sr, -(sp)    * save CCR to stack
                movem.l rl_addr_reg, -(sp) * save current regs to stack
* ---- subroutine code:
                
                move.l  d7, d1          *Save the contents in a temp registry
                and.b   #%111000, d7    *mask opmode to expected opmode
                cmp     #%001000, d7    *check mask result to make its expected
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
*   d7 - 6 bit binary string that holds the address mode and address register
*
rl_ind_addr_reg      reg     a0-a6/d0-d7 * every reg except parameters/return

ind_addr_reg    move.w  sr, -(sp)    * save CCR to stack
                movem.l rl_ind_addr_reg, -(sp) * save current regs to stack
* ---- subroutine code:
                
                move.l  d7, d1          *Save the contents of d0 in a temp registry
                and.b   #%111000, d7    *mask opmode to expected opmode
                cmp     #%010000, d7    *check mask result to make its expected
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
*   d7 - 6 bit binary string that holds the address mode and address register
*
rl_inc_addr_reg      reg     a0-a6/d0-d7 * every reg except parameters/return

inc_addr_reg    move.w  sr, -(sp)    * save CCR to stack
                movem.l rl_inc_addr_reg, -(sp) * save current regs to stack
* ---- subroutine code:
                
                move.l  d7, d1          *Save the contents of d0 in a temp registry
                and.b   #%111000, d7    *mask opmode to expected opmode
                cmp     #%011000, d7    *check mask result to make its expected
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
*   d7 - 6 bit binary string that holds the address mode and address register
*
rl_dec_addr_reg      reg     a0-a6/d0-d7 * every reg except parameters/return

dec_addr_reg    move.w  sr, -(sp)    * save CCR to stack
                movem.l rl_dec_addr_reg, -(sp) * save current regs to stack
* ---- subroutine code:
                
                move.l  d7, d1          *Save the contents of d0 in a temp registry
                and.b   #%111000, d7    *mask opmode to expected opmode
                cmp     #%100000, d7    *check mask result to make its expected
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
                
                cmp     #%111100, d7     *check op to ensure its expected
                bne     immdte_x         *if not expected, exit subroutine
                
                lea     pound_sign, a1  *load the pound sign to print
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                
                lea     dollar_sign, a1 *print hex dollar sign
                move.b  #14, d0 
                trap    #15
                
                *Since we print source then destination, if we are printing source A0 is the opcode
                *...if we are printing destination, A0 is the source. So by adding 2 (word size)
                *...we get the next additional data in memory
                
                *Read the additional data at A0 (the opcode) + 2 (the next word)
                addq.l  #$2, a0
                move.w  (a0), d1
                bsr     print_hex_w     *print value as hex word
                
* ---- exit        
immdte_x   		movem.l (sp)+, rl_immdte *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Prints absolute value of the data as ASCII
* parameters:
*   d7 - op mode and op register
*   a0 - address of opcode
* return:
*   prints to screen the decimal value of the absolute value

rl_abs          reg     a1-a6/d0-d7     * every reg except parameters/return
abs             move.w  sr, -(sp)       * save CCR to stack
                movem.l rl_abs, -(sp)   * save current regs to stack

* ---- subroutine code:
                
                cmp     #%111000, d7    *check op to see if abs short
                beq     abs_short
                
                cmp     #%111001, d7    *check op to see if abs long
                bne     abs_x           *if not, exit
                
abs_long        
                lea     dollar_sign, a1 *load the pound sign to print
                move.b  #14, d0         *set trap
                trap    #15             *print to screen
                
                *Since we print source then destination, if we are printing source A0 is the opcode
                *...if we are printing destination, A0 is the source. So by adding 2 (word size)
                *...we get the next additional data in memory
                
                *Read the additional data at A0 (the opcode) + 2, then move forward by 2
                addq    #2, a0
                move.l  (a0), d1
                bsr     print_hex_l
                *Since we printed long we need to move forward 4 bytes...
                *...the next time we call this function it moves forward 2 bytes, so we add 2 here.
                addq    #2, a0
                bra     abs_x                

abs_short       

                lea     dollar_sign, a1 *load the pound sign to print
                move.b  #14, d0         *set trap
                trap    #15             *print to screen

                *Read the additional data at A0 (the opcode) + 2 (the next word)
                addq    #2, a0
                move.W  (a0), d1
                bsr     print_hex_w

* ---- exit        
abs_x   		movem.l (sp)+, rl_abs *restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// reset printer
* parameters:
*   d7 - source ea
*   d6 - destination ea
*   d5 - destination exists flag
*   a0 - opcode address
* return:
*   clears all parameters
*
rl_reset_printer reg     a1-a6/d0-d4 * every reg except parameters/return
reset_printer    move.w  sr, -(sp) * save CCR to stack
                 movem.l rl_reset_printer, -(sp) * save current regs to stack
* ---- subroutine code:
                
                clr     d7
                clr     d6
                clr     d5
                clr     (a0)
                
* ---- exit        
reset_printer_x movem.l (sp)+, rl_reset_printer * restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

**-----------------------------------------------------------
** //// print long (32 bits) as hex digit
** parameters:
**   d1 - contains word to print as hex
** return:
**   none
**
*rl_print_hex_l  reg     a0-a6/d0-d7
*print_hex_l     move.w  sr, -(sp)
*                movem.l rl_print_hex_l, -(sp)
** ---- subroutine code:
*                
*                swap    d1              *flip long or else it prints in reverse
*                bsr     print_hex_w     *print first half of long
*                swap    d1              *flip first half of register to second half
*                bsr     print_hex_w     *print rest of long
*                
** ---- exit
*print_hex_l_x   movem.l (sp)+, rl_print_hex_l
*                rtr
**-----------------------------------------------------------                

**-----------------------------------------------------------
** //// print word (16 bits) as hex digit
** parameters:
**   d1 - contains word to print as hex
** return:
**   none
**
*rl_print_hex_w  reg     a0-a6/d0-d7
*print_hex_w     move.w  sr, -(sp)
*                movem.l rl_print_hex_w, -(sp)
** ---- subroutine code:
*                
*                rol.w   #$4, d1 * rotate first 4 bits to last 4 bits
*                bsr     print_hex_n
*                rol.w   #$4, d1
*                bsr     print_hex_n
*                rol.w   #$4, d1
*                bsr     print_hex_n
*                rol.w   #$4, d1
*                bsr     print_hex_n
*                
** ---- exit
*print_hex_w_x   movem.l (sp)+, rl_print_hex_w
*                rtr
**-----------------------------------------------------------

**-----------------------------------------------------------
** //// print nibble (4 bits) as hex digit
** parameters:
**   d1 - contains nibble to print as hex
** return:
**   none
**
*rl_print_hex_n  reg     a0-a6/d0-d7
*print_hex_n     move.w  sr, -(sp)
*                movem.l rl_print_hex_n, -(sp)
** ---- subroutine code:
*                
*                andi.b  #%00001111, d1 * clear first 4 bits
*                addi.b  #$30, d1 * ASCII offset to start at char 0
*                cmpi.b  #$39, d1 * check if above ASCII $39
*                ble     pr_hn_skip1 * hex $0-9 can be safely printed
*                addi.b  #$7, d1 * hex $A-F needs another ASCII offset
*                
*pr_hn_skip1     move.b  #6, d0 * display char at d1.b
*                trap    #15
*                
** ---- exit
*print_hex_n_x   movem.l (sp)+, rl_print_hex_n
*                rtr
**-----------------------------------------------------------

*-----------------------------------------------------------
* //// print comma
* parameters:
*   none
* return:
*   prints comma to screen
*
rl_print_comma  reg     d0
print_comma     move.w  sr, -(sp)
                movem.l rl_print_comma, -(sp)
* ---- subroutine code:
                *print comma
                lea     comma, a1   *load the message for d0
                move.b  #14, d0     *set trap
                trap    #15         *print to screen     
* ---- exit
print_comma_x   movem.l (sp)+, rl_print_comma
                rtr
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// print slash
* parameters:
*   none
* return:
*   prints slash to screen
*
rl_print_slash  reg     d0
print_slash     move.w  sr, -(sp)
                movem.l rl_print_slash, -(sp)
* ---- subroutine code:
                *print slash
                lea     slash, a1   *load the message for d0
                move.b  #14, d0     *set trap
                trap    #15         *print to screen     
* ---- exit
print_slash_x   movem.l (sp)+, rl_print_slash
                rtr
*-----------------------------------------------------------

*-----------------------------------------------------------
* //// Tests for the EA printer
*
rl_printer_tests    	reg     a0-a6/d0-d7 * every reg except parameters/return
printer_tests    move.w  sr, -(sp) * save CCR to stack
                    movem.l rl_printer_tests, -(sp) * save current regs to stack
* ---- subroutine code:
                
    *Tests for MOVEM
    bsr     reset_printer
    move    #%100000, d7        *EA = -(a0)
    move.l  #0,d6              *direction = reg to mem
    move.l  #$48A0E000, (a0)   *Registers = D0/D1/D2
    bsr     movem_printer    

    bsr     reset_printer
    move    #%100000, d7        *EA = -(a0)
    move.l  #0,d6              *direction = mem to reg
    move.l  #$48A0FFFF, (a0)   *Registers = All
    bsr     movem_printer               
    
*    *Tests for data register
*    bsr     reset_printer
*    move.b  #%000111, d7
*    move.b  #%000110, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%000101, d7
*    move.b  #%000100, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%000011, d7
*    move.b  #%000010, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%000001, d7
*    move.b  #%000000, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%000111, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%000010, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%000000, d7
*    move.b  #0, d5
*    bsr     printer
*     
*    *Tests for direct address register
*    bsr     reset_printer
*    move.b  #%001111, d7
*    move.b  #%001110, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%001101, d7
*    move.b  #%001100, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%001011, d7
*    move.b  #%001010, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer 
*    move.b  #%001001, d7
*    move.b  #%001000, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%001111, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%001010, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%001000, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    *Tests for INDIRECT address register
*    bsr     reset_printer
*    move.b  #%010111, d7
*    move.b  #%010110, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%010101, d7
*    move.b  #%010100, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%010011, d7
*    move.b  #%010010, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%010001, d7
*    move.b  #%010000, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%010111, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%010010, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%010000, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    *Tests for INCREMENT address register
*    bsr     reset_printer
*    move.b  #%011111, d7
*    move.b  #%011110, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%011101, d7
*    move.b  #%011100, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%011011, d7
*    move.b  #%011010, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%011001, d7
*    move.b  #%011000, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%011111, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%011010, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%011000, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    *Tests for DECREMENT address register
*    bsr     reset_printer
*    move.b  #%100111, d7
*    move.b  #%100110, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%100101, d7
*    move.b  #%100100, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%100011, d7
*    move.b  #%100010, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%100001, d7
*    move.b  #%100000, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%100111, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%100010, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    move.b  #%100000, d7
*    move.b  #0, d5
*    bsr     printer
*    
*    *Test for Immediate
*    
*    *immediate source test
*    bsr     reset_printer
*    lea     $0000, a0
*    move.b  #%111100, d7 *set source (immediate value) to print
*    move.l  #$1E3CFFFF, (a0) *opcode and additional data
*    move.l  #0, d5          *destination exists flag = false
*    bsr     printer
*   
*    bsr     reset_printer
*    lea     $0000, a0
*    move.b  #%111100, d7
*    move.w  #$ABCD, (a0) *opcode
*    movea   a0, a1
*    addq    #2, a1 *go to 1st additional word
*    move.w  #$4202, (a1)
*    addq    #2, a1 *go to 2nd additional word
*    move.w  #$6969, (a1)
*    move.b  #%111100, d6
*    move.l  #1, d5              *destination exists flag = true
*    bsr     printer
*    
*    bsr     reset_printer
*    lea     $0000, a0
*    move.b  #%111100, d7
*    move.l  #%001111, d6
*    move.b  #1, d5
*    bsr     printer
*    
*    bsr     reset_printer
*    lea     $0000, a0
*    move.b  #%111100, d7
*    move.l  #%01111111111111111111111111111111, (a0)
*    move.b  #0, d5
*    bsr     printer
*    
*    *Test for absolute
*    bsr     reset_printer
*    lea     $0000, a0
*    move.b  #%111000, d7
*    move.l  #$1E3C0AAA, (a0) *opcode and additional data
*    bsr     printer
*    
*    bsr     reset_printer
*    lea     $0000, a0
*    move.b  #%111001, d7
*    move.w  #$ABCD, (a0) *opcode
*    movea   a0, a1
*    addq    #2, a1 *go to 1st additional word
*    move.w  #$4202, (a1)
*    addq    #2, a1 *go to 2nd additional word
*    move.w  #$6969, (a1)
*    move.b  #%100111, d6
*    move.l  #1, d5              *destination exists flag = true
*    bsr     printer
                
* ---- exit        
printer_tests_x   		movem.l (sp)+, rl_printer_tests * restore old registers
                rtr * restore CCR, exit subroutine
*-----------------------------------------------------------

invalid     dc.b    'BAD EA', 0

*direct data registers print
direct_data_0 dc.b    'd0', 0
direct_data_1 dc.b    'd1', 0
direct_data_2 dc.b    'd2', 0
direct_data_3 dc.b    'd3', 0
direct_data_4 dc.b    'd4', 0
direct_data_5 dc.b    'd5', 0
direct_data_6 dc.b    'd6', 0
direct_data_7 dc.b    'd7', 0

*direct address registers print
direct_addr_0 dc.b    'a0', 0
direct_addr_1 dc.b    'a1', 0
direct_addr_2 dc.b    'a2', 0
direct_addr_3 dc.b    'a3', 0
direct_addr_4 dc.b    'a4', 0
direct_addr_5 dc.b    'a5', 0
direct_addr_6 dc.b    'a6', 0
direct_addr_7 dc.b    'a7', 0

*INDIRECT address registers print
indirect_addr_0 dc.b  '(a0)', 0
indirect_addr_1 dc.b  '(a1)', 0
indirect_addr_2 dc.b  '(a2)', 0
indirect_addr_3 dc.b  '(a3)', 0
indirect_addr_4 dc.b  '(a4)', 0
indirect_addr_5 dc.b  '(a5)', 0
indirect_addr_6 dc.b  '(a6)', 0
indirect_addr_7 dc.b  '(a7)', 0

*INCREMENT address registers print
incrmnt_addr_0 dc.b  '(a0)+', 0
incrmnt_addr_1 dc.b  '(a1)+', 0
incrmnt_addr_2 dc.b  '(a2)+', 0
incrmnt_addr_3 dc.b  '(a3)+', 0
incrmnt_addr_4 dc.b  '(a4)+', 0
incrmnt_addr_5 dc.b  '(a5)+', 0
incrmnt_addr_6 dc.b  '(a6)+', 0
incrmnt_addr_7 dc.b  '(a7)+', 0

*DECREMENT address registers print
decrmnt_addr_0 dc.b  '-(a0)', 0
decrmnt_addr_1 dc.b  '-(a1)', 0
decrmnt_addr_2 dc.b  '-(a2)', 0
decrmnt_addr_3 dc.b  '-(a3)', 0
decrmnt_addr_4 dc.b  '-(a4)', 0
decrmnt_addr_5 dc.b  '-(a5)', 0
decrmnt_addr_6 dc.b  '-(a6)', 0
decrmnt_addr_7 dc.b  '-(a7)', 0

*Immediate values prints
pound_sign     dc.b  '#', 0
dollar_sign    dc.b  '$', 0
*Utility
break          dc.b  CR, LF, 0
comma          dc.b  ',' , 0
slash          dc.b  '/', 0
























*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
