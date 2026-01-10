PlayerX:      .byte 0
PlayerOldX:   .byte 0

BulletX:      .byte 0
BulletY:      .byte 0
BulletActive: .byte 0

ObjTick:       .byte 0
ObjTickVal:    .byte 0
PlayerTickVal: .byte 0
MoveTick:      .byte 0
DropCount:     .byte 0

GameOver:     .byte 0

TempColor:    .byte 0
TempRow:      .byte 0
TempCol:      .byte 0
TempChar:     .byte 0

CurObj:       .byte 0
CurExp:       .byte 0

JoyState:     .byte 0
WantFire:     .byte 0

ObjX:  .fill NUM_OBJ,0
ObjY:  .fill NUM_OBJ,0
ObjDX: .fill NUM_OBJ,0
ObjDY: .fill NUM_OBJ,0

ExpX: .fill NUM_EXP,0
ExpY: .fill NUM_EXP,0
ExpT: .fill NUM_EXP,0

RandSeed: .byte $A5
