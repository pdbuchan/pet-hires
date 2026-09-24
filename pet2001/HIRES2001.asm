; HIRES2001.PRG — Annotated 6502 disassembly
; Original program: CURSOR #18, March 1980
; BASIC portion credited in the file to Glen Fisher; machine code to Dave Dixon.
;
; Core idea: on every system IRQ, synchronize to the fixed PET 2001 raster timing,
; then rewrite nine screen cells once per 64-cycle raster line. Each 8-pixel
; horizontal slice can therefore come from a different character-ROM glyph.
; The immediate operands below are the graphics data and are modified by BASIC.

        .org $0EF4


setup_old_rom:
        SEI            ; $0EF4: 78       (2 cyc) Disable maskable IRQs while exchanging the BASIC 1.0 user-IRQ vector.
        LDA $0219      ; $0EF5: AD 19 02 (4 cyc) Read low byte of the BASIC 1.0 user-IRQ vector at $0219.
        LDX $1763      ; $0EF8: AE 63 17 (4 cyc) Read the low byte currently stored in the final JMP operand; initially $2A.
        STA $1763      ; $0EFB: 8D 63 17 (4 cyc) Put the previous user-IRQ low byte into the final JMP operand.
        STX $0219      ; $0EFE: 8E 19 02 (4 cyc) Install $2A as the new user-IRQ low byte.
        LDA $021A      ; $0F01: AD 1A 02 (4 cyc) Read high byte of the BASIC 1.0 user-IRQ vector at $021A.
        LDX $1764      ; $0F04: AE 64 17 (4 cyc) Read the high byte currently stored in the final JMP operand; initially $0F.
        STA $1764      ; $0F07: 8D 64 17 (4 cyc) Put the previous user-IRQ high byte into the final JMP operand.
        STX $021A      ; $0F0A: 8E 1A 02 (4 cyc) Install $0F as the new user-IRQ high byte; vector now points to $0F2A.
        CLI            ; $0F0D: 58       (2 cyc) Re-enable maskable IRQs.
        RTS            ; $0F0E: 60       (6 cyc) Return to BASIC. A second call performs the same swap in reverse and unhooks HI-RES.

setup_new_rom:
        SEI            ; $0F0F: 78       (2 cyc) BASIC 2.0-4.0 setup entry: same reversible vector exchange using $0090/$0091.
        LDA $0090      ; $0F10: AD 90 00 (4 cyc) Read low byte of newer-ROM user-IRQ vector.
        LDX $1763      ; $0F13: AE 63 17 (4 cyc) Read low byte from final JMP target.
        STA $1763      ; $0F16: 8D 63 17 (4 cyc) Save old vector byte into final JMP target.
        STX $0090      ; $0F19: 8E 90 00 (4 cyc) Install custom IRQ low byte.
        LDA $0091      ; $0F1C: AD 91 00 (4 cyc) Read high byte of newer-ROM user-IRQ vector.
        LDX $1764      ; $0F1F: AE 64 17 (4 cyc) Read high byte from final JMP target.
        STA $1764      ; $0F22: 8D 64 17 (4 cyc) Save old vector byte into final JMP target.
        STX $0091      ; $0F25: 8E 91 00 (4 cyc) Install custom IRQ high byte.
        CLI            ; $0F28: 58       (2 cyc) Re-enable IRQs.
        RTS            ; $0F29: 60       (6 cyc) Return to BASIC.

video_irq:
        PHP            ; $0F2A: 08       (3 cyc) Custom user-IRQ/video-kernel entry. Save processor status.
        PHA            ; $0F2B: 48       (3 cyc) Save accumulator.
        TXA            ; $0F2C: 8A       (2 cyc) Move X to A so X can be pushed.
        PHA            ; $0F2D: 48       (3 cyc) Save X.
        TYA            ; $0F2E: 98       (2 cyc) Move Y to A so Y can be pushed.
        PHA            ; $0F2F: 48       (3 cyc) Save Y.
        NOP            ; $0F30: EA       (2 cyc) Timing pad.
        NOP            ; $0F31: EA       (2 cyc) Timing pad.
        NOP            ; $0F32: EA       (2 cyc) Timing pad.
        NOP            ; $0F33: EA       (2 cyc) Timing pad.
        NOP            ; $0F34: EA       (2 cyc) Timing pad; prologue totals 26 cycles from $0F2A.

line_00_r0_s0:
        ; primed during VBLANK before synchronization; target VRAM $8011-$8019.
        ; Values: 20 20 20 20 20 20 20 20 20   [dummy slot 00]
        LDX #$20       ; $0F35: A2 20    (2 cyc) Load screen code $20 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $0F37: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$20       ; $0F39: A9 20    (2 cyc) Load screen code $20 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8011      ; $0F3B: 8E 11 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8011.
        STY $8012      ; $0F3E: 8C 12 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8012.
        STA $8013      ; $0F41: 8D 13 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8013.
        LDA #$20       ; $0F44: A9 20    (2 cyc) Load screen code $20 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8014      ; $0F46: 8D 14 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8014.
        LDA #$20       ; $0F49: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8015      ; $0F4B: 8D 15 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8015.
        LDA #$20       ; $0F4E: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8016      ; $0F50: 8D 16 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8016.
        LDA #$20       ; $0F53: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8017      ; $0F55: 8D 17 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8017.
        LDA #$20       ; $0F58: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8018      ; $0F5A: 8D 18 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8018.
        LDA #$20       ; $0F5D: A9 20    (2 cyc) Load screen code $20 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8019      ; $0F5F: 8D 19 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8019.
        LDA #$00       ; $0F62: A9 00    (2 cyc) Load screen code $00 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $031A      ; $0F64: 8D 1A 03 (4 cyc) Dummy store to $031A; burns 4 cycles without touching a tenth visible screen cell.
        LDY #$DD       ; $0F67: A0 DD    (2 cyc) Load $DD (221) iterations for the vertical-blank synchronization delay.

sync_delay:
        NOP            ; $0F69: EA       (2 cyc) Delay loop: NOP 1 of 6.
        NOP            ; $0F6A: EA       (2 cyc) Delay loop: NOP 2 of 6.
        NOP            ; $0F6B: EA       (2 cyc) Delay loop: NOP 3 of 6.
        NOP            ; $0F6C: EA       (2 cyc) Delay loop: NOP 4 of 6.
        NOP            ; $0F6D: EA       (2 cyc) Delay loop: NOP 5 of 6.
        NOP            ; $0F6E: EA       (2 cyc) Delay loop: NOP 6 of 6.
        DEY            ; $0F6F: 88       (2 cyc) Count one 17-cycle delay-loop iteration.
        BNE $0F69      ; $0F70: D0 F7    (2/3 cyc) Loop while Y != 0. Taken=3 cycles, final fall-through=2; total delay is 3756 cycles.

