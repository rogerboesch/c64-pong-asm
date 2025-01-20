*=$0810
;
; - INITIALISATION --------------------
;
$0810    START:     NOP
                    LDA #14         ; SETTING SPRITE GFX
                    STA 07F8 
                    STA 07F9        ; SPRITE POS INIT
                    LDA #20 
                    STA D000        ; P1.X
                    LDA #82 
                    STA DO01        ; P1.Y
                    LDA #20 
                    STA D002        ; P2.X
                    LDA #82 
                    STA D003        ; P2.Y
                    LDA #AC 
                    STA D004        ; BALL.X
                    LDA #8A 
                    STA D005        ; BALL
                    LDA #26 
                    STA 07F8        ; SPRITE GFX P1
                    STA 07F9        ; SPRITE GFX P2
                    LDA #27 
                    STA O7FA        ; SPRITE GFX BALL
                    LDA #OF 
                    STA D017        ; SPRITE H STRETCH
                    LDA #02 
                    STA D010        ; SET P2.X HIGH BIT
                    LDA #OF         ;  (X IS 9BIT)
                    STA D015        ; ENABLE SPRITES
                    LDA #OF         ;  (BITFIELD)
                    STA DO1D        ; SPRITE V STRETCH
                    LDA #06 
                    STA D020        ; BORDER COLOR
                    LDA #05 
                    STA D021        ; BG COLOR
                    LDA #01 
                    STA D027        ; P1.COLOR
                    LDA #01 
                    STA D028        ; P2.COLOR
                    LDA #01 
                    STA D029        ; BALL.COLOR
                    LDA #A0 
                    STA D006        ; SCOREBOARD.X
                    LDA #32 
                    STA D007        ; SCOREBOARD.Y
                    LDA #01 
                    STA DO2A        ; SCOREBOARD.COLOR
                    LDA #38 
                    STA 07FB        ; SCOREBOARD GRAPHICS
                    LDA #00 
                    STA 0BFO        ; BALL.X.DIRECTION
                    STA 0BF1        ; BALL.Y.DIRECTION
                    STA 0BFE        ; P2.SCORE
                    STA 0BFF        ; P1.SCORE
                    LDX #00         ; CLS
                    LDA #20         ; SPACE 
$0897    LBL_1:     STA 0400,X      ; SCREEN LOC 0400-07F0
                    STA 0500,X      ; 40X25=1000
                    STA 0600,X 
                    STA 06F0,X 
                    INX
                    BNE LBL_1 
                    LDA DO11 
                    AND #EF         ; DISABLE DISPLAY 
                    STA DO11 
                    LDX #C0 
$08B0    LBL_2:     LDY #00
$08B2    LBL_3:     JSR BEEP       ; BEEP SOUND
                    INY
                    BNE LBL_3 
                    INC D020        ; BLINK SCREEN
                    INX
                    BNE LBL_2       ; REPEAT
                    LDA #00 
                    STA D020        ; SET BORDER BLACK
                    STA DO21        ; SET BG BLACK
                    LDA DO11 
                    ORA #10         ; ENABLE DISPLAY
                    STA DO11 
                    JMP SCORE_INIT
        ;
        ; - SPRITE SCORE CLEAR ----------------
        ;
$0BA0   SCORE_INIT: LDA #00
                    LDX #40         ; CLEAR 64 BYTES
$0BA4   LBL_4:      STA 0E00,X      ; SBOARD SPRITE AT 0E00
                    DEX
                    BNE LBL_4
                    LDA #3C
                    STA 0E07
                    STA 0E0A        ; PLACE A DOT
                    STA 0E0D        ; BETWEEN PLAYER SCORES
                    STA 0E10
                    JMP GAME_LOOP
        ;
        ; - MAIN LOOP -------------------------
        ;
$0900   GAME_LOOP:  JSR PLAYER_MOV
                    JSR BALL_MOV
                    JSR SLOWDOWN
                    JSR GOAL_CHECK
                    JSR SCORE_RNDR
                    JSR WIN_CHECK
                    JSR COLL_CHECK
                    JMP GAME_LOOP
        ;
        ; - PLAYER MOVEMENT -------------------
        ;
