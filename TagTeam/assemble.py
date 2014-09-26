#!/usr/bin/python3
    
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
        
with open('test.gba', 'rb+') as rom:
    
    hook('noexp.s', 'test.gba', 0xE00000, 0x04A728)
    
    # From 0808DD04, patch
    # lsl r0, #0x10
    # lsr r0, #0x10
