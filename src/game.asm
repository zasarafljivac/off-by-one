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