$0A00   PLAYER_MOV: LDA DC00        ; GET JOYS #2
                    AND #02         ; CHECK DOWN
                    BNE LBL_5 
                    INC D001        ; MOVE P1 DOWN
                    INC DO01 
                    INC DO01 
$0A10   LBL_5:      LDA DC00        ; CHECK UP
                    AND #01 
                    BNE LBL_6 
                    DEC DO01        ; MOVE P1 UP
                    DEC DO01 
                    DEC DO01
$OA20   LBL_6:      JSR LBL_7
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    LDX #02         ; CHECK WALL
$0A2A   LBL_10:     LDA DO01,X      ; GET PLAYER Y
                    CMP #32         ; CHECK IF TO HIGH
                    BCS LBL_8 
                    LDA #32         ; CLAMP
                    STA DO01,X 
$0A36   LBL_8:      LDA DO01,X      ; GET PLAYER Y 
                    CMP #CF         ; CHECK IF TO LOW
                    BCC LBL_9 
                    LDA #CF         ; CLAMP
                    STA D001,X
$0A42   LBL_9:      DEX
                    DEX
                    BEQ LBL_10      ; LOOP FOR 2 PLAYERS
                    LDA DC00        ; CHECK IF ONLY ONE
                    EOR DC01        ; FIRE BTN IS PRESSED
                    AND #10 
                    BNE LBL_11      ; IF NOT UPD BALL
                    JSR BALL_MOV    ; 3 TIMES
                    JSR BALL_MOV    ; OTHERWISE BALL
                    JSR BALL_MOV    ; IS 4 TIMES SLOWER
$0A59   LBL_11:     RTS
                    RTS
                    BRK 
$0A5C   LBL_7:      LDA DC01        ; PLAYER 2 JOY CHECK
                    AND #02         ; POLL JOY #1
                    BNE LBL_12      ; CHECK DOWN
                    INC D003 
                    INC D003 
                    INC D003 
$0A6C   LBL_12:     LDA DC01        ; POLL JOY #1
                    AND #01 
                    BNE LBL_13      ; CHECK UP
                    DEC D003 
                    DEC D003        ; MOVE UP
                    DEC D003
$0A7C   LBL_13:     RTS
        ;
        ; - BALL MOVEMENT ---------------------
        ;
$0A80   BALL_MOV:   LDA OBFO    
                    BEQ LBL_14      ; CHECK BALL H DIR
                    INC D004        ; IF 0 - MOVE RIGHT
                    JMP LBL_15
$0A8B   LBL_14:     DEC D004        ; IF 1 - MOVE LEFT
$0A8E   LBL_15:     LDA OBF1
                    BEQ LBL_16      ; CHECK BALL V DIR
                    INC D005        ; IF 0 - MOVE DOWN
                    JMP LBL_17
$0A99   LBL_16:     DEC D005        ; IF 1 - MOVE UP
$0A9C   LBL_17:     LDA D004        ; CHECK FOR X OVERFLOW 
                    LDX OBFO        ; TO SETUP THE 9BIT
                    BEQ LBL_18      ; CHECK FOR 00 OR FF
                    EOR #FF         ; DEPENDS ON DIR
$0AA6   LBL_18:     AND #FF
                    BNE LBL_19      ; IF OVERFLOW
                    LDA D010        ; SET HIGHBIT OF
                    EOR #04         ; SPRITE 3 TO 1
                    STA D010
$0AB2   LBL_19:     LDY #20         ; SET BEEP PITCH
                    LDA D005        ; GET BALL Y
                    CMP #32         ; CHECK IF TOO HIGH
                    BCS LBL_20  
                    LDA #01         ; CHANGE DIRECTION
                    STA OBF1
                    JSR BEEP
