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
    
    hook('init.s', 'test.gba', 0xE10000, 0x0B0804)
    
    hook('backsprite.s', 'test.gba', 0xE40000, 0x1BD38E)
    
    hook('palettefix.s', 'test.gba', 0xE50000, 0x1BE1C0)
    
    hook('battlename.s', 'test.gba', 0xE70000, 0x162E68)
    
    hook('othername.s', 'test.gba', 0xE80000, 0x06EC14)
    
    hook('exit.s', 'test.gba', 0xE90000, 0x0861CC)
    
    hook('doublecheck.s', 'test.gba', 0xEA0000, 0x06B68C)
    
    assemble('othername.s', 'test.gba', 0xE80000)
    rom.seek(0x06EC14)
    rom.write(b'\x00\x47')
    rom.seek(0x06EC24)
    rom.write(b'\x01\x00\xE8\x08')
    
    # Write Trainer Class
    assemble('trainerclass.s', 'test.gba', 0xE60000)
    rom.seek(0x162C24)
    rom.write(b'\x00\x47\x00\x00\x00\x00')
    rom.seek(0x162C30)
    rom.write(b'\x01\x00\xE6\x08')
    
    pokes = []
    with open('dump.bin', 'rb') as binary:
        for i in range(3):
            binary.seek(i * 100)
            pokes.append(binary.read(80))
            
    output = b''.join(pokes)
    
    rom.seek(0xE30000)
    rom.write(output)
            
    output = b''
    name = bytearray.fromhex('CE E3 E9 D7 DC D9 D8 FF')
    
    output = name + b'\x03' + b'\x00' + b'\x00' + b'\x00' + b'\x06'
    output += b'\x00' + b'\x00' + b'\x00'
    
    pointers = b''.join((0x08E30000 + (i * 80)).to_bytes(4, 'little') for i in range(3))
    output += pointers
    
    rom.seek(0xE20000)
    rom.write(output)
    
    # From 0808DD04, patch
    # lsl r0, #0x10
    # lsr r0, #0x10
