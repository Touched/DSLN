@ Generic functions that are needed by everything

.text
.thumb_func

@ Gets the ability of the current attacker

.align 2
get_ability:
    ldr r0, battle_participants
    mov r1, #0x58 @ sizeof(battle_participant)
    ldr r2, battle_attacker
    ldrb r2, [r2]
    mul r1, r2
    mov r2, #0x20 @ Ability index
    add r1, r2
    add r0, r1 @ Current attacker's ability
    ldrb r0, [r0]
    bx lr
    
.align 2
battle_participants: .word 0x02024084
battle_attacker: .word 0x0202420B
