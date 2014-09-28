@ Hook here 0806EC14

.include "config.s"

.text
.align 2
.thumb_func

main:
    ldr r0, =TAG_TEAM_FLAG
    bl checkflag
    cmp r0, #0
    beq normal
    
    @ Tag Teams are enabled, load the partner's stuff
    ldr r0, =TAG_TEAM_VAR @ Currently selected partner
    bl var_load
    lsl r0, #5 @ index * 0x20
    ldr r1, =TAG_TEAM_PARTNERS
    add r0, r0, r1 @ Name is the first field
    b return

normal:
    ldr r2, steven_name
    ldr r0, [r2]

return:
    ldr r1, =(0x0806EC64 + 1)
    bx r1
    
.align 2
steven_name: .word 0x08162E84
    
checkflag:
    ldr r1, =(0x0809D790 + 1)
    bx r1
    
var_load:
    ldr r1, =(0x0809D694 + 1)
    bx r1