line_01_r0_s1:
        ; prepares logical scanline 1 (text row 0, glyph row 1); target VRAM $8011-$8019.
        ; Values: 20 20 67 20 20 20 20 20 20   [dummy slot 00]
        LDX #$20       ; $0F72: A2 20    (2 cyc) Load screen code $20 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $0F74: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$67       ; $0F76: A9 67    (2 cyc) Load screen code $67 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8011      ; $0F78: 8E 11 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8011.
        STY $8012      ; $0F7B: 8C 12 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8012.
        STA $8013      ; $0F7E: 8D 13 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8013.
        LDA #$20       ; $0F81: A9 20    (2 cyc) Load screen code $20 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8014      ; $0F83: 8D 14 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8014.
        LDA #$20       ; $0F86: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8015      ; $0F88: 8D 15 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8015.
        LDA #$20       ; $0F8B: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8016      ; $0F8D: 8D 16 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8016.
        LDA #$20       ; $0F90: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8017      ; $0F92: 8D 17 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8017.
        LDA #$20       ; $0F95: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8018      ; $0F97: 8D 18 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8018.
        LDA #$20       ; $0F9A: A9 20    (2 cyc) Load screen code $20 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8019      ; $0F9C: 8D 19 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8019.
        LDA #$00       ; $0F9F: A9 00    (2 cyc) Load screen code $00 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $031A      ; $0FA1: 8D 1A 03 (4 cyc) Dummy store to $031A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $0FA4: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $0FA5: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_02_r0_s2:
        ; prepares logical scanline 2 (text row 0, glyph row 2); target VRAM $8011-$8019.
        ; Values: E5 A0 76 A0 A0 A0 A0 A0 E7   [dummy slot 00]
        LDX #$E5       ; $0FA6: A2 E5    (2 cyc) Load screen code $E5 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$A0       ; $0FA8: A0 A0    (2 cyc) Load screen code $A0 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$76       ; $0FAA: A9 76    (2 cyc) Load screen code $76 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8011      ; $0FAC: 8E 11 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8011.
        STY $8012      ; $0FAF: 8C 12 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8012.
        STA $8013      ; $0FB2: 8D 13 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8013.
        LDA #$A0       ; $0FB5: A9 A0    (2 cyc) Load screen code $A0 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8014      ; $0FB7: 8D 14 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8014.
        LDA #$A0       ; $0FBA: A9 A0    (2 cyc) Load screen code $A0 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8015      ; $0FBC: 8D 15 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8015.
        LDA #$A0       ; $0FBF: A9 A0    (2 cyc) Load screen code $A0 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8016      ; $0FC1: 8D 16 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8016.
        LDA #$A0       ; $0FC4: A9 A0    (2 cyc) Load screen code $A0 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8017      ; $0FC6: 8D 17 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8017.
        LDA #$A0       ; $0FC9: A9 A0    (2 cyc) Load screen code $A0 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8018      ; $0FCB: 8D 18 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8018.
        LDA #$E7       ; $0FCE: A9 E7    (2 cyc) Load screen code $E7 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8019      ; $0FD0: 8D 19 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8019.
        LDA #$00       ; $0FD3: A9 00    (2 cyc) Load screen code $00 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $031A      ; $0FD5: 8D 1A 03 (4 cyc) Dummy store to $031A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $0FD8: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $0FD9: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_03_r0_s3:
        ; prepares logical scanline 3 (text row 0, glyph row 3); target VRAM $8011-$8019.
        ; Values: A0 A0 F5 A0 A0 A0 A0 A0 A0   [dummy slot 20]
        LDX #$A0       ; $0FDA: A2 A0    (2 cyc) Load screen code $A0 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$A0       ; $0FDC: A0 A0    (2 cyc) Load screen code $A0 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$F5       ; $0FDE: A9 F5    (2 cyc) Load screen code $F5 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8011      ; $0FE0: 8E 11 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8011.
        STY $8012      ; $0FE3: 8C 12 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8012.
        STA $8013      ; $0FE6: 8D 13 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8013.
        LDA #$A0       ; $0FE9: A9 A0    (2 cyc) Load screen code $A0 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8014      ; $0FEB: 8D 14 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8014.
        LDA #$A0       ; $0FEE: A9 A0    (2 cyc) Load screen code $A0 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8015      ; $0FF0: 8D 15 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8015.
        LDA #$A0       ; $0FF3: A9 A0    (2 cyc) Load screen code $A0 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8016      ; $0FF5: 8D 16 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8016.
        LDA #$A0       ; $0FF8: A9 A0    (2 cyc) Load screen code $A0 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8017      ; $0FFA: 8D 17 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8017.
        LDA #$A0       ; $0FFD: A9 A0    (2 cyc) Load screen code $A0 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8018      ; $0FFF: 8D 18 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8018.
        LDA #$A0       ; $1002: A9 A0    (2 cyc) Load screen code $A0 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8019      ; $1004: 8D 19 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8019.
        LDA #$20       ; $1007: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $031A      ; $1009: 8D 1A 03 (4 cyc) Dummy store to $031A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $100C: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $100D: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_04_r0_s4:
        ; prepares logical scanline 4 (text row 0, glyph row 4); target VRAM $8011-$8019.
        ; Values: A0 A0 76 A0 A0 A0 A0 A0 A0   [dummy slot 20]
        LDX #$A0       ; $100E: A2 A0    (2 cyc) Load screen code $A0 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$A0       ; $1010: A0 A0    (2 cyc) Load screen code $A0 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$76       ; $1012: A9 76    (2 cyc) Load screen code $76 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8011      ; $1014: 8E 11 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8011.
        STY $8012      ; $1017: 8C 12 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8012.
        STA $8013      ; $101A: 8D 13 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8013.
        LDA #$A0       ; $101D: A9 A0    (2 cyc) Load screen code $A0 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8014      ; $101F: 8D 14 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8014.
        LDA #$A0       ; $1022: A9 A0    (2 cyc) Load screen code $A0 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8015      ; $1024: 8D 15 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8015.
        LDA #$A0       ; $1027: A9 A0    (2 cyc) Load screen code $A0 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8016      ; $1029: 8D 16 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8016.
        LDA #$A0       ; $102C: A9 A0    (2 cyc) Load screen code $A0 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8017      ; $102E: 8D 17 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8017.
        LDA #$A0       ; $1031: A9 A0    (2 cyc) Load screen code $A0 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8018      ; $1033: 8D 18 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8018.
        LDA #$A0       ; $1036: A9 A0    (2 cyc) Load screen code $A0 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8019      ; $1038: 8D 19 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8019.
        LDA #$20       ; $103B: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $031A      ; $103D: 8D 1A 03 (4 cyc) Dummy store to $031A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1040: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1041: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_05_r0_s5:
        ; prepares logical scanline 5 (text row 0, glyph row 5); target VRAM $8011-$8019.
        ; Values: EA 20 67 20 20 20 20 20 F4   [dummy slot 20]
        LDX #$EA       ; $1042: A2 EA    (2 cyc) Load screen code $EA for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $1044: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$67       ; $1046: A9 67    (2 cyc) Load screen code $67 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8011      ; $1048: 8E 11 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8011.
        STY $8012      ; $104B: 8C 12 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8012.
        STA $8013      ; $104E: 8D 13 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8013.
        LDA #$20       ; $1051: A9 20    (2 cyc) Load screen code $20 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8014      ; $1053: 8D 14 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8014.
        LDA #$20       ; $1056: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8015      ; $1058: 8D 15 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8015.
        LDA #$20       ; $105B: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8016      ; $105D: 8D 16 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8016.
        LDA #$20       ; $1060: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8017      ; $1062: 8D 17 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8017.
        LDA #$20       ; $1065: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8018      ; $1067: 8D 18 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8018.
        LDA #$F4       ; $106A: A9 F4    (2 cyc) Load screen code $F4 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8019      ; $106C: 8D 19 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8019.
        LDA #$20       ; $106F: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $031A      ; $1071: 8D 1A 03 (4 cyc) Dummy store to $031A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1074: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1075: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_06_r0_s6:
        ; prepares logical scanline 6 (text row 0, glyph row 6); target VRAM $8011-$8019.
        ; Values: F6 20 20 20 20 20 20 20 F5   [dummy slot 20]
        LDX #$F6       ; $1076: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $1078: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$20       ; $107A: A9 20    (2 cyc) Load screen code $20 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8011      ; $107C: 8E 11 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8011.
        STY $8012      ; $107F: 8C 12 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8012.
        STA $8013      ; $1082: 8D 13 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8013.
        LDA #$20       ; $1085: A9 20    (2 cyc) Load screen code $20 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8014      ; $1087: 8D 14 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8014.
        LDA #$20       ; $108A: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8015      ; $108C: 8D 15 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8015.
        LDA #$20       ; $108F: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8016      ; $1091: 8D 16 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8016.
        LDA #$20       ; $1094: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8017      ; $1096: 8D 17 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8017.
        LDA #$20       ; $1099: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8018      ; $109B: 8D 18 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8018.
        LDA #$F5       ; $109E: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8019      ; $10A0: 8D 19 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8019.
        LDA #$20       ; $10A3: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $031A      ; $10A5: 8D 1A 03 (4 cyc) Dummy store to $031A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $10A8: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $10A9: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_07_r0_s7:
        ; prepares logical scanline 7 (text row 0, glyph row 7); target VRAM $8011-$8019.
        ; Values: F6 20 20 20 20 20 20 20 F5   [dummy slot 20]
        LDX #$F6       ; $10AA: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $10AC: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$20       ; $10AE: A9 20    (2 cyc) Load screen code $20 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8011      ; $10B0: 8E 11 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8011.
        STY $8012      ; $10B3: 8C 12 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8012.
        STA $8013      ; $10B6: 8D 13 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8013.
        LDA #$20       ; $10B9: A9 20    (2 cyc) Load screen code $20 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8014      ; $10BB: 8D 14 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8014.
        LDA #$20       ; $10BE: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8015      ; $10C0: 8D 15 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8015.
        LDA #$20       ; $10C3: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8016      ; $10C5: 8D 16 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8016.
        LDA #$20       ; $10C8: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8017      ; $10CA: 8D 17 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8017.
        LDA #$20       ; $10CD: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8018      ; $10CF: 8D 18 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8018.
        LDA #$F5       ; $10D2: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8019      ; $10D4: 8D 19 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8019.
        LDA #$20       ; $10D7: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $031A      ; $10D9: 8D 1A 03 (4 cyc) Dummy store to $031A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $10DC: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $10DD: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_08_r1_s0:
        ; prepares logical scanline 8 (text row 1, glyph row 0); target VRAM $8039-$8041.
        ; Values: F6 51 56 66 5A 66 4A 2A F5   [dummy slot 20]
        LDX #$F6       ; $10DE: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$51       ; $10E0: A0 51    (2 cyc) Load screen code $51 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$56       ; $10E2: A9 56    (2 cyc) Load screen code $56 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8039      ; $10E4: 8E 39 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8039.
        STY $803A      ; $10E7: 8C 3A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $803A.
        STA $803B      ; $10EA: 8D 3B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $803B.
        LDA #$66       ; $10ED: A9 66    (2 cyc) Load screen code $66 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $803C      ; $10EF: 8D 3C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $803C.
        LDA #$5A       ; $10F2: A9 5A    (2 cyc) Load screen code $5A for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $803D      ; $10F4: 8D 3D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $803D.
        LDA #$66       ; $10F7: A9 66    (2 cyc) Load screen code $66 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $803E      ; $10F9: 8D 3E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $803E.
        LDA #$4A       ; $10FC: A9 4A    (2 cyc) Load screen code $4A for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $803F      ; $10FE: 8D 3F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $803F.
        LDA #$2A       ; $1101: A9 2A    (2 cyc) Load screen code $2A for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8040      ; $1103: 8D 40 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8040.
        LDA #$F5       ; $1106: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8041      ; $1108: 8D 41 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8041.
        LDA #$20       ; $110B: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0342      ; $110D: 8D 42 03 (4 cyc) Dummy store to $0342; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1110: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1111: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_09_r1_s1:
        ; prepares logical scanline 9 (text row 1, glyph row 1); target VRAM $8039-$8041.
        ; Values: F6 51 56 66 5A E6 4A 2A F5   [dummy slot 20]
        LDX #$F6       ; $1112: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$51       ; $1114: A0 51    (2 cyc) Load screen code $51 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$56       ; $1116: A9 56    (2 cyc) Load screen code $56 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8039      ; $1118: 8E 39 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8039.
        STY $803A      ; $111B: 8C 3A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $803A.
        STA $803B      ; $111E: 8D 3B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $803B.
        LDA #$66       ; $1121: A9 66    (2 cyc) Load screen code $66 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $803C      ; $1123: 8D 3C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $803C.
        LDA #$5A       ; $1126: A9 5A    (2 cyc) Load screen code $5A for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $803D      ; $1128: 8D 3D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $803D.
        LDA #$E6       ; $112B: A9 E6    (2 cyc) Load screen code $E6 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $803E      ; $112D: 8D 3E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $803E.
        LDA #$4A       ; $1130: A9 4A    (2 cyc) Load screen code $4A for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $803F      ; $1132: 8D 3F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $803F.
        LDA #$2A       ; $1135: A9 2A    (2 cyc) Load screen code $2A for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8040      ; $1137: 8D 40 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8040.
        LDA #$F5       ; $113A: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8041      ; $113C: 8D 41 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8041.
        LDA #$20       ; $113F: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0342      ; $1141: 8D 42 03 (4 cyc) Dummy store to $0342; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1144: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1145: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_10_r1_s2:
        ; prepares logical scanline 10 (text row 1, glyph row 2); target VRAM $8039-$8041.
        ; Values: F6 51 56 66 5A 66 4A 2A F5   [dummy slot 20]
        LDX #$F6       ; $1146: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$51       ; $1148: A0 51    (2 cyc) Load screen code $51 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$56       ; $114A: A9 56    (2 cyc) Load screen code $56 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8039      ; $114C: 8E 39 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8039.
        STY $803A      ; $114F: 8C 3A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $803A.
        STA $803B      ; $1152: 8D 3B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $803B.
        LDA #$66       ; $1155: A9 66    (2 cyc) Load screen code $66 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $803C      ; $1157: 8D 3C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $803C.
        LDA #$5A       ; $115A: A9 5A    (2 cyc) Load screen code $5A for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $803D      ; $115C: 8D 3D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $803D.
        LDA #$66       ; $115F: A9 66    (2 cyc) Load screen code $66 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $803E      ; $1161: 8D 3E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $803E.
        LDA #$4A       ; $1164: A9 4A    (2 cyc) Load screen code $4A for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $803F      ; $1166: 8D 3F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $803F.
        LDA #$2A       ; $1169: A9 2A    (2 cyc) Load screen code $2A for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8040      ; $116B: 8D 40 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8040.
        LDA #$F5       ; $116E: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8041      ; $1170: 8D 41 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8041.
        LDA #$20       ; $1173: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0342      ; $1175: 8D 42 03 (4 cyc) Dummy store to $0342; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1178: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1179: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_11_r1_s3:
        ; prepares logical scanline 11 (text row 1, glyph row 3); target VRAM $8039-$8041.
        ; Values: F6 51 56 66 5A E6 4A 2A F5   [dummy slot 20]
        LDX #$F6       ; $117A: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$51       ; $117C: A0 51    (2 cyc) Load screen code $51 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$56       ; $117E: A9 56    (2 cyc) Load screen code $56 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8039      ; $1180: 8E 39 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8039.
        STY $803A      ; $1183: 8C 3A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $803A.
        STA $803B      ; $1186: 8D 3B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $803B.
        LDA #$66       ; $1189: A9 66    (2 cyc) Load screen code $66 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $803C      ; $118B: 8D 3C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $803C.
        LDA #$5A       ; $118E: A9 5A    (2 cyc) Load screen code $5A for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $803D      ; $1190: 8D 3D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $803D.
        LDA #$E6       ; $1193: A9 E6    (2 cyc) Load screen code $E6 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $803E      ; $1195: 8D 3E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $803E.
        LDA #$4A       ; $1198: A9 4A    (2 cyc) Load screen code $4A for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $803F      ; $119A: 8D 3F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $803F.
        LDA #$2A       ; $119D: A9 2A    (2 cyc) Load screen code $2A for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8040      ; $119F: 8D 40 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8040.
        LDA #$F5       ; $11A2: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8041      ; $11A4: 8D 41 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8041.
        LDA #$20       ; $11A7: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0342      ; $11A9: 8D 42 03 (4 cyc) Dummy store to $0342; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $11AC: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $11AD: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_12_r1_s4:
        ; prepares logical scanline 12 (text row 1, glyph row 4); target VRAM $8039-$8041.
        ; Values: F6 57 5A 6C E9 66 55 5D F5   [dummy slot 20]
        LDX #$F6       ; $11AE: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$57       ; $11B0: A0 57    (2 cyc) Load screen code $57 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$5A       ; $11B2: A9 5A    (2 cyc) Load screen code $5A for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8039      ; $11B4: 8E 39 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8039.
        STY $803A      ; $11B7: 8C 3A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $803A.
        STA $803B      ; $11BA: 8D 3B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $803B.
        LDA #$6C       ; $11BD: A9 6C    (2 cyc) Load screen code $6C for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $803C      ; $11BF: 8D 3C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $803C.
        LDA #$E9       ; $11C2: A9 E9    (2 cyc) Load screen code $E9 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $803D      ; $11C4: 8D 3D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $803D.
        LDA #$66       ; $11C7: A9 66    (2 cyc) Load screen code $66 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $803E      ; $11C9: 8D 3E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $803E.
        LDA #$55       ; $11CC: A9 55    (2 cyc) Load screen code $55 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $803F      ; $11CE: 8D 3F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $803F.
        LDA #$5D       ; $11D1: A9 5D    (2 cyc) Load screen code $5D for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8040      ; $11D3: 8D 40 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8040.
        LDA #$F5       ; $11D6: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8041      ; $11D8: 8D 41 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8041.
        LDA #$20       ; $11DB: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0342      ; $11DD: 8D 42 03 (4 cyc) Dummy store to $0342; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $11E0: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $11E1: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_13_r1_s5:
        ; prepares logical scanline 13 (text row 1, glyph row 5); target VRAM $8039-$8041.
        ; Values: F6 57 5A 6C E9 E6 55 5D F5   [dummy slot 20]
        LDX #$F6       ; $11E2: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$57       ; $11E4: A0 57    (2 cyc) Load screen code $57 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$5A       ; $11E6: A9 5A    (2 cyc) Load screen code $5A for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8039      ; $11E8: 8E 39 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8039.
        STY $803A      ; $11EB: 8C 3A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $803A.
        STA $803B      ; $11EE: 8D 3B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $803B.
        LDA #$6C       ; $11F1: A9 6C    (2 cyc) Load screen code $6C for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $803C      ; $11F3: 8D 3C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $803C.
        LDA #$E9       ; $11F6: A9 E9    (2 cyc) Load screen code $E9 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $803D      ; $11F8: 8D 3D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $803D.
        LDA #$E6       ; $11FB: A9 E6    (2 cyc) Load screen code $E6 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $803E      ; $11FD: 8D 3E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $803E.
        LDA #$55       ; $1200: A9 55    (2 cyc) Load screen code $55 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $803F      ; $1202: 8D 3F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $803F.
        LDA #$5D       ; $1205: A9 5D    (2 cyc) Load screen code $5D for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8040      ; $1207: 8D 40 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8040.
        LDA #$F5       ; $120A: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8041      ; $120C: 8D 41 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8041.
        LDA #$20       ; $120F: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0342      ; $1211: 8D 42 03 (4 cyc) Dummy store to $0342; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1214: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1215: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_14_r1_s6:
        ; prepares logical scanline 14 (text row 1, glyph row 6); target VRAM $8039-$8041.
        ; Values: F6 57 5A 6C E9 66 55 5D F5   [dummy slot 20]
        LDX #$F6       ; $1216: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$57       ; $1218: A0 57    (2 cyc) Load screen code $57 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$5A       ; $121A: A9 5A    (2 cyc) Load screen code $5A for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8039      ; $121C: 8E 39 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8039.
        STY $803A      ; $121F: 8C 3A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $803A.
        STA $803B      ; $1222: 8D 3B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $803B.
        LDA #$6C       ; $1225: A9 6C    (2 cyc) Load screen code $6C for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $803C      ; $1227: 8D 3C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $803C.
        LDA #$E9       ; $122A: A9 E9    (2 cyc) Load screen code $E9 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $803D      ; $122C: 8D 3D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $803D.
        LDA #$66       ; $122F: A9 66    (2 cyc) Load screen code $66 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $803E      ; $1231: 8D 3E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $803E.
        LDA #$55       ; $1234: A9 55    (2 cyc) Load screen code $55 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $803F      ; $1236: 8D 3F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $803F.
        LDA #$5D       ; $1239: A9 5D    (2 cyc) Load screen code $5D for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8040      ; $123B: 8D 40 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8040.
        LDA #$F5       ; $123E: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8041      ; $1240: 8D 41 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8041.
        LDA #$20       ; $1243: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0342      ; $1245: 8D 42 03 (4 cyc) Dummy store to $0342; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1248: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1249: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_15_r1_s7:
        ; prepares logical scanline 15 (text row 1, glyph row 7); target VRAM $8039-$8041.
        ; Values: F6 57 5A 6C E9 E6 55 5D F5   [dummy slot 20]
        LDX #$F6       ; $124A: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$57       ; $124C: A0 57    (2 cyc) Load screen code $57 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$5A       ; $124E: A9 5A    (2 cyc) Load screen code $5A for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8039      ; $1250: 8E 39 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8039.
        STY $803A      ; $1253: 8C 3A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $803A.
        STA $803B      ; $1256: 8D 3B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $803B.
        LDA #$6C       ; $1259: A9 6C    (2 cyc) Load screen code $6C for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $803C      ; $125B: 8D 3C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $803C.
        LDA #$E9       ; $125E: A9 E9    (2 cyc) Load screen code $E9 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $803D      ; $1260: 8D 3D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $803D.
        LDA #$E6       ; $1263: A9 E6    (2 cyc) Load screen code $E6 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $803E      ; $1265: 8D 3E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $803E.
        LDA #$55       ; $1268: A9 55    (2 cyc) Load screen code $55 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $803F      ; $126A: 8D 3F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $803F.
        LDA #$5D       ; $126D: A9 5D    (2 cyc) Load screen code $5D for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8040      ; $126F: 8D 40 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8040.
        LDA #$F5       ; $1272: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8041      ; $1274: 8D 41 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8041.
        LDA #$20       ; $1277: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0342      ; $1279: 8D 42 03 (4 cyc) Dummy store to $0342; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $127C: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $127D: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_16_r2_s0:
        ; prepares logical scanline 16 (text row 2, glyph row 0); target VRAM $8061-$8069.
        ; Values: F6 A0 58 A0 4E 20 20 20 F5   [dummy slot 20]
        LDX #$F6       ; $127E: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$A0       ; $1280: A0 A0    (2 cyc) Load screen code $A0 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$58       ; $1282: A9 58    (2 cyc) Load screen code $58 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8061      ; $1284: 8E 61 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8061.
        STY $8062      ; $1287: 8C 62 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8062.
        STA $8063      ; $128A: 8D 63 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8063.
        LDA #$A0       ; $128D: A9 A0    (2 cyc) Load screen code $A0 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8064      ; $128F: 8D 64 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8064.
        LDA #$4E       ; $1292: A9 4E    (2 cyc) Load screen code $4E for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8065      ; $1294: 8D 65 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8065.
        LDA #$20       ; $1297: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8066      ; $1299: 8D 66 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8066.
        LDA #$20       ; $129C: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8067      ; $129E: 8D 67 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8067.
        LDA #$20       ; $12A1: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8068      ; $12A3: 8D 68 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8068.
        LDA #$F5       ; $12A6: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8069      ; $12A8: 8D 69 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8069.
        LDA #$20       ; $12AB: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $036A      ; $12AD: 8D 6A 03 (4 cyc) Dummy store to $036A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $12B0: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $12B1: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_17_r2_s1:
        ; prepares logical scanline 17 (text row 2, glyph row 1); target VRAM $8061-$8069.
        ; Values: F6 20 58 A0 4E 20 20 20 F5   [dummy slot 20]
        LDX #$F6       ; $12B2: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $12B4: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$58       ; $12B6: A9 58    (2 cyc) Load screen code $58 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8061      ; $12B8: 8E 61 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8061.
        STY $8062      ; $12BB: 8C 62 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8062.
        STA $8063      ; $12BE: 8D 63 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8063.
        LDA #$A0       ; $12C1: A9 A0    (2 cyc) Load screen code $A0 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8064      ; $12C3: 8D 64 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8064.
        LDA #$4E       ; $12C6: A9 4E    (2 cyc) Load screen code $4E for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8065      ; $12C8: 8D 65 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8065.
        LDA #$20       ; $12CB: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8066      ; $12CD: 8D 66 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8066.
        LDA #$20       ; $12D0: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8067      ; $12D2: 8D 67 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8067.
        LDA #$20       ; $12D5: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8068      ; $12D7: 8D 68 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8068.
        LDA #$F5       ; $12DA: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8069      ; $12DC: 8D 69 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8069.
        LDA #$20       ; $12DF: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $036A      ; $12E1: 8D 6A 03 (4 cyc) Dummy store to $036A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $12E4: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $12E5: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_18_r2_s2:
        ; prepares logical scanline 18 (text row 2, glyph row 2); target VRAM $8061-$8069.
        ; Values: F6 A0 58 A0 4E 20 20 F5 F5   [dummy slot 20]
        LDX #$F6       ; $12E6: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$A0       ; $12E8: A0 A0    (2 cyc) Load screen code $A0 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$58       ; $12EA: A9 58    (2 cyc) Load screen code $58 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8061      ; $12EC: 8E 61 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8061.
        STY $8062      ; $12EF: 8C 62 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8062.
        STA $8063      ; $12F2: 8D 63 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8063.
        LDA #$A0       ; $12F5: A9 A0    (2 cyc) Load screen code $A0 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8064      ; $12F7: 8D 64 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8064.
        LDA #$4E       ; $12FA: A9 4E    (2 cyc) Load screen code $4E for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8065      ; $12FC: 8D 65 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8065.
        LDA #$20       ; $12FF: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8066      ; $1301: 8D 66 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8066.
        LDA #$20       ; $1304: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8067      ; $1306: 8D 67 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8067.
        LDA #$F5       ; $1309: A9 F5    (2 cyc) Load screen code $F5 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8068      ; $130B: 8D 68 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8068.
        LDA #$F5       ; $130E: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8069      ; $1310: 8D 69 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8069.
        LDA #$20       ; $1313: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $036A      ; $1315: 8D 6A 03 (4 cyc) Dummy store to $036A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1318: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1319: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_19_r2_s3:
        ; prepares logical scanline 19 (text row 2, glyph row 3); target VRAM $8061-$8069.
        ; Values: F6 20 58 A0 4E 5D 74 42 F5   [dummy slot 20]
        LDX #$F6       ; $131A: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $131C: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$58       ; $131E: A9 58    (2 cyc) Load screen code $58 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8061      ; $1320: 8E 61 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8061.
        STY $8062      ; $1323: 8C 62 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8062.
        STA $8063      ; $1326: 8D 63 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8063.
        LDA #$A0       ; $1329: A9 A0    (2 cyc) Load screen code $A0 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8064      ; $132B: 8D 64 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8064.
        LDA #$4E       ; $132E: A9 4E    (2 cyc) Load screen code $4E for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8065      ; $1330: 8D 65 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8065.
        LDA #$5D       ; $1333: A9 5D    (2 cyc) Load screen code $5D for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8066      ; $1335: 8D 66 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8066.
        LDA #$74       ; $1338: A9 74    (2 cyc) Load screen code $74 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8067      ; $133A: 8D 67 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8067.
        LDA #$42       ; $133D: A9 42    (2 cyc) Load screen code $42 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8068      ; $133F: 8D 68 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8068.
        LDA #$F5       ; $1342: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8069      ; $1344: 8D 69 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8069.
        LDA #$20       ; $1347: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $036A      ; $1349: 8D 6A 03 (4 cyc) Dummy store to $036A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $134C: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $134D: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_20_r2_s4:
        ; prepares logical scanline 20 (text row 2, glyph row 4); target VRAM $8061-$8069.
        ; Values: F6 A0 A0 DC 56 20 74 42 F5   [dummy slot 20]
        LDX #$F6       ; $134E: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$A0       ; $1350: A0 A0    (2 cyc) Load screen code $A0 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$A0       ; $1352: A9 A0    (2 cyc) Load screen code $A0 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8061      ; $1354: 8E 61 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8061.
        STY $8062      ; $1357: 8C 62 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8062.
        STA $8063      ; $135A: 8D 63 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8063.
        LDA #$DC       ; $135D: A9 DC    (2 cyc) Load screen code $DC for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8064      ; $135F: 8D 64 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8064.
        LDA #$56       ; $1362: A9 56    (2 cyc) Load screen code $56 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8065      ; $1364: 8D 65 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8065.
        LDA #$20       ; $1367: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8066      ; $1369: 8D 66 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8066.
        LDA #$74       ; $136C: A9 74    (2 cyc) Load screen code $74 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8067      ; $136E: 8D 67 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8067.
        LDA #$42       ; $1371: A9 42    (2 cyc) Load screen code $42 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8068      ; $1373: 8D 68 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8068.
        LDA #$F5       ; $1376: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8069      ; $1378: 8D 69 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8069.
        LDA #$20       ; $137B: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $036A      ; $137D: 8D 6A 03 (4 cyc) Dummy store to $036A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1380: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1381: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_21_r2_s5:
        ; prepares logical scanline 21 (text row 2, glyph row 5); target VRAM $8061-$8069.
        ; Values: F6 20 A0 DC 56 20 20 F5 F5   [dummy slot 20]
        LDX #$F6       ; $1382: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $1384: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$A0       ; $1386: A9 A0    (2 cyc) Load screen code $A0 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8061      ; $1388: 8E 61 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8061.
        STY $8062      ; $138B: 8C 62 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8062.
        STA $8063      ; $138E: 8D 63 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8063.
        LDA #$DC       ; $1391: A9 DC    (2 cyc) Load screen code $DC for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8064      ; $1393: 8D 64 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8064.
        LDA #$56       ; $1396: A9 56    (2 cyc) Load screen code $56 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8065      ; $1398: 8D 65 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8065.
        LDA #$20       ; $139B: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8066      ; $139D: 8D 66 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8066.
        LDA #$20       ; $13A0: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8067      ; $13A2: 8D 67 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8067.
        LDA #$F5       ; $13A5: A9 F5    (2 cyc) Load screen code $F5 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8068      ; $13A7: 8D 68 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8068.
        LDA #$F5       ; $13AA: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8069      ; $13AC: 8D 69 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8069.
        LDA #$20       ; $13AF: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $036A      ; $13B1: 8D 6A 03 (4 cyc) Dummy store to $036A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $13B4: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $13B5: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_22_r2_s6:
        ; prepares logical scanline 22 (text row 2, glyph row 6); target VRAM $8061-$8069.
        ; Values: F6 A0 A0 DC 56 20 20 20 F5   [dummy slot 20]
        LDX #$F6       ; $13B6: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$A0       ; $13B8: A0 A0    (2 cyc) Load screen code $A0 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$A0       ; $13BA: A9 A0    (2 cyc) Load screen code $A0 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8061      ; $13BC: 8E 61 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8061.
        STY $8062      ; $13BF: 8C 62 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8062.
        STA $8063      ; $13C2: 8D 63 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8063.
        LDA #$DC       ; $13C5: A9 DC    (2 cyc) Load screen code $DC for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8064      ; $13C7: 8D 64 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8064.
        LDA #$56       ; $13CA: A9 56    (2 cyc) Load screen code $56 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8065      ; $13CC: 8D 65 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8065.
        LDA #$20       ; $13CF: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8066      ; $13D1: 8D 66 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8066.
        LDA #$20       ; $13D4: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8067      ; $13D6: 8D 67 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8067.
        LDA #$20       ; $13D9: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8068      ; $13DB: 8D 68 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8068.
        LDA #$F5       ; $13DE: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8069      ; $13E0: 8D 69 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8069.
        LDA #$20       ; $13E3: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $036A      ; $13E5: 8D 6A 03 (4 cyc) Dummy store to $036A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $13E8: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $13E9: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_23_r2_s7:
        ; prepares logical scanline 23 (text row 2, glyph row 7); target VRAM $8061-$8069.
        ; Values: F6 57 A0 DC 56 20 20 20 F5   [dummy slot 20]
        LDX #$F6       ; $13EA: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$57       ; $13EC: A0 57    (2 cyc) Load screen code $57 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$A0       ; $13EE: A9 A0    (2 cyc) Load screen code $A0 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8061      ; $13F0: 8E 61 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8061.
        STY $8062      ; $13F3: 8C 62 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $8062.
        STA $8063      ; $13F6: 8D 63 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $8063.
        LDA #$DC       ; $13F9: A9 DC    (2 cyc) Load screen code $DC for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $8064      ; $13FB: 8D 64 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $8064.
        LDA #$56       ; $13FE: A9 56    (2 cyc) Load screen code $56 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $8065      ; $1400: 8D 65 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $8065.
        LDA #$20       ; $1403: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $8066      ; $1405: 8D 66 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $8066.
        LDA #$20       ; $1408: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $8067      ; $140A: 8D 67 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $8067.
        LDA #$20       ; $140D: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8068      ; $140F: 8D 68 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8068.
        LDA #$F5       ; $1412: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8069      ; $1414: 8D 69 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8069.
        LDA #$20       ; $1417: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $036A      ; $1419: 8D 6A 03 (4 cyc) Dummy store to $036A; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $141C: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $141D: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_24_r3_s0:
        ; prepares logical scanline 24 (text row 3, glyph row 0); target VRAM $8089-$8091.
        ; Values: F6 57 20 20 20 20 20 20 F5   [dummy slot 20]
        LDX #$F6       ; $141E: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$57       ; $1420: A0 57    (2 cyc) Load screen code $57 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$20       ; $1422: A9 20    (2 cyc) Load screen code $20 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8089      ; $1424: 8E 89 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8089.
        STY $808A      ; $1427: 8C 8A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $808A.
        STA $808B      ; $142A: 8D 8B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $808B.
        LDA #$20       ; $142D: A9 20    (2 cyc) Load screen code $20 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $808C      ; $142F: 8D 8C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $808C.
        LDA #$20       ; $1432: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $808D      ; $1434: 8D 8D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $808D.
        LDA #$20       ; $1437: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $808E      ; $1439: 8D 8E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $808E.
        LDA #$20       ; $143C: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $808F      ; $143E: 8D 8F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $808F.
        LDA #$20       ; $1441: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8090      ; $1443: 8D 90 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8090.
        LDA #$F5       ; $1446: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8091      ; $1448: 8D 91 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8091.
        LDA #$20       ; $144B: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0392      ; $144D: 8D 92 03 (4 cyc) Dummy store to $0392; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1450: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1451: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_25_r3_s1:
        ; prepares logical scanline 25 (text row 3, glyph row 1); target VRAM $8089-$8091.
        ; Values: F6 57 20 61 5C 56 5F 20 F5   [dummy slot 20]
        LDX #$F6       ; $1452: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$57       ; $1454: A0 57    (2 cyc) Load screen code $57 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$20       ; $1456: A9 20    (2 cyc) Load screen code $20 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8089      ; $1458: 8E 89 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8089.
        STY $808A      ; $145B: 8C 8A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $808A.
        STA $808B      ; $145E: 8D 8B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $808B.
        LDA #$61       ; $1461: A9 61    (2 cyc) Load screen code $61 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $808C      ; $1463: 8D 8C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $808C.
        LDA #$5C       ; $1466: A9 5C    (2 cyc) Load screen code $5C for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $808D      ; $1468: 8D 8D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $808D.
        LDA #$56       ; $146B: A9 56    (2 cyc) Load screen code $56 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $808E      ; $146D: 8D 8E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $808E.
        LDA #$5F       ; $1470: A9 5F    (2 cyc) Load screen code $5F for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $808F      ; $1472: 8D 8F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $808F.
        LDA #$20       ; $1475: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8090      ; $1477: 8D 90 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8090.
        LDA #$F5       ; $147A: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8091      ; $147C: 8D 91 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8091.
        LDA #$20       ; $147F: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0392      ; $1481: 8D 92 03 (4 cyc) Dummy store to $0392; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1484: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1485: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_26_r3_s2:
        ; prepares logical scanline 26 (text row 3, glyph row 2); target VRAM $8089-$8091.
        ; Values: F6 57 20 E1 5C 56 5F 20 F5   [dummy slot 20]
        LDX #$F6       ; $1486: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$57       ; $1488: A0 57    (2 cyc) Load screen code $57 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$20       ; $148A: A9 20    (2 cyc) Load screen code $20 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8089      ; $148C: 8E 89 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8089.
        STY $808A      ; $148F: 8C 8A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $808A.
        STA $808B      ; $1492: 8D 8B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $808B.
        LDA #$E1       ; $1495: A9 E1    (2 cyc) Load screen code $E1 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $808C      ; $1497: 8D 8C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $808C.
        LDA #$5C       ; $149A: A9 5C    (2 cyc) Load screen code $5C for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $808D      ; $149C: 8D 8D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $808D.
        LDA #$56       ; $149F: A9 56    (2 cyc) Load screen code $56 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $808E      ; $14A1: 8D 8E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $808E.
        LDA #$5F       ; $14A4: A9 5F    (2 cyc) Load screen code $5F for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $808F      ; $14A6: 8D 8F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $808F.
        LDA #$20       ; $14A9: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8090      ; $14AB: 8D 90 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8090.
        LDA #$F5       ; $14AE: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8091      ; $14B0: 8D 91 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8091.
        LDA #$20       ; $14B3: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0392      ; $14B5: 8D 92 03 (4 cyc) Dummy store to $0392; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $14B8: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $14B9: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_27_r3_s3:
        ; prepares logical scanline 27 (text row 3, glyph row 3); target VRAM $8089-$8091.
        ; Values: F6 57 5D 61 5C 56 5F 20 F5   [dummy slot 20]
        LDX #$F6       ; $14BA: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$57       ; $14BC: A0 57    (2 cyc) Load screen code $57 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$5D       ; $14BE: A9 5D    (2 cyc) Load screen code $5D for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8089      ; $14C0: 8E 89 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8089.
        STY $808A      ; $14C3: 8C 8A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $808A.
        STA $808B      ; $14C6: 8D 8B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $808B.
        LDA #$61       ; $14C9: A9 61    (2 cyc) Load screen code $61 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $808C      ; $14CB: 8D 8C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $808C.
        LDA #$5C       ; $14CE: A9 5C    (2 cyc) Load screen code $5C for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $808D      ; $14D0: 8D 8D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $808D.
        LDA #$56       ; $14D3: A9 56    (2 cyc) Load screen code $56 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $808E      ; $14D5: 8D 8E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $808E.
        LDA #$5F       ; $14D8: A9 5F    (2 cyc) Load screen code $5F for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $808F      ; $14DA: 8D 8F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $808F.
        LDA #$20       ; $14DD: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8090      ; $14DF: 8D 90 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8090.
        LDA #$F5       ; $14E2: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8091      ; $14E4: 8D 91 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8091.
        LDA #$20       ; $14E7: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0392      ; $14E9: 8D 92 03 (4 cyc) Dummy store to $0392; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $14EC: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $14ED: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_28_r3_s4:
        ; prepares logical scanline 28 (text row 3, glyph row 4); target VRAM $8089-$8091.
        ; Values: F6 57 48 E1 5C 56 5F 20 F5   [dummy slot 20]
        LDX #$F6       ; $14EE: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$57       ; $14F0: A0 57    (2 cyc) Load screen code $57 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$48       ; $14F2: A9 48    (2 cyc) Load screen code $48 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8089      ; $14F4: 8E 89 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8089.
        STY $808A      ; $14F7: 8C 8A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $808A.
        STA $808B      ; $14FA: 8D 8B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $808B.
        LDA #$E1       ; $14FD: A9 E1    (2 cyc) Load screen code $E1 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $808C      ; $14FF: 8D 8C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $808C.
        LDA #$5C       ; $1502: A9 5C    (2 cyc) Load screen code $5C for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $808D      ; $1504: 8D 8D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $808D.
        LDA #$56       ; $1507: A9 56    (2 cyc) Load screen code $56 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $808E      ; $1509: 8D 8E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $808E.
        LDA #$5F       ; $150C: A9 5F    (2 cyc) Load screen code $5F for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $808F      ; $150E: 8D 8F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $808F.
        LDA #$20       ; $1511: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8090      ; $1513: 8D 90 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8090.
        LDA #$F5       ; $1516: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8091      ; $1518: 8D 91 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8091.
        LDA #$20       ; $151B: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0392      ; $151D: 8D 92 03 (4 cyc) Dummy store to $0392; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1520: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1521: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_29_r3_s5:
        ; prepares logical scanline 29 (text row 3, glyph row 5); target VRAM $8089-$8091.
        ; Values: F6 51 E7 61 20 57 DF 20 F5   [dummy slot 20]
        LDX #$F6       ; $1522: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$51       ; $1524: A0 51    (2 cyc) Load screen code $51 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$E7       ; $1526: A9 E7    (2 cyc) Load screen code $E7 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8089      ; $1528: 8E 89 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8089.
        STY $808A      ; $152B: 8C 8A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $808A.
        STA $808B      ; $152E: 8D 8B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $808B.
        LDA #$61       ; $1531: A9 61    (2 cyc) Load screen code $61 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $808C      ; $1533: 8D 8C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $808C.
        LDA #$20       ; $1536: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $808D      ; $1538: 8D 8D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $808D.
        LDA #$57       ; $153B: A9 57    (2 cyc) Load screen code $57 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $808E      ; $153D: 8D 8E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $808E.
        LDA #$DF       ; $1540: A9 DF    (2 cyc) Load screen code $DF for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $808F      ; $1542: 8D 8F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $808F.
        LDA #$20       ; $1545: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8090      ; $1547: 8D 90 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8090.
        LDA #$F5       ; $154A: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8091      ; $154C: 8D 91 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8091.
        LDA #$20       ; $154F: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0392      ; $1551: 8D 92 03 (4 cyc) Dummy store to $0392; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1554: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1555: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_30_r3_s6:
        ; prepares logical scanline 30 (text row 3, glyph row 6); target VRAM $8089-$8091.
        ; Values: F6 51 48 E1 20 57 DF 20 F5   [dummy slot 20]
        LDX #$F6       ; $1556: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$51       ; $1558: A0 51    (2 cyc) Load screen code $51 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$48       ; $155A: A9 48    (2 cyc) Load screen code $48 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8089      ; $155C: 8E 89 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8089.
        STY $808A      ; $155F: 8C 8A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $808A.
        STA $808B      ; $1562: 8D 8B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $808B.
        LDA #$E1       ; $1565: A9 E1    (2 cyc) Load screen code $E1 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $808C      ; $1567: 8D 8C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $808C.
        LDA #$20       ; $156A: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $808D      ; $156C: 8D 8D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $808D.
        LDA #$57       ; $156F: A9 57    (2 cyc) Load screen code $57 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $808E      ; $1571: 8D 8E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $808E.
        LDA #$DF       ; $1574: A9 DF    (2 cyc) Load screen code $DF for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $808F      ; $1576: 8D 8F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $808F.
        LDA #$20       ; $1579: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8090      ; $157B: 8D 90 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8090.
        LDA #$F5       ; $157E: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8091      ; $1580: 8D 91 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8091.
        LDA #$20       ; $1583: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0392      ; $1585: 8D 92 03 (4 cyc) Dummy store to $0392; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1588: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1589: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_31_r3_s7:
        ; prepares logical scanline 31 (text row 3, glyph row 7); target VRAM $8089-$8091.
        ; Values: F6 51 5D 61 20 57 DF 6A F5   [dummy slot 20]
        LDX #$F6       ; $158A: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$51       ; $158C: A0 51    (2 cyc) Load screen code $51 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$5D       ; $158E: A9 5D    (2 cyc) Load screen code $5D for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $8089      ; $1590: 8E 89 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $8089.
        STY $808A      ; $1593: 8C 8A 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $808A.
        STA $808B      ; $1596: 8D 8B 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $808B.
        LDA #$61       ; $1599: A9 61    (2 cyc) Load screen code $61 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $808C      ; $159B: 8D 8C 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $808C.
        LDA #$20       ; $159E: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $808D      ; $15A0: 8D 8D 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $808D.
        LDA #$57       ; $15A3: A9 57    (2 cyc) Load screen code $57 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $808E      ; $15A5: 8D 8E 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $808E.
        LDA #$DF       ; $15A8: A9 DF    (2 cyc) Load screen code $DF for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $808F      ; $15AA: 8D 8F 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $808F.
        LDA #$6A       ; $15AD: A9 6A    (2 cyc) Load screen code $6A for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $8090      ; $15AF: 8D 90 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $8090.
        LDA #$F5       ; $15B2: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $8091      ; $15B4: 8D 91 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $8091.
        LDA #$20       ; $15B7: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $0392      ; $15B9: 8D 92 03 (4 cyc) Dummy store to $0392; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $15BC: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $15BD: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_32_r4_s0:
        ; prepares logical scanline 32 (text row 4, glyph row 0); target VRAM $80B1-$80B9.
        ; Values: F6 51 20 E1 20 57 DF 6A F5   [dummy slot 20]
        LDX #$F6       ; $15BE: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$51       ; $15C0: A0 51    (2 cyc) Load screen code $51 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$20       ; $15C2: A9 20    (2 cyc) Load screen code $20 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $80B1      ; $15C4: 8E B1 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $80B1.
        STY $80B2      ; $15C7: 8C B2 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $80B2.
        STA $80B3      ; $15CA: 8D B3 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $80B3.
        LDA #$E1       ; $15CD: A9 E1    (2 cyc) Load screen code $E1 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $80B4      ; $15CF: 8D B4 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $80B4.
        LDA #$20       ; $15D2: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $80B5      ; $15D4: 8D B5 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $80B5.
        LDA #$57       ; $15D7: A9 57    (2 cyc) Load screen code $57 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $80B6      ; $15D9: 8D B6 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $80B6.
        LDA #$DF       ; $15DC: A9 DF    (2 cyc) Load screen code $DF for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $80B7      ; $15DE: 8D B7 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $80B7.
        LDA #$6A       ; $15E1: A9 6A    (2 cyc) Load screen code $6A for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $80B8      ; $15E3: 8D B8 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $80B8.
        LDA #$F5       ; $15E6: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $80B9      ; $15E8: 8D B9 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $80B9.
        LDA #$20       ; $15EB: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $03BA      ; $15ED: 8D BA 03 (4 cyc) Dummy store to $03BA; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $15F0: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $15F1: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_33_r4_s1:
        ; prepares logical scanline 33 (text row 4, glyph row 1); target VRAM $80B1-$80B9.
        ; Values: F6 20 20 20 20 20 20 20 F5   [dummy slot 20]
        LDX #$F6       ; $15F2: A2 F6    (2 cyc) Load screen code $F6 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $15F4: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$20       ; $15F6: A9 20    (2 cyc) Load screen code $20 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $80B1      ; $15F8: 8E B1 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $80B1.
        STY $80B2      ; $15FB: 8C B2 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $80B2.
        STA $80B3      ; $15FE: 8D B3 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $80B3.
        LDA #$20       ; $1601: A9 20    (2 cyc) Load screen code $20 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $80B4      ; $1603: 8D B4 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $80B4.
        LDA #$20       ; $1606: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $80B5      ; $1608: 8D B5 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $80B5.
        LDA #$20       ; $160B: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $80B6      ; $160D: 8D B6 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $80B6.
        LDA #$20       ; $1610: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $80B7      ; $1612: 8D B7 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $80B7.
        LDA #$20       ; $1615: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $80B8      ; $1617: 8D B8 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $80B8.
        LDA #$F5       ; $161A: A9 F5    (2 cyc) Load screen code $F5 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $80B9      ; $161C: 8D B9 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $80B9.
        LDA #$20       ; $161F: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $03BA      ; $1621: 8D BA 03 (4 cyc) Dummy store to $03BA; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1624: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1625: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_34_r4_s2:
        ; prepares logical scanline 34 (text row 4, glyph row 2); target VRAM $80B1-$80B9.
        ; Values: EA 20 20 20 20 20 65 20 F4   [dummy slot 20]
        LDX #$EA       ; $1626: A2 EA    (2 cyc) Load screen code $EA for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $1628: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$20       ; $162A: A9 20    (2 cyc) Load screen code $20 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $80B1      ; $162C: 8E B1 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $80B1.
        STY $80B2      ; $162F: 8C B2 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $80B2.
        STA $80B3      ; $1632: 8D B3 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $80B3.
        LDA #$20       ; $1635: A9 20    (2 cyc) Load screen code $20 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $80B4      ; $1637: 8D B4 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $80B4.
        LDA #$20       ; $163A: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $80B5      ; $163C: 8D B5 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $80B5.
        LDA #$20       ; $163F: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $80B6      ; $1641: 8D B6 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $80B6.
        LDA #$65       ; $1644: A9 65    (2 cyc) Load screen code $65 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $80B7      ; $1646: 8D B7 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $80B7.
        LDA #$20       ; $1649: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $80B8      ; $164B: 8D B8 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $80B8.
        LDA #$F4       ; $164E: A9 F4    (2 cyc) Load screen code $F4 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $80B9      ; $1650: 8D B9 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $80B9.
        LDA #$20       ; $1653: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $03BA      ; $1655: 8D BA 03 (4 cyc) Dummy store to $03BA; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1658: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1659: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_35_r4_s3:
        ; prepares logical scanline 35 (text row 4, glyph row 3); target VRAM $80B1-$80B9.
        ; Values: A0 A0 A0 A0 A0 A0 75 A0 A0   [dummy slot A0]
        LDX #$A0       ; $165A: A2 A0    (2 cyc) Load screen code $A0 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$A0       ; $165C: A0 A0    (2 cyc) Load screen code $A0 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$A0       ; $165E: A9 A0    (2 cyc) Load screen code $A0 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $80B1      ; $1660: 8E B1 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $80B1.
        STY $80B2      ; $1663: 8C B2 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $80B2.
        STA $80B3      ; $1666: 8D B3 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $80B3.
        LDA #$A0       ; $1669: A9 A0    (2 cyc) Load screen code $A0 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $80B4      ; $166B: 8D B4 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $80B4.
        LDA #$A0       ; $166E: A9 A0    (2 cyc) Load screen code $A0 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $80B5      ; $1670: 8D B5 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $80B5.
        LDA #$A0       ; $1673: A9 A0    (2 cyc) Load screen code $A0 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $80B6      ; $1675: 8D B6 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $80B6.
        LDA #$75       ; $1678: A9 75    (2 cyc) Load screen code $75 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $80B7      ; $167A: 8D B7 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $80B7.
        LDA #$A0       ; $167D: A9 A0    (2 cyc) Load screen code $A0 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $80B8      ; $167F: 8D B8 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $80B8.
        LDA #$A0       ; $1682: A9 A0    (2 cyc) Load screen code $A0 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $80B9      ; $1684: 8D B9 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $80B9.
        LDA #$A0       ; $1687: A9 A0    (2 cyc) Load screen code $A0 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $03BA      ; $1689: 8D BA 03 (4 cyc) Dummy store to $03BA; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $168C: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $168D: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_36_r4_s4:
        ; prepares logical scanline 36 (text row 4, glyph row 4); target VRAM $80B1-$80B9.
        ; Values: A0 A0 A0 A0 A0 A0 F6 A0 A0   [dummy slot A0]
        LDX #$A0       ; $168E: A2 A0    (2 cyc) Load screen code $A0 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$A0       ; $1690: A0 A0    (2 cyc) Load screen code $A0 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$A0       ; $1692: A9 A0    (2 cyc) Load screen code $A0 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $80B1      ; $1694: 8E B1 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $80B1.
        STY $80B2      ; $1697: 8C B2 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $80B2.
        STA $80B3      ; $169A: 8D B3 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $80B3.
        LDA #$A0       ; $169D: A9 A0    (2 cyc) Load screen code $A0 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $80B4      ; $169F: 8D B4 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $80B4.
        LDA #$A0       ; $16A2: A9 A0    (2 cyc) Load screen code $A0 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $80B5      ; $16A4: 8D B5 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $80B5.
        LDA #$A0       ; $16A7: A9 A0    (2 cyc) Load screen code $A0 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $80B6      ; $16A9: 8D B6 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $80B6.
        LDA #$F6       ; $16AC: A9 F6    (2 cyc) Load screen code $F6 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $80B7      ; $16AE: 8D B7 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $80B7.
        LDA #$A0       ; $16B1: A9 A0    (2 cyc) Load screen code $A0 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $80B8      ; $16B3: 8D B8 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $80B8.
        LDA #$A0       ; $16B6: A9 A0    (2 cyc) Load screen code $A0 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $80B9      ; $16B8: 8D B9 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $80B9.
        LDA #$A0       ; $16BB: A9 A0    (2 cyc) Load screen code $A0 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $03BA      ; $16BD: 8D BA 03 (4 cyc) Dummy store to $03BA; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $16C0: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $16C1: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_37_r4_s5:
        ; prepares logical scanline 37 (text row 4, glyph row 5); target VRAM $80B1-$80B9.
        ; Values: E5 A0 A0 A0 A0 A0 75 A0 E7   [dummy slot 20]
        LDX #$E5       ; $16C2: A2 E5    (2 cyc) Load screen code $E5 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$A0       ; $16C4: A0 A0    (2 cyc) Load screen code $A0 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$A0       ; $16C6: A9 A0    (2 cyc) Load screen code $A0 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $80B1      ; $16C8: 8E B1 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $80B1.
        STY $80B2      ; $16CB: 8C B2 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $80B2.
        STA $80B3      ; $16CE: 8D B3 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $80B3.
        LDA #$A0       ; $16D1: A9 A0    (2 cyc) Load screen code $A0 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $80B4      ; $16D3: 8D B4 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $80B4.
        LDA #$A0       ; $16D6: A9 A0    (2 cyc) Load screen code $A0 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $80B5      ; $16D8: 8D B5 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $80B5.
        LDA #$A0       ; $16DB: A9 A0    (2 cyc) Load screen code $A0 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $80B6      ; $16DD: 8D B6 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $80B6.
        LDA #$75       ; $16E0: A9 75    (2 cyc) Load screen code $75 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $80B7      ; $16E2: 8D B7 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $80B7.
        LDA #$A0       ; $16E5: A9 A0    (2 cyc) Load screen code $A0 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $80B8      ; $16E7: 8D B8 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $80B8.
        LDA #$E7       ; $16EA: A9 E7    (2 cyc) Load screen code $E7 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $80B9      ; $16EC: 8D B9 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $80B9.
        LDA #$20       ; $16EF: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $03BA      ; $16F1: 8D BA 03 (4 cyc) Dummy store to $03BA; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $16F4: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $16F5: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_38_r4_s6:
        ; prepares logical scanline 38 (text row 4, glyph row 6); target VRAM $80B1-$80B9.
        ; Values: 20 20 20 20 20 20 65 20 20   [dummy slot 20]
        LDX #$20       ; $16F6: A2 20    (2 cyc) Load screen code $20 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $16F8: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$20       ; $16FA: A9 20    (2 cyc) Load screen code $20 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $80B1      ; $16FC: 8E B1 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $80B1.
        STY $80B2      ; $16FF: 8C B2 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $80B2.
        STA $80B3      ; $1702: 8D B3 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $80B3.
        LDA #$20       ; $1705: A9 20    (2 cyc) Load screen code $20 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $80B4      ; $1707: 8D B4 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $80B4.
        LDA #$20       ; $170A: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $80B5      ; $170C: 8D B5 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $80B5.
        LDA #$20       ; $170F: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $80B6      ; $1711: 8D B6 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $80B6.
        LDA #$65       ; $1714: A9 65    (2 cyc) Load screen code $65 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $80B7      ; $1716: 8D B7 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $80B7.
        LDA #$20       ; $1719: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $80B8      ; $171B: 8D B8 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $80B8.
        LDA #$20       ; $171E: A9 20    (2 cyc) Load screen code $20 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $80B9      ; $1720: 8D B9 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $80B9.
        LDA #$20       ; $1723: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $03BA      ; $1725: 8D BA 03 (4 cyc) Dummy store to $03BA; burns 4 cycles without touching a tenth visible screen cell.
        NOP            ; $1728: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.
        NOP            ; $1729: EA       (2 cyc) Timing pad; with the 60-cycle load/store body this makes a 64-cycle raster kernel.

