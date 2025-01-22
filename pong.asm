//
// - MEMORY Adresses (Constants) ==============================================
//

// Zero Page ($0000-$00FF | 0-255)
// Processor Stack ($0100-$01FF, 256-511)
// Name ($0200-$02FF, 512-767)
// Name ($0300-$03FF, 768-1023)

// Default Screen Memory ($0400-$07F0 | 1024-2047)
.const CHARMEM     = $0400      // Character memory $0400-$07F0

// Upper RAM Area ($C000-$CFFF | 49152-53247)
.const MEM_UPRAM    = $C000     // Upper RAM area begin

// VIC-II: Video Display ($D000-$DFFF | 53248-54271)
.const SPRITE0_PTR = $07F8      // Sprite pointer #0
.const SPRITE1_PTR = $07F9      // Sprite pointer #1
.const SPRITE2_PTR = $07FA      // Sprite pointer #2
.const SPRITE3_PTR = $07FB      // Sprite pointer #3

.const SPRITE0_X   = $D000      // Sprite #0 X-coordinate
.const SPRITE0_Y   = $D001      // Sprite #0 Y-coordinate
.const SPRITE1_X   = $D002      // Sprite #1 X-coordinate
.const SPRITE1_Y   = $D003      // Sprite #1 Y-coordinate
.const SPRITE2_X   = $D004      // Sprite #2 X-coordinate
.const SPRITE2_Y   = $D005      // Sprite #2 Y-coordinate
.const SPRITE3_X   = $D006      // Sprite #3 X-coordinate
.const SPRITE3_Y   = $D007      // Sprite #3 Y-coordinate
.const SCREEN_CTL  = $D011      // Screen Control Register
.const SPRITE_DBH  = $D017      // Sprite double height register
.const SPRITE_DBL  = $D01D      // Sprite double vertical register
.const BORDER_COL  = $D020      // Border color
.const BGND_COL    = $D021      // Background color
.const SPRITE0_CLR = $D027      // Sprite #0 color 
.const SPRITE1_CLR = $D028      // Sprite #1 color 
.const SPRITE2_CLR = $D029      // Sprite #2 color 
.const SPRITE3_CLR = $D02A      // Sprite #3 color
.const SPRITE_CORD = $D010      // Sprite #0-#7 X-coordinates (bit #8). Bits
.const SPRITE_ENBL = $D015      // Sprite enable register
.const SPRITE_COLL = $D01E      // Sprite/sprite collision register

// SID: Audio ($D400-$D7FF | 54272-55295)
.const SIDV1_FRQL  = $D400      // Voice #1 frequency (low-byte)
.const SIDV1_FRQH  = $D401      // Voice #1 frequency (high-byte)
.const SIDV1_CTRL  = $D404      // Voice #1 control register
.const SIDV1_ATDE  = $D405      // Voice #1 Attack and Decay length
.const SIDV1_SURE  = $D406      // Voice #1 Sustain volume and Release length
.const SID_VOLFLT  = $D418      // Volume and filter modes

// CIA: Inputs ($DC00-$DCFF |56320-56575)
.const CIA_PORTA   = $DC00      // Port A, keyboard matrix columns and joystick #2
.const CIA_PORTB   = $DC01      // Port B, keyboard matrix rows and joystick #1

// Program vars
.const CHARMEM_X1  = $0500      // Offset 1 to charmem
.const CHARMEM_X2  = $0600      // Offset 2 to charmen
.const CHARMEM_X3  = $06F0      // Offset 3 to charmem, TODO: Only 240 instead of 256 difference, is this correct?

//
// - KERNAL Functions (Constants) ============================================
//

.const GET_CHAR    = $FFE4      // Get character  

// Memory Map:
//  $0800-$080f BASIC Starter
//  $1000-$12ba Game
//  $1770-$187f Sprite Data

//
// = BASIC ====================================================================
//

*=$0800 "BASIC"

