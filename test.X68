* 
* Testing file.
*

test_org    equ     $5000

            org     test_org

* testing codes
test_start  nop
            
            * group 1
            move.b  d1, d2
            
            * group 2
            move.l  d0, d1
            movea.l d0, a0
            
            * group 3
            move.w  d0, d1
            movea.w d0, a0
            
            * group 4
            nop
            movem   a0-a3/d1-d4, (a6)
            lea     (a0), a1
            not     d0
            jsr     (a0)
            rts
            
test_end    nop

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
