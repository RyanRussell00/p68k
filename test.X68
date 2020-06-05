* 
* Testing file.
*

test_org    equ     $5000

            org     test_org

* testing codes
test_start  nop 

             not    (a0)
top


             ROXL   (a5) *invalid
             ROXR   (a2) *invalid
             lsl    (a1)
             lsr    #2, d2
             
             addq   #4, d0
             not    (a0)
             not    (a0)
             not    (a0)
             not    (a0)
*             BGT    top
*             BGT    last
             
             jsr     mid
             jsr     (a4)
             jsr     $8888
             jsr     $90901111
             jsr     top
                 
             not    (a0)
             not    (a0)
             not    (a0)
             not    (a0)
             not    (a0)
             not    (a0)
mid
             not    (a0)
             not    (a0)
             not    (a0)
             not    (a0)
             not    (a0)
             not    (a0)   

             BGT top       

            not      (a1)
            not      d4
            not      (a1)+
            not      -(a3)
            not      $3321
            not      $99996666

            or      d1, (a1)
            or      $12345555, d4
            or      d3, d4
            or      (a4), d3
            or      (a1)+, d1
            or      -(a3), d5
            or      $3321, d6
            or      d1, (a3)
            or      d3, (a2)+
            or      d4, -(a1)
            or      d7, $1234
            or      d4, $88881111
            
            
            

            lea     $1234, a0
            lea     $5555, a1
            lea     $99999999, a5
            lea     (a2), a6

            sub     #1, d1
            sub     d1, d2
            sub     (a0), d5
            sub     d3, (a5)

            addq    #5, d1
            addq    #2, (a1)
            addq    #3, $5
               
            * Test for ea printer


             movem.w a0-a5, -(a6)
            movem.l (a6)+, a0-a7/d0-d7
            movem.w a0-a7/d0-d7, -(a0)
            movem.w d7, -(a3)
            movem.w a0-a7/d0-d7, -(a6)

            
            
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

            
            bra     top
            
            * extras to test screen limits
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            BGT    top

            
last
            nop


test_end    nop



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