// Add BASIC starter (SYS 2064)
.byte $00                           // first byte of BASIC must be 0      $0800
.byte $0B,$08                       // adress to next BASIC line ($080A)  $0801
.byte $0A,$00                       // line 10                            $0803
.byte $9E                           // BASIC token for SYS                $0805
.byte $32,$30,$36,$34               // ASCII for 2064                     $0806
.byte $00,$00,$00                   // end of BASIC                       $080A

//
// = Game =====================================================================
//

*=$0810 "GAME"

//
// - Initialisation -----------------------------------------------------------
//
START:      nop
            // Init all 4 sprites ---------------------------------------------
            lda #$80            // sprite 0: paddle 1 ($2000/64=$80)
            sta SPRITE0_PTR     
            lda #$20 
            sta SPRITE0_X       
            lda #$82 
            sta SPRITE0_Y       
            lda #$01 
            sta SPRITE0_CLR     
            lda #$80            // sprite 1: paddle 2 ($80)
            sta SPRITE1_PTR     
            lda #$20 
            sta SPRITE1_X       
            lda #$82 
            sta SPRITE1_Y       
            lda #$01 
            sta SPRITE1_CLR     
            lda #$81            // sprite 2: ball ($81)
            sta SPRITE2_PTR     
            lda #$AC 
            sta SPRITE2_X       
            lda #$8A 
            sta SPRITE2_Y       
            lda #$01 
            sta SPRITE2_CLR     
            lda #$82            // sprite 3: Scoreboard ($82)
            sta SPRITE3_PTR     
            lda #$A0 
            sta SPRITE3_X       
            lda #$36 
            sta SPRITE3_Y       
            lda #$01 
            sta SPRITE3_CLR 
            lda #$00 
            sta SPRITE_DBH      // SPRITE H STRETCH ??
            lda #$02 
            sta SPRITE_CORD     // SET P2.X HIGH BIT ??
            lda #$0F           
            sta SPRITE_ENBL     // ENABLE SPRITES ??
            lda #$00            
            sta SPRITE_DBL      // SPRITE V STRETCH ??
            lda #$06 
            sta BORDER_COL      // border color
            lda #$05 
            sta BGND_COL        // background color
            // Reset variables ------------------------------------------------
            lda #$00 
            sta VBALLVX         // ball.vx
            sta VBALLVY         // ball.vy
            sta VSCOREP2        // p2.score
            sta VSCOREP1        // p2.score
            // Clear screen ---------------------------------------------------
            ldx #$00            
            lda #$20            
LBL_1:      sta CHARMEM,X       
            sta CHARMEM_X1,X    
            sta CHARMEM_X2,X  
            sta CHARMEM_X3,X 
            inx
            bne LBL_1 
            // Disable display ------------------------------------------------ 
            lda SCREEN_CTL 
            and #$EF            
            sta SCREEN_CTL      
            // Screen blink --------------------------------------------------- 
            ldx #$C0 
LBL_2:      ldy #$00
LBL_3:      jsr BLEEP           
            iny
            bne LBL_3 
            inc BORDER_COL      // blink border
            inx
            bne LBL_2   
            // Set field colors -----------------------------------------------        
            lda #$01 
            sta BORDER_COL      
            lda #00
            sta BGND_COL        
            lda SCREEN_CTL 
            // Enable display ------------------------------------------------- 
            ora #$10           
            sta SCREEN_CTL 
            jmp SCORE_INIT
//
// - Sprite Score Clear -------------------------------------------------------
//
SCORE_INIT: lda #$00
            ldx #$40            
LBL_4:      sta SCOREBRD,X      // clear all 64 bytes
            dex
            bne LBL_4
            lda #$3C            // place dot between player scores
            sta SCOREBRD+7
            sta SCOREBRD+10     
            sta SCOREBRD+13     
            sta SCOREBRD+16
            jmp GAME_LOOP
