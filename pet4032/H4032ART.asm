; H4032ART — Annotated 6502 source
;
; CURSOR #18-style pseudo-hi-res for a CRTC PET 4032.
; Displays original PET 2001 artwork, the right-hand side of which gets
; truncated on a PET 4032.

        .org $0EF4


; ---------------------------------------------------------------------------
; 27-byte compatibility entry retained so BASIC can still use ML+27.
; ---------------------------------------------------------------------------
setup_old_rom:
        sei
        lda $0219
        ldx chain_operand
        sta chain_operand
        stx $0219
        lda $021A
        ldx chain_operand_hi
        sta chain_operand_hi
        stx $021A
        cli
        rts

; ---------------------------------------------------------------------------
; CRTC PET 4032 setup / teardown.  $E01B selects the Editor ROM graphics
; timing (8 raster lines per character).  The clear loop removes remnants
; of the introductory BASIC screen before the raster image starts.
; ---------------------------------------------------------------------------
setup_4032:
        sei
        jsr $E01B
        ldy #$00
        lda #$20
clear_top_rows:
        sta $8000,y
        iny
        cpy #$C8            ; 5 text rows * 40 columns = 200 bytes
        bne clear_top_rows
        lda $0090
        ldx chain_operand
        sta chain_operand
        stx $0090
        lda $0091
        ldx chain_operand_hi
        sta chain_operand_hi
        stx $0091
        cli
        rts

; ---------------------------------------------------------------------------
; Custom CINV handler.  Raster 0 is primed before waiting for the end of
; vertical blank.  Each following block runs once per 50-cycle scanline.
; ---------------------------------------------------------------------------
video_irq:
        php
        pha
        txa
        pha
        tya
        pha
        nop
        nop
        nop
        nop
        nop

line_00:
        ldx #$20          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$20          ; column 2 data, 2 cycles
        stx $8010         ; write 0 completes at cycle 10
        sty $8011         ; write 1 completes at cycle 14
        sta $8012         ; write 2 completes at cycle 18
        lda #$20          ; column 3 data, 2 cycles
        sta $8013         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $8014         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8015         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $8016         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $8017         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

        lda #$20
wait_blank_start:
        bit $E880           ; MOS 6545-1 status bit 5 = vertical blank
        beq wait_blank_start
wait_blank_end:
        bit $E880
        bne wait_blank_end

        .byte $A0           ; LDY #immediate, separated to expose operand
phase_count_operand:
        .byte $02           ; proven real-PET value: 2
phase_delay:
        dey
        bne phase_delay

