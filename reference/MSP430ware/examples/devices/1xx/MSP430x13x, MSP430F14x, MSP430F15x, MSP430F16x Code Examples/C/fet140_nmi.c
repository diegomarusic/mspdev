//******************************************************************************
//  MSP-FET430P140 Demo - Basic Clock, Configure RST/NMI as NMI
//
//  Description: Configure RST/NMI as NMI, hi/lo edge. Flash P1.0  inside of
//  NMI_ISR if NMI occurs. General enable interrupt in status register does
//  not need to be set for NMI. NMIIE does need to be reset, as NMI_ISR
//  automatically clears NMI enable to prevent unintentional stack overflow
//  that could result from, bounce or uncontrolled NMI's.
//  ACLK = n/a, MCLK = SMCLK = DCO ~ 800k
//
//               MSP430F149
//            -----------------
//        /|\|              XIN|-
//         | |                 |
//         --|RST          XOUT|-
//           |                 |
//
//  M. Buccini
//  Texas Instruments Inc.
//  Feb 2005
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.21A
//******************************************************************************

#include  <msp430x14x.h>

void main(void)
{
  WDTCTL = WDTPW + WDTHOLD + WDTNMI + WDTNMIES;  // WDT off NMI hi/lo
  P1DIR |= 0x01;                            // Set P1.0 to output direction
  P1OUT &= ~0x01;                           // Clear P1.0 LED off
  IE1 |= NMIIE;                             // Enable NMI

  _BIS_SR(LPM0_bits);                       // Enter LPM0
}

#pragma vector=NMI_VECTOR
__interrupt void nmi_ (void)
{
  volatile unsigned int i;
  P1OUT |= 0x01;                            // Set P1.0 LED on
  for (i = 20000; i > 0; i--);              // Delay
  P1OUT &= ~0x01;                           // Clear P1.0 LED off
  IFG1 &= ~NMIIFG;                          // Reclear NMI flag in case bounce

  IE1 |= NMIIE;                             // Enable NMI
}
