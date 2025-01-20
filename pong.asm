*=$1000
//
// - OS ADRESSES -----------------------
//
.var CHARMEM     = $0400    // Character memory $0400-$07F0
.var CHARMEMX1   = $0500    // Offset to charmem
.var CHARMEMX2   = $0600    // Offset to charmen
.var CHARMEMX3   = $06F0    // TODO: Only 240 instead of 256 difference, is this correct?
.var SPRITE0_X   = $D000    // Sprite #0 X-coordinate
.var SPRITE0_Y   = $D001    // Sprite #0 Y-coordinate
.var SPRITE1_X   = $D002    // Sprite #1 X-coordinate
.var SPRITE1_Y   = $D003    // Sprite #1 Y-coordinate
.var SPRITE2_X   = $D004    // Sprite #2 X-coordinate
.var SPRITE2_Y   = $D005    // Sprite #2 Y-coordinate
.var SPRITE3_X   = $D006    // Sprite #3 X-coordinate
.var SPRITE3_Y   = $D007    // Sprite #3 Y-coordinate
.var SCRCTRLREG  = $D011    // Screen Control Register
.var SPRITEDBLH  = $D017    // Sprite double height register
.var SPRITEDBLV  = $D01D    // Sprite double vertical register
.var BORDER_COL  = $D020    // Border color
.var BACK_COL    = $D021    // Background color
.var xx = $D027 // Sprite #0 color 
.var xx = $D028 // Sprite #1 color 
.var xx = $D029 // Sprite #2 color 
.var xx = $D02A // Sprite #3 color
.var SPRITEPTR0  = $07F8    // Sprite pointer #0
.var SPRITEPTR1  = $07F9    // Sprite pointer #1
.var SPRITEPTR2  = $07FA    // Sprite pointer #2
.var SPRITEXCRD  = $D010    // Sprite #0-#7 X-coordinates (bit #8). Bits
.var SPRITEENBL  = $D015    // Sprite enable register

//
// - INITIALISATION --------------------
//
START:      nop
            lda #$14        // SETTING SPRITE GFX
            sta SPRITEPTR0 
            sta SPRITEPTR1  // SPRITE POS INIT
            lda #$20 
            sta SPRITE0_X   // P1.X
            lda #$82 
            sta SPRITE0_Y   // P1.Y
            lda #$20 
            sta SPRITE1_X   // P2.X
            lda #$82 
            sta SPRITE1_Y   // P2.Y
            lda #$AC 
            sta SPRITE2_X   // BALL.X
            lda #$8A 
            sta SPRITE2_Y   // BALL.Y
            lda #$26 
            sta SPRITEPTR0  // SPRITE GFX P1
            sta SPRITEPTR1  // SPRITE GFX P2
            lda #$27 
            sta SPRITEPTR2  // SPRITE GFX BALL
            lda #$0F 
            sta SPRITEDBLH  // SPRITE H STRETCH
            lda #$02 
            sta SPRITEXCRD  // SET P2.X HIGH BIT
            lda #$0F        //  (X IS 9BIT)
            sta SPRITEENBL  // ENABLE SPRITES
            lda #$0F        //  (BITFIELD)
            sta SPRITEDBLV  // SPRITE V STRETCH
            lda #$06 
            sta BORDER_COL  // BORDER COLOR
            lda #$05 
            sta BACK_COL    // BG COLOR
            lda #$01 
            sta $D027       // P1.COLOR
            lda #$01 
            sta $D028       // P2.COLOR
            lda #$01 
            sta $D029       // BALL.COLOR
            lda #$A0 
            sta SPRITE3_X   // SCOREBOARD.X
            lda #$32 
            sta SPRITE3_Y   // SCOREBOARD.Y
            lda #$01 
            sta $D02A       // SCOREBOARD.COLOR
            lda #$38 
            sta $07FB       // SCOREBOARD GRAPHICS
            lda #$00 
            sta VBALLVX     // BALL.X.DIRECTION
            sta VBALLVY     // BALL.Y.DIRECTION
            sta VSCOREP2    // P2.SCORE
            sta VSCOREP1    // P1.SCORE
            ldx #$00        // CLS
            lda #$20        // SPACE
LBL_1:      sta CHARMEM,X   // SCREEN LOC 0400-07F0 1024
            sta CHARMEMX1,X // 40X25=1000
            sta CHARMEMX2,X  
            sta CHARMEMX3,X 
            inx
            bne LBL_1 
            lda SCRCTRLREG 
            and #$EF        // DISABLE DISPLAY 
            sta SCRCTRLREG 
            ldx #$C0 
LBL_2:      ldy #$00
LBL_3:      jsr BLEEP       // BEEP SOUND
            iny
            bne LBL_3 
            inc BORDER_COL  // BLINK SCREEN
            inx
            bne LBL_2       // REPEAT
            lda #$00 
            sta BORDER_COL  // SET BORDER BLACK
            sta BACK_COL    // SET BG BLACK
            lda SCRCTRLREG 
            ora #$10        // ENABLE DISPLAY
            sta SCRCTRLREG 
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
            inc SPRITE0_Y   // MOVE P1 DOWN
            inc SPRITE0_Y 
            inc $D01 
LBL_5:      lda $DC00       // CHECK UP
            and #$01 
            bne LBL_6 
            dec SPRITE0_Y   // MOVE P1 UP
            dec SPRITE0_Y 
            dec SPRITE0_Y
LBL_6:      jsr LBL_7
            nop
            nop
            nop
            nop
            nop
            ldx #$02        // CHECK WALL
