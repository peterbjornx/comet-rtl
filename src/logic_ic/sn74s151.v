/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   ---
 * Chip:    SN74S151
 * FUB:     ---
 * Purpose: Eight to one multiplexer
 *
 * Changes: Behavioral description, no timing model attempted.
 *
 * Author:  Peter Bosch ( based on Texas Instrument datasheet )
 ********************************************************************/

module sn74s151 (
    /* Data inputs */
    input [7:0] D,
    /* Select input (active high) */
    input [2:0] SEL,
    /* Strobe / enable input (active low) */
    input       nEN,
    /* Normal output */
    output      B,
    /* Inverted output */
    output      nB);

    wire b_h;

    assign b_h = D[SEL] & ~nEN;

    assign B  =  b_h;
    assign nB = ~b_h;

endmodule