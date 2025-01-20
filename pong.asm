*=$1000
//
// - INITIALISATION --------------------
//
START:  nop
        lda #$14            // SETTING SPRITE GFX
        sta $07F8 
        sta $07F9           // SPRITE POS INIT
        lda #$20 
        sta $D000           // P1.X
        lda #$82 
        sta $D001           // P1.Y
        lda #$20 
        sta $D002           // P2.X
        lda #$82 
        sta $D003           // P2.Y
        lda #$AC 
        sta $D004           // BALL.X
        lda #$8A 
        sta $D005           // BALL
        lda #$26 
        sta $07F8           // SPRITE GFX P1
        sta $07F9           // SPRITE GFX P2
        lda #$27 
        sta $07FA           // SPRITE GFX BALL
        lda #$0F 
        sta $D017           // SPRITE H STRETCH
        lda #$02 
        sta $D010           // SET P2.X HIGH BIT
        lda #$0F            //  (X IS 9BIT)
        sta $D015           // ENABLE SPRITES
        lda #$0F            //  (BITFIELD)
        sta $D01D           // SPRITE V STRETCH
        lda #$06 
        sta $D020           // BORDER COLOR
        lda #$05 
        sta $D021           // BG COLOR
        lda #$01 
        sta $D027           // P1.COLOR
        lda #$01 
        sta $D028           // P2.COLOR
        lda #$01 
        sta $D029           // BALL.COLOR
        lda #$A0 
        sta $D006           // SCOREBOARD.X
        lda #$32 
        sta $D007           // SCOREBOARD.Y
        lda #$01 
        sta $D02A           // SCOREBOARD.COLOR
        lda #$38 
        sta $07FB           // SCOREBOARD GRAPHICS
        lda #$00 
        sta $0BF0           // BALL.X.DIRECTION
        sta $0BF1           // BALL.Y.DIRECTION
        sta $0BFE           // P2.SCORE
        sta $0BFF           // P1.SCORE
        ldx #$00            // CLS
        lda #$20            // SPACE
LBL_1:  sta $0400,X         // SCREEN LOC 0400-07F0
        sta $0500,X         // 40X25=1000
        sta $0600,X 
        sta $06F0,X 
        inx
        bne LBL_1 
        lda $D011 
        and #$EF            // DISABLE DISPLAY 
        sta $D011 
        ldx #$C0 
LBL_2:  ldy #$00
LBL_3:  jsr BLEEP           // BEEP SOUND
        iny
        bne LBL_3 
        inc $D020           // BLINK SCREEN
        inx
        bne LBL_2           // REPEAT
        lda #$00 
        sta $D020           // SET BORDER BLACK
        sta $D021           // SET BG BLACK
        lda $D011 
        ora #$10            // ENABLE DISPLAY
        sta $D011 
        jmp SCORE_INIT
//
// - SPRITE SCORE CLEAR ----------------
//
SCORE_INIT: lda #$00
            ldx #$40        // CLEAR 64 BYTES
LBL_4:      sta $0E00,X     // SBOARD SPRITE AT 0E00
            dex
            bne LBL_4
            lda #$3C
            sta $0E07
            sta $0E0A       // PLACE A DOT
            sta $0E0D       // BETWEEN PLAYER SCORES
            sta $0E10
            jmp GAME_LOOP
//
// - MAIN LOOP -------------------------
//
GAME_LOOP:  jsr PLAYER_MOV
            jsr BALL_MOV
            jsr SLOWDOWN
            jsr GOAL_CHECK
            jsr SCORE_REND
            jsr WIN_CHECK
            jsr COLL_CHEK
            jmp GAME_LOOP
//
// - PLAYER MOVEMENT -------------------
//
PLAYER_MOV: lda $DC00       // GET JOYS #2
            and #$02        // CHECK DOWN
            bne LBL_5 
            inc $D001       // MOVE P1 DOWN
            inc $D001 
            inc $D01 
LBL_5:      lda $DC00       // CHECK UP
            and #$01 
            bne LBL_6 
            dec $D001       // MOVE P1 UP
            dec $D001 
            dec $D001
LBL_6:      jsr LBL_7
            nop
            nop
            nop
            nop
            nop
            ldx #$02        // CHECK WALL
LBL_10:     lda $D001,X     // GET PLAYER Y
            cmp #$32        // CHECK IF TO HIGH
            bcs LBL_8 
            lda #$32        // CLAMP
            sta $D001,X 
LBL_8:      lda $D001,X     // GET PLAYER Y
            cmp #$CF        // CHECK IF TO LOW
            bcc LBL_9 
            lda #$CF        // CLAMP
            sta $D001,X