$0AC3   LBL_20:     LDA D005        ; GET BALL Y
                    CMP #F0         ; CHECK IF TO LOW
                    BCC LBL_21
                    LDA #00         ; CHANGE DIRECTION
                    STA OBF1
                    JSR BEEP   
$0AD2   LBL_21:     RTS
        ;
        ; - GOAL CHECK ------------------------
        ;
$0B20   GOAL_CHECK: LDA D010        ; CHECK HIGHT OF 
                    AND #04         ; BALL SPRITE
                    BNE LBL_22      ; IF H.BIT IS DISABLED
                    LDA D004        ; BALL IS ON THE LEFT
                    CMP #10
                    BCC LBL_23      ; CHK 16 < BALL.X < 32
                    CMP #20
                    BCS LBL_23
                    INC 0BFE        ; INCREASE SCORE
                    JSR BALL_RST
$0B38   LBL_23:     RTS
$0B38   LBL_22:     LDA D004        ; IF H.BIT IS ENABLED
                    CMP #F0         ; BALL IS ON THE RIGHT
                    BCS LBL_24
                    CMP #60
                    BCC LBL_24      ; CHK 384 < BALLX < 496
                    INC 0BFF
                    JSR BALL_RST
$0BA4   LBL_24:     RTS
        ;
        ; - SCORE RENDER ----------------------
        ;
$0B50   SCORE_RNDR: LDA 0BFF        ; LOAD P1 SCORE
                    AND #0F
                    ASL             ; MULTIPLY BY 8
                    ASL
                    ASL
                    TAX
                    LDA #08         ; SET COUNTER VAR TO 8
                    STA C000
                    LDY #00
$0B70   LBL_25:     LDA 0930,X      ; LOAD NUMBER GFX LINE
                    STA 0E00,Y      ; STORE LINE IN SPRITE
                    INX             ; INC NUM GFX LINE
                    INY             ; INC SPRITE LINE
                    INY             ; SPRITES=3 BYTES WIDE
                    INY             ; =24 PIXELS
                    DEC C000
                    BNE LBL_25      ; REPEAT FOR 8 LINES
                    LDA 0BFE        ; LOAD P2 SCORE
                    AND #0F
                    ASL             ; MULTIPLY NY 8
                    ASL
                    ASL
                    TAX
                    LDA #08         ; COUNTER TO 8 LINES
                    STA C000        ; 
                    LDY #00
$0B8F   LBL_26:     LDA 0930,X      ; LOAD NUM GFX LINE
                    STA 0E02,Y      ; STORE IN SPRITE
                    INX             ; INC NUM GFX LINE
                    INY             ; INC SPRITE LINE
                    INY
                    INY
                    DEC C000
                    BNE LBL_26      ; REPEAR 8 TIMES
                    RTS
        ;
        ; - MATCH OVER CHECK ------------------
        ;
$0BBB   WIN_CHECK:  LDA OBFE        ; CHECK P2 SCORE
                    CMP #0A         ; IF >= 10
                    BCC LBL_27
                    JMP START       ; RESET IF YES
$0BC5   LBL_27:     LDA 0BFF        ; GET P1 SCORE
                    CMP #0A         ; IF >= 10
                    BCC LBL_28
                    JMP START       ; RESET IF YES
$0BCF   LBL_28:     RTS
        ;
        ; - SPRITE COLLISION ------------------
        ;
$0B00   COLL_CHECK: LDY #40         ; SET BEEP PITCH
                    LDA D01E        ; POLL SPRITE COLLISION
                    TAX
                    AND #01
                    BEQ LBL_29      ; IF P1 IS COLLIDING
                    LDA #01         ; CHANGE BALL DIR.
                    STA 0BF0
                    JSR BEEP
$0B12   LBL_29:     TXA
                    AND #02
                    BEQ LBL_30      ; IF P2 IS COLLIDING
                    LDA #00         ; CHANGE BALL DIR.
                    STA 0BF0
                    JSR BEEP
$0BF1   LBL_30:     RTS
        ;
        ; - SLOWDOWN --------------------------
        ;
