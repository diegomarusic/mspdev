;******************************************************************************
;   MSP-FET430P430 Demo - DMA0, Repeated Burst to-from RAM, Software Trigger
;
;   Description: A 16 word block from 220h-240h is transferred to 240h-260h
;   using DMA0 in a burst block using software DMAREQ trigger.
;   After each transfer, source, destination and DMA size are
;   reset to inital software setting because DMA transfer mode 5 is used.
;   P5.1 is toggled during DMA transfer only for demonstration purposes.
;   ** RAM location 0x220 - 0x260 used - always make sure no compiler conflict **
;   ACLK = n/a, MCLK = SMCLK = default DCO
;
;                MSP430FG439
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;            |                 |
;            |             P5.1|-->LED
;
;   M. Buccini / M. Mitchell
;   Texas Instruments Inc.
;   May 2005
;   Built with Code Composer Essentials Version: 1.0
;******************************************************************************
 .cdecls C,LIST,  "msp430xG43x.h"
;------------------------------------------------------------------------------
            .text                  ; Progam Start
;------------------------------------------------------------------------------
RESET       mov.w   #0A00h,SP               ; Initialize stack pointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP1     bis.b   #002h,&P5DIR            ; P5.1  output
            mov.w   #0220h,&DMA0SA          ; Start block address
            mov.w   #0240h,&DMA0DA          ; Destination block address
            mov.w   #0010h,&DMA0SZ          ; Block size
            mov.w   #DMADT_5+DMASRCINCR_3+DMADSTINCR_3+DMAEN,&DMA0CTL; Rpt, inc
            bis.w   #DMAEN,&DMA0CTL         ; Enable DMA0
                                            ;
Mainloop    bis.b   #02h,&P5OUT             ; P5.1 = 1, LED on
            bis.w   #DMAREQ,&DMA0CTL        ; Trigger block transfer
            bic.b   #02h,&P5OUT             ; P5.1 = 0, LED off
            jmp     Mainloop                ; Set BREAKPOINT HERE
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; RESET Vector
            .short  RESET                   ;
            .end
