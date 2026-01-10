BasicUpstart2(main)

.encoding "petscii_upper"

.import source "constants.asm"
.import source "vars.asm"
.import source "render.asm"
.import source "text.asm"
.import source "menu.asm"
.import source "game.asm"
main:
    jsr SetupColors

MainMenuLoop:
    jsr ShowStoryScreen1
    jsr WaitForSpace

    jsr StartGame
    jmp MainMenuLoop
