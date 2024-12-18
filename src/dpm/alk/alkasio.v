`include "ucodedef.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK
 * FUB:     alkasio (ALK ALU Shift In/Out routing)
 * Purpose: Route ALU_SIO[] pins from/to shift in and shift out lines.
 *          
 *          Both left and right shift provide the bit to be shifted
 *          into ALU output via alu_sin_h. The alu_sout_shl_h,
 *          alu_sout_shr_h lines carry the bit shifted out of the ALU
 *          output to the multiplexers for left, right shifts.
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, vector-XNORization of
 *          NAND decode terms, inlining of PAD receiver gates as ANDs.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/
 
module alkasio(

	/* Decoded signals from ALU field */
	input  alu_shl_en_h,
	input  alu_shr_en_h,

	/* Shift input (from ALU shift mux) */
	input  alu_sin_h,
	
	/* Shift outputs (to muxes) */
	output alu_sout_shl_h,
	output alu_sout_shr_h,
	
	/* ALU_SIO[] pad inputs */
	input  alu_sio0_in_l,
	input  alu_sio31_in_l,
	
	/* ALU_SIO[] pad outputs ( open drain, 1 means pull down ) */
	output alu_sio0_out_l,
	output alu_sio31_out_l

)
	/* Pad output logic for ALU_SIO[31,0] */
	/* Effectively this drives q_sin_h onto the correct ALU_SIO */
	assign alu_sio0_out_l  = alu_sin_h & alu_shl_en_h; /* SHR, sin->ALU[0]  */
	assign alu_sio31_out_l = alu_sin_h & alu_shr_en_h; /* SHL, sin->ALU[31] */
	
	/* Shift input for SHR */
	assign alu_sout_shr_h  = ~alu_sio31_in_l;
	
	/* Shift input for SHL */
	assign alu_sout_shl_h  = ~alu_sio0_in_l;
	
endmodule