line_39_r4_s7:
        ; prepares logical scanline 39 (text row 4, glyph row 7); target VRAM $80B1-$80B9.
        ; Values: 20 20 20 20 20 20 20 20 20   [dummy slot 20]
        LDX #$20       ; $172A: A2 20    (2 cyc) Load screen code $20 for logical X=0 (visible); BASIC may overwrite this immediate operand.
        LDY #$20       ; $172C: A0 20    (2 cyc) Load screen code $20 for logical X=1 (visible); BASIC may overwrite this immediate operand.
        LDA #$20       ; $172E: A9 20    (2 cyc) Load screen code $20 for logical X=2 (visible); BASIC may overwrite this immediate operand.
        STX $80B1      ; $1730: 8E B1 80 (4 cyc) Commit logical X=0 to PET screen RAM column 17, address $80B1.
        STY $80B2      ; $1733: 8C B2 80 (4 cyc) Commit logical X=1 to PET screen RAM column 18, address $80B2.
        STA $80B3      ; $1736: 8D B3 80 (4 cyc) Commit logical X=2 to PET screen RAM column 19, address $80B3.
        LDA #$20       ; $1739: A9 20    (2 cyc) Load screen code $20 for logical X=3 (visible); BASIC may overwrite this immediate operand.
        STA $80B4      ; $173B: 8D B4 80 (4 cyc) Commit logical X=3 to PET screen RAM column 20, address $80B4.
        LDA #$20       ; $173E: A9 20    (2 cyc) Load screen code $20 for logical X=4 (visible); BASIC may overwrite this immediate operand.
        STA $80B5      ; $1740: 8D B5 80 (4 cyc) Commit logical X=4 to PET screen RAM column 21, address $80B5.
        LDA #$20       ; $1743: A9 20    (2 cyc) Load screen code $20 for logical X=5 (visible); BASIC may overwrite this immediate operand.
        STA $80B6      ; $1745: 8D B6 80 (4 cyc) Commit logical X=5 to PET screen RAM column 22, address $80B6.
        LDA #$20       ; $1748: A9 20    (2 cyc) Load screen code $20 for logical X=6 (visible); BASIC may overwrite this immediate operand.
        STA $80B7      ; $174A: 8D B7 80 (4 cyc) Commit logical X=6 to PET screen RAM column 23, address $80B7.
        LDA #$20       ; $174D: A9 20    (2 cyc) Load screen code $20 for logical X=7 (visible); BASIC may overwrite this immediate operand.
        STA $80B8      ; $174F: 8D B8 80 (4 cyc) Commit logical X=7 to PET screen RAM column 24, address $80B8.
        LDA #$20       ; $1752: A9 20    (2 cyc) Load screen code $20 for logical X=8 (visible); BASIC may overwrite this immediate operand.
        STA $80B9      ; $1754: 8D B9 80 (4 cyc) Commit logical X=8 to PET screen RAM column 25, address $80B9.
        LDA #$20       ; $1757: A9 20    (2 cyc) Load screen code $20 for logical X=9 (dummy/non-display); BASIC may overwrite this immediate operand.
        STA $03BA      ; $1759: 8D BA 03 (4 cyc) Dummy store to $03BA; burns 4 cycles without touching a tenth visible screen cell.

video_irq_epilogue:
        PLA            ; $175C: 68       (4 cyc) Restore saved Y value from the custom prologue.
        TAY            ; $175D: A8       (2 cyc) Transfer restored value to Y.
        PLA            ; $175E: 68       (4 cyc) Restore saved X value.
        TAX            ; $175F: AA       (2 cyc) Transfer restored value to X.
        PLA            ; $1760: 68       (4 cyc) Restore accumulator.
        PLP            ; $1761: 28       (4 cyc) Restore processor status.

chain_irq:
        JMP $0F2A      ; $1762: 4C 2A 0F (3 cyc) Chain to the original user-IRQ handler. Its operand is self-modified by the setup routine.
        BRK            ; $1765: 00       (7 cyc) Trailing zero byte after the machine-code payload; not reached in normal operation.
