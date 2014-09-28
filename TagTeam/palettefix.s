.include "config.s"

.text
.align 2
.thumb_func

@ Hook at 081BE1C0

main:
    push {r0}

    ldr r0, =TAG_TEAM_FLAG
    bl checkflag
    cmp r0, #0
    beq normal
    
    @ Tag Teams are enabled, load the partner's stuff
    ldr r0, =TAG_TEAM_VAR @ Currently selected partner
    bl var_load
    lsl r0, #5 @ index * 0x20
    ldr r1, =TAG_TEAM_PARTNERS
    add r1, r0
    ldrb r1, [r1, #(partner.sprite)] @ Return class byte
    
    @ Restore r0
    pop {r0}
    b continue

normal:
    pop {r0} @ fix stack
    mov r1, #7 @ Steven's Backsprite
    
continue:
    lsl r1, #3 @ * 8
    add r0, r1
    ldr r0, [r0]
    
    @ Resume normal behaviour
    lsl r4, #4
    ldr r2, =0x100
    add r1, r4, r2
    mov r2, #0x20
    ldr r3, exit
    bx r3
    
checkflag:
    ldr r1, =(0x0809D790 + 1)
    bx r1
    
var_load:
    ldr r1, =(0x0809D694 + 1)
    bx r1
    
.align 2
exit: .word 0x081BE1CC + 1
