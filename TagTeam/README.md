## What is this?
This mod uses a modified version of the Mossdeep Space Station tag team special in order to create tag team battles for your hack. It attempts to model the Diamond/Pearl/Platinum style of tag teams. This means you set a flag to enable tag teams, and clear it to disable it. You can have different "partners" with whom you pair up. These partners are controlled by a custom table to be inserted into the ROM.

## Installation
Change the variable, flag and table offset found in `config.s` to suit your needs. Then run `install.py` in the parent directory, as described in the main README.

## Creating a table
Partners are stored in a specific table, using 0x20 bytes per entry. The following format should be observed:

```
u8[8] Trainer Name
u8    Trainer Class
u8    Gender
u16   Trainer ID
u8    Backsprite Index (In the backsprite table)
u8    Flags for Pokemon 1.
u8    Flags for Pokemon 2.
u8    Flags for Pokemon 3.
u32   Pointer to Pokemon 1.
u32   Pointer to Pokemon 2.
u32   Pointer to Pokemon 3.
```

The pointers to the Pokemon follow the same structure as the encrypted data in the RAM (80 bytes per Pokemon, see Bulbapedia for more info). Right now, it is recommended to do a RAM dump on your party and use that to create teams. A tool will be provided to create teams in the future, however. The data is stored in its encrypted form, so be careful not to modify it by hand, lest you give the character a bad egg.

The flags only have one option for now. Setting the flag to 0 means that the Pokemon is loaded exactly as is from the data given by the repsective pointer. If you set it to 1, however, the data will be loaded, but the original trainer information will be overwritten with the data found in the partner entry.

The Trainer name should be formatted in the Pokemon text format, terminated with FF. Gender is 0 for male, 1 for female. Trainer ID is what will be used for the Pokemon's ID in its summary window. This is useful if you want a consistent ID for this character, otherwise just use a random value.

Backsprite index is the number (starting at 0) of the backsprite you wish to use for this character. I will allow more backsprites and things in future mods, so look out for this.

Pad the table with 00, as this data isn't exactly 0x20 bytes long.

## Using the hack
Simply create a script that sets the flag specified in `config.s`. After this, all multi battles (with 2 enemy trainers) will become tag team battles. Clear it to revert to the standard behaviour. If only one trainer spots you, a single battle will commence. The partner you battle with is controlled by the var in `config.s`. Simply set this to the index of the partner in the table described above, and all battles will use that character as a tag team partner.

## Future
I'll probably add a way to run a script automatically after each battle with the partner, that way you can heal Pokemon etc.

## Notes
The hack uses special 0x28 and 0x29 to save your party for each battle. Do not use these specials during a tag team event, as you will lose the party you backed up. I might change this in the future.
