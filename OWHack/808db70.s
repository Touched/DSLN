.text
.align 2
.thumb_func

main:
    lsl r4, #0x10
    lsr r4, #0x10
    lsl r5, #0x10
    lsr r5, #0x10
    mov r0, #0
    str r0, [sp, #0x20]
    mov r1, r9
    ldrb r0, [r1, #1]
    ldrb r2, [r1, #3]
    lsl r2, #8
    orr r0, r2
    ldr r2, =0x0808DB71
    bx r2
