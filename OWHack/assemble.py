#!/usr/bin/python3

text = """0x808d912 0x1c20
0x808d9d4 0x1c30
0x808e206 0x1c30
0x808eb28 0x1c30
0x8095496 0x1c20
0x8096540 0x1c28
0x8096a9a 0x1c28
0x8096fee 0x1c20
0x809701a 0x1c20
0x8097e18 0x1c00
0x8097f3a 0x1c30
0x80e092c 0x1c00
0x8153f9a 0x1c00
0x8153fc2 0x1c28
0x8154022 0x1c00
0x815407e 0x1c00
0x815435c 0x1c08
0x8154a5c 0x1c08
0x8154d1e 0x1c28
0x8154f2e 0x1c30
0x81551a0 0x1c08
0x8155932 0x1c30
0x8155cc6 0x1c00
0x8156224 0x1c20"""

items = {}

for line in text.split('\n'):
    offset, patch = map(lambda x: int(x[2:], 16), line.split())
    items[offset] = patch
    
import os
import subprocess
import sys
import shutil

OBJCOPY = 'arm-linux-gnueabi-objcopy'
AS = 'arm-linux-gnueabi-as'
CC = 'arm-linux-gnueabi-gcc-4.7'
CXX = 'arm-linux-gnueabi-g++'

def assemble(assembly, rom, offset):
	subprocess.check_output([AS, '-mthumb', assembly])
	subprocess.check_output([OBJCOPY, '-O', 'binary', 'a.out', 'a.bin'])
	os.remove('a.out')
	with open(rom, 'rb+') as out, open('a.bin', 'rb') as ins:
		out.seek(offset)
		out.write(ins.read())
		out.write(bytes(100))
		
shutil.copyfile('BPEE0.gba', 'test.gba')

with open('test.gba', 'rb+') as rom:
    for key, value in items.items():
        offset = key - 0x08000000
        rom.seek(offset)
        data = value.to_bytes(2, 'little')
        rom.write(data)
        
def hook(file, rom, space, hook_at):
    assemble(file, rom, space)
    with open('test.gba', 'rb+') as rom:
        # Align 2
        if hook_at & 1:
            hook_at -= 1
            
        rom.seek(hook_at)
        
        if hook_at % 4:
            data = bytes([0x01, 0x49, 0x08, 0x47, 0x0, 0x0])
        else:
            data = bytes([0x00, 0x49, 0x08, 0x47])
            
        space += 0x08000001
        data += (space.to_bytes(4, 'little'))
        rom.write(bytes(data))
        
assemble('npc_get_template.s', 'test.gba', 0xE00000)
assemble('load_hook.s', 'test.gba', 0xE10000)
with open('test.gba', 'rb+') as rom:
    rom.seek(0x08E694)
    data = bytes([0x00, 0x49, 0x08, 0x47, 0x01, 0x00, 0xE0, 0x08])
    rom.write(data)
    
    rom.seek(0x08D694)
    data = bytes([0x00, 0x49, 0x08, 0x47, 0x01, 0x00, 0xE1, 0x08])
    rom.write(data)
    
    hook('808db70.s', 'test.gba', 0xE20000, 0x08db60)
    
    # From 0808DD04, patch
    # lsl r0, #0x10
    # lsr r0, #0x10