//
// - Main Loop ----------------------------------------------------------------
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
// - Player Movement ----------------------------------------------------------
//
PLAYER_MOV: lda CIA_PORTA       // Get data from port A
            and #$02            // Joystick #2
            bne LBL_5 
            inc SPRITE0_Y       // Move paddle 1 down: y (sprite 0)
            inc SPRITE0_Y 
            inc SPRITE0_Y 
            inc SPRITE0_Y 
            inc $D01 
LBL_5:      lda CIA_PORTA       // CHECK UP
            and #$01 
            bne LBL_6 
            dec SPRITE0_Y       // MOVE P1 UP
            dec SPRITE0_Y 
            dec SPRITE0_Y
            dec SPRITE0_Y
LBL_6:      jsr LBL_7
            nop
            nop
            nop
            nop
            nop
            ldx #$02            // CHECK WALL
LBL_10:     lda SPRITE0_Y,X     // GET PLAYER Y
            cmp #$32            // CHECK IF TO HIGH
            bcs LBL_8 
            lda #$32            // CLAMP
            sta SPRITE0_Y,X 
LBL_8:      lda SPRITE0_Y,X     // GET PLAYER Y
            cmp #$CF            // CHECK IF TO LOW
            bcc LBL_9 
            lda #$CF            // CLAMP
            sta SPRITE0_Y,X
LBL_9:      dex
            dex
            beq LBL_10          // LOOP FOR 2 PLAYERS
            lda CIA_PORTA       // CHECK IF ONLY ONE
            eor CIA_PORTB       // FIRE BTN IS PRESSED
            and #$10 
            bne LBL_11          // IF NOT UPD BALL
            jsr BALL_MOV        // 3 TIMES
            //jsr BALL_MOV        // OTHERWISE BALL
            //jsr BALL_MOV        // IS 4 TIMES SLOWER
LBL_11:     rts
            rts
            brk 
LBL_7:      lda CIA_PORTB       // PLAYER 2 JOY CHECK
            and #$02            // POLL JOY #1
            bne LBL_12          // CHECK DOWN
            inc SPRITE1_Y 
            inc SPRITE1_Y 
            inc SPRITE1_Y 
LBL_12:     lda CIA_PORTB       // POLL JOY #1
            and #01 
            bne LBL_13          // CHECK UP
            dec SPRITE1_Y 
            dec SPRITE1_Y       // MOVE UP
            dec SPRITE1_Y
LBL_13:     rts
//
// - Ball Movement ------------------------------------------------------------
//
BALL_MOV:   lda VBALLVX    
            beq LBL_14          // CHECK BALL H DIR
            inc SPRITE2_X       // IF 0 - MOVE RIGHT
            jmp LBL_15
LBL_14:     dec SPRITE2_X       // IF 1 - MOVE LEFT
LBL_15:     lda VBALLVY
            beq LBL_16          // CHECK BALL V DIR
            inc SPRITE2_Y       // IF 0 - MOVE DOWN
            jmp LBL_17
LBL_16:     dec SPRITE2_Y       // IF 1 - MOVE UP
LBL_17:     lda SPRITE2_X       // CHECK FOR X OVERFLOW 
            ldx VBALLVX         // TO SETUP THE 9BIT
            beq LBL_18          // CHECK FOR 00 OR FF
            eor #$FF            // DEPENDS ON DIR
LBL_18:     and #$FF
            bne LBL_19          // IF OVERFLOW
            lda SPRITE_CORD     // SET HIGHBIT OF
            eor #$04            // SPRITE 3 TO 1
            sta SPRITE_CORD
LBL_19:     ldy #$20            // SET BLEEP PITCH
            lda SPRITE2_Y       // GET BALL Y
            cmp #$32            // CHECK IF TOO HIGH
            bcs LBL_20  
            lda #$01            // CHANGE DIRECTION
            sta VBALLVY
            jsr BLEEP
LBL_20:     lda SPRITE2_Y       // GET BALL Y
            cmp #$F0            // CHECK IF TO LOW
            bcc LBL_21
            lda #$00            // CHANGE DIRECTION
            sta VBALLVY
            jsr BLEEP   
