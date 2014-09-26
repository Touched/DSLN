.text
.align 2
.thumb_func

main:
    push {lr}
    
    @ Check if what we have is more than can fit in a u16
    ldr r1, =0xFFFF
    cmp r0, r1
    
    @ It is, so it's a pointer
    bhi pointer
    
    @ Check if it's a u8 or 16
    lsl r0, #0x10
    lsr r1, r0, #0x10
    lsr r2, r1, #8
    cmp r2, #0
    
    @ u16
    bne extended
    
normal:
    @ Return to normal execution (after the hooked part)
    cmp r1, #0xEF
    bls branch_return
    ldr r2, return_no_branch
    bx r2
    
branch_return:
    ldr r2, return
    bx r2
  
.align 2
return: .word 0x0808E6AC + 1
return_no_branch: .word 0x0808E69E  + 1
    
pointer:
    @ We received a pointer to an NPC state in r0. Load
    @ the extended ID number
    
    ldrb r1, [r0, #0x1A] @ Unused byte in the NPC state struct
    ldrb r0, [r0, #5]
    b table_lookup
    
extended:
    @ We have an extended overworld ID number in r0
    
    @ Clear upper 16 bits
    lsl r1, #0x10
    lsr r1, r0, #0x18 @ Clear lower 8 bits of word
    
    @ Clear upper 8 bits of word
    lsl r0, #8
    lsr r0, #0x18
    
table_lookup:
    @ Overworld table in r1, Overworld in the table in r0
    
    @ Get the offset to the OW table
    lsl r1, #2 @ x 4
    adr r2, owtable
    add r1, r2
    ldr r1, [r1]
    
    lsl r0, #2 @ x 4
    add r1, r0
    ldr r0, [r1]
    
    pop {pc}
    
.align 2
owtable: 
    .word 0x08505620
    .word 0x08505620 + 4
    .word 0x08505620 
    .word 0x08A00000
