`include "chipmacros.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK ( ALU Control )
 * FUB:     alkcflag (ALKC flag)
 * Purpose: Microarchitectural carry flag
 *
 *          The ALKC flag allows microcode and the mul/div state 
 *          machine to perform carry without clobbering the PSL.C
 *          (VAX architectural) carry flag.
 *          
 *          The ALKC is loaded using the following values:
 *            source           |  operation
 *           ------------------+--------------------
 *            !ALU carry out   | Subtract
 *            ALU carry out    | Add
 *            ALU[0] shift out | Multiply
 *            unchanged        | <otherwise>
 *
 * Changes: merge of wire-ANDed gates, merge of _h/_l versions of 
 *          control signals, D flip flop lifted.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/
 
module alkcflag(

	/* Clocks */
	input qdclk_l,              /* was qdclk_l_b */
	
	/* Micro-op decodes */
	input long_lit_l,           /* Current micro-op is long literal format */
	
	/* ALU field decoded signals */
	input alu_sub_op_h,         /* ALU encodes SUB instruction */
	input alu_01xx_h,           /* ALU encodes ADD instruction */
	
	/* ALPCTL field decoded signals */
	input alpctl_wx_srot_l,     /* ALPCTL op is WX SROT? */
	input alpctl_mul_l,         /* ALPCTL op is MUL or DIV but not DIVD or REM */
	
	input c32_in_h,
	input alu_sout_shr_h,
	
	output alkc_flag_h );
	
	reg alkc_ff_q_h = 1'b0;
	
	/* Matches valid SUBtract ops, excluding overlapping encodings */
	wire   is_sub_op_l = 
			~(                 alu_sub_op_h & alpctl_wx_srot_l & long_lit_l   );

	/* ALKC input mux */
	wire   cmux_out_l = 
	        ~(~c32_in_h      & alu_sub_op_h & alpctl_wx_srot_l & long_lit_l   ) &
	        ~( c32_in_h      & alu_01xx_h                ) &
	        ~(alkc_ff_q_h    & alpctl_mul_l & ~alu_01xx_h      & is_sub_op_l  ) &
	        ~(alu_sout_shr_h & ~alpctl_mul_l             );
	

	wire   cmux_out_h  = ~cmux_out_l;
	wire   alkc_ff_d_h = ~(~cmux_out_h);

	`FF_P( qdclk_l, alkc_ff_d_h, alkc_ff_q_h )
	
	assign alkc_flag_h = alkc_ff_q_h;

endmodule