LBL_10:     lda SPRITE0_Y,X // GET PLAYER Y
            cmp #$32        // CHECK IF TO HIGH
            bcs LBL_8 
            lda #$32        // CLAMP
            sta SPRITE0_Y,X 
LBL_8:      lda SPRITE0_Y,X // GET PLAYER Y
            cmp #$CF        // CHECK IF TO LOW
            bcc LBL_9 
            lda #$CF        // CLAMP
            sta SPRITE0_Y,X
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
            inc SPRITE1_Y 
            inc SPRITE1_Y 
            inc SPRITE1_Y 
LBL_12:     lda $DC01       // POLL JOY #1
            and #01 
            bne LBL_13      // CHECK UP
            dec SPRITE1_Y 
            dec SPRITE1_Y   // MOVE UP
            dec SPRITE1_Y
LBL_13:     rts
//
// - BALL MOVEMENT ---------------------
//
BALL_MOV:   lda VBALLVX    
            beq LBL_14      // CHECK BALL H DIR
            inc SPRITE2_X   // IF 0 - MOVE RIGHT
            jmp LBL_15
LBL_14:     dec SPRITE2_X   // IF 1 - MOVE LEFT
LBL_15:     lda VBALLVY
            beq LBL_16      // CHECK BALL V DIR
            inc SPRITE2_Y   // IF 0 - MOVE DOWN
            jmp LBL_17
LBL_16:     dec SPRITE2_Y   // IF 1 - MOVE UP
LBL_17:     lda SPRITE2_X   // CHECK FOR X OVERFLOW 
            ldx VBALLVX     // TO SETUP THE 9BIT
            beq LBL_18      // CHECK FOR 00 OR FF
            eor #$FF        // DEPENDS ON DIR
LBL_18:     and #$FF
            bne LBL_19      // IF OVERFLOW
            lda SPRITEXCRD  // SET HIGHBIT OF
            eor #$04        // SPRITE 3 TO 1
            sta SPRITEXCRD
LBL_19:     ldy #$20        // SET BLEEP PITCH
            lda SPRITE2_Y   // GET BALL Y
            cmp #$32        // CHECK IF TOO HIGH
            bcs LBL_20  
            lda #$01        // CHANGE DIRECTION
            sta VBALLVY
            jsr BLEEP
LBL_20:     lda SPRITE2_Y   // GET BALL Y
            cmp #$F0        // CHECK IF TO LOW
            bcc LBL_21
            lda #$00        // CHANGE DIRECTION
            sta VBALLVY
            jsr BLEEP   
LBL_21:     rts
//
// - GOAL CHECK ------------------------
//
GOAL_CHECK: lda SPRITEXCRD  // CHECK HIGHT OF 
            and #$04        // BALL SPRITE
            bne LBL_22      // IF H.BIT IS DISABLED
            lda SPRITE2_X   // BALL IS ON THE LEFT
            cmp #$10
            bcc LBL_23      // CHK 16 < BALL.X < 32
            cmp #$20
            bcs LBL_23
            inc VSCOREP2    // INCREASE SCORE
            jsr BALL_RST
LBL_23:     rts
LBL_22:     lda SPRITE2_X   // IF H.BIT IS ENABLED
            cmp #$F0        // BALL IS ON THE RIGHT
            bcs LBL_24
            cmp #$60
            bcc LBL_24      // CHK 384 < BALLX < 496
            inc VSCOREP1
            jsr BALL_RST
LBL_24:     rts
//
// - SCORE RENDER ----------------------
//
SCORE_REND: lda VSCOREP1    // LOAD P1 SCORE
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
            lda VSCOREP2    // LOAD P2 SCORE
            and #$0F
            asl             // MULTIPLY NY 8
            asl
            asl
            tax
            lda #$08        // COUNTER TO 8 LINES
            sta $C000        
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
WIN_CHECK:  lda VSCOREP2    // CHECK P2 SCORE
            cmp #$0A        // IF >= 10
            bcc LBL_27
            jmp START       // RESET IF YES
LBL_27:     lda VSCOREP1    // GET P1 SCORE
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
            sta VBALLVX
            jsr BLEEP
LBL_29:     txa
            and #$02
            beq LBL_30      // IF P2 IS COLLIDING
            lda #$00        // CHANGE BALL DIR.
            sta VBALLVX
            jsr BLEEP
LBL_30:     rts
//
// - SLOWDOWN --------------------------
//
SLOWDOWN:   ldx VSLOWX       // LOAD SPEED VALUES
LBL_32:     ldy VSLOWY
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
            sta SPRITE2_X   // SET BALL.X
            lda #$8A
            sta SPRITE2_Y   // SET BALL.Y
            lda SPRITEXCRD
            and #$FB        // CLEAR 9TH BIT
            sta SPRITEXCRD  // OF BALL.X
            lda VBALLVX
            eor #$01        // TOGGLE DIRECTION
            sta VBALLVX
            ldy #$10        // SET BLEEP PITCH
            jsr BLEEP
            rts
//
// - PLAY SOUND ------------------------
//
BLEEP:      sty $D401       // H.byte OF FREQ TO Y
            lda #$20        // L.byte OF FREQ TO 32
            sta $D400       
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
VBALLVX:    .byte $00   // Ball velocity x  $0BF0 (old mem!)
VBALLVY:    .byte $00   // .. y             $0BF1
VSLOWX:     .byte $1f   // Ball slowdown x  $0BF2
VSLOWY:     .byte $1f   // .. y             $0BF3
VSCOREP1:   .byte $00   // Score player 1   $0BFF
VSCOREP2:   .byte $00   // Score player 2   $0BFE
