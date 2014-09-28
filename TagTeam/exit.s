@ Hook here 080861CC

.text
.align 2
.thumb_func

main:
    push {lr}
    
    @ Restore the party, no matter the outcome (special 29)
    bl restore_party
    
    bl check_victory
    cmp r0, #0
    bne normal
    bl setflags @ Set the trainer flags for this match
    
normal:
    bl sub_808631C
    ldr r1, =0x03005DAC
    ldr r0, =0x080AF169
    str r0, [r1]
    bl sub_80860C8
    pop {pc}
    
sub_808631C:
    ldr r0, =(0x0808631C + 1)
    bx r0

sub_80860C8:
    ldr r0, =(0x080860C8 + 1)
    bx r0
    
check_victory:
    ldr r0, =(0x08139E80 + 1)
    bx r0
    
restore_party:
    ldr r0, =(0x08076DD4 + 1)
    bx r0
    
setflags:
    push {r4, lr}
    ldr r4, opponent_trainers
    ldrh r0, [r4, #2]
    bl settrainerflag
    ldrh r0, [r4, #4]
    bl settrainerflag
    pop {r4, pc}
    
settrainerflag:
    ldr r1, =(0x080B17B8 + 1)
    bx r1
    
.align 2
opponent_trainers: .word 0x02038BC8
