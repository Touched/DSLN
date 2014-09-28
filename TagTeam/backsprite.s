@ Palette is loaded at 081BD3DC
@ Graphics are loaded at 081BD3EE (template)
@ 081BE1C0 is where the animation of the backsprite takes place

.include "config.s"

@ So hook here 081BD38E
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
    ldrb r4, [r1, #(partner.sprite)] @ Return class byte
    b load

normal:
    mov r4, #7 @ Steven's backsprite number
    
load:
    mov r0, #0x5A
    mov r9, r0
    ldr r0, =0x08305D2C
    ldrb r1, [r0, #0]
    ldr r0, exit
    bx r0
    
checkflag:
    ldr r1, =(0x0809D790 + 1)
    bx r1
    
var_load:
    ldr r1, =(0x0809D694 + 1)
    bx r1
    
.align 2
exit: .word 0x081BD3BE + 1