LBL_9:      dex
            dex
            beq LBL_10      // LOOP FOR 2 PLAYERS
            lda $DC00       // CHECK IF ONLY ONE
            eor $DC01       // FIRE BTN IS PRESSED
            and #$10 
            bne LBL_11      // IF NOT UPD BALL
            jsr BALL_MOV    // 3 TIMES
            jsr BALL_MOV    // OTHERWISE BALL
            jsr BALL_MOV    // IS 4 TIMES SLOWER
LBL_11:     rts
            rts
            brk 
LBL_7:      lda $DC01       // PLAYER 2 JOY CHECK
            and #$02        // POLL JOY #1
            bne LBL_12      // CHECK DOWN
            inc $D003 
            inc $D003 
            inc $D003 
LBL_12:     lda $DC01       // POLL JOY #1
            and #01 
            bne LBL_13      // CHECK UP
            dec $D003 
            dec $D003       // MOVE UP
            dec $D003
LBL_13:     rts
//
// - BALL MOVEMENT ---------------------
//
BALL_MOV:   lda $0BF0    
            beq LBL_14      // CHECK BALL H DIR
            inc $D004       // IF 0 - MOVE RIGHT
            jmp LBL_15
LBL_14:     dec $D004       // IF 1 - MOVE LEFT
LBL_15:     lda $0BF1
            beq LBL_16      // CHECK BALL V DIR
            inc $D005       // IF 0 - MOVE DOWN
            jmp LBL_17
LBL_16:     dec $D005       // IF 1 - MOVE UP
LBL_17:     lda $D004       // CHECK FOR X OVERFLOW 
            ldx $0BF0       // TO SETUP THE 9BIT
            beq LBL_18      // CHECK FOR 00 OR FF
            eor #$FF        // DEPENDS ON DIR
LBL_18:     and #$FF
            bne LBL_19      // IF OVERFLOW
            lda $D010       // SET HIGHBIT OF
            eor #$04        // SPRITE 3 TO 1
            sta $D010
LBL_19:     ldy #$20        // SET BLEEP PITCH
            lda $D005       // GET BALL Y
            cmp #$32        // CHECK IF TOO HIGH
            bcs LBL_20  
            lda #$01        // CHANGE DIRECTION
            sta $0BF1
            jsr BLEEP
LBL_20:     lda $D005       // GET BALL Y
            cmp #$F0        // CHECK IF TO LOW
            bcc LBL_21
            lda #$00        // CHANGE DIRECTION
            sta $0BF1
            jsr BLEEP   
LBL_21:     rts
//
// - GOAL CHECK ------------------------
//
GOAL_CHECK: lda $D010       // CHECK HIGHT OF 
            and #$04        // BALL SPRITE
            bne LBL_22      // IF H.BIT IS DISABLED
            lda $D004       // BALL IS ON THE LEFT
            cmp #$10
            bcc LBL_23      // CHK 16 < BALL.X < 32
            cmp #$20
            bcs LBL_23
            inc $0BFE       // INCREASE SCORE
            jsr BALL_RST
LBL_23:     rts
LBL_22:     lda $D004       // IF H.BIT IS ENABLED
            cmp #$F0        // BALL IS ON THE RIGHT
            bcs LBL_24
            cmp #$60
            bcc LBL_24      // CHK 384 < BALLX < 496
            inc $0BFF
            jsr BALL_RST
LBL_24:     rts
//
// - SCORE RENDER ----------------------
//
SCORE_REND: lda $0BFF       // LOAD P1 SCORE
            and #$0F
            asl             // MULTIPLY BY 8
            asl
            asl
            tax
            lda #$08        // SET COUNTER VAR TO 8
            sta $C000
            ldy #$00
LBL_25:     lda $0930,X     // LOAD NUMBER GFX LINE
            sta $0E00,Y     // STORE LINE IN SPRITE
            inx             // INC NUM GFX LINE
            iny             // INC SPRITE LINE
            iny             // SPRITES=3 BYTES WIDE
            iny             // =24 PIXELS
            dec $C000
            bne LBL_25      // REPEAT FOR 8 LINES
            lda $0BFE       // LOAD P2 SCORE
            and #$0F
            asl             // MULTIPLY NY 8
            asl
            asl
            tax
            lda #$08        // COUNTER TO 8 LINES
            sta $C000       // 
            ldy #$00
LBL_26:     lda $0930,X     // LOAD NUM GFX LINE
            sta $0E02,Y     // STORE IN SPRITE
            inx             // INC NUM GFX LINE
            iny             // INC SPRITE LINE
            iny
            iny
            dec $C000
            bne LBL_26      // REPEAT 8 TIMES
            rts
//
// - MATCH OVER CHECK ------------------
//
WIN_CHECK:  lda $0BFE       // CHECK P2 SCORE
            cmp #$0A        // IF >= 10
            bcc LBL_27
            jmp START       // RESET IF YES
