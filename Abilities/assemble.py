#!/usr/bin/python3
    
import os
import subprocess
import sys
import shutil

OBJCOPY = 'arm-linux-gnueabi-objcopy'
AS = 'arm-linux-gnueabi-as'
CC = 'arm-linux-gnueabi-gcc-4.7'
CXX = 'arm-linux-gnueabi-g++'

def assemble(assembly, rom, offset, *args):
	subprocess.check_output([AS, '-mthumb'] + list(args) + [assembly])
	subprocess.check_output([OBJCOPY, '-O', 'binary', 'a.out', 'a.bin'])
	os.remove('a.out') 
	with open(rom, 'rb+') as out, open('a.bin', 'rb') as ins:
		out.seek(offset)
		out.write(ins.read())
		out.write(bytes(100))
		
shutil.copyfile('BPEE0.gba', 'test.gba')

def hook(file, rom, space, hook_at, register=0):
    assemble(file, rom, space)
    with open('test.gba', 'rb+') as rom:
        # Align 2
        if hook_at & 1:
            hook_at -= 1
            
        rom.seek(hook_at)
        
        register &= 7
        
        if hook_at % 4:
            data = bytes([0x01, 0x48 | register, 0x00 | (register << 3), 0x47, 0x0, 0x0])
        else:
            data = bytes([0x00, 0x48 | register, 0x00 | (register << 3), 0x47])
            
        space += 0x08000001
        data += (space.to_bytes(4, 'little'))
        rom.write(bytes(data))
        
with open('test.gba', 'rb+') as rom:
    hook('ability_index_hook.s', 'test.gba', 0xE00000, 0x06B694, 2)
    assemble('getattr_hook.s', 'test.gba', 0xE10000)
    assemble('setattr_hook.s', 'test.gba', 0xE20000)
    assemble('ability_index_hook.s', 'test.gba', 0xE30000, '-defsym', 'NOSTORE=1')
    
    rom.seek(0x06A7C0)
    rom.write((0x08E10000).to_bytes(4, 'little'))
    rom.seek(0x06AEEC)
    rom.write((0x08E20000).to_bytes(4, 'little'))
    
