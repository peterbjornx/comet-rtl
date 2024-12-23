`include "ucodedef.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK
 * FUB:     alkrotdec
 * Purpose: Decode ROT micro-op field.
 *          
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, vector-XNORization of
 *          NAND decode terms.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/

module alkrotdec(
	input [5:0] rot_h,	
	output      modsp_l );
	
	wire rot_1xxxx1_h = rot_h[5] & rot_h[0];
	
	/* Matches ROT={27,2D,2F,3B,3D,3F} (functions that modify the S or P latch) */
	assign modsp_l = 
		/* Match ROT=1x11x1 ({2,3}{D,F}) */
		~( rot_1xxxx1_h & &(  rot_h[3:2]           ^~ 2'b__11__) ) &
		/* Match ROT=111_11 (3{B,F}) */
		~( rot_1xxxx1_h & &( {rot_h[4:3],rot_h[1]} ^~ 3'b_11_1_)) &
		/* Match ROT=10_111 (2{7,F}) */
		~( rot_1xxxx1_h & &( {rot_h[4],rot_h[2:1]} ^~ 3'b_0_11_));

endmodule