line_01:
        ldx #$20          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$67          ; column 2 data, 2 cycles
        stx $8010         ; write 0 completes at cycle 10
        sty $8011         ; write 1 completes at cycle 14
        sta $8012         ; write 2 completes at cycle 18
        lda #$20          ; column 3 data, 2 cycles
        sta $8013         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $8014         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8015         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $8016         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $8017         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_02:
        ldx #$E5          ; column 0 data, 2 cycles
        ldy #$A0          ; column 1 data, 2 cycles
        lda #$76          ; column 2 data, 2 cycles
        stx $8010         ; write 0 completes at cycle 10
        sty $8011         ; write 1 completes at cycle 14
        sta $8012         ; write 2 completes at cycle 18
        lda #$A0          ; column 3 data, 2 cycles
        sta $8013         ; write 3 completes at cycle 24
        lda #$A0          ; column 4 data, 2 cycles
        sta $8014         ; write 4 completes at cycle 30
        lda #$A0          ; column 5 data, 2 cycles
        sta $8015         ; write 5 completes at cycle 36
        lda #$A0          ; column 6 data, 2 cycles
        sta $8016         ; write 6 completes at cycle 42
        lda #$A0          ; column 7 data, 2 cycles
        sta $8017         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_03:
        ldx #$A0          ; column 0 data, 2 cycles
        ldy #$A0          ; column 1 data, 2 cycles
        lda #$F5          ; column 2 data, 2 cycles
        stx $8010         ; write 0 completes at cycle 10
        sty $8011         ; write 1 completes at cycle 14
        sta $8012         ; write 2 completes at cycle 18
        lda #$A0          ; column 3 data, 2 cycles
        sta $8013         ; write 3 completes at cycle 24
        lda #$A0          ; column 4 data, 2 cycles
        sta $8014         ; write 4 completes at cycle 30
        lda #$A0          ; column 5 data, 2 cycles
        sta $8015         ; write 5 completes at cycle 36
        lda #$A0          ; column 6 data, 2 cycles
        sta $8016         ; write 6 completes at cycle 42
        lda #$A0          ; column 7 data, 2 cycles
        sta $8017         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_04:
        ldx #$A0          ; column 0 data, 2 cycles
        ldy #$A0          ; column 1 data, 2 cycles
        lda #$76          ; column 2 data, 2 cycles
        stx $8010         ; write 0 completes at cycle 10
        sty $8011         ; write 1 completes at cycle 14
        sta $8012         ; write 2 completes at cycle 18
        lda #$A0          ; column 3 data, 2 cycles
        sta $8013         ; write 3 completes at cycle 24
        lda #$A0          ; column 4 data, 2 cycles
        sta $8014         ; write 4 completes at cycle 30
        lda #$A0          ; column 5 data, 2 cycles
        sta $8015         ; write 5 completes at cycle 36
        lda #$A0          ; column 6 data, 2 cycles
        sta $8016         ; write 6 completes at cycle 42
        lda #$A0          ; column 7 data, 2 cycles
        sta $8017         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_05:
        ldx #$EA          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$67          ; column 2 data, 2 cycles
        stx $8010         ; write 0 completes at cycle 10
        sty $8011         ; write 1 completes at cycle 14
        sta $8012         ; write 2 completes at cycle 18
        lda #$20          ; column 3 data, 2 cycles
        sta $8013         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $8014         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8015         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $8016         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $8017         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_06:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$20          ; column 2 data, 2 cycles
        stx $8010         ; write 0 completes at cycle 10
        sty $8011         ; write 1 completes at cycle 14
        sta $8012         ; write 2 completes at cycle 18
        lda #$20          ; column 3 data, 2 cycles
        sta $8013         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $8014         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8015         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $8016         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $8017         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_07:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$20          ; column 2 data, 2 cycles
        stx $8010         ; write 0 completes at cycle 10
        sty $8011         ; write 1 completes at cycle 14
        sta $8012         ; write 2 completes at cycle 18
        lda #$20          ; column 3 data, 2 cycles
        sta $8013         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $8014         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8015         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $8016         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $8017         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_08:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$51          ; column 1 data, 2 cycles
        lda #$56          ; column 2 data, 2 cycles
        stx $8038         ; write 0 completes at cycle 10
        sty $8039         ; write 1 completes at cycle 14
        sta $803A         ; write 2 completes at cycle 18
        lda #$66          ; column 3 data, 2 cycles
        sta $803B         ; write 3 completes at cycle 24
        lda #$5A          ; column 4 data, 2 cycles
        sta $803C         ; write 4 completes at cycle 30
        lda #$66          ; column 5 data, 2 cycles
        sta $803D         ; write 5 completes at cycle 36
        lda #$4A          ; column 6 data, 2 cycles
        sta $803E         ; write 6 completes at cycle 42
        lda #$2A          ; column 7 data, 2 cycles
        sta $803F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_09:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$51          ; column 1 data, 2 cycles
        lda #$56          ; column 2 data, 2 cycles
        stx $8038         ; write 0 completes at cycle 10
        sty $8039         ; write 1 completes at cycle 14
        sta $803A         ; write 2 completes at cycle 18
        lda #$66          ; column 3 data, 2 cycles
        sta $803B         ; write 3 completes at cycle 24
        lda #$5A          ; column 4 data, 2 cycles
        sta $803C         ; write 4 completes at cycle 30
        lda #$E6          ; column 5 data, 2 cycles
        sta $803D         ; write 5 completes at cycle 36
        lda #$4A          ; column 6 data, 2 cycles
        sta $803E         ; write 6 completes at cycle 42
        lda #$2A          ; column 7 data, 2 cycles
        sta $803F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_10:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$51          ; column 1 data, 2 cycles
        lda #$56          ; column 2 data, 2 cycles
        stx $8038         ; write 0 completes at cycle 10
        sty $8039         ; write 1 completes at cycle 14
        sta $803A         ; write 2 completes at cycle 18
        lda #$66          ; column 3 data, 2 cycles
        sta $803B         ; write 3 completes at cycle 24
        lda #$5A          ; column 4 data, 2 cycles
        sta $803C         ; write 4 completes at cycle 30
        lda #$66          ; column 5 data, 2 cycles
        sta $803D         ; write 5 completes at cycle 36
        lda #$4A          ; column 6 data, 2 cycles
        sta $803E         ; write 6 completes at cycle 42
        lda #$2A          ; column 7 data, 2 cycles
        sta $803F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_11:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$51          ; column 1 data, 2 cycles
        lda #$56          ; column 2 data, 2 cycles
        stx $8038         ; write 0 completes at cycle 10
        sty $8039         ; write 1 completes at cycle 14
        sta $803A         ; write 2 completes at cycle 18
        lda #$66          ; column 3 data, 2 cycles
        sta $803B         ; write 3 completes at cycle 24
        lda #$5A          ; column 4 data, 2 cycles
        sta $803C         ; write 4 completes at cycle 30
        lda #$E6          ; column 5 data, 2 cycles
        sta $803D         ; write 5 completes at cycle 36
        lda #$4A          ; column 6 data, 2 cycles
        sta $803E         ; write 6 completes at cycle 42
        lda #$2A          ; column 7 data, 2 cycles
        sta $803F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_12:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$57          ; column 1 data, 2 cycles
        lda #$5A          ; column 2 data, 2 cycles
        stx $8038         ; write 0 completes at cycle 10
        sty $8039         ; write 1 completes at cycle 14
        sta $803A         ; write 2 completes at cycle 18
        lda #$6C          ; column 3 data, 2 cycles
        sta $803B         ; write 3 completes at cycle 24
        lda #$E9          ; column 4 data, 2 cycles
        sta $803C         ; write 4 completes at cycle 30
        lda #$66          ; column 5 data, 2 cycles
        sta $803D         ; write 5 completes at cycle 36
        lda #$55          ; column 6 data, 2 cycles
        sta $803E         ; write 6 completes at cycle 42
        lda #$5D          ; column 7 data, 2 cycles
        sta $803F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_13:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$57          ; column 1 data, 2 cycles
        lda #$5A          ; column 2 data, 2 cycles
        stx $8038         ; write 0 completes at cycle 10
        sty $8039         ; write 1 completes at cycle 14
        sta $803A         ; write 2 completes at cycle 18
        lda #$6C          ; column 3 data, 2 cycles
        sta $803B         ; write 3 completes at cycle 24
        lda #$E9          ; column 4 data, 2 cycles
        sta $803C         ; write 4 completes at cycle 30
        lda #$E6          ; column 5 data, 2 cycles
        sta $803D         ; write 5 completes at cycle 36
        lda #$55          ; column 6 data, 2 cycles
        sta $803E         ; write 6 completes at cycle 42
        lda #$5D          ; column 7 data, 2 cycles
        sta $803F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_14:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$57          ; column 1 data, 2 cycles
        lda #$5A          ; column 2 data, 2 cycles
        stx $8038         ; write 0 completes at cycle 10
        sty $8039         ; write 1 completes at cycle 14
        sta $803A         ; write 2 completes at cycle 18
        lda #$6C          ; column 3 data, 2 cycles
        sta $803B         ; write 3 completes at cycle 24
        lda #$E9          ; column 4 data, 2 cycles
        sta $803C         ; write 4 completes at cycle 30
        lda #$66          ; column 5 data, 2 cycles
        sta $803D         ; write 5 completes at cycle 36
        lda #$55          ; column 6 data, 2 cycles
        sta $803E         ; write 6 completes at cycle 42
        lda #$5D          ; column 7 data, 2 cycles
        sta $803F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_15:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$57          ; column 1 data, 2 cycles
        lda #$5A          ; column 2 data, 2 cycles
        stx $8038         ; write 0 completes at cycle 10
        sty $8039         ; write 1 completes at cycle 14
        sta $803A         ; write 2 completes at cycle 18
        lda #$6C          ; column 3 data, 2 cycles
        sta $803B         ; write 3 completes at cycle 24
        lda #$E9          ; column 4 data, 2 cycles
        sta $803C         ; write 4 completes at cycle 30
        lda #$E6          ; column 5 data, 2 cycles
        sta $803D         ; write 5 completes at cycle 36
        lda #$55          ; column 6 data, 2 cycles
        sta $803E         ; write 6 completes at cycle 42
        lda #$5D          ; column 7 data, 2 cycles
        sta $803F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_16:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$A0          ; column 1 data, 2 cycles
        lda #$58          ; column 2 data, 2 cycles
        stx $8060         ; write 0 completes at cycle 10
        sty $8061         ; write 1 completes at cycle 14
        sta $8062         ; write 2 completes at cycle 18
        lda #$A0          ; column 3 data, 2 cycles
        sta $8063         ; write 3 completes at cycle 24
        lda #$4E          ; column 4 data, 2 cycles
        sta $8064         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8065         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $8066         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $8067         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_17:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$58          ; column 2 data, 2 cycles
        stx $8060         ; write 0 completes at cycle 10
        sty $8061         ; write 1 completes at cycle 14
        sta $8062         ; write 2 completes at cycle 18
        lda #$A0          ; column 3 data, 2 cycles
        sta $8063         ; write 3 completes at cycle 24
        lda #$4E          ; column 4 data, 2 cycles
        sta $8064         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8065         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $8066         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $8067         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_18:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$A0          ; column 1 data, 2 cycles
        lda #$58          ; column 2 data, 2 cycles
        stx $8060         ; write 0 completes at cycle 10
        sty $8061         ; write 1 completes at cycle 14
        sta $8062         ; write 2 completes at cycle 18
        lda #$A0          ; column 3 data, 2 cycles
        sta $8063         ; write 3 completes at cycle 24
        lda #$4E          ; column 4 data, 2 cycles
        sta $8064         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8065         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $8066         ; write 6 completes at cycle 42
        lda #$F5          ; column 7 data, 2 cycles
        sta $8067         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_19:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$58          ; column 2 data, 2 cycles
        stx $8060         ; write 0 completes at cycle 10
        sty $8061         ; write 1 completes at cycle 14
        sta $8062         ; write 2 completes at cycle 18
        lda #$A0          ; column 3 data, 2 cycles
        sta $8063         ; write 3 completes at cycle 24
        lda #$4E          ; column 4 data, 2 cycles
        sta $8064         ; write 4 completes at cycle 30
        lda #$5D          ; column 5 data, 2 cycles
        sta $8065         ; write 5 completes at cycle 36
        lda #$74          ; column 6 data, 2 cycles
        sta $8066         ; write 6 completes at cycle 42
        lda #$42          ; column 7 data, 2 cycles
        sta $8067         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_20:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$A0          ; column 1 data, 2 cycles
        lda #$A0          ; column 2 data, 2 cycles
        stx $8060         ; write 0 completes at cycle 10
        sty $8061         ; write 1 completes at cycle 14
        sta $8062         ; write 2 completes at cycle 18
        lda #$DC          ; column 3 data, 2 cycles
        sta $8063         ; write 3 completes at cycle 24
        lda #$56          ; column 4 data, 2 cycles
        sta $8064         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8065         ; write 5 completes at cycle 36
        lda #$74          ; column 6 data, 2 cycles
        sta $8066         ; write 6 completes at cycle 42
        lda #$42          ; column 7 data, 2 cycles
        sta $8067         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_21:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$A0          ; column 2 data, 2 cycles
        stx $8060         ; write 0 completes at cycle 10
        sty $8061         ; write 1 completes at cycle 14
        sta $8062         ; write 2 completes at cycle 18
        lda #$DC          ; column 3 data, 2 cycles
        sta $8063         ; write 3 completes at cycle 24
        lda #$56          ; column 4 data, 2 cycles
        sta $8064         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8065         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $8066         ; write 6 completes at cycle 42
        lda #$F5          ; column 7 data, 2 cycles
        sta $8067         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_22:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$A0          ; column 1 data, 2 cycles
        lda #$A0          ; column 2 data, 2 cycles
        stx $8060         ; write 0 completes at cycle 10
        sty $8061         ; write 1 completes at cycle 14
        sta $8062         ; write 2 completes at cycle 18
        lda #$DC          ; column 3 data, 2 cycles
        sta $8063         ; write 3 completes at cycle 24
        lda #$56          ; column 4 data, 2 cycles
        sta $8064         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8065         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $8066         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $8067         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_23:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$57          ; column 1 data, 2 cycles
        lda #$A0          ; column 2 data, 2 cycles
        stx $8060         ; write 0 completes at cycle 10
        sty $8061         ; write 1 completes at cycle 14
        sta $8062         ; write 2 completes at cycle 18
        lda #$DC          ; column 3 data, 2 cycles
        sta $8063         ; write 3 completes at cycle 24
        lda #$56          ; column 4 data, 2 cycles
        sta $8064         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $8065         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $8066         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $8067         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_24:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$57          ; column 1 data, 2 cycles
        lda #$20          ; column 2 data, 2 cycles
        stx $8088         ; write 0 completes at cycle 10
        sty $8089         ; write 1 completes at cycle 14
        sta $808A         ; write 2 completes at cycle 18
        lda #$20          ; column 3 data, 2 cycles
        sta $808B         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $808C         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $808D         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $808E         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $808F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_25:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$57          ; column 1 data, 2 cycles
        lda #$20          ; column 2 data, 2 cycles
        stx $8088         ; write 0 completes at cycle 10
        sty $8089         ; write 1 completes at cycle 14
        sta $808A         ; write 2 completes at cycle 18
        lda #$61          ; column 3 data, 2 cycles
        sta $808B         ; write 3 completes at cycle 24
        lda #$5C          ; column 4 data, 2 cycles
        sta $808C         ; write 4 completes at cycle 30
        lda #$56          ; column 5 data, 2 cycles
        sta $808D         ; write 5 completes at cycle 36
        lda #$5F          ; column 6 data, 2 cycles
        sta $808E         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $808F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_26:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$57          ; column 1 data, 2 cycles
        lda #$20          ; column 2 data, 2 cycles
        stx $8088         ; write 0 completes at cycle 10
        sty $8089         ; write 1 completes at cycle 14
        sta $808A         ; write 2 completes at cycle 18
        lda #$E1          ; column 3 data, 2 cycles
        sta $808B         ; write 3 completes at cycle 24
        lda #$5C          ; column 4 data, 2 cycles
        sta $808C         ; write 4 completes at cycle 30
        lda #$56          ; column 5 data, 2 cycles
        sta $808D         ; write 5 completes at cycle 36
        lda #$5F          ; column 6 data, 2 cycles
        sta $808E         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $808F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_27:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$57          ; column 1 data, 2 cycles
        lda #$5D          ; column 2 data, 2 cycles
        stx $8088         ; write 0 completes at cycle 10
        sty $8089         ; write 1 completes at cycle 14
        sta $808A         ; write 2 completes at cycle 18
        lda #$61          ; column 3 data, 2 cycles
        sta $808B         ; write 3 completes at cycle 24
        lda #$5C          ; column 4 data, 2 cycles
        sta $808C         ; write 4 completes at cycle 30
        lda #$56          ; column 5 data, 2 cycles
        sta $808D         ; write 5 completes at cycle 36
        lda #$5F          ; column 6 data, 2 cycles
        sta $808E         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $808F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_28:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$57          ; column 1 data, 2 cycles
        lda #$48          ; column 2 data, 2 cycles
        stx $8088         ; write 0 completes at cycle 10
        sty $8089         ; write 1 completes at cycle 14
        sta $808A         ; write 2 completes at cycle 18
        lda #$E1          ; column 3 data, 2 cycles
        sta $808B         ; write 3 completes at cycle 24
        lda #$5C          ; column 4 data, 2 cycles
        sta $808C         ; write 4 completes at cycle 30
        lda #$56          ; column 5 data, 2 cycles
        sta $808D         ; write 5 completes at cycle 36
        lda #$5F          ; column 6 data, 2 cycles
        sta $808E         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $808F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_29:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$51          ; column 1 data, 2 cycles
        lda #$E7          ; column 2 data, 2 cycles
        stx $8088         ; write 0 completes at cycle 10
        sty $8089         ; write 1 completes at cycle 14
        sta $808A         ; write 2 completes at cycle 18
        lda #$61          ; column 3 data, 2 cycles
        sta $808B         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $808C         ; write 4 completes at cycle 30
        lda #$57          ; column 5 data, 2 cycles
        sta $808D         ; write 5 completes at cycle 36
        lda #$DF          ; column 6 data, 2 cycles
        sta $808E         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $808F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_30:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$51          ; column 1 data, 2 cycles
        lda #$48          ; column 2 data, 2 cycles
        stx $8088         ; write 0 completes at cycle 10
        sty $8089         ; write 1 completes at cycle 14
        sta $808A         ; write 2 completes at cycle 18
        lda #$E1          ; column 3 data, 2 cycles
        sta $808B         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $808C         ; write 4 completes at cycle 30
        lda #$57          ; column 5 data, 2 cycles
        sta $808D         ; write 5 completes at cycle 36
        lda #$DF          ; column 6 data, 2 cycles
        sta $808E         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $808F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_31:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$51          ; column 1 data, 2 cycles
        lda #$5D          ; column 2 data, 2 cycles
        stx $8088         ; write 0 completes at cycle 10
        sty $8089         ; write 1 completes at cycle 14
        sta $808A         ; write 2 completes at cycle 18
        lda #$61          ; column 3 data, 2 cycles
        sta $808B         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $808C         ; write 4 completes at cycle 30
        lda #$57          ; column 5 data, 2 cycles
        sta $808D         ; write 5 completes at cycle 36
        lda #$DF          ; column 6 data, 2 cycles
        sta $808E         ; write 6 completes at cycle 42
        lda #$6A          ; column 7 data, 2 cycles
        sta $808F         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_32:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$51          ; column 1 data, 2 cycles
        lda #$20          ; column 2 data, 2 cycles
        stx $80B0         ; write 0 completes at cycle 10
        sty $80B1         ; write 1 completes at cycle 14
        sta $80B2         ; write 2 completes at cycle 18
        lda #$E1          ; column 3 data, 2 cycles
        sta $80B3         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $80B4         ; write 4 completes at cycle 30
        lda #$57          ; column 5 data, 2 cycles
        sta $80B5         ; write 5 completes at cycle 36
        lda #$DF          ; column 6 data, 2 cycles
        sta $80B6         ; write 6 completes at cycle 42
        lda #$6A          ; column 7 data, 2 cycles
        sta $80B7         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_33:
        ldx #$F6          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$20          ; column 2 data, 2 cycles
        stx $80B0         ; write 0 completes at cycle 10
        sty $80B1         ; write 1 completes at cycle 14
        sta $80B2         ; write 2 completes at cycle 18
        lda #$20          ; column 3 data, 2 cycles
        sta $80B3         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $80B4         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $80B5         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $80B6         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $80B7         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_34:
        ldx #$EA          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$20          ; column 2 data, 2 cycles
        stx $80B0         ; write 0 completes at cycle 10
        sty $80B1         ; write 1 completes at cycle 14
        sta $80B2         ; write 2 completes at cycle 18
        lda #$20          ; column 3 data, 2 cycles
        sta $80B3         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $80B4         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $80B5         ; write 5 completes at cycle 36
        lda #$65          ; column 6 data, 2 cycles
        sta $80B6         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $80B7         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_35:
        ldx #$A0          ; column 0 data, 2 cycles
        ldy #$A0          ; column 1 data, 2 cycles
        lda #$A0          ; column 2 data, 2 cycles
        stx $80B0         ; write 0 completes at cycle 10
        sty $80B1         ; write 1 completes at cycle 14
        sta $80B2         ; write 2 completes at cycle 18
        lda #$A0          ; column 3 data, 2 cycles
        sta $80B3         ; write 3 completes at cycle 24
        lda #$A0          ; column 4 data, 2 cycles
        sta $80B4         ; write 4 completes at cycle 30
        lda #$A0          ; column 5 data, 2 cycles
        sta $80B5         ; write 5 completes at cycle 36
        lda #$75          ; column 6 data, 2 cycles
        sta $80B6         ; write 6 completes at cycle 42
        lda #$A0          ; column 7 data, 2 cycles
        sta $80B7         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_36:
        ldx #$A0          ; column 0 data, 2 cycles
        ldy #$A0          ; column 1 data, 2 cycles
        lda #$A0          ; column 2 data, 2 cycles
        stx $80B0         ; write 0 completes at cycle 10
        sty $80B1         ; write 1 completes at cycle 14
        sta $80B2         ; write 2 completes at cycle 18
        lda #$A0          ; column 3 data, 2 cycles
        sta $80B3         ; write 3 completes at cycle 24
        lda #$A0          ; column 4 data, 2 cycles
        sta $80B4         ; write 4 completes at cycle 30
        lda #$A0          ; column 5 data, 2 cycles
        sta $80B5         ; write 5 completes at cycle 36
        lda #$F6          ; column 6 data, 2 cycles
        sta $80B6         ; write 6 completes at cycle 42
        lda #$A0          ; column 7 data, 2 cycles
        sta $80B7         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_37:
        ldx #$E5          ; column 0 data, 2 cycles
        ldy #$A0          ; column 1 data, 2 cycles
        lda #$A0          ; column 2 data, 2 cycles
        stx $80B0         ; write 0 completes at cycle 10
        sty $80B1         ; write 1 completes at cycle 14
        sta $80B2         ; write 2 completes at cycle 18
        lda #$A0          ; column 3 data, 2 cycles
        sta $80B3         ; write 3 completes at cycle 24
        lda #$A0          ; column 4 data, 2 cycles
        sta $80B4         ; write 4 completes at cycle 30
        lda #$A0          ; column 5 data, 2 cycles
        sta $80B5         ; write 5 completes at cycle 36
        lda #$75          ; column 6 data, 2 cycles
        sta $80B6         ; write 6 completes at cycle 42
        lda #$A0          ; column 7 data, 2 cycles
        sta $80B7         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_38:
        ldx #$20          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$20          ; column 2 data, 2 cycles
        stx $80B0         ; write 0 completes at cycle 10
        sty $80B1         ; write 1 completes at cycle 14
        sta $80B2         ; write 2 completes at cycle 18
        lda #$20          ; column 3 data, 2 cycles
        sta $80B3         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $80B4         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $80B5         ; write 5 completes at cycle 36
        lda #$65          ; column 6 data, 2 cycles
        sta $80B6         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $80B7         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

