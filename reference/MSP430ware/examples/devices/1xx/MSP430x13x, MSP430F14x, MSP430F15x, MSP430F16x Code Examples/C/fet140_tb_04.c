//******************************************************************************
//  MSP-FET430P140 Demo - Timer_B, Toggle P1.0, Overflow ISR, 32kHz ACLK
//
//  Description: Toggle P1.0 using software and the Timer_B overflow ISR.
//  In this example an ISR triggers when TB overflows. Inside the ISR P1.0
//  is toggled. Toggle rate is exactly 0.5Hz. Proper use of the TBIV
//  interrupt vector generator is demonstrated.
//  ACLK = TBCLK = 32kHz, MCLK = SMCLK = default DCO ~800kHz
//  //* An external watch crystal on XIN XOUT is required for ACLK *//	
//
//           MSP430F149
//         ---------------
//     /|\|            XIN|-
//      | |               | 32kHz
//      --|RST        XOUT|-
//        |               |
//        |           P1.0|-->LED
//
//  M. Buccini
//  Texas Instruments Inc.
//  Feb 2005
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.21A
//******************************************************************************

#include  <msp430x14x.h>

void main(void)
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  P1DIR |= 0x01;                            // Set P1.0 to output direction
  TBCTL = TBSSEL_1 + MC_2 + TBIE;           // ACLK, contmode, interrupt

  _BIS_SR(LPM3_bits + GIE);                 // Enter LPM3 w/ interrupt
}

// Timer_B7 Interrupt Vector (TBIV) handler
#pragma vector=TIMERB1_VECTOR
__interrupt void Timer_B(void)
{
 switch( TBIV )
 {
   case  2: break;                          // CCR1 not used
   case  4: break;                          // CCR2 not used
   case 14: P1OUT ^= 0x01;                  // overflow
           break;
  }
}

