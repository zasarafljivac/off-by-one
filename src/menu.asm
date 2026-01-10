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
