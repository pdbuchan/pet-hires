# Commodore PET pseudo-high-resolution graphics

This repository documents and experiments with the unusual raster-timed graphics technique used by the **HI-RES** program published with [**CURSOR Magazine #18 (March 1980)**](Cursor_Magazine_No.18_March_1980.pdf) for the Commodore PET.

The original PET 2001 program changes screen-RAM character codes while the CRT is scanning the display. By selecting different character-ROM rows on successive raster lines, it can construct apparent graphics that do not exist as ordinary PET characters. The original implementation is tightly coupled to the fixed video timing of early, non-CRTC PETs.

The PET 4032 project here adapts the same underlying idea to a 40-column CRTC machine. It uses CRTC vertical-blank status for synchronization and an exactly 50-cycle, eight-band raster kernel, producing a nominal **64 x 40** pseudo-high-resolution area.

## Repository layout

```text
pet2001/
  HIRES2001.PRG
  HIRES2001.asm
  README.md

pet4032/
  H4032ART.PRG
  H4032ART.asm
  H4032ART.jpg
  H4032FIT.PRG
  H4032FIT.asm
  H4032FIT.jpg
  README.md

Cursor_Magazine_No_18_March_1980.pdf
COPYRIGHT.md
README.md
```

## PET 2001

`pet2001/HIRES2001.asm` is a heavily annotated disassembly of the original machine-code renderer. `TECHNICAL_README.md` explains its timing, interrupt hook, self-modifying graphics data, and the 72 x 40 display mechanism.

## PET 4032

Two 4032 variants are included:

- `H4032ART` keeps the first eight bands of the historical artwork, so the right side is cropped.
- `H4032FIT` adapts the artwork to the narrower eight-band display area so that both outer borders are retained.

## Copyright

The March 1980 CURSOR #18 newsletter bears the notice:

> © 1980 The Code Works — All Rights Reserved

The `HI-RES` PRG itself contains more specific notices identifying separate portions of the program:

- `HI-RES BASIC CODE COPYRIGHT (C) 1980 GLEN FISHER`
- `HI-RES MACHINE CODE COPYRIGHT(C) 1980 DAVE DIXON`
- `LINES 61000-65000 (C) 1980 CURSOR MAGAZINE`
