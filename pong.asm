//
// - MEMORY Adresses (Constants) ==============================================
//

// Zero Page ($0000-$00FF | 0-255)
// Processor Stack ($0100-$01FF, 256-511)
// Name ($0200-$02FF, 512-767)
// Name ($0300-$03FF, 768-1023)

// Default Screen Memory ($0400-$07F0 | 1024-2047)
.const CHARMEM     = $0400      // character memory $0400-$07F0

// Upper RAM Area ($C000-$CFFF | 49152-53247)
.const MEM_UPRAM    = $C000     // upper RAM area begin

// VIC-II: Video Display ($D000-$DFFF | 53248-54271)
.const SPRITE0_PTR = $07F8      // sprite pointer #0
.const SPRITE1_PTR = $07F9      // sprite pointer #1
.const SPRITE2_PTR = $07FA      // sprite pointer #2
.const SPRITE3_PTR = $07FB      // sprite pointer #3

.const SPRITE0_X   = $D000      // sprite #0 x-coordinate
.const SPRITE0_Y   = $D001      // sprite #0 y-coordinate
.const SPRITE1_X   = $D002      // sprite #1 x-coordinate
.const SPRITE1_Y   = $D003      // sprite #1 y-coordinate
.const SPRITE2_X   = $D004      // sprite #2 x-coordinate
.const SPRITE2_Y   = $D005      // sprite #2 y-coordinate
.const SPRITE3_X   = $D006      // sprite #3 x-coordinate
.const SPRITE3_Y   = $D007      // sprite #3 y-coordinate
.const SCREEN_CTL  = $D011      // screen control register
.const SPRITE_DBLH = $D017      // sprite double height register
.const SPRITE_DBLV = $D01D      // sprite double vertical register
.const BORDER_COL  = $D020      // border color
.const BGND_COL    = $D021      // background color
.const SPRITE0_CLR = $D027      // sprite #0 color 
.const SPRITE1_CLR = $D028      // sprite #1 color 
.const SPRITE2_CLR = $D029      // sprite #2 color 
.const SPRITE3_CLR = $D02A      // sprite #3 color
.const SPRITE_CORD = $D010      // sprite #0-#7 x-coordinates offset (set bit per sprite)
.const SPRITE_ENBL = $D015      // sprite enable register
.const SPRITE_COLL = $D01E      // Sprite/sprite collision register

// SID: Audio ($D400-$D7FF | 54272-55295)
.const SIDV1_FRQL  = $D400      // voice #1 frequency (low-byte)
.const SIDV1_FRQH  = $D401      // voice #1 frequency (high-byte)
.const SIDV1_CTRL  = $D404      // voice #1 control register
.const SIDV1_ATDE  = $D405      // voice #1 Attack and Decay length
.const SIDV1_SURE  = $D406      // voice #1 Sustain volume and Release length
.const SID_VOLFLT  = $D418      // volume and filter modes

// CIA: Inputs ($DC00-$DCFF |56320-56575)
.const CIA_PORTA   = $DC00      // port a, keyboard matrix columns and joystick #2
.const CIA_PORTB   = $DC01      // port b, keyboard matrix rows and joystick #1

//
// - KERNAL Functions (Constants) =============================================
//

.const GET_CHAR    = $FFE4      // get character  

//
// = PROGRAM ==================================================================
//
// Memory Map:
//  $0800-$080f BASIC (starter)
//  $1000-$12ba Game
//  $1770-$187f Sprites (data)
//

.const CHARMEM_X1  = $0500      // offset 1 to charmem
.const CHARMEM_X2  = $0600      // offset 2 to charmen
.const CHARMEM_X3  = $06F0      // offset 3 to charmem

//
// = BASIC ====================================================================
//

*=$0800 "BASIC"

// Add BASIC starter (SYS 2064)
.byte $00                       // first byte of BASIC must be 0      $0800
.byte $0B,$08                   // adress to next BASIC line ($080A)  $0801
.byte $0A,$00                   // line 10                            $0803
.byte $9E                       // BASIC token for SYS                $0805
.byte $32,$30,$36,$34           // ASCII for 2064                     $0806
.byte $00,$00,$00               // end of BASIC                       $080A

//
// = Game =====================================================================
//

