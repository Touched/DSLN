













delta_memcpy:
    push {r5-r6, lr}
    mov r6, #0 @ counter
    @ r0=src, r1=dest, r2=delta, r3=length
loop:
    add r4, r0, r6
    add r5, r1, r6
    ldrb r4, [r4]
    add r4, r2 @ add delta
    strb r4, [r5]
    add r6, #1 @ increment counter
    cmp r6, r3 @ loop
    blt loop
    pop {r5-r6, pc}