line_39:
        ldx #$20          ; column 0 data, 2 cycles
        ldy #$20          ; column 1 data, 2 cycles
        lda #$20          ; column 2 data, 2 cycles
        stx $80B0         ; write 0 completes at cycle 10
        sty $80B1         ; write 1 completes at cycle 14
        sta $80B2         ; write 2 completes at cycle 18
        lda #$20          ; column 3 data, 2 cycles
        sta $80B3         ; write 3 completes at cycle 24
        lda #$20          ; column 4 data, 2 cycles
        sta $80B4         ; write 4 completes at cycle 30
        lda #$20          ; column 5 data, 2 cycles
        sta $80B5         ; write 5 completes at cycle 36
        lda #$20          ; column 6 data, 2 cycles
        sta $80B6         ; write 6 completes at cycle 42
        lda #$20          ; column 7 data, 2 cycles
        sta $80B7         ; write 7 completes at cycle 48
        nop                 ; +2: complete raster block = exactly 50 cycles

video_irq_epilogue:
        pla
        tay
        pla
        tax
        pla
        plp
chain_irq:
        jmp video_irq       ; operand is swapped with old CINV at setup
chain_operand = chain_irq + 1
chain_operand_hi = chain_irq + 2

; Important generated addresses:
;   setup_4032           $0F0F
;   video_irq            $0F39
;   line_00              $0F44
;   phase_count_operand  $0F7A
;   line_01              $0F7E
;   line_39              $1594
;   chain_irq            $15C3
