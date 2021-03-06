;******************************************************************************
;   MSP430xG46x Demo - OA0, Comparator in General-Purpose Mode
;
;   Description: Use OA0 as a comparator in general-purpose mode. In this
;   example, OA0 is configured for general-purpose mode, but used as a
;   comparator. The reference is supplied by DAC12_0 on the "-" input.
;   The "+" terminal is connected to OA0I0.
;   ACLK = 32.768kHz, MCLK = SMCLK = default DCO
;
;                 MSP430FG461x
;              -------------------
;          /|\|                XIN|-
;           | |                   |
;           --|RST            XOUT|-
;             |                   |
;      "+" -->|P6.0/OA0I0         |
;      Input  |                   |
;             |          P6.1/OA0O|--> OA0 Output
;             |                   |    Output goes high when
;             |                   |    Input > 1.5V
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430xG46x.h"
;-------------------------------------------------------------------------------
			.text	;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #900,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
                                            ;
REFOn       mov.w   #REFON+REF2_5V,&ADC12CTL0
                                            ; 2.5V reference for DAC12
DAC12_0     mov.w   #DAC12IR+DAC12AMP_2+DAC12ENC,&DAC12_0CTL
                                            ; 1x input range, enable DAC120,
                                            ; low speed/current
            mov.w   #099Ah,&DAC12_0DAT      ; Set DAC120 to output 1.5V
                                            ;
SetupOA     mov.b   #OAN_2+OAPM_1,&OA0CTL0  ; "-" connected to DAC120,
                                            ; "+" connected to OA0I0 (default),
                                            ; slow slew rate
            mov.b   #OARRIP,&OA0CTL1        ; General purpose (default),
                                            ; limited range (see datasheet)
                                            ;						
Mainloop    bis.w   #LPM3,SR                ; Enter LPM3
            nop                             ; Required only for debug
                                            ;
;------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".reset"            ; POR, ext. Reset, Watchdog
            .short   RESET
            .end
           