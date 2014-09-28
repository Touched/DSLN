@ Hook at 0806B68C
@ Luckily there are two bytes for padding

@ This function hooks into the check whether the player can double battle or
@ not. We must make it so that if tag teams are enabled, then the player can
@ always double battle.

.include "config.s"

.text
.align 2
.thumb_func

main:
    @ Store the old return value
    @ 1 = can't double battle
    @ 0 = can double battle
    mov r4, r0
    
    @ Check the tag team flag
    ldr r0, =TAG_TEAM_FLAG
    bl checkflag
    cmp r0, #0
    bne flag_set
    
    @ Otherwise use the old result
    mov r0, r4
    b return
    
flag_set:
    @ We can always double battle if the tag team flag is set
    mov r0, #0
    @ fallthrough and return

return:
    @ Do the instructions we replaced
    pop {r4-r6, pc}
    
checkflag:
    ldr r1, =(0x0809D790 + 1)
    bx r1