$0920   SLOWDOWN:   LDX 0BF2        ; LOAD SPEED VALUES
$0923   LBL_32:     LDY 0BF3
$0926   LBL_31:     NOP
                    NOP
                    NOP
                    DEY
                    BNE LBL_31
                    DEX             ; LOOPCEPTION UNTIL DONE
                    BNE LBL_32
                    RTS
        ;
        ; - BALL RESET ------------------------
        ;
$08BD0  BALL_RST:   LDA #AC     
                    STA D004        ; SET BALL.X
                    LDA #8A
                    STA D005        ; SET BALL.Y
                    LDA D010
                    AND #FB         ; CLEAR 9TH BIT
                    STA D010        ; OF BALL.X
                    LDA 0BF0
                    EOR #01         ; TOGGLE DIRECTION
                    STA 0BF0
                    LDY #10         ; SET BEEP PITCH
                    JSR BEEP
                    RTS
        ;
        ; - PLAY SOUND ------------------------
        ;
$08DA   BEEP:       STY D401        ; H.BYTE OF FREQ TO Y
                    LDA #20         ; L.BYTE OF FREQ TO 32
                    STA D400        ; 
                    LDA #0F         ; SET DECAY TO 15
                    STA D405
                    LDA #F4         ; SET RELEASE TO 4
                    STA D406
                    LDA #11         ; SET TRIANGLE WAVE
                    STA D404
                    LDA #0F         ; SET VOLUME TO 15
                    STA D418
                    LDA #10         ; STOP PLAYING NOTE
                    STA D404
                    RTS
        ;
        ; = DATA ==============================
        ;
        ; NUMBER GRAPHICS
        ;
$0930   NUMBER:     .BYTE FF,FF,E7,E7,E7,E7,FF,FF
                    .BYTE 3C,3C,3C,3C,3C,3C,3C,3C
                    .BYTE FF,FF,0F,FF,FF,F0,FF,FF
                    .BYTE FF,FF,0F,3F,3F,0F,FF,FF
                    .BYTE E7,E7,E7,FF,FF,07,07,07
                    .BYTE FF,FF,F0,FF,FF,0F,FF,FF
                    .BYTE FF,FF,E0,FF,FF,E7,FF,FF
                    .BYTE FF,FF,0F,0F,0F,0F,0F,0F
                    .BYTE FF,FF,E7,FF,FF,E7,FF,FF
                    .BYTE FF,FF,E7,FF,FF,07,FF,FF
        ;
        ; PADDLE SPRITE
        ;
        PADDLE:     .BYTE 00 FF 00 00 81 00 00 BD
                    .BYTE 00 00 BD 00 00 BD 00 00
                    .BYTE BD 00 00 BD 00 00 BD 00
                    .BYTE 00 BD 00 00 BD 00 00 BD
                    .BYTE 00 00 BD 00 00 BD 00 00
                    .BYTE BD BB BB BD BB BB BD 00
                    .BYTE 00 BD 00 00 BD 00 00 BD
                    .BYTE 00 00 81 00 00 FF 00 00
        ;
        ; BALL SPRITE
        ;
$0980   BALL:       .BYTE C0 00 00 C0 00 00 00 00
                    .BYTE 00 00 00 00 00 00 00 00
                    .BYTE 00 00 00 00 00 00 00 00
                    .BYTE 00 00 00 00 00 00 00 00
                    .BYTE 00 00 00 00 00 00 00 00
                    .BYTE 00 00 00 00 00 00 00 00
                    .BYTE 00 00 00 00 00 00 00 00
                    .BYTE 00 00 00 00 00 00 00 00
        ;
        ; VARIABLES
        ;
        VARS:       ;     BALL   SLOWDOWN
                    ;     VX VY  VALUES
$0BF0               .BYTE 00 00 1F 1F 00 00 00 00
$0BF8               .BYTE 00 00 00 00 00 00 00 00
                    ;                       SCORE
