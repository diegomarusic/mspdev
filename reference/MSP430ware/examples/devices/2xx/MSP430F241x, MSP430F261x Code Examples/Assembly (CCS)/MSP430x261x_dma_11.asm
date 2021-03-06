;*******************************************************************************
;  MSP430x261x Demo - DMA0/1, ADC12 A10 rpt single transfer to MPY/RAM, TBCCR1, DCO
;
;  Description: A 0x20 word block of data is sampled and recorded into RAM
;  starting at address 01500h from the ADC12 channel 10 (temp sensor) using the
;  Record() function. Timer_B CCR1 begins the ADC12 sample period, CCR0 the hold
;  and conversion start. Timer_B operates in the up mode with CCR0 defining the
;  sample period.
;  DMA0 will automatically transfer each ADC12 conversion code to the HW MPY
;  which will preform MPY x 0x1000 - this will rotate the operand 12-bits to
;  the left. DMA1 uses the multiplier ready trigger to move the lower byte of
;  the upper operand of the multiplier result to a RAM block. At the end of the
;  transfer block, DMA1 issues an interrupt.
;  The purpose of this example is to show how multiple DMA triggers can be
;  combined.
;  P1.0 is toggled during DMA transfer only for demonstration purposes.
;  ACLK = 32Khz, MCLK = SMCLK = default DCO 1MHz
;
;               MSP430x2619
;            -----------------
;        /|\|              XIN|-
;         | |                 | 32kHz
;         --|RST          XOUT|-
;           |                 |
;           |             P1.0|-->LED
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x26x.h"
;-------------------------------------------------------------------------------
			.text	;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #0850h,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
SetupP5     bis.b   #BIT0,&P1DIR            ; Set P1.0 to output direction
Mainloop    call    #Record
            nop                             ; Needed only for debugger
            jmp     Mainloop

Record      mov.b   #SREF_1+INCH_10,&ADC12MCTL0 ; Channel A10, Vref+
            clr.w   &ADC12IFG
            mov.w   #SHS_3+CONSEQ_2,&ADC12CTL1 ; S&H TB.OUT1, rep. single chan
            mov.w   #REF2_5V+REFON+ADC12ON+ENC,&ADC12CTL0 ; VRef ADC12 on, enabl
            mov.w   #03600h,R15             ; Delay for needed ref start-up.
RefDelay    dec.w   R15                     ; See datasheet for details.
            jnz     RefDelay                ;
            mov.w   #100,&TBCCR0            ; Init TBCCR0 w/ sample prd
            mov.w   #70,&TBCCR1             ; Trigger for ADC12 SC
            mov.w   #OUTMOD_7,&TBCCTL1      ; Reset OUT1 on EQU1, set on EQU0
SetupDMAx   movx.a  #ADC12MEM0,&DMA0SA     ; Src address = ADC12 module
            movx.a  #OP2,&DMA0DA           ; Dst address = HW multiplier
            mov.w   #01h,&DMA0SZ            ; Size in words
            mov.w   #DMADT_4+DMAEN,&DMA0CTL ; Sng rpt, config
            movx.a  #RESHI,&DMA1SA         ; Src address = HW multiplier
            movx.a  #01500h,&DMA1DA         ; Dst address = RAM memory
            mov.w   #020h,&DMA1SZ           ; Size in byte
            mov.w   #DMADSTINCR_3+DMASBDB+DMAIE+DMAEN,&DMA1CTL ; Sng, config
            mov.w   #1000h,&MPY             ; MPY first operand
            mov.w   #DMA1TSEL_11+DMA0TSEL_6,&DMACTL0 ; DMA1=MPY Ready,
                                            ; DMA0=ADC12IFGx
            bis.b   #BIT0,&P1OUT             ; Start recording and enter LPM0
            mov.w   #TBSSEL_2+MC_1+TBCLR,&TBCTL ; SMCLK, clear TBR, up mode
            bis.w   #CPUOFF+GIE,SR          ; Enter LPM0, enable interrupts
            bic.w   #CONSEQ_2,&ADC12CTL1    ; Stop conversion immediately
            bic.w   #ENC,&ADC12CTL0         ; Disable ADC12 conversion
            clr.w   &ADC12CTL0              ; Switch off ADC12 & ref voltage
            clr.w   &TBCTL                  ; Disable Timer_B
            bic.b   #BIT0,&P1OUT             ; Clear P1.0 (LED Off)
            ret
;-------------------------------------------------------------------------------
DMA_ISR;    Common ISR for DMA/DAC12
;-------------------------------------------------------------------------------
            bic.w   #DMAIFG,&DMA1CTL        ; Clear DMA1 interrupt flag
            bic.w   #LPM0,0(SP)             ; Exit LPMx, interrupts enabled
            reti                            ;
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect     ".int15"              ; DMA Vector
            .short   DMA_ISR                 ;
            .sect    ".reset"            ; POR, ext. Reset
            .short   RESET
            .end
