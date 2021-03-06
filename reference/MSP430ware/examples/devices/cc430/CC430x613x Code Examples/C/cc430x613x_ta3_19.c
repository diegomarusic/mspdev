//*******************************************************************************
//  CC430F613x Demo - Timer_A3, PWM TA1.1-2, Up/Down Mode, DCO SMCLK
//
//  Description: This program generates two PWM outputs on P2.2,3 using
//  Timer1_A configured for up/down mode. The value in CCR0, 128, defines the
//  PWM period/2 and the values in CCR1 and CCR2 the PWM duty cycles. Using
//  ~1.045MHz SMCLK as TACLK, the timer period is ~233us with a 75% duty cycle
//  on P2.0 and 25% on P2.2.
//  SMCLK = MCLK = TACLK = default DCO ~1.045MHz.
//
//                CC430F6137
//            -------------------
//        /|\|                   |
//         | |                   |
//         --|RST                |
//           |                   |
//           |         P2.0/TA1.1|--> CCR1 - 75% PWM
//           |         P2.2/TA1.2|--> CCR2 - 25% PWM
//
//   M Morales
//   Texas Instruments Inc.
//   April 2009
//   Built with CCE Version: 3.2.2 and IAR Embedded Workbench Version: 4.11B
//******************************************************************************

#include "cc430x613x.h"

void main(void)
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT

  PMAPPWD = 0x02D52;                        // Get write-access to port mapping regs  
  P2MAP0 = PM_TA1CCR1A;                     // Map TA1CCR1 output to P2.0 
  P2MAP2 = PM_TA1CCR2A;                     // Map TA1CCR2 output to P2.2 
  PMAPPWD = 0;                              // Lock port mapping registers 
  
  P2DIR |= BIT0 + BIT2;                     // P2.0 and P2.2 output
  P2SEL |= BIT0 + BIT2;                     // P2.0 and P2.2 options select

  TA1CCR0 = 128;                            // PWM Period/2
  TA1CCTL1 = OUTMOD_6;                      // CCR1 toggle/set
  TA1CCR1 = 32;                             // CCR1 PWM duty cycle
  TA1CCTL2 = OUTMOD_6;                      // CCR2 toggle/set
  TA1CCR2 = 96;                             // CCR2 PWM duty cycle
  TA1CTL = TASSEL_2 + MC_3 + TACLR;         // SMCLK, up-down mode, clear TAR

  __bis_SR_register(LPM0_bits);             // Enter LPM0
  __no_operation();                         // For debugger
}

