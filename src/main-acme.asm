*=$0801
!word basic_end
!word 10
!byte $9e
!text "2061"
!byte 0
basic_end = *
!word 0

Start:
    jmp main

CHROUT = $FFD2
GETIN  = $FFE4

NUM_EXP = 4
NUM_OBJ = 4

BulletActive: !byte 0
BulletX:      !byte 0
BulletY:      !byte 0

CurExp:       !byte 0
CurObj:       !byte 0

DropCount:     !byte 0

ExpT: !fill NUM_EXP,0
ExpX: !fill NUM_EXP,0
ExpY: !fill NUM_EXP,0

GameOver:     !byte 0

JoyState:     !byte 0

MoveTick:      !byte 0

ObjDX: !fill NUM_OBJ,0
ObjDY: !fill NUM_OBJ,0
ObjTick:       !byte 0
ObjTickVal:    !byte 0
ObjX:  !fill NUM_OBJ,0
ObjY:  !fill NUM_OBJ,0

PlayerOldX:   !byte 0
PlayerTickVal: !byte 0
PlayerX:      !byte 0

RandSeed: !byte $A5

TempChar:     !byte 0
TempCol:      !byte 0
TempColor:    !byte 0
TempRow:      !byte 0

WantFire:     !byte 0

COLOR  = $D800
SCREEN = $0400
SPACE_CHAR = 32
ZP_COL = $FD
ZP_SCR = $FB

SetPtrs:
    asl
    tay
    lda ScreenRows,y
    sta ZP_SCR
    lda ScreenRows+1,y
    sta ZP_SCR+1
    lda ColorRows,y
    sta ZP_COL
    lda ColorRows+1,y
    sta ZP_COL+1
    rts

EraseAt:
    jsr SetPtrs
    txa
    tay
    lda #SPACE_CHAR
    sta (ZP_SCR),y
    lda #0
    sta (ZP_COL),y
    rts

PutCharColor:
    sty TempChar
    jsr SetPtrs
    txa
    tay
    lda TempChar
    sta (ZP_SCR),y
    lda TempColor
    sta (ZP_COL),y
    rts

ScreenRows:
    !word SCREEN+0,SCREEN+40,SCREEN+80,SCREEN+120,SCREEN+160,SCREEN+200,SCREEN+240,SCREEN+280,SCREEN+320,SCREEN+360
    !word SCREEN+400,SCREEN+440,SCREEN+480,SCREEN+520,SCREEN+560,SCREEN+600,SCREEN+640,SCREEN+680,SCREEN+720,SCREEN+760
    !word SCREEN+800,SCREEN+840,SCREEN+880,SCREEN+920,SCREEN+960

ColorRows:
    !word COLOR+0,COLOR+40,COLOR+80,COLOR+120,COLOR+160,COLOR+200,COLOR+240,COLOR+280,COLOR+320,COLOR+360
    !word COLOR+400,COLOR+440,COLOR+480,COLOR+520,COLOR+560,COLOR+600,COLOR+640,COLOR+680,COLOR+720,COLOR+760
    !word COLOR+800,COLOR+840,COLOR+880,COLOR+920,COLOR+960

StoryText:
    !text "SOMEBODY IS THROWING BITS AROUND!"
    !byte 13
    !text "THEY SEEM TO BE OFF BY ONE!"
    !byte 13,13
    !text "STOP THEM BEFORE IT'S TOO LATE!"
    !byte 13
    !byte 0

PressSpace:
    !byte 13
    !text "PRESS SPACE TO CONTINUE"
    !byte 0

BG     = $D021
BORDER = $D020

SetupColors:
    lda #$00
    sta BG
    lda #$06
    sta BORDER
    rts

ShowStoryScreen1:
    lda #$93
    jsr CHROUT
    lda #$8E
    jsr CHROUT

    lda #$0D
    jsr CHROUT
    lda #$0D
    jsr CHROUT

    ldx #<StoryText
    ldy #>StoryText
    jsr PrintZ

    lda #$0D
    jsr CHROUT
    lda #$0D
    jsr CHROUT

    ldx #<PressSpace
    ldy #>PressSpace
    jsr PrintZ
    rts

WaitForSpace:
WFS_loop:
    jsr GETIN
    beq WFS_loop
    cmp #$20
    bne WFS_loop
    rts

PrintZ:
    stx ptr+1
    sty ptr+2
    ldy #$00
PZ_next:
ptr:
    lda $FFFF,y
    beq PZ_done
    jsr CHROUT
    iny
    bne PZ_next
PZ_done:
    rts

