.text
.align 2
.thumb_func

@ Hook at 0804A728

main:
    push {r0-r7}
    
    @ Check battle flags here. Make sure this check only happens if we're in a
    @ tag team battle.
    ldr r0, battle_type_flags
    ldr r0, [r0] 
    
    @ We don't care about the flags in the lower 4 bits
    lsr r0, #4
    ldr r1, =0x40804 @ These are the flags set for a tag team battle
    cmp r0, r1
    bne normal
    
    @ Pokemon number for this message
    ldr r0, =0x0202449C
    ldr r0, [r0]
    ldrb r0, [r0, #0x10]
    
    @ We don't wan't Pokemon in our partner's team gaining EXP. 
    cmp r0, #3
    bge no_exp

normal:
    pop {r0-r7}
    
    @ These are the instructions that were replaced by the hook
    ldr r1, =0x0202449C
    ldr r4, [r1]
    ldrh r0, [r0, #4]
    mov r5, r1
    
    @ Return execution and show the EXP message
    ldr r1, return
    bx r1
    
no_exp:
    @ Increase state counter. This will allow the callback to continue normally
    ldr r1, =0x02024474
    ldrb r0, [r1, #0x1C]
    add r0, #2
    strb r0, [r1, #0x1C]
    
    @ Restore the stack and return execution to the return of the function
    pop {r0-r7}
    ldr r1, return_no_msg
    bx r1
    
.align 2
pokemon_team_id: .word 0x0202406E
return: .word 0x0804A730 + 1
return_no_msg: .word 0x0804ACB2 + 1
partner: .word 0x0202420D
battle_type_flags: .word 0x02022FEC
