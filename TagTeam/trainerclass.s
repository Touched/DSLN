@ 0814F5A2 is where class and name are loaded

@ Patch
@ 08162C24: bx r0
@ 08162C26: nop
@ 08162C28: nop
@ 08162C30: OFFSET TO HERE + 1
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
    add r1, r0
    ldrb r0, [r1, #(partner.class)] @ Return class byte
    
    b return
    
normal:
    ldr r0, =0x08310030
    ldr r1, =0x7DA1
    add r0, r1
    ldrb r0, [r0]
    
return:
    ldr r1, exit
    bx r1
    
checkflag:
    ldr r1, =(0x0809D790 + 1)
    bx r1
    
var_load:
    ldr r1, =(0x0809D694 + 1)
    bx r1
    
.align 2
exit: .word 0x08162D1E + 1