LBL_21:     rts
//
// - Goal Check ---------------------------------------------------------------
//
GOAL_CHECK: lda SPRITE_CORD     // CHECK HIGHT OF 
            and #$04            // BALL SPRITE
            bne LBL_22          // IF H.BIT IS DISABLED
            lda SPRITE2_X       // BALL IS ON THE LEFT
            cmp #$10
            bcc LBL_23          // CHK 16 < BALL.X < 32
            cmp #$20
            bcs LBL_23
            inc VSCOREP2        // INCREASE SCORE
            jsr BALL_RST
LBL_23:     rts
LBL_22:     lda SPRITE2_X       // IF H.BIT IS ENABLED
            cmp #$F0            // BALL IS ON THE RIGHT
            bcs LBL_24
            cmp #$60
            bcc LBL_24          // CHK 384 < BALLX < 496
            inc VSCOREP1
            jsr BALL_RST
LBL_24:     rts
//
// - Score Render -------------------------------------------------------------
//
SCORE_REND: lda VSCOREP1        // LOAD P1 SCORE
            and #$0F
            asl                 // MULTIPLY BY 8
            asl
            asl
            tax
            lda #$08            // SET COUNTER VAR TO 8
            sta MEM_UPRAM
            ldy #$00
LBL_25:     lda NUMBER,X        // LOAD NUMBER GFX LINE
            sta SCOREBRD,Y      // STORE LINE IN SPRITE
            inx                 // INC NUM GFX LINE
            iny                 // INC SPRITE LINE
            iny                 // SPRITES=3 BYTES WIDE
            iny                 // =24 PIXELS
            dec MEM_UPRAM
            bne LBL_25          // REPEAT FOR 8 LINES
            lda VSCOREP2        // LOAD P2 SCORE
            and #$0F
            asl                 // MULTIPLY NY 8
            asl
            asl
            tax
            lda #$08            // COUNTER TO 8 LINES
            sta MEM_UPRAM        
            ldy #$00
LBL_26:     lda NUMBER,X        // LOAD NUM GFX LINE
            sta SCOREBRD+2,Y    // STORE IN SPRITE
            inx                 // INC NUM GFX LINE
            iny                 // INC SPRITE LINE
            iny
            iny
            dec MEM_UPRAM
            bne LBL_26          // REPEAT 8 TIMES
            rts
//
// - Match Over Check ---------------------------------------------------------
//
WIN_CHECK:  lda VSCOREP2        // CHECK P2 SCORE
            cmp #$0A            // IF >= 10
            bcc LBL_27
            jmp START           // RESET IF YES
LBL_27:     lda VSCOREP1        // GET P1 SCORE
            cmp #$0A            // IF >= 10
            bcc LBL_28
            jmp START           // RESET IF YES
LBL_28:     rts
//
// - Sprite Collision ---------------------------------------------------------
//
COLL_CHEK:  ldy #$40            // SET BLEEP PITCH
            lda SPRITE_COLL     // POLL SPRITE COLLISION
            tax
            and #$01
            beq LBL_29          // IF P1 IS COLLIDING
            lda #$01            // CHANGE BALL DIR.
            sta VBALLVX
            jsr BLEEP
LBL_29:     txa
            and #$02
            beq LBL_30          // IF P2 IS COLLIDING
            lda #$00            // CHANGE BALL DIR.
            sta VBALLVX
            jsr BLEEP
LBL_30:     rts
//
// - Slowdown -----------------------------------------------------------------
//
SLOWDOWN:   ldx VSLOWX          // LOAD SPEED VALUES
LBL_32:     ldy VSLOWY
LBL_31:     nop
            nop
            nop
            dey
            bne LBL_31
            dex                 // LOOPCEPTION UNTIL DONE
            bne LBL_32
            rts
