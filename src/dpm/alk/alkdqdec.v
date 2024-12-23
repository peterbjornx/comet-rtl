`include "ucodedef.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK
 * FUB:     alkdqdec
 * Purpose: Decode DQ micro-op field.
 *          
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, vector-XNORization of
 *          NAND decode terms.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/

module alkdqdec(
	input [3:0] mux_h,
	input [1:0] dq_h,
	
	output      q_noshf_h, /* was mux_dq2_dq3_l */
	output      q_shl_l,
	output      q_shr_l );
	
	wire   dq1_h     = &({mux_h[2], mux_h[0]} ^~ 2'b_0_1);
	
	/* MUX=1,3,9,B (DQ2 or DQ3) */
	assign q_noshf_h = ~dq1_h;

	assign q_shl_l = ~( dq1_h & ~dq_h[0] );
	assign q_shr_l = ~( dq1_h &  dq_h[0] );
	
endmodule