ACCEL_EVERY_DROPS = 10
BULLET_CHAR = 46
BULLET_COLOR = 1
EXP_CHAR = 42
EXP_COLOR = 2
JOY2   = $DC00
OBJECT_CHAR = 2
OBJECT_COLOR = 7
OBJ_TICK_MIN   = 6
OBJ_TICK_START = 18
PLAYER_CHAR = 24
PLAYER_COLOR = 1
PLAYER_ROW = 24
PLAYER_TICK_MIN   = 1
PLAYER_TICK_START = 3

StartGame:
    lda #$93
    jsr CHROUT
    lda #$8E
    jsr CHROUT

    lda $D012
    eor #$A5
    sta RandSeed

    lda #0
    sta BulletActive
    sta GameOver
    sta MoveTick
    sta DropCount

    lda #OBJ_TICK_START
    sta ObjTickVal
    sta ObjTick

    lda #PLAYER_TICK_START
    sta PlayerTickVal

    ldx #0
SG_einit:
    lda #0
    sta ExpT,x
    inx
    cpx #NUM_EXP
    bne SG_einit

    lda #20
    sta PlayerX
    sta PlayerOldX
    jsr DrawPlayer

    ldx #0
SG_oinit:
    stx CurObj
    jsr RandX
    ldx CurObj
    sta ObjX,x
    lda #0
    sta ObjY,x

    ldx CurObj
    lda ObjY,x
    sta TempRow
    lda ObjX,x
    sta TempCol
    lda #OBJECT_COLOR
    sta TempColor
    lda TempRow
    ldx TempCol
    ldy #OBJECT_CHAR
    jsr PutCharColor

    ldx CurObj
    lda ObjX,x
    sta ObjDX,x
    lda ObjY,x
    sta ObjDY,x

    ldx CurObj
    inx
    cpx #NUM_OBJ
    bne SG_oinit

GameLoop:
    jsr WaitFrame
    jsr HandleInputJoy
    jsr UpdateBullet
    jsr UpdateExplosions
    jsr CheckBulletHit

    dec ObjTick
    bne GL_skipObj
    lda ObjTickVal
    sta ObjTick
    jsr UpdateObjects
    jsr UpdateDifficulty
GL_skipObj:
    lda GameOver
    beq GameLoop
    rts

HandleInputJoy:
    lda JOY2
    sta JoyState

    lda JoyState
    and #$10
    bne HIJ_space
    lda #1
    sta WantFire
    jmp HIJ_fire

HIJ_space:
    lda #0
    sta WantFire
    jsr GETIN
    beq HIJ_fire
    cmp #$20
    bne HIJ_fire
    lda #1
    sta WantFire

HIJ_fire:
    lda WantFire
    beq HIJ_move
    lda BulletActive
    bne HIJ_move
    lda PlayerX
    sta BulletX
    lda #23
    sta BulletY
    lda #1
    sta BulletActive
    jsr DrawBullet

HIJ_move:
    lda MoveTick
    beq HIJ_mvok
    dec MoveTick
    rts

HIJ_mvok:
    lda JoyState
    and #$04
    bne HIJ_chkR
    lda PlayerX
    beq HIJ_done
    jsr ErasePlayer
    dec PlayerX
    jsr DrawPlayer
    lda PlayerTickVal
    sta MoveTick
    rts

HIJ_chkR:
    lda JoyState
    and #$08
    bne HIJ_done
    lda PlayerX
    cmp #39
    beq HIJ_done
    jsr ErasePlayer
    inc PlayerX
    jsr DrawPlayer
    lda PlayerTickVal
    sta MoveTick
    rts

HIJ_done:
    rts

UpdateDifficulty:
    inc DropCount
    lda DropCount
    cmp #ACCEL_EVERY_DROPS
    bne UD_done
    lda #0
    sta DropCount

    lda ObjTickVal
    cmp #OBJ_TICK_MIN
    beq UD_player
    dec ObjTickVal

UD_player:
    lda PlayerTickVal
    cmp #PLAYER_TICK_MIN
    beq UD_done
    dec PlayerTickVal

UD_done:
    rts

UpdateBullet:
    lda BulletActive
    beq UB_done

    lda BulletY
    ldx BulletX
    jsr EraseAt

    lda BulletY
    beq UB_off
    dec BulletY
    jsr DrawBullet
    rts

UB_off:
    lda #0
    sta BulletActive
UB_done:
    rts

UpdateObjects:
    ldx #0
