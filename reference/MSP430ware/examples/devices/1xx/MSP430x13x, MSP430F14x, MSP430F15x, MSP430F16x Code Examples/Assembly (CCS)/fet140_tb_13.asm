;******************************************************************************
;   MSP-FET430P140 Demo - Timer_B, PWM TB1-2, Up/Down Mode, DCO SMCLK
;
;   Description: This program generates two PWM outputs on P4.1,2 using
;   Timer_B configured for up/down mode. The value in CCR0, 128, defines
;   the PWM period/2 and the values in CCR1-2 the PWM duty cycles. Using
;   ~800kHz SMCLK as TBCLK, the timer period is ~340us with a 75% duty
;   cycle on P4.1 and 25% on P4.2.
;   ACLK = n/a, SMCLK = MCLK = TBCLK = default DCO ~800kHz.
;
;                MSP430F149
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;            |                 |
;            |         P4.1/TB1|--> CCR1 - 75% PWM
;            |         P4.2/TB2|--> CCR2 - 25% PWM
;
;   M. Buccini / G. Morton
;   Texas Instruments Inc.
;   May 2005
;   Built with Code Composer Essentials Version: 1.0
;******************************************************************************
 .cdecls C,LIST,  "msp430x14x.h"
;-----------------------------------------------------------------------------
            .text                           ; Program Start
;-----------------------------------------------------------------------------
RESET       mov.w   #0A00h,SP               ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP4     bis.b   #006h,&P4DIR            ; P4.1 and P4.2 output
            bis.b   #006h,&P4SEL            ; P4.1 and P4.2 TB1/2 otions
SetupC0     mov.w   #128,&TBCCR0            ; PWM Period/2
SetupC1     mov.w   #OUTMOD_6,&TBCCTL1      ; CCR1 toggle/set
            mov.w   #32,&TBCCR1             ; CCR1 PWM Duty Cycle	
SetupC2     mov.w   #OUTMOD_6,&TBCCTL2      ; CCR2 toggle/set
            mov.w   #96,&TBCCR2             ; CCR2 PWM duty cycle	
SetupTB     mov.w   #TBSSEL_2+MC_3,&TBCTL   ; SMCLK, updown mode
                                            ;					
Mainloop    bis.w   #CPUOFF,SR              ; CPU off
            nop                             ; Required only for debugger
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .end
