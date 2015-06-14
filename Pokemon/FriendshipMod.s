@Adds happiness to all pokemon in party.

.text
.align 2
.thumb
.thumb_func
.global AddHappiness

main:
push {r0-r7, lr}
@ Check the size of the party
ldr r4, party_amount
ldrb r4, [r4]
cmp r4, #0x0
beq exit @ Quit if there are zero
@ Start the loop
mov r6, #0xFF @ Max happiness
mov r7, #0x0
loop:
@ Load the amount of happiness to add
ldr r5, var
ldrb r5, [r5]
@ Get the offset of the party member to decrypt
ldr r0, first_pokemon
mov r1, #0x64
mul r1, r1, r7
add r0, r0, r1
@ Get the happiness of that member
bl get_happiness
mov r9, r0
pop {r0-r7}
@ Check if we can add what we want
add r9, r9, r5
cmp r9, r6
ble store_it
@ Subtract beyond maximum
mov r5, #0xff
store_it:
bl set_happiness
pop {r0-r7}

next:
@ Increment the counter
add r7, r7, #0x1
cmp r7, r4
blo loop @ Go back to start if less than party size

exit:
pop {r0-r7, pc}

get_happiness:
push {r0-r7}
mov r1, #0x20
ldr r2, decrypt_poke
bx r2

set_happiness:
push {r0-r7}
mov r1, #0x20
mov r2, r5
ldr r3, encrypt_poke
bx r3

.align 2
party_amount:
.word 0x20244E9
first_pokemon:
.word 0x20244EC
var:
.word 0x20270B8
decrypt_poke:
.word 0x806A519
encrypt_poke:
.word 0x806ACAD

