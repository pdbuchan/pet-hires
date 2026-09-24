# Commodore PET 2001 “HI-RES” — technical notes

## Executive summary

[CURSOR Magazine #18 (March 1980)](../Cursor_Magazine_No.18_March_1980.pdf) introduced a **HI-RES** program for PET 2001 computers.  The program gives the user the ability to turn individual pixels on and off within a small area of the screen. The file itself credits the BASIC to Glen Fisher and the machine-code renderer to Dave Dixon.

The PRG loads at `$0401`; tokenized BASIC occupies `$0401-$0EF3`, and the 6502 payload occupies `$0EF4-$1765`.

The renderer is a cycle-counted interrupt routine for the fixed-timing, discrete-TTL video system used by early PETs. It does not redefine the character ROM and it does not create a normal bitmap framebuffer. Instead, on each raster line it rewrites the nine screen-RAM character codes at columns 17–25. Because the video circuitry fetches the same screen cell again for the next of the eight glyph rows, the program can choose a different character for every glyph row. The displayed 8-pixel slice on line 0 may therefore come from character A, line 1 from character B, line 2 from character C, and so on. The resulting 9×5 character area is effectively **72×40 pixel positions**, subject to the important limitation that every 8-pixel horizontal byte must exist as that raster row of some PET character (or its inverse).

## Incompatibility with PET 4032

The program hard-codes the timing of the early PET video generator: 64 CPU cycles per scan line, eight scan lines per character row, and a fixed phase relationship between the vertical-blank IRQ and visible video. A CRTC-based 4032 has a different video subsystem and programmable CRTC timing, commonly using a 10-scan-line character cell. The 3756-cycle synchronization delay and the 64-cycle update cadence therefore no longer meet the beam at the intended places. This is a hardware/timing incompatibility, not a BASIC-version problem. Some 9-inch 4032 machines retained non-CRTC video, so model number alone is not a perfect discriminator; the relevant distinction is discrete-TTL versus MOS Technology 6545 Cathode Ray Tube Controller (CRTC) video hardware.

## The reversible IRQ hook

There are two setup entry points: `$0EF4` for the BASIC 1.0 user IRQ vector at `$0219/$021A`, and `$0F0F` for the BASIC 2.0–4.0 vector at `$0090/$0091`. The BASIC detects which family it is running on and chooses the appropriate entry. The elegant part is that the program uses the operand of the final `JMP` instruction at `$1762` as storage for the previous vector. Initially that instruction is `JMP $0F2A`. The setup routine swaps the vector bytes with `$1763/$1764`, so the user IRQ points to `$0F2A` and the final `JMP` points to the former user IRQ handler. Calling the setup routine a second time swaps them back, cleanly uninstalling the effect.

## Timing and the 64-cycle kernel

After the system IRQ dispatcher reaches `$0F2A`, the custom prologue consumes 26 cycles. The first scan-line values are installed while the machine is still in vertical blank. A delay loop of 221 iterations then consumes `221 × 17 - 1 = 3756` cycles. Allowing for the 6502 interrupt sequence and the ROM IRQ dispatcher puts the renderer into the visible frame around character position 19 of the first raster line. From then on every update block is exactly 64 cycles: 60 cycles for ten load/store pairs and 4 cycles for two NOPs.

The tenth load/store pair is deliberately **not** sent to screen RAM. It writes to a harmless byte in the cassette-buffer area (`$031A`, `$0342`, `$036A`, `$0392`, or `$03BA`). This gives BASIC a convenient 10-column logical addressing scheme and, more importantly, preserves the exact 60-cycle body without risking a partially drawn tenth display column.

A useful way to visualize one 64-cycle block is:

```text
block start (about visible column 19 of scanline N)
  +10  write logical X0  -> current scanline has already passed target col 17
  +14  write logical X1
  +18  write logical X2
  +24  write logical X3
  +30  write logical X4
  +36  write logical X5
  +42  write logical X6
  +48  write logical X7  -> after wrap, early in scanline N+1
  +54  write logical X8  -> still before target col 25 is fetched
  +60  dummy write       -> no tenth visible cell
  +64  next block starts at the same beam phase on scanline N+1
```

That fixed phase is the entire trick: the early writes occur after those cells have already been fetched for the current line, while the late writes occur before those cells are fetched on the following line. The next scan line therefore sees a new set of character codes.

## BASIC as a self-modifying graphics editor

The BASIC does not maintain a bitmap. At startup it scans the machine code for the 40 `LDX #immediate` instructions that begin the 40 logical raster-line blocks and stores the addresses of their operands in `RW(0..39)`. `CL(0..9)` then supplies offsets `[0,2,4,15,20,25,30,35,40,45]` to the ten immediate operands inside each block. Thus a BASIC operation such as `POKE RW(R)+CL(C),CH` changes the actual machine instruction that the interrupt routine will execute on every frame.

The visible coordinate system is logically 40 rows × 10 columns, but column 9 is the dummy timing slot. The displayed area is therefore 40 raster rows × 9 character bytes = 40×72 dots. Commands `H`, `V`, `P`, `F`, and `S` merely calculate which immediate operands to alter; `Q` calls the setup routine again to restore the original IRQ vector.

## Scan-line block map

| Logical Y | Text row | Glyph row | Code start | Operand base | VRAM cells | Dummy store |
|---:|---:|---:|---:|---:|---|---:|
| 0 | 0 | 0 | `$0F35` | `$0F36` | `$8011-$8019` | `$031A` |
| 1 | 0 | 1 | `$0F72` | `$0F73` | `$8011-$8019` | `$031A` |
| 2 | 0 | 2 | `$0FA6` | `$0FA7` | `$8011-$8019` | `$031A` |
| 3 | 0 | 3 | `$0FDA` | `$0FDB` | `$8011-$8019` | `$031A` |
| 4 | 0 | 4 | `$100E` | `$100F` | `$8011-$8019` | `$031A` |
| 5 | 0 | 5 | `$1042` | `$1043` | `$8011-$8019` | `$031A` |
| 6 | 0 | 6 | `$1076` | `$1077` | `$8011-$8019` | `$031A` |
| 7 | 0 | 7 | `$10AA` | `$10AB` | `$8011-$8019` | `$031A` |
| 8 | 1 | 0 | `$10DE` | `$10DF` | `$8039-$8041` | `$0342` |
| 9 | 1 | 1 | `$1112` | `$1113` | `$8039-$8041` | `$0342` |
| 10 | 1 | 2 | `$1146` | `$1147` | `$8039-$8041` | `$0342` |
| 11 | 1 | 3 | `$117A` | `$117B` | `$8039-$8041` | `$0342` |
| 12 | 1 | 4 | `$11AE` | `$11AF` | `$8039-$8041` | `$0342` |
| 13 | 1 | 5 | `$11E2` | `$11E3` | `$8039-$8041` | `$0342` |
| 14 | 1 | 6 | `$1216` | `$1217` | `$8039-$8041` | `$0342` |
| 15 | 1 | 7 | `$124A` | `$124B` | `$8039-$8041` | `$0342` |
| 16 | 2 | 0 | `$127E` | `$127F` | `$8061-$8069` | `$036A` |
| 17 | 2 | 1 | `$12B2` | `$12B3` | `$8061-$8069` | `$036A` |
| 18 | 2 | 2 | `$12E6` | `$12E7` | `$8061-$8069` | `$036A` |
| 19 | 2 | 3 | `$131A` | `$131B` | `$8061-$8069` | `$036A` |
| 20 | 2 | 4 | `$134E` | `$134F` | `$8061-$8069` | `$036A` |
| 21 | 2 | 5 | `$1382` | `$1383` | `$8061-$8069` | `$036A` |
| 22 | 2 | 6 | `$13B6` | `$13B7` | `$8061-$8069` | `$036A` |
| 23 | 2 | 7 | `$13EA` | `$13EB` | `$8061-$8069` | `$036A` |
| 24 | 3 | 0 | `$141E` | `$141F` | `$8089-$8091` | `$0392` |
| 25 | 3 | 1 | `$1452` | `$1453` | `$8089-$8091` | `$0392` |
| 26 | 3 | 2 | `$1486` | `$1487` | `$8089-$8091` | `$0392` |
| 27 | 3 | 3 | `$14BA` | `$14BB` | `$8089-$8091` | `$0392` |
| 28 | 3 | 4 | `$14EE` | `$14EF` | `$8089-$8091` | `$0392` |
| 29 | 3 | 5 | `$1522` | `$1523` | `$8089-$8091` | `$0392` |
| 30 | 3 | 6 | `$1556` | `$1557` | `$8089-$8091` | `$0392` |
| 31 | 3 | 7 | `$158A` | `$158B` | `$8089-$8091` | `$0392` |
| 32 | 4 | 0 | `$15BE` | `$15BF` | `$80B1-$80B9` | `$03BA` |
| 33 | 4 | 1 | `$15F2` | `$15F3` | `$80B1-$80B9` | `$03BA` |
| 34 | 4 | 2 | `$1626` | `$1627` | `$80B1-$80B9` | `$03BA` |
| 35 | 4 | 3 | `$165A` | `$165B` | `$80B1-$80B9` | `$03BA` |
| 36 | 4 | 4 | `$168E` | `$168F` | `$80B1-$80B9` | `$03BA` |
| 37 | 4 | 5 | `$16C2` | `$16C3` | `$80B1-$80B9` | `$03BA` |
| 38 | 4 | 6 | `$16F6` | `$16F7` | `$80B1-$80B9` | `$03BA` |
| 39 | 4 | 7 | `$172A` | `$172B` | `$80B1-$80B9` | `$03BA` |

## Character-code data in the supplied demo

### Text row 0
```text
line 0: 20 20 20 20 20 20 20 20 20
line 1: 20 20 67 20 20 20 20 20 20
line 2: E5 A0 76 A0 A0 A0 A0 A0 E7
line 3: A0 A0 F5 A0 A0 A0 A0 A0 A0
line 4: A0 A0 76 A0 A0 A0 A0 A0 A0
line 5: EA 20 67 20 20 20 20 20 F4
line 6: F6 20 20 20 20 20 20 20 F5
line 7: F6 20 20 20 20 20 20 20 F5
```
### Text row 1
```text
line 0: F6 51 56 66 5A 66 4A 2A F5
line 1: F6 51 56 66 5A E6 4A 2A F5
line 2: F6 51 56 66 5A 66 4A 2A F5
line 3: F6 51 56 66 5A E6 4A 2A F5
line 4: F6 57 5A 6C E9 66 55 5D F5
line 5: F6 57 5A 6C E9 E6 55 5D F5
line 6: F6 57 5A 6C E9 66 55 5D F5
line 7: F6 57 5A 6C E9 E6 55 5D F5
```
### Text row 2
```text
line 0: F6 A0 58 A0 4E 20 20 20 F5
line 1: F6 20 58 A0 4E 20 20 20 F5
line 2: F6 A0 58 A0 4E 20 20 F5 F5
line 3: F6 20 58 A0 4E 5D 74 42 F5
line 4: F6 A0 A0 DC 56 20 74 42 F5
line 5: F6 20 A0 DC 56 20 20 F5 F5
line 6: F6 A0 A0 DC 56 20 20 20 F5
line 7: F6 57 A0 DC 56 20 20 20 F5
```
### Text row 3
```text
line 0: F6 57 20 20 20 20 20 20 F5
line 1: F6 57 20 61 5C 56 5F 20 F5
line 2: F6 57 20 E1 5C 56 5F 20 F5
line 3: F6 57 5D 61 5C 56 5F 20 F5
line 4: F6 57 48 E1 5C 56 5F 20 F5
line 5: F6 51 E7 61 20 57 DF 20 F5
line 6: F6 51 48 E1 20 57 DF 20 F5
line 7: F6 51 5D 61 20 57 DF 6A F5
```
### Text row 4
```text
line 0: F6 51 20 E1 20 57 DF 6A F5
line 1: F6 20 20 20 20 20 20 20 F5
line 2: EA 20 20 20 20 20 65 20 F4
line 3: A0 A0 A0 A0 A0 A0 75 A0 A0
line 4: A0 A0 A0 A0 A0 A0 F6 A0 A0
line 5: E5 A0 A0 A0 A0 A0 75 A0 E7
line 6: 20 20 20 20 20 20 65 20 20
line 7: 20 20 20 20 20 20 20 20 20
```

## Compatibility conclusion

The program works on a PET 2001 but not on a CRTC PET 4032. The routine assumes the early PET raster is a fixed extension of the CPU clock and that the vertical-blank system interrupt has a fixed phase relationship to scanout. A 6545 CRTC introduces a different timing generator, different scan-line organization, and different interrupt/display relationship. Porting the effect to a CRTC PET requires a new synchronization strategy and a newly cycle-counted kernel; simply changing the IRQ vector address or BASIC ROM entry point cannot make this binary portable.

## Files in this directory

* `HIRES2001.PRG` — historical CURSOR #18 program.
* `HIRES2001.asm` — instruction-by-instruction annotated disassembly of `$0EF4-$1765`, with cycle counts, scan-line labels, self-modified operand notes, and the visible/dummy write distinction.
* `README.md` — this document.

