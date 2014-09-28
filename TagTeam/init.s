.include "config.s"

.text
.align 2
.thumb_func

@ Hook here 080B0804

main:
    push {lr}
    
    bl hook
    cmp r0, #1
    bne normal
    
    @ Steven battle flags
    ldr r1, =0xC03
    ldr r0, =0x02038BCE
    strh r1, [r0]
    
    ldr r0, =0x08163A8D
    mov r1, #1
    bl task_add
    
    mov r0, #0
    bl battle_music
    
    mov r0, #0x0
    bl load_battle_callback
    
    pop {pc}
    
normal:
    bl sub_80B0F34
    lsl r0, #0x18
    lsr r0, #0x18
    mov r1, #0

    ldr r2, =(0x080B0810 + 1)
    bx r2
    
sub_80B0F34:
    ldr r0, =(0x80B0F34 + 1)
    bx r0
    
battle_music:
    ldr r1, =(0x0806E668 + 1)
    bx r1

load_battle_callback:   
    ldr r1, =(0x08145EF4 + 1)
    bx r1
    
task_add:
    ldr r2, =(0x080A8FB0 + 1)
    bx r2
    
load_partner_pkmn:
    ldr r2, =(0x08165404 + 1)
    bx r2
    
hook:
    push {r4-r5, lr}
    
    @ Check if tag team battles should happen
    ldr r0, =TAG_TEAM_FLAG
    bl checkflag
    cmp r0, #0
    beq no_tag_team
    
    @ Set battle flags. This makes it a tag team
    ldr r1, battle_type_flags
    
    @ Check the battle flags
    ldr r0, [r1]
    ldr r2, =0x8001 @ These flags are set if two trainers spotted you
    and r2, r0 
    cmp r2, #0
    beq no_tag_team
    
    @ Tag team flags
    ldr r0, =0x408049
    str r0, [r1]
    
    @ Store the players team
    @ Using special 0x28's code. Will be restored by special 0x29 after the battle
    bl store_party
    
    @ Load the partner's Pokemon from the tag team table
    ldr r0, =TAG_TEAM_VAR
    bl var_load
    lsl r0, #5 @ index * 0x20
    ldr r4, =TAG_TEAM_PARTNERS
    add r4, r0
    
    @ Init counter
    mov r5, #0x0
    
loop:
    @ Calculate RAM offset of party slot
    mov r0, #0x64
    mul r0, r5
    ldr r1, pokemon_party
    add r0, r1
    
    @ Calculate offset of pokemon data
    lsl r1, r5, #2
    add r1, r4
    
    @ Load flags
    ldrb r3, [r1, #(partner.poke1flags)]
    mov r2, #1
    and r3, r2 @ LSB
    
    @ Load the Pokemon data
    ldr r1, [r1, #(partner.poke1)]
    
    @ Use partner data
    mov r2, r4
    
    bl load_partner_pokemon
    
    @ Increase counter and loop
    add r5, #1
    cmp r5, #3
    blt loop
    
continue:
    mov r0, #1 @ Return 1 for tag team hook applied
    b return
    
no_tag_team:
    mov r0, #0
    
return:
    pop {r4-r5, pc}
    
checkflag:
    ldr r1, =(0x0809D790 + 1)
    bx r1
    
var_load:
    ldr r1, =(0x0809D694 + 1)
    bx r1
    
store_party:
    ldr r0, =(0x08076D8C + 1)
    bx r0

.align 2
battle_type_flags: .word 0x02022FEC
pokemon_party: .word 0x020244EC + (3 * 0x64) @ lower half of party
tag_team_enabled_flag: .word 0x200

load_partner_pokemon:
    push {r4-r7, lr}
    
    @ Save arguments in the higher registers
    mov r4, r0 @ dest
    mov r5, r1 @ data
    mov r6, r2 @ partner
    mov r7, r3 @ reset OT flag
    
    @ Zero out 100 bytes
    mov r1, #0
    mov r2, #64
    bl memset
    
    @ Load the Pokemon data from the ROM. Should be pre-encrypted
    mov r0, r4
    mov r1, r5
    mov r2, #0x50 @ 80 bytes. Stats, etc. are calculated
    bl memcpy
    
    @ Calculate stats
    mov r0, r4
    bl pokemon_calculate_stats
    
    @ Do we need to change OT Data?
    cmp r7, #0
    beq load_partner_pokemon_return @ no we do not
    
    @ Set OT Name
    mov r0, r4
    mov r1, #0x7
    add r2, r6, #(partner.name)
    bl pokemon_setattr
    
    @ Set OT Gender
    mov r0, r4
    mov r1, #0x31
    mov r2, #(partner.gender)
    add r2, r6
    bl pokemon_setattr
    
    @ Set OT ID
    mov r0, r4
    mov r1, #0x1
    mov r2, #(partner.id)
    add r2, r6
    bl pokemon_setattr
    
    @ TODO: Maybe set origin information?
    
load_partner_pokemon_return:
    pop {r4-r7, pc}
    
memcpy:
    ldr r3, =(0x082E93D4 + 1)
    bx r3
    
memset:
    ldr r3, =(0x082E9434 + 1)
    bx r3
    
pokemon_calculate_stats:
    ldr r1, =(0x08068D0C + 1)
    bx r1
    
pokemon_setattr:
    ldr r3, =(0x0806ACAC + 1)
    bx r3
    
