`include "chipmacros.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK ( ALU Control )
 * FUB:     alkaluf (ALK ALUSO / ALUF flag)
 * Purpose: ALUF flag used in MUL/DIV operations
 *          
 *          
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, D flip flop lifted.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/
 
module alkaluf(

	/* Clocks */
	input qdclk_l, /* was qdclk_l_b */

	/* ALU field decoded signals */
	input alu_shift_op_l,       /* ALU op specifies A shift left or right */
	
	/* ALPCTL field decoded signals */
	input alpctl_shl_op_h,      /* ALPCTL op specifies A shift left */
	input alpctl_shr_op_h,      /* ALPCTL op specifies A shift right */
	input alpctl_divdbl_l,
	input alpctl_mul_group_h,
	
	/* Shift inputs (from ALU shifter routing) */
	input  alu_sout_shl_h,
	input  alu_sout_shr_h,
	
	output aluso_flag_h );
	
	reg aluso_ff_q_h;
	
	/* ALUSO input mux */
	wire aluso_ff_d_l = 
		~(aluso_ff_q_h   & ~alpctl_mul_group_h & alu_shift_op_l    ) &
		~(aluso_ff_q_h   & ~alpctl_divdbl_l                       ) &
		~(alu_sout_shl_h &  alpctl_divdbl_l    & alpctl_shl_op_h   ) &
		~(alu_sout_shr_h &                       alpctl_shr_op_h   );
	
	wire aluso_ff_d_h = ~aluso_ff_d_l;
	
	/* Clock ALUF on negative edge of QDCLK */
	`FF_P( qdclk_l, aluso_ff_d_h, aluso_ff_q_h )
	
	assign aluso_flag_h = aluso_ff_q_h;
	
endmodule