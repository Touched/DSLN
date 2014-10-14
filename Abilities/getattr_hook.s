.text
.align 2
.thumb_func

@ Place pointer to this at 0806A7C0. Don't add 1

@ Hooks into the ability part of the getattr function (Pokemon Decryption)
@ This is to allow multiple abilities

@ r9 holds the species

main:
    @mov r4, r9 @ Growth data
    @ldrh r4, [r4] @ species word
    
    @ multiply by 0x1C
    @lsl r6, r4, #3 
    @sub r6, r4
    @lsl r6, #2
    
    @ Base stats offset
    @ldr r0, base_stats
    @add r0, r6
    
    @ There is an unknown byte in the growth data. We'll use the MSB to mark
    @ hidden abilities
    mov r4, r9
    ldrb r4, [r4, #10] @ Unknown byte
    lsr r4, #0x7 @ Clear all but MSB
    cmp r4, #0
    beq normal
    
hidden:
    @add r4, r0, #0x1A @ padding offset - used for hidden ability index
    @ldrb r4, [r4]
    @cmp r4, #0
    @beq normal @ No hidden ability for this Pokemon. Fallback to normal ability
    
    @ Return the hidden ability index
    mov r4, #2
    b return
    
normal:
    
    @add r0, #0x16 @ ability 1 offset

    @ Load the ability bit into r4
    ldrb r4, [r5, #7]
    lsr r4, #7
    @add r4, r0 @ ability 1/2 offset
    @ldrb r4, [r4] @ load the ability index
    
return:
    @ Return to normal execution
    ldr r0, exit
    bx r0

.align 2
exit: .word 0x0806AC8C + 1
base_stats: .word 0x083203CC