UO_loop:
    stx CurObj

    ldx CurObj
    lda ObjDY,x
    sta TempRow
    lda ObjDX,x
    sta TempCol
    lda TempRow
    ldx TempCol
    jsr EraseAt

    ldx CurObj
    inc ObjY,x
    lda ObjY,x
    cmp #PLAYER_ROW
    beq UO_reached

    lda ObjY,x
    sta TempRow
    lda ObjX,x
    sta TempCol
    lda #OBJECT_COLOR
    sta TempColor
    lda TempRow
    ldx TempCol
    ldy #OBJECT_CHAR
    jsr PutCharColor

    ldx CurObj
    lda ObjX,x
    sta ObjDX,x
    lda ObjY,x
    sta ObjDY,x

    ldx CurObj
    inx
    cpx #NUM_OBJ
    bne UO_loop
    rts

UO_reached:
    ldx CurObj
    lda ObjX,x
    cmp PlayerX
    beq UO_hit
    lda #1
    sta GameOver
    rts
UO_hit:
    lda #1
    sta GameOver
    rts

CheckBulletHit:
    lda BulletActive
    bne CBH_start
    rts

CBH_start:
    ldx #0
CBH_loop:
    stx CurObj

    lda BulletX
    ldx CurObj
    cmp ObjX,x
    beq CBH_xok
    jmp CBH_next
CBH_xok:

    lda BulletY
    cmp ObjY,x
    beq CBH_yok
    jmp CBH_next
CBH_yok:

    jsr EraseBullet
    lda #0
    sta BulletActive

    ldx CurObj
    lda ObjDY,x
    sta TempRow
    lda ObjDX,x
    sta TempCol
    lda TempRow
    ldx TempCol
    jsr EraseAt

    lda TempRow
    ldx TempCol
    jsr AddExplosion

    ldx CurObj
    jsr RandX
    ldx CurObj
    sta ObjX,x
    lda #0
    sta ObjY,x

    ldx CurObj
    lda ObjY,x
    sta TempRow
    lda ObjX,x
    sta TempCol
    lda #OBJECT_COLOR
    sta TempColor
    lda TempRow
    ldx TempCol
    ldy #OBJECT_CHAR
    jsr PutCharColor

    ldx CurObj
    lda ObjX,x
    sta ObjDX,x
    lda ObjY,x
    sta ObjDY,x

    rts

CBH_next:
    ldx CurObj
    inx
    cpx #NUM_OBJ
    beq CBH_exit
    jmp CBH_loop
CBH_exit:
    rts

UpdateExplosions:
    ldx #0
UE_loop:
    stx CurExp
    lda ExpT,x
    beq UE_next

    dec ExpT,x
    lda ExpT,x
    bne UE_next

    ldx CurExp
    lda ExpY,x
    sta TempRow
    lda ExpX,x
    sta TempCol
    lda TempRow
    ldx TempCol
    jsr EraseAt

UE_next:
    ldx CurExp
    inx
    cpx #NUM_EXP
    bne UE_loop
    rts

AddExplosion:
    sta TempRow
    stx TempCol

    ldx #0
AE_find:
    lda ExpT,x
    beq AE_use
    inx
    cpx #NUM_EXP
    bne AE_find
    rts

AE_use:
    lda TempCol
    sta ExpX,x
    lda TempRow
    sta ExpY,x
    lda #6
    sta ExpT,x

    lda #EXP_COLOR
    sta TempColor
    lda TempRow
    ldx TempCol
    ldy #EXP_CHAR
    jsr PutCharColor
    rts

ErasePlayer:
    lda #PLAYER_ROW
    ldx PlayerOldX
    jsr EraseAt
    rts

DrawPlayer:
    lda #PLAYER_COLOR
    sta TempColor
    lda #PLAYER_ROW
    ldx PlayerX
    ldy #PLAYER_CHAR
    jsr PutCharColor
    lda PlayerX
    sta PlayerOldX
    rts

EraseBullet:
    lda BulletY
    ldx BulletX
    jsr EraseAt
    rts

DrawBullet:
    lda #BULLET_COLOR
    sta TempColor
    lda BulletY
    ldx BulletX
    ldy #BULLET_CHAR
    jsr PutCharColor
    rts

WaitFrame:
WF_a:
    lda $D012
    cmp #$FF
    bne WF_a
WF_b:
    lda $D012
    cmp #$FF
    beq WF_b
    rts

RandX:
    lda RandSeed
    asl
    bcc RX_s1
    eor #$1D
RX_s1:
    sta RandSeed
    and #$3F
    cmp #40
    bcc RX_ok
    sbc #40
RX_ok:
    rts

main:
    jsr SetupColors

MainMenuLoop:
    jsr ShowStoryScreen1
    jsr WaitForSpace

    jsr StartGame
    jmp MainMenuLoop