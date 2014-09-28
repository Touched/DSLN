import subprocess
import os
import configparser

bin_prefix = '/opt/devkit/devkitARM/bin/arm-none-eabi-'

AS = bin_prefix + 'as'
OBJCOPY = bin_prefix + 'objcopy'
START = 0
BYTE = 0xFF

def find_toolchain(prefix):
    global AS, OBJCOPY
    AS = prefix + 'as'
    OBJCOPY = prefix + 'objcopy'

def assemble(infile, path):
    # Create build dir if it doesn't exist
    try:
        os.mkdir(os.path.join(path, 'build'))
    except FileExistsError:
        pass

    base, _ = os.path.splitext(infile)

    infile = os.path.join(path, infile)
    outfile = os.path.join(path, 'build', base + '.bin')

    subprocess.check_output([AS, '-mthumb', infile, '-I', path])
    subprocess.check_output([OBJCOPY, '-O', 'binary', 'a.out', outfile])
    os.remove('a.out')

    return outfile

def assemble_all(path):
    files = os.path.join(path, 'config', 'assembly')

    out = []

    # Assemble everything catalogued in the 'config/assembly' file
    with open(files) as file:
        for line in file:
            if line:
                asm = line.strip()
                out.append((asm, assemble(asm, path)))

    return out

def change(rom, line):
    # Write a change
    offset, hex_string = line.split(':')
    data = bytes.fromhex(hex_string.strip())
    offset = int(offset, 16)
    rom.seek(offset)
    rom.write(data)

def change_all(rom, path):
    files = os.path.join(path, 'config', 'changes')
    with open(files) as file:
        for line in file:
            if line:
                change(rom, line)

def freespace(rom, size, start, byte):
    if type(byte) == int:
        search = bytes([byte] * size)
    elif type(byte) == bytes and len(byte) == 1:
        search = byte * size
    else:
        raise TypeError

    rom.seek(start)
    data = rom.read()

    beg = 0
    # Search until we have found an appropriate offset
    while True:
        place = data.find(search, beg)
        print(hex(place), beg)

        if place == -1:
            raise ValueError('No free space')

        offset = start + place
        if offset % 4:
            beg = place + 1
        else:
            break

    return offset

def where_to_point(path):
    out = {}
    files = os.path.join(path, 'config', 'pointers')
    with open(files) as pointers:
        for line in pointers:
            offset, file = line.split(':')
            offset = int(offset, 16)
            file = file.strip()
            if file in out:
                # Append to the list, the file already is in the dict
                out[file].append(offset)
            else:
                # Make it a single item list for appending later
                out[file] = [offset]
    return out

def install_hack(rom, name):
    files = assemble_all(name)

    binaries = []

    pointers = where_to_point(name)

    for src, file in files:
        with open(file, 'rb') as data:
            binary = data.read()
            offset = freespace(rom, len(binary), START, BYTE)

            offset_adj = offset + 0x08000000 + 1

            for pointer in pointers[src]:
                rom.seek(pointer)
                p = offset_adj.to_bytes(4, 'little')
                rom.write(p)

            print(src, hex(offset))
            rom.seek(offset)
            rom.write(binary)

    change_all(rom, name)

config = configparser.ConfigParser()
config.read('config.ini')

p = os.path.join(config['main']['toolchain_path'], config['main']['toolchain_prefix'])
find_toolchain(p)

START = int(config['main']['freespace_start'], 16)
BYTE = int(config['main']['freespace_byte'], 16)

with open(config['main']['rom'], 'rb+') as rom:
    install_hack(rom, 'TagTeam')
