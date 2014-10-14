.text 
.align 2
.thumb_func

@ This function is called virtually every time an ability index is needed
@ instead of a slot number

@ Hook here: 0806B694
@ ldr r2, routine
@ bx r2

main:
    push {r1-r3, lr}

    @ Cast
    lsl r0, #0x10
    lsr r0, #0x10
    lsl r1, #0x18
    lsr r1, #0x18
    
    @ Check for hidden ability
    ldr r2, base_stats
    
    @ multiply by 0x1C
    lsl r3, r0, #3 
    sub r3, r0
    lsl r3, #2
    add r2, r3
    
    @ Check if we have a hidden ability (ability slot != 0 or 1)
    cmp r1, #1
    bhi hidden
    
    @ First ability slot
    add r2, #0x16
    cmp r1, #0
    beq normal
    
second:
    @ Load the second ability
    add r2, #1
    b normal
    
hidden:
    @ Padding offset; this is where the hidden ability index is stored
    add r2, #0x1A

    @ fall through
normal:
    @ Load the ability bit
    ldrb r0, [r2]

store:
    @ This address is used to store the ability for other functions
    @ It can be toggled with a preprocessor macro because I needed another
    @ function like this that didn't alter this address. Once less file to fix
    @ if a glitch happens ;)    

.ifndef NOSTORE
    ldr r2, ability_store
    strb r0, [r2]
.endif
    
    @ The value is also returned in r0
    pop {r1-r3, pc}

.align 2
base_stats: .word 0x083203CC
ability_store: .word 0x0202420A
