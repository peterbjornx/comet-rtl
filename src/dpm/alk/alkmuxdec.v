`include "ucodedef.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK
 * FUB:     alkmuxdec
 * Purpose: Decode MUX micro-op field.
 *          
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, vector-XNORization of
 *          NAND decode terms.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/

module alkmuxdec(
	input [3:0] mux_h,
	input       long_lit_l, /* was long_lit_ld */
	
	/*  */
	output      force_cout0_l /* MUX forces carry output to 0 */
	);
	
	wire mux_0x0x_l =  ~&({mux_h[3], mux_h[1]} ^~ 2'b0_0_);
	
	assign force_cout0_l = long_lit_l & 
		/* Match ALPCTL.MUX=1111,0111,1101 (F,D,7) */
		~(mux_0x0x_l &  &({mux_h[2], mux_h[0]} ^~ 2'b_1_1) ) &
		/* Match ALPCTL.MUX=1100,0100      (4,C)   */
		~(              &( mux_h[2:0]          ^~ 3'b_100) );
		
endmodule