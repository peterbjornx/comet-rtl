`include "ucodedef.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK
 * FUB:     alkashdec
 * Purpose: Decode ALUSHF micro-op field.
 *          
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, vector-XNORization of
 *          NAND decode terms.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/

module alkashdec(
	input [2:0] alushf_h,
	
	output      op_shf_h, /* was mux_dq2_dq3_l */
	output      op_rot_h,
	output      op_qsi1_l,
	output		op_asi1_l,
	output		op_wbus30_h );
	
	assign op_shf_h    =  &(alushf_h      ^~ 3'b010);
	
	assign op_rot_h    =  &(alushf_h      ^~ 3'b011);
	
	assign op_qsi1_l   = ~&(alushf_h      ^~ 3'b001) &
	                             ~&(alushf_h      ^~ 3'b100);
								 
	assign op_asi1_l   = ~&(alushf_h[1:0] ^~ 2'b_01);
	
	assign op_wbus30_h =  &(alushf_h      ^~ 3'b110);

endmodule