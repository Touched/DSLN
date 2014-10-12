@ Changes the type of a move to something else

@ Hook at 0804706C: bx r0

main:
    lsl r0, r1, #1
    add r0, r1
    lsl r0, #2
    add r0, r2
    ldrb r0, [r0, #2] @ Move type
    
    @ Modify the move's type
    push {r4}
    mov r4, r0
    
    bl get_ability
    
.ifdef AERILATE
    cmp r0, #ABILITY_AERILATE
    bne no_aerilate
    
    @ Normal moves become flying type
    cmp r4, #TYPE_NORMAL
    @ We can just bypass all the checks. The Pokemon can only have one ability
    @ at a time after all.
    bne return @ We don't change this move
    
    @ Change the move's type
    mov r0, #TYPE_FLYING
    b return

@ Next check
no_aerilate:
.endif

.ifdef NORMALIZE
    cmp r0, #ABILITY_NORMALIZE
    bne no_normalize
    
    mov r0, #TYPE_NORMAL
    b return
no_normalize:
.endif

.ifdef REFRIGERATE
    cmp r0, #ABILITY_REFRIGERATE
    bne no_refrigerate
    
    cmp r4, #TYPE_NORMAL
    bne return
    
    mov r0, #TYPE_ICE
    b return
no_refrigerate:
.endif

.ifdef PIXILATE
    cmp r0, #ABILITY_PIXILATE
    bne no_pixilate
    
    cmp r4, #TYPE_NORMAL
    bne return
    
    mov r0, #TYPE_FAIRY
    b return
no_pixilate:
.endif

return:
    @ End of hook
    pop {r4}
    
    @ Save the move type
    mov r8, r0
    ldr r0, exit
    bx r0
    
.align 2
exit: .word 0x08047078 +  1
