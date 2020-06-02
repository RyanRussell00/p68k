* 
* Testing file.
*

test_org    equ     $5000

            org     test_org

* testing codes
test_start  nop

            * Tests for ea printer
            moveq   #1, d0
            moveq   #0000, d6
            moveq   #255, d7
            moveq   #152, d0

            
*            movem.w a0-a5, -(a6)
*            movem.l (a6)+, a0-a7/d0-d7
*            movem.w a0-a7/d0-d7, -(a0)
*            movem.w d7, -(a3)
*            movem.w a0-a7/d0-d7, -(a6)
            
            
            * Tests for abs.w and abs.l
            move.w  $1, d0
            move.w  $ABCD0123, d0
            move.w  d0, $2
            move.w  d0, $0123DCBA
            
            move.w  $1, $2
            move.w  $1, $12345678
            move.w  $12345678, $1
            move.w  $12345678, $12345678
            
            * Tests for immediate data
            move.b  #$12, d0
            move.w  #$1234, d0
            move.l  #$12345678, d0
            
            * Tests for unsupported EA modes
            move.w  ($AA, a1), ($BB, a2)
            
            * group 1
            move.b  d0, d1
            
            * group 2
            move.l  d0, d1
            movea.l d0, a0
            
            * group 3
            move.w  d0, d1
            movea.w d0, a0
            
            * group 4
            nop
            movem.w a0-a3/d1-d4, -(a6)
            lea     (a0), a1
            not.b   d0
            jsr     (a0)
            rts
            
            * group 5
            addq.b  #$1, d0
            
            * group 6
            bgt     *+6
            bra     *+6
            
            * group 7
            moveq   #$1, d0
            
            * group 8
            or.b    d0, d1
            
            * group 9
            sub.b   d0, d1
            
            * group c
            and.b   d0, d1
            
            * group d
            add.b   d0, d1
            adda.w  a0, a1
            
            * group e
            lsl.b   #$1, d0
            lsr.b   #$1, d0
            asl.b   #$1, d0
            asr.b   #$1, d0
            rol.b   #$1, d0
            ror.b   #$1, d0
                       
test_end    nop






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
