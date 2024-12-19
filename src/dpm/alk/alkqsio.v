`include "ucodedef.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK
 * FUB:     alkqsio (ALK Q Shift In/Out routing)
 * Purpose: Route Q_SIO[] pins from/to shift in and shift out lines.
 *          
 *          Both left and right shift provide the bit to be shifted
 *          into Q via q_sin_h. The q_sout_shl_h, q_sout_shr_h lines
 *          carry the bit shifted out of Q to the multiplexers for 
 *          left, right shifts, respectively.
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, vector-XNORization of
 *          NAND decode terms, inlining of PAD receiver gates as ANDs.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/
 
module alkqsio(
	/* DSIZE field */
	input [1:0] dsize_l,
	
	/* DQ field decode outputs */
	input  dq_q_shl_h,
	input  dq_q_shr_h,
	
	/* ALUSHF field decode outputs */
	input  alushf_force_sout0_l, /* ALUSHF dictates 0 -> shift out  */
	
	/* ALPCTL field decode outputs */
	input  alpctl_div_divdbl_l,
	input  alpctl_divdbl_l,
	input  alpctl_mul_l,
	input  alpctl_div_h_b,
	input  alpctl_div_h,
	
	/* Shift input (from Q shift mux) */
	input  q_sin_h,
	
	/* Shift outputs (to muxes) */
	output q_sout_shl_h,
	output q_sout_shr_h,
	
	/* Q_SIO[] pad inputs */
	input  q_sio0_in_l,
	input  q_sio7_in_l,
	input  q_sio15_in_l,
	input  q_sio31_in_l,
	
	/* Q_SIO[] pad outputs ( open drain, 1 means pull down ) */
	output q_sio0_out_l,
	output q_sio7_out_l,
	output q_sio15_out_l,
	output q_sio31_out_l );
	
	// dsize_h / dsize_l was replaced by ^~ comparison!
	
	/* Input enable generation for Q_SIO[7]  */
	/* Matches DSIZE = 10 when div_h_b is high */
	wire q_shl8_en_l  = ~( alpctl_div_h_b & &(dsize_h[1:0] ^~ 2'b00) );
	wire q_shl8_en_h  = ~q_shl8_en_l;
	
	/* Input enable generation for Q_SIO[15] */
	/* Matches DSIZE = 00 when div_h_b is high */
	wire q_shl16_en_l = ~( alpctl_div_h_b & &(dsize_h[1:0] ^~ 2'b10) );
	wire q_shl16_en_h = ~q_shl8_en_l;
	
	/* Input enable generation for Q_SIO[31] */
	/* Matches DSIZE = 1x when div_h is high */
	/* Also active when div_h is low !!! */
	wire q_shl32_en_l = ~( alpctl_div_h & dsize_h[1] );
	wire q_shl32_en_h = (~q_shl8_en_l) | (~alpctl_div_h); /* DeMorgan applied */

	/* Output enable generation for Q_SIO[0] */
	wire CELL_15_06_OUT = ~( dq_q_shl_h & alushf_force_sout0_l & alpctl_rem_l );
	wire q_shl_en_h   = ~(CELL_15_06_OUT & alpctl_div_divdbl_l)

	/* Output enable generation for Q_SIO[7] */
	wire q_shr8_en_l  = ~(~alpctl_mul_l  & &(dsize_h[1:0] ^~ 2'b00) );
	wire q_shr8_en_h  = ~q_shr8_en_l;

	/* Output enable generation for Q_SIO[15] */
	wire q_shr16_en_l = ~(~alpctl_mul_l & &(dsize_h[1:0] ^~ 2'b10) );
	wire q_shr16_en_h = ~q_shr16_en_l;

	/* Output enable generation for Q_SIO[31] */
	/* Behaviour:
	      MUL:
		      When DSIZE=1x
	      Not MUL:
		      When Q SHR selected in DQ 
			  Inhibited by ALPCTL=>DIVDBL
			  Inhibited by ALUSHF=>Force SOUT0 
	*/
	// Changed mul_h into ~mul_l
	wire q_shr32_en_l = ~((~alpctl_mul_l & dsize_h[1] ) | 
	                      ( alpctl_mul_l & dq_q_shr_h & alushf_force_sout0_l & alpctl_divdbl_l ));
	wire q_shr32_en_h = ~q_shr32_en_l;
	
	/* Pad output logic for Q_SIO[31,15,7] */
	/* Effectively this drives q_sin_h onto the correct Q_SIO */
	assign q_sio0_out_l  = q_sin_h & q_shl_en_h  ; /* SHL  , sin->Q[0]  */
	assign q_sio7_out_l  = q_sin_h & q_shr8_en_h ; /* SHR8 , sin->Q[7]  */
	assign q_sio15_out_l = q_sin_h & q_shr16_en_h; /* SHR16, sin->Q[15] */
	assign q_sio31_out_l = q_sin_h & q_shr32_en_h; /* SHR32, sin->Q[31] */
	
	
	/* Pad wire-and logic for Q_SIO[31,15,7] */
	/* Effectively this muxes the correct Q_SIO onto q_sout_shl_h */
	assign q_sout_shl_h = ~( q_sio7_in_l  & q_shl8_en_h) &
	                      ~( q_sio15_in_l & q_shl16_en_h) &
	                      ~( q_sio31_in_l & q_shl32_en_h);
	
	assign q_sout_shr_h = ~  q_sio0_in_l;

endmodule