//
// - Ball Reset ---------------------------------------------------------------
//
BALL_RST:   lda #$AC     
            sta SPRITE2_X       // SET BALL.X
            lda #$8A
            sta SPRITE2_Y       // SET BALL.Y
            lda SPRITE_CORD
            and #$FB            // CLEAR 9TH BIT
            sta SPRITE_CORD     // OF BALL.X
            lda VBALLVX
            eor #$01            // TOGGLE DIRECTION
            sta VBALLVX
            ldy #$10            // SET BLEEP PITCH
            jsr BLEEP
            rts
//
// - Play Sound ---------------------------------------------------------------
//
BLEEP:      sty SIDV1_FRQH      // H.byte OF FREQ TO Y
            lda #$20            // L.byte OF FREQ TO 32
            sta SIDV1_FRQL       
            lda #$0F            // SET DECAY TO 15
            sta SIDV1_ATDE
            lda #$F4            // SET RELEASE TO 4
            sta SIDV1_SURE
            lda #$11            // SET TRIANGLE WAVE
            sta SIDV1_CTRL
            lda #$0F            // SET VOLUME TO 15
            sta SID_VOLFLT
            lda #$10            // STOP PLAYING NOTE
            sta SIDV1_CTRL
            rts
//
// = Variables ================================================================
//
VBALLVX:    .byte $00   // Ball velocity x  $0BF0 (old mem!)
VBALLVY:    .byte $00   // .. y             $0BF1
VSLOWX:     .byte $1f   // Ball slowdown x  $0BF2
VSLOWY:     .byte $1f   // .. y             $0BF3
VSCOREP1:   .byte $00   // Score player 1   $0BFF
VSCOREP2:   .byte $00   // Score player 2   $0BFE

//
// = Data =====================================================================
//

*=$2000 "SPRITE DATA"

//
// Paddle Sprite
//
PADDLE:     .byte $00,$FF,$00   // 01
            .byte $00,$81,$00   // 02
            .byte $00,$BD,$00   // 03
            .byte $00,$BD,$00   // 04
            .byte $00,$BD,$00   // 05
            .byte $00,$BD,$00   // 06
            .byte $00,$BD,$00   // 07
            .byte $00,$BD,$00   // 08
            .byte $00,$BD,$00   // 09
            .byte $00,$BD,$00   // 10
            .byte $00,$BD,$00   // 11
            .byte $00,$BD,$00   // 12
            .byte $00,$BD,$00   // 13
            .byte $00,$BD,$00   // 14
            .byte $00,$BD,$00   // 15
            .byte $00,$BD,$00   // 16
            .byte $00,$BD,$00   // 17
            .byte $00,$BD,$00   // 18
            .byte $00,$BD,$00   // 19
            .byte $00,$81,$00   // 20
            .byte $00,$FF,$00   // 21
            .byte $00           // fill to 64 bytes
//
// Ball Sprite
//
BALL:       .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$FF,$00
            .byte $00,$FF,$00
            .byte $00,$FF,$00
            .byte $00,$FF,$00
            .byte $00,$FF,$00
            .byte $00,$FF,$00
            .byte $00,$FF,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00           

//
// Scoreboard Sprite (empty, will be filled programmatically)
//
SCOREBRD:   .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00,$00,$00
            .byte $00
//
// Numbers
//
NUMBER:     .byte $FF,$FF,$E7,$E7,$E7,$E7,$FF,$FF   // 0
            .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C   // 1
            .byte $FF,$FF,$0F,$FF,$FF,$F0,$FF,$FF   // 2
            .byte $FF,$FF,$0F,$3F,$3F,$0F,$FF,$FF   // 3
            .byte $E7,$E7,$E7,$FF,$FF,$07,$07,$07   // 4
            .byte $FF,$FF,$F0,$FF,$FF,$0F,$FF,$FF   // 5
            .byte $FF,$FF,$E0,$FF,$FF,$E7,$FF,$FF   // 6
            .byte $FF,$FF,$0F,$0F,$0F,$0F,$0F,$0F   // 7
            .byte $FF,$FF,$E7,$FF,$FF,$E7,$FF,$FF   // 8
            .byte $FF,$FF,$E7,$FF,$FF,$07,$FF,$FF   // 9

