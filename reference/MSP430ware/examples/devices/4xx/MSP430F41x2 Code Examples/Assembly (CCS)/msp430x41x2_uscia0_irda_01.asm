;*******************************************************************************
;   MSP430x41x2 Demo - USCI_A0 IrDA External Loopback Test, 4MHz SMCLK
;
;   Description: This example transmits bytes through the USCI module
;   configured for IrDA mode, and receives them using an external loopback
;   connection. The transfered sequence is 00h, 01h, 02h, ..., ffh. The
;   received bytes are also stored in memory starting at address RxData.
;   In the case of an RX error the LED is lighted and program execution stops.
;   An external loopback connection has been used as it allows for the
;   connection of a scope to monitor the communication, which is not possible
;   when using the internal loopback.
;
;   MCLK = SMCLK = DCO = 4MHz, ACLK = 32kHz
;   //* An external 32kHz XTAL on XIN XOUT is required for ACLK *//
;
;               MSP430x41x2
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-
;            |                 |
;            |          UCA0RXD|--+   external
;            |          UCA0TXD|--+   loopback connection
;            |                 |
;            |                 |
;            |             P5.1|--->  LED
;            |                 |
;
;  P. Thanigai
;  Texas Instruments Inc.
;  January 2009
;  Built with CCE Version: 3.1 
;******************************************************************************
 .cdecls C,LIST, "msp430x41x2.h" 
            .global _main 
;-------------------------------------------------------------------------------
RxData      .usect ".bss",256                     ; Allocate 256 byte of RAM
;-------------------------------------------------------------------------------
			.text							; Program Start
;-------------------------------------------------------------------------------
_main
RESET       mov.w   #0400h,SP               ; Initialize stack pointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP2     bis.b   #BIT5+BIT6,&P6SEL       ; Use P6.5/P6.6 for USCI_A0
SetupP5     bic.b   #BIT1,&P5OUT            ; Clear P5.1
            bis.b   #BIT1,&P5DIR            ; P5.1 output
SetupOSC    mov.b   #121,&SCFQCTL           ; Set FLL to 3.998MHz
            mov.b   #FLLD0+FN_2,&SCFI0      ; Adjust range select
SetupUCA0   bis.b   #UCSWRST,&UCA0CTL1      ; Set USCI_A0 SW Reset
            mov.b   #UCSSEL_2+UCSWRST,&UCA0CTL1
                                            ; Use SMCLK, keep SW reset
            mov.b   #26,&UCA0BR0            ; 4Mhz/26=153.8kHz
            mov.b   #0,&UCA0BR1
            mov.b   #UCBRF_1+UCOS16,&UCA0MCTL
                                            ; Set 1st stage modulator to 1
                                            ; 16-times oversampling mode
            mov.b   #UCIRTXPL2+UCIRTXPL0+UCIRTXCLK+UCIREN,&UCA0IRTCTL
                                            ; Pulse length = 6 half clock cyc
                                            ; Enable BITCLK16, IrDA enc/dec
            bic.b   #UCSWRST,&UCA0CTL1      ; Resume USCI_A0 operation
            bis.b   #UCA0RXIE,&IE2          ; Enable RX int

            clr.w   R4                      ; Init delay counter
            clr.b   R5                      ; TX data and pointer, 8-bit

Mainloop    inc.w   R4                      ; Small delay
            cmp.w   #1000,R4
            jne     Mainloop
            clr.w   R4                      ; Re-init delay counter

TX          bit.b   #UCA0TXIFG,&IFG2        ; USCI_A0 TX buffer ready?
            jnc     TX                      ; Loop if not
            mov.b   R5,&UCA0TXBUF           ; TX character

            dint
            bis.b   #UCA0RXIE,&IE2          ; Enable RX int
            bis.w   #CPUOFF+GIE,SR          ; Enter LPM0, interrupts enabled

            mov.b   R6,RxData(R5)           ; Store RXed character in RAM
            cmp.b   R5,R6                   ; RX OK?
            jeq     RX_OK

RX_ERROR    bis.b   #BIT1,&P5OUT            ; LED P5.1 on
            jmp     $                       ; Trap PC here

RX_OK       inc.b   R5                      ; Next character to TX
            jmp     Mainloop                ; Again
;-------------------------------------------------------------------------------
USCIRX_ISR; Clear UCA0RXIFG interrupt flag and return active
;-------------------------------------------------------------------------------
            mov.b   &UCA0RXBUF,R6           ; Get RXed character
            bic.b   #UCA0RXIE,&IE2          ; Disable RX int
            bic.w   #CPUOFF,0(SP)           ; Return active after receiption
            reti                            ; Return from ISR
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect     ".int09"       		; USCI A0/B0 Receive
            .short   USCIRX_ISR
            .sect    ".reset"          		; POR, ext. Reset
            .short   RESET
            .end
