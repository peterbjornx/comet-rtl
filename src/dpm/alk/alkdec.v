`include "ucodedef.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK
 * FUB:     alkdec
 * Purpose: Decode micro-op fields.
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, vector-XNORization of
 *          NAND decode terms.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/

module alkdec(
	input [1:0] dsize_h,
	input [1:0] spw_h,
	input [9:0] alpctl_h,
	input [5:0] rot_h,
	input       long_lit_l,
	input       loop_flag_h,
	
	/* DSIZE decoded signals */
	output      dsize_byte_l,
	
	/* SPW decoded signals */
	output      spwb_h,
	output      spww_h,
	output      spwl_h,
	
	/* MUX decoded signals */
	output      mux_force_cout0_l,
	
	/* DQ decoded signals */
	output      dq_q_noshf_h, /* was mux_dq2_dq3_l */
	output      dq_q_shl_l,
	output      dq_q_shr_l,
	
	/* ALU decoded signals */
	output      alu_x0xx_l,
	output      alu_01xx_h,
	output      alu_0xxx_l,	
	
	output      alu_sub_op_h,
	output      alu_shift_op_l,
	output      alu_shl_op_h,
	output      alu_shr_op_h,
	output      alu_bcd_op_l,
	
	/* ALPCTL decoded signals */
	output      alpctl_shl_op_h,
	output      alpctl_shr_op_h,
	output      alpctl_wb_group_ld,
	output      alpctl_wb_aluf_h,
	output      alpctl_wb_loopf_h,
	output      alpctl_rem_l,
	output      alpctl_mul_l,
	output      alpctl_div_l,
	output      alpctl_divdbl_l,
	output      alpctl_mul_group_h,
	output      alpctl_wx_srot_l,
	output      alpctl_sub_or_logic_l, /* alu_sub_or_logic_l */
	
	output      alushf_force_sout0_h,
	
	output      alushf_dec_shf_h,
	output      alushf_dec_rot_h,
	output      alushf_dec_qsi1_l,
	output		alushf_dec_asi1_l,
	output		alushf_dec_wbus30_h,
	
	output      rot_modsp_l, 
	output      dblclk_h /* was muldiv_fast_l */
	);
	
	wire alu_01xx_l;
	wire dblclk_l;
	assign dblclk_h = ~dblclk_l;
	
	/* Matches DSIZE = BYTE */
	assign dsize_byte_l = ~&(dsize_h ^~ 2'b00);
	
	/* Matches SPW = NOP */
	wire spw_nop_l      = ~( &(                            spw_h ^~ 2'b00 ));
	/* Matches SPW = RSIZE, DSIZE={BYTE,WORD} */
	wire spw_rsize_bw_l = ~( &(dsize_h[1]   ^~ 1'b0_) & &( spw_h ^~ 2'b01 ));
	/* Matches SPW = RSIZE, DSIZE=BYTE */
	wire spw_rsize_b_h  = ~( &(dsize_h[1:0] ^~ 2'b00) & &( spw_h ^~ 2'b01 ));
	
	/* Scratchpad write enable for low 8 bits: inhibited by NOP */
	assign spwb_h =  spw_nop_l;
	/* Scratchpad write enable for mid 8 bits: inhibited by NOP or BYTE RSIZE write */
	assign spww_h =  spw_nop_l & spw_rsize_b_h;
	/* Scratchpad write enable for high 16 bits: inhibited by NOP or BYTE/WORD RSIZE write */
	assign spwl_h =  spw_nop_l & spw_rsize_bw_l;
	
	/* High if mod SP or force cout0 */
	assign alushf_force_sout0_h = ~(mux_force_cout0_l & rot_modsp_l);
	
	alkdqdec dqdec(
		.mux_h         (alpctl_h[9:6]),
		.dq_h          (alpctl_h[1:0]),
		.q_noshf_h     (dq_q_noshf_h),
		.q_shl_l       (dq_q_shl_l),
		.q_shr_l       (dq_q_shr_l) );
	
	alkmuxdec muxdec(
		.mux_h         (alpctl_h[9:6]),
		.long_lit_l    (long_lit_l),
		.force_cout0_l (mux_force_cout0_l) );
	
	alkaludec aludec(
		.alu_h         (alpctl_h[5:2]),
		.long_lit_l    (long_lit_l),
					   
		.alu_x0xx_l    (alu_x0xx_l),
		.alu_01xx_l    (alu_01xx_l),
		.alu_01xx_h    (alu_01xx_h),
		.alu_0xxx_l    (alu_0xxx_l),		
		.sub_op_h      (alu_sub_op_h),
		.shift_op_l    (alu_shift_op_l),
		.shl_op_h      (alu_shl_op_h),
		.shr_op_h      (alu_shr_op_h),
		.bcd_op_l      (alu_bcd_op_l) );
					   
	alkctldec ctldec(  
		.alpctl_h      (alpctl_h),
		.alu_0xxx_l    (alu_0xxx_l),
		.alu_x0xx_l    (alu_x0xx_l),
		.alu_01xx_l    (alu_01xx_l),
		.alu_shl_op_h  (alu_shl_op_h),
		.alu_shr_op_h  (alu_shr_op_h),
		.loop_flag_h   (loop_flag_h),
		.shl_op_h      (alpctl_shl_op_h),
		.shr_op_h      (alpctl_shr_op_h),
		.wb_group_ld   (alpctl_wb_group_ld),
		.wb_aluf_h     (alpctl_wb_aluf_h),
		.wb_loopf_h    (alpctl_wb_loopf_h),
		.muldiv_fast_l (dblclk_l),
		.rem_l         (alpctl_rem_l),
		.mul_l         (alpctl_mul_l),
		.div_l         (alpctl_div_l),
		.divdbl_l      (alpctl_divdbl_l),
		.mul_group_h   (alpctl_mul_group_h),
		.sub_or_logic_l(alpctl_sub_or_logic_l),
		.wx_srot_l     (alpctl_wx_srot_l) );
	
	alkrotdec rotdec(
		.rot_h         (rot_h),
		.modsp_l       (rot_modsp_l) );
		
	alkashdec ashdec(
		.alushf_h      (rot_h[4:2]),
		.op_shf_h      (alushf_dec_shf_h),
		.op_rot_h      (alushf_dec_rot_h),
		.op_qsi1_l     (alushf_dec_qsi1_l),
		.op_asi1_l     (alushf_dec_asi1_l),
		.op_wbus30_h   (alushf_dec_wbus30_h) );
endmodule
	