LBL_27:     lda $0BFF       // GET P1 SCORE
            cmp #$0A        // IF >= 10
            bcc LBL_28
            jmp START       // RESET IF YES
LBL_28:     rts
//
// - SPRITE COLLISION ------------------
//
COLL_CHEK:  ldy #$40        // SET BLEEP PITCH
            lda $D01E       // POLL SPRITE COLLISION
            tax
            and #$01
            beq LBL_29      // IF P1 IS COLLIDING
            lda #$01        // CHANGE BALL DIR.
            sta $0BF0
            jsr BLEEP
LBL_29:     txa
            and #$02
            beq LBL_30      // IF P2 IS COLLIDING
            lda #$00        // CHANGE BALL DIR.
            sta $0BF0
            jsr BLEEP
LBL_30:     rts
//
// - SLOWDOWN --------------------------
//
SLOWDOWN:   ldx $0BF2       // LOAD SPEED VALUES
LBL_32:     ldy $0BF3
LBL_31:     nop
            nop
            nop
            dey
            bne LBL_31
            dex             // LOOPCEPTION UNTIL DONE
            bne LBL_32
            rts
//
// - BALL RESET ------------------------
//
BALL_RST:   lda #$AC     
            sta $D004       // SET BALL.X
            lda #$8A
            sta $D005       // SET BALL.Y
            lda $D010
            and #$FB        // CLEAR 9TH BIT
            sta $D010       // OF BALL.X
            lda $0BF0
            eor #$01        // TOGGLE DIRECTION
            sta $0BF0
            ldy #$10        // SET BLEEP PITCH
            jsr BLEEP
            rts
//
// - PLAY SOUND ------------------------
//
BLEEP:      sty $D401       // H.byte OF FREQ TO Y
            lda #$20        // L.byte OF FREQ TO 32
            sta $D400       // 
            lda #$0F        // SET DECAY TO 15
            sta $D405
            lda #$F4        // SET RELEASE TO 4
            sta $D406
            lda #$11        // SET TRIANGLE WAVE
            sta $D404
            lda #$0F        // SET VOLUME TO 15
            sta $D418
            lda #$10        // STOP PLAYING NOTE
            sta $D404
            rts
//
// = DATA ==============================
//
// NUMBER GRAPHICS
//
NUMBER:     .byte $FF,$FF,$E7,$E7,$E7,$E7,$FF,$FF
            .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
            .byte $FF,$FF,$0F,$FF,$FF,$F0,$FF,$FF
            .byte $FF,$FF,$0F,$3F,$3F,$0F,$FF,$FF
            .byte $E7,$E7,$E7,$FF,$FF,$07,$07,$07
            .byte $FF,$FF,$F0,$FF,$FF,$0F,$FF,$FF
            .byte $FF,$FF,$E0,$FF,$FF,$E7,$FF,$FF
            .byte $FF,$FF,$0F,$0F,$0F,$0F,$0F,$0F
            .byte $FF,$FF,$E7,$FF,$FF,$E7,$FF,$FF
            .byte $FF,$FF,$E7,$FF,$FF,$07,$FF,$FF
//
// PADDLE SPRITE
//
PADDLE:     .byte $00,$FF,$00,$00,$81,$00,$00,$BD
            .byte $00,$00,$BD,$00,$00,$BD,$00,$00
            .byte $BD,$00,$00,$BD,$00,$00,$BD,$00
            .byte $00,$BD,$00,$00,$BD,$00,$00,$BD
            .byte $00,$00,$BD,$00,$00,$BD,$00,$00
            .byte $BD,$BB,$BB,$BD,$BB,$BB,$BD,$00
            .byte $00,$BD,$00,$00,$BD,$00,$00,$BD
            .byte $00,$00,$81,$00,$00,$FF,$00,$00
//
// BALL SPRITE
//
BALL:       .byte $C0,$00,$00,$C0,$00,$00,$00,$00
            .byte $00,$00,$00,$00,$00,$00,$00,$00
            .byte $00,$00,$00,$00,$00,$00,$00,$00
            .byte $00,$00,$00,$00,$00,$00,$00,$00
            .byte $00,$00,$00,$00,$00,$00,$00,$00
            .byte $00,$00,$00,$00,$00,$00,$00,$00
            .byte $00,$00,$00,$00,$00,$00,$00,$00
            .byte $00,$00,$00,$00,$00,$00,$00,$00
//
// VARIABLES
//
VARS:       //     BALL   SLOWDOWN
            //    |VX VY|  |VALS|
            .byte $00,$00,$1F,$1F,$00,$00,$00,$00
            .byte $00,$00,$00,$00,$00,$00,$00,$00
            //                            |SCORE|