*=$0810 "Game"

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
            // Sprite settings ------------------------------------------------
            lda #$01 
            sta SPRITE3_CLR     // color white
            lda #$00            
            sta SPRITE_DBLV     // vertical stretch off
            lda #$00 
            sta SPRITE_DBLH     // horizontal stretch off
            lda #$02 
            sta SPRITE_CORD     // Set highbit for x-oofset (paddle 2)
            lda #$0F           
            sta SPRITE_ENBL     // Enable sprites 0-3
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
LBL_3:      jsr SOUND           
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
PLAYER_MOV: lda CIA_PORTA       // get data for joystick #2
            and #$02            // check if down 
            bne LBL_5 
            inc SPRITE0_Y       // move paddle 1 down: y (sprite 0)
            inc SPRITE0_Y 
            inc SPRITE0_Y 
            inc SPRITE0_Y 
            inc $D01 
LBL_5:      lda CIA_PORTA       
            and #$01            // check if up
            bne LBL_6 
            dec SPRITE0_Y       // move paddle 1 up: y (sprite 0)
            dec SPRITE0_Y 
            dec SPRITE0_Y
            dec SPRITE0_Y
LBL_6:      jsr LBL_7
            nop
            nop
            nop
            nop
            nop
            ldx #$02            // check against wall
LBL_10:     lda SPRITE0_Y,X     // get player y
            cmp #$32            // check if to high
            bcs LBL_8 
            lda #$32            // clamp
            sta SPRITE0_Y,X 
LBL_8:      lda SPRITE0_Y,X     
            cmp #$CF            // check if to low
            bcc LBL_9 
            lda #$CF            // clamp
            sta SPRITE0_Y,X
LBL_9:      dex
            dex
            beq LBL_10          // ?
            lda CIA_PORTA       // ?
            eor CIA_PORTB       // ?
            and #$10 
            bne LBL_11          // Check for second joystick
            jsr BALL_MOV        // call ball_mov() several times here makes it faster
LBL_11:     rts
            rts
            brk 
LBL_7:      lda CIA_PORTB       // get data for joystick #1
            and #$02            // check if down
            bne LBL_12          
            inc SPRITE1_Y       // move paddle 0 down: y (sprite 1)
            inc SPRITE1_Y 
            inc SPRITE1_Y 
LBL_12:     lda CIA_PORTB       
            and #01             // check if up
            bne LBL_13          
            dec SPRITE1_Y       // move paddle 0 up: y (sprite 1)
            dec SPRITE1_Y       // MOVE UP
            dec SPRITE1_Y
LBL_13:     rts
//
// - Ball Movement ------------------------------------------------------------
//
BALL_MOV:   lda VBALLVX    
            beq LBL_14          // check h direction of ball
            inc SPRITE2_X       // if 0 - move right
            jmp LBL_15
LBL_14:     dec SPRITE2_X       // if 1 - move left
LBL_15:     lda VBALLVY
            beq LBL_16          // check h direction of ball
            inc SPRITE2_Y       // if 0 - move down
            jmp LBL_17
LBL_16:     dec SPRITE2_Y       // if 1 - move up
LBL_17:     lda SPRITE2_X       // check for x overflow 
            ldx VBALLVX         // to setup bit#9
            beq LBL_18          // check for 00 or FF
            eor #$FF            // depending on direction
LBL_18:     and #$FF
            bne LBL_19          // if overflow
            lda SPRITE_CORD     // set high-byte of sprite 3 to 1
            eor #$04            
            sta SPRITE_CORD
LBL_19:     ldy #$20            // set sound pitch
            lda SPRITE2_Y       // get ball y
            cmp #$32            // check if to high
            bcs LBL_20  
            lda #$01            // change direction
            sta VBALLVY
            jsr SOUND
LBL_20:     lda SPRITE2_Y       // get ball y
            cmp #$F0            // check if TO LOW
            bcc LBL_21
            lda #$00            // change direction
            sta VBALLVY
            jsr SOUND   
LBL_21:     rts
//
// - Goal Check ---------------------------------------------------------------
//
GOAL_CHECK: lda SPRITE_CORD     // check height of ball sprite 
            and #$04            
            bne LBL_22          // if high-byte is disabled
            lda SPRITE2_X       // ball is on the left side
            cmp #$10
            bcc LBL_23          // check 16 < ball.x < 32
            cmp #$20
            bcs LBL_23
            inc VSCOREP2        // increase score
            jsr BALL_RST
