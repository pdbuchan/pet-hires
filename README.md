# Commodore PET pseudo-high-resolution graphics

This repository documents and experiments with the unusual raster-timed graphics technique used by the **HI-RES** program published with [**CURSOR Magazine #18 (March 1980)**](Cursor_Magazine_No.18_March_1980.pdf) for the Commodore PET.

The original PET 2001 program changes screen-RAM character codes while the CRT is scanning the display. By selecting different character-ROM rows on successive raster lines, it can construct apparent graphics that do not exist as ordinary PET characters. The original implementation is tightly coupled to the fixed video timing of early, non-CRTC PETs.

The PET 4032 project here adapts the same underlying idea to a 40-column CRTC machine. It uses CRTC vertical-blank status for synchronization and an exactly 50-cycle, eight-band raster kernel, producing a nominal **64 x 40** pseudo-high-resolution area.

## Repository Files

| File | Description |
|---|---|
| `Cursor_Magazine_No_18_March_1980.pdf` | CURSOR Magazine #18 |
| `PET-HIRES.D64` | Disk image containing `HIRES2001.PRG`, `H4032ART.PRG`, and `H4032FIT.PRG` in .D64 format |
| `README.md` | This file |

PET 2001

| File | Description |
|---|---|
| `pet2001/HIRES2001.PRG` | The full original HI-RES program (BASIC and machine-code) in .PRG format |
| `pet2001/HIRES2001.pdf` | Listing of the BASIC portion in Adobe Acrobat format |
| `pet2001/HIRES2001.asm` | Annotated disassembly of the original machine-code renderer in text format |
| `pet2001/HIRES2001.png` | Photo of artwork produced by original program |
| `pet2001/README.md` | Explains its timing, interrupt hook, self-modifying graphics data, and the 72 x 40 display mechanism |

PET 4032

Two PET 4032 variants are included:

H4032ART - Keeps the first eight bands of the historical artwork, so the right side is cropped.

| File | Description |
|---|---|
| `pet4032/H4032ART.PRG` | Full program (BASIC and machine-code) in .PRG format |
| `pet4032/H4032ART.pdf` | Listing of the BASIC portion in Adobe Acrobat format |
| `pet4032/H4032ART.asm` | Annotated disassembly of the machine-code renderer in text format |
| `pet4032/H4032ART.jpg` | Photo of the original artwork rendered on PET 4032, showing truncation on right side |

H4032FIT - Adapts the artwork to the narrower eight-band display area so that both outer borders are retained.

| File | Description |
|---|---|
| `pet4032/H4032FIT.PRG` | Full program (BASIC and machine-code) in .PRG format |
| `pet4032/H4032FIT.pdf` | Listing of the BASIC portion in Adobe Acrobat format |
| `pet4032/H4032FIT.asm` | Annotated disassembly of the machine-code renderer in text format |
| `pet4032/H4032FIT.jpg` | Photo of the modified artwork rendered on PET 4032, showing it fits in available display region |

`pet4032/README.md` explains the adaptation to PET 4032.

## Copyright

The March 1980 CURSOR #18 newsletter bears the notice:

> © 1980 The Code Works — All Rights Reserved

The `HI-RES` PRG itself contains more specific notices identifying separate portions of the program:

- `HI-RES BASIC CODE COPYRIGHT (C) 1980 GLEN FISHER`
- `HI-RES MACHINE CODE COPYRIGHT(C) 1980 DAVE DIXON`
- `LINES 61000-65000 (C) 1980 CURSOR MAGAZINE`
