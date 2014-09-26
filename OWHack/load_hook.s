.text
.align 2
.thumb_func

main:
    @ Just do the stuff we overwrote with the hook
    @mov r1, #1
    @orr r0, r1
    @mov r1, #4
    @orr r0, r1
    mov r1, #5
    orr r0, r1
    strb r0, [r4]
    
    @ Now we can perform the hook function
    
    ldrb r0, [r5, #1] @ picture number
    strb r0, [r4, #5]
    
    ldrb r0, [r5, #3] @ overworld bank
    strb r0, [r4, #0x1A]
    
    ldr r0, return
    bx r0
    
.align 2
return: .word 0x0808D6A2 + 1

@ This shouldn't be  a hook
@ We can just patch after optimising
@ From: 0808D694 - 0808D69E
@ mov r1, #5
@ orr r0, r1
@ strb r0, [r4]
@ ldrb r0, [r5, #3]
@ strb r0, [r4 #23]



