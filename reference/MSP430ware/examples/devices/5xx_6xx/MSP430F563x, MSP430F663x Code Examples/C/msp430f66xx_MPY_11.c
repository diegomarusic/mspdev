//******************************************************************************
//  MSP430F66x Demo - 32x32 Signed Multiply Accumalate
//
//  Description: Hardware multiplier is used to multiply-accumalate a set of
//  numbers. The first calculation is automatically initiated after the second
//  operand is loaded. A second multiply-accumulate operation is performed next.
//  Results are stored in RES0, RES1, RES2 and RES3.
//  SUMEXT contains the extended sign of the result.
//
//   ACLK = REFO, MCLK = SMCLK = default DCO
//
//                MSP430F66x
//             -----------------
//         /|\|                 |
//          | |                 |
//          --|RST              |
//            |                 |
//            |                 |
//
//   Priya Thanigai
//   Texas Instruments Inc.
//   Nov 2009
//   Built with IAR Embedded Workbench Version: 4.20 & Code Composer Studio V4.0
//******************************************************************************
#include <msp430f6638.h>

void main(void)
{
  WDTCTL = WDTPW+WDTHOLD;                   // Stop WDT

                                            // unsigned multiply
  MPY32L = 0x1234;                          // Load lower 16 bits of operand 1
  MPY32H = 0x1234;                          // Load upper 16 bits of operand 1

  OP2L = 0x5678;                            // Load lower 16 bits of operand 2
  OP2H = 0x5678;                            // Load upper 16 bits of operand 2
                                            // signed MAC
  MACS32L = 0x1234;                         // Load lower 16 bits of operand 1
  MACS32H = 0x1234;                         // Load upper 16 bits of operand 1

  OP2L = 0x5678;                            // Load lower 16 bits of operand 2
  OP2H = 0x5678;                            // Load upper 16 bits of operand 2
  
  __delay_cycles(10);
  __bis_SR_register(LPM4_bits);             // Enter LPM4
  __no_operation();                         // For debugger
}
