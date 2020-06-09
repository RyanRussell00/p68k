* 
* Testing file.
*

test_org    equ     $5000

            org     test_org

* testing codes
test_start            

            movem.l a4/d5, $9999
            movem.l a2-a5/d0/d4-d6, -(sp)
            movem.l $22223333, d3/a7/d1-d4

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
            move.b      d1, (a1)
            move.b      $12345555, d4
            move.b      d3, d4
            move.b      (a4), d3
            move.b      (a1)+, d1
            move.b      -(a3), d5
            move.b      $3321, d6
            move.b      d1, (a3)
            move.b      d3, (a2)+
            move.b      d4, -(a1)
            move.b      d7, $1234
            move.b      d4, $88881111
            
            * group 2
            move.l      d1, (a1)
            move.l      $12345555, d4
            move.l      d3, d4
            move.l      (a4), d3
            move.l      (a1)+, d1
            move.l      -(a3), d5
            move.l      $3321, d6
            move.l      d1, (a3)
            move.l      d3, (a2)+
            move.l      d4, -(a1)
            move.l      d7, $1234
            move.l      d4, $88881111
            movea.l     d0, a0
            movea.l     a0, a7
            movea.l    (a2)+, a1
            movea.l    $1111, a3
            movea.l    #$9999, a6 
             
            * group 3
            move.w      d1, (a1)
            move.w      $12345555, d4
            move.w      d3, d4
            move.w      (a4), d3
            move.w      (a1)+, d1
            move.w     -(a3), d5
            move.w      $3321, d6
            move.w      d1, (a3)
            move.w      d3, (a2)+
            move.w      d4, -(a1)
            move.w      d7, $1234
            move.w      d4, $88881111
            movea.w     d0, a0
            movea.w     a0, a7
            movea.w     (a2)+, a1
            movea.w     $1111, a3
            movea.w     #$9999, a6 
            
            * group 4
            nop
            movem.w a0-a3/d1-d4, -(a6)
            movem.w a0-a5, -(a6)
            movem.l (a6)+, a0-a7/d0-d7
            movem.w (a0)+, d3/a2/d4/a0/a7/d1
            movem.w (a7)+, a2/d2/a4/d0/a7/d1
            movem.w a0-a7/d0-d7, -(a0)
            movem.w d7, -(a3)
            lea     (a0), a1
            lea     $1111, a4
            lea     $99990444, a0
            not.b   d0
            not.w   (a0)
            not.l   (a7)+
            not.b   -(a0)
            not.w   $3333
            not.l   $22229999
            jsr     (a0)
            jsr     $2333
            jsr     $22224444
            rts
            
            * group 5
            addq.b  #$1, d0
            addq.w  #8, a0
            addq.l  #3, (a7)+
            addq.b  #4, -(a4)
            addq.w  #1, $3333
            addq.l  #8, $22229999
            
            * group 6
            bgt     *+6
            ble     $3210
            beq     *-2
            ble     *-32
            beq     *+32
            bra     *+6
            bra     $5555
            
            * group 7
            moveq   #$1, d0
            moveq   #128, d0
            moveq   #55, d7
            moveq   #0, d4
            
            * group 8
            or.b      d1, (a1)
            or.w      $12345555, d4
            or.l      d3, d4
            or.b      (a4), d3
            or.w      (a1)+, d1
            or.l      -(a3), d5
            or.b      $3321, d6
            or.w      d1, (a3)
            or.l      d3, (a2)+
            or.b      d4, -(a1)
            or.w      d7, $1234
            or.l      d4, $88881111
            
            * group 9
            sub.b     d1, (a1)
            sub.w     $12345555, d4
            sub.l     d3, d4
            sub.b     (a4), d3
            sub.w      (a1)+, d1
            sub.l      -(a3), d5
            sub.b      $3321, d6
            sub.w      d1, (a3)
            sub.l      d3, (a2)+
            sub.b      d4, -(a1)
            sub.w      d7, $1234
            sub.l      d4, $88881111
            
            * group c
            and.b     d1, (a1)
            and.w     $12345555, d4
            and.l     d3, d4
            and.b     (a4), d3
            and.w      (a1)+, d1
            and.l      -(a3), d5
            and.b      $3321, d6
            and.w      d1, (a3)
            and.l      d3, (a2)+
            and.b      d4, -(a1)
            and.w      d7, $1234
            and.l      d4, $88881111
            
            * group d
            add.b     d1, (a1)
            add.w     $12345555, d4
            add.l     d3, d4
            add.b     (a4), d3
            add.w      (a1)+, d1
            add.l      -(a3), d5
            add.b      $3321, d6
            add.w      d1, (a3)
            add.l      d3, (a2)+
            add.b      d4, -(a1)
            add.w      d7, $1234
            add.l      d4, $88881111
            adda.w  a0, a1
            adda.l  d0, a7
            adda.w  (a0), a0
            adda.w  (a3)+, a7
            adda.l  -(a7), a3
            adda.w  $3333, a0
            adda.l  $99992222, a7
            adda.w  #9999, a2
            
            * group e
             ROXL   (a5) *invalid
             ROXR   (a2) *invalid
             ROXL   #2, d5 *invalid
             ROXR   #7, d7 *invalid
             lsl    (a1)
             asl    -(a0)
             asl    (a7)+
             asr    $1245
             asl    $12349876
             lsr    #2, d2
             lsl    #1, d0
             asl    #8, d7
             lsr    #4, d5
             
             ror    (a3)
             ror    (a0)+
             ror    -(a7)
             rol    $3333
             rol    $12346789
             rol    #1, d0
             rol    #5, d5
             rol    #8, d7
            nop

test_end    nop












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
