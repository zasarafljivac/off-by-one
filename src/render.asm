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
    .word SCREEN+0,SCREEN+40,SCREEN+80,SCREEN+120,SCREEN+160,SCREEN+200,SCREEN+240,SCREEN+280,SCREEN+320,SCREEN+360
    .word SCREEN+400,SCREEN+440,SCREEN+480,SCREEN+520,SCREEN+560,SCREEN+600,SCREEN+640,SCREEN+680,SCREEN+720,SCREEN+760
    .word SCREEN+800,SCREEN+840,SCREEN+880,SCREEN+920,SCREEN+960

ColorRows:
    .word COLOR+0,COLOR+40,COLOR+80,COLOR+120,COLOR+160,COLOR+200,COLOR+240,COLOR+280,COLOR+320,COLOR+360
    .word COLOR+400,COLOR+440,COLOR+480,COLOR+520,COLOR+560,COLOR+600,COLOR+640,COLOR+680,COLOR+720,COLOR+760
    .word COLOR+800,COLOR+840,COLOR+880,COLOR+920,COLOR+960
