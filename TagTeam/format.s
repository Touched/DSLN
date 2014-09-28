@ Partner table entry structure
@ 0x20 bytes for alignment

    .struct 0
partner.name:
    .struct partner.name + 8
partner.class:
    .struct partner.class + 1
partner.gender:
    .struct partner.gender + 1
partner.id:
    .struct partner.id + 2
partner.sprite:
    .struct partner.sprite + 1
partner.poke1flags:
    .struct partner.poke1flags + 1
partner.poke2flags:
    .struct partner.poke2flags + 1
partner.poke3flags:
    .struct partner.poke3flags + 1
partner.poke1:
    .struct partner.poke1 + 4
partner.poke2:
    .struct partner.poke2 + 4
partner.poke3:
    

