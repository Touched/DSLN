.text
.align 2
.thumb_func

@ getattr counterpart
@ Hook at 0806AEEC: Don't add 1

main:
    ldrb r0, [r4]
    cmp r0, #2
    bhi return
    beq hidden
    
    @ Normal ability bit
    
    @ Save the input
    push {r0}
    
    @ Clear the hidden ability bit
    mov r1, r8 @ Growth data
    ldrb r2, [r1, #10] @ Unknown byte
    mov r0, #0x7F
    and r2, r0
    strb r2, [r1, #10]
    
    @ Restore input
    pop {r0}
    
    b store_ability
    
hidden:
    mov r1, r8 @ Growth data
    ldrb r2, [r1, #10] @ Unknown byte
    mov r0, #0x80 @ Force MSB to be set
    orr r0, r2
    
    @ Save the hidden ability byte
    strb r0, [r1, #10]

    @ Store ability 0
    mov r0, #0
    
store_ability:
    @ Save the ability bit
    lsl r0, #7
    ldrb r2, [r5, #7]
    mov r1, #0x7F
    and r1, r2
    orr r1, r0
    strb r1, [r5, #7]
    
return:
    ldr r0, exit
    bx r0
    
.align 2
exit: .word 0x0806B3D8 + 1
