@Checks Pokemon's(0x8000) egg groups stores in 0x8000 and 0x8001

.text
.align 2
.thumb
.thumb_func

main:
	push {r0-r3, lr}
        ldr r0, =(var)
        ldrh r0, [r0]
        mov r2, #0x1c
        mul r0, r0, r2
        ldr r3, =(BaseStats + 0x14)
        add r3, r3, r0
        ldrb r1, [r0, #0x1]
        ldrb r0, [r0]
        ldr r2, =(var)
        ldr r3, =(var1)
        strh r0, [r2]
        strh r1, [r3]
        pop {r0-r3, pc}

.align 2
var:
.word 0x20270B8
var1:
.word 0x20270Ba
BaseStats:
.word 0x83203cc