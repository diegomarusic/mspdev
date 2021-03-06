;******************************************************************************
;   MSP430x24x Demo - 16x16 Signed Multiply
;
;   Description: Hardware multiplier is used to multiply two numbers.
;   The calculation is automatically initiated after the second operand is
;   loaded. Results are stored in RESLO, RESHI and SUMEXT = FFFF if result is
;   negative, SUMEXT = 0 otherwise.
;
;   ACLK = 32.768kHz, MCLK = SMCLK = default DCO
;
;                 MSP430x249
;             -----------------
;         /|\|                 |
;          | |                 |
;          --|RST              |
;            |                 |
;            |                 |
;
;  JL Bile
;  Texas Instruments Inc.
;  May 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x24x.h"
;-------------------------------------------------------------------------------
			.text	;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #0500h,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
            mov.w   #01234h,&MPYS           ; Load first operand -signed mult
            mov.w   #05678h,&OP2            ; Load second operand
            bis.w   #LPM4,SR                ; LPM4
            nop                             ; set BREAKPOINT here

;------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".reset"            ; POR, ext. Reset
            .short    RESET
            .end