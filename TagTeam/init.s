.text
.align 2
.thumb_func

main:
    push {lr}
    
    @ Check if tag team battles should happen
    ldrh r0, tag_team_enabled_flag
    bl checkflag
    cmp r0, #0
    beq return
    
    @ Set battle flags. This makes it a tag team
    ldr r1, battle_type_flags
    ldr r0, =0x408049
    str r0, [r1]
    
    @ Store the players team
    
    @ Clear the bottom half of the players team
    
    @ Load the partner's Pokemon from the tag team table
    
return:
    pop {pc}
    
checkflag:
    ldr r3, checkflag_func
    bx r3

.align 2
battle_type_flags: .word 0x02022FEC
tag_team_enabled_flag: .word 0x200
checkflag_func: .word 0x08099C48 + 1