LBL_23:     rts
LBL_22:     lda SPRITE2_X       // if high-byte is enabled
            cmp #$F0            // ball is on the right side
            bcs LBL_24
            cmp #$60
            bcc LBL_24          // check 384 < ball.x < 496
            inc VSCOREP1
            jsr BALL_RST
LBL_24:     rts
//
// - Score Render -------------------------------------------------------------
//
SCORE_REND: lda VSCOREP1        // load p1 score
            and #$0F
            asl                 // multiply by 8
            asl
            asl
            tax
            lda #$08            // set counter var to 8
            sta MEM_UPRAM
            ldy #$00
LBL_25:     lda NUMBER,X        // load character line (number)
            sta SCOREBRD,Y      // store line in sprite
            inx                 // next character line (number)
            iny                 // next sprite line
            iny                 // sprite is 3 byte wide = 24 pixels
            iny                 
            dec MEM_UPRAM
            bne LBL_25          // repeat for 8 lines
            lda VSCOREP2        // load p2 score
            and #$0F
            asl                 // multiply by 8
            asl
            asl
            tax
            lda #$08            // set counter var to 8
            sta MEM_UPRAM        
            ldy #$00
LBL_26:     lda NUMBER,X        // load character line (number)
            sta SCOREBRD+2,Y    // store line in sprite
            inx                 // next character line (number)
            iny                 // next sprite line
            iny
            iny
            dec MEM_UPRAM
            bne LBL_26          // repeat for 8 lines
            rts
//
// - Match Over Check ---------------------------------------------------------
//
WIN_CHECK:  lda VSCOREP2        // get p2 score
            cmp #$0A            // if >= 10
            bcc LBL_27
            jmp START           // reset if yes
LBL_27:     lda VSCOREP1        // get p1 score
            cmp #$0A            // if >= 10
            bcc LBL_28
            jmp START           // reset if yes
LBL_28:     rts
//
// - Sprite Collision ---------------------------------------------------------
//
COLL_CHEK:  ldy #$40            // set sound pitch
            lda SPRITE_COLL     // poll sprite collision
            tax
            and #$01
            beq LBL_29          // if p1 is colliding
            lda #$01            // change ball direction
            sta VBALLVX
            jsr SOUND
LBL_29:     txa
            and #$02
            beq LBL_30          // IF P2 IS COLLIDING
            lda #$00            // change ball direction
            sta VBALLVX
            jsr SOUND
LBL_30:     rts
//
// - Slowdown -----------------------------------------------------------------
//
SLOWDOWN:   ldx VSLOWX          // load speed values
LBL_32:     ldy VSLOWY
LBL_31:     nop
            nop
            nop
            dey
            bne LBL_31
            dex                 
            bne LBL_32
            rts
//
// - Ball Reset ---------------------------------------------------------------
//
BALL_RST:   lda #$AC     
            sta SPRITE2_X       // set ball.x
            lda #$8A
            sta SPRITE2_Y       // set ball.y
            lda SPRITE_CORD
            and #$FB            // clear 9th bit of ball.x
            sta SPRITE_CORD  
            lda VBALLVX
            eor #$01            // toggle direction
            sta VBALLVX
            ldy #$10            // set beep pitch
            jsr SOUND
            rts
//
// - Play Sound ---------------------------------------------------------------
//
SOUND:      sty SIDV1_FRQH      // high-byte of freq to y (pass as argument)
            lda #$20            // low-byte of freq to 32
            sta SIDV1_FRQL       
            lda #$0F            // set decay to 15
            sta SIDV1_ATDE
            lda #$F4            // set release to 5
            sta SIDV1_SURE
            lda #$11            // set triangle wave
            sta SIDV1_CTRL
            lda #$0F            // set volume to 15
            sta SID_VOLFLT
            lda #$10            // stop playing note
            sta SIDV1_CTRL
            rts
//
// = Variables ================================================================
//
VBALLVX:    .byte $00   // ball velocity x  $0BF0 (old mem!)
VBALLVY:    .byte $00   // .. y             $0BF1
VSLOWX:     .byte $1f   // ball slowdown x  $0BF2
VSLOWY:     .byte $1f   // .. y             $0BF3
VSCOREP1:   .byte $00   // score player 1   $0BFF
VSCOREP2:   .byte $00   // score player 2   $0BFE

//
// = Data =====================================================================
//

*=$2000 "Sprites"

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

