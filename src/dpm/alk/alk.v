module dc615_alk( // @suppress "Design unit name 'dc615_alk' does not match file name 'alk'"
	/* -----    Clocks     ----- */
	
	/* QD Clock? */
	input            qdck_l,
	
	/* ----- Control signals ----- */
	
	/* Opcode */
	input      [9:0] alpctl_h,
	
	/* Rotate */
	input      [5:0] rot_h,
	
	/* Data Size */
	input      [1:0] dsize_h,
	
	input      [1:0] spw_h,
	
	input            pslc_h,
	input            llit_l,
	
	/* Carry input */
	input            c31_h,
	
	/* Shift in-out */
	
	/* ----- ALU Shifter ----- */
	/* From perspective of ALP */
	
	/* Shift input  for bit 31 (SHR) */
	output          a_si31_l,
	/* Shift output for bit 31 (SHL) */
	input           a_so31_l,
	/* Shift output for bit 0  (SHR) */
	input           a_so0_l, 
	/* Shift input  for bit 0  (SHL) */
	output          a_si0_l,
	
	/* ----- Q Shifter ----- */
	/* From perspective of ALP */
	
	/* Shift input  for bit 31 (SHR) */
	output          q_si31_l,
	/* Shift output for bit 31 (SHL) */
	input           q_so31_l,
	/* Shift input  for bit 15 (SHR) */
	output          q_si15_l,
	/* Shift output for bit 15 (SHL) */
	input           q_so15_l,
	/* Shift input  for bit 7 (SHR) */
	output          q_si7_l,
	/* Shift output for bit 7  (SHL) */
	input           q_so7_l,
	/* Shift output for bit 0  (SHR) */
	input           q_so0_l, 
	/* Shift input  for bit 0  (SHL) */
	output          q_si0_l,
	
	/* BCD */
	output           bcd_l,
	
	/* Byte */
	output           byte_l,
	
	/* Scratchpad writes */
	output           spwb_en_h,
	output           spww_en_h,
	output           spwl_en_h,
	
	/* Double enable */
	output           dbl_h,
	
	/* ALK Opcode */
	output   [6:4]   alk_op_64_h,
	output   [1:0]   alk_op_10_h,
	
	/* WBUS */
	input    [31:30] wbus_h,
	output   [31:30] wbus_h_out,
	
	/* Carry out */
	output           cout_l );
	
	wire c32_in_h = c31_h;
	
	wire loop_flag_h, aluso_flag_h, alkc_flag_h;
	
	wire q_sin_h, q_sout_shl_h, q_sout_shr_h;	
	wire alu_sin_h, alu_sout_shl_h, alu_sout_shr_h;
	
	/* control signals */
	wire dq_q_noshf_h, dq_q_shl_l, dq_q_shr_l;
	wire alushf_force_sout0_h, mux_force_cout0_l;
	wire alpctl_mul_l, alpctl_div_l, alpctl_rem_l;
	wire alpctl_divdbl_l, alu_sub_op_h ,rot_modsp_l;
	wire alushf_dec_qsi1_l, alushf_dec_shf_h, alushf_dec_rot_h;
	wire alushf_dec_asi1_l, alushf_dec_wbus30_h;
	wire alpctl_mul_group_h,alpctl_wx_srot_l;
	wire alpctl_shl_op_h, alpctl_shr_op_h;
	wire alu_01xx_h,alu_x0xx_l,alu_0xxx_l;
	wire alpctl_sub_or_logic_l,alpctl_wb_loopf_h;
	wire alpctl_wb_group_ld,alpctl_wb_aluf_h;
	wire alu_shift_op_l, alu_shl_op_h, alu_shr_op_h;

	alkdec decoder(
		.dsize_h    (dsize_h),
		.spw_h      (spw_h),
		.alpctl_h   (alpctl_h),
		.rot_h      (rot_h),
		.loop_flag_h(loop_flag_h),	
		.long_lit_l (llit_l),
	
		.mux_force_cout0_l(mux_force_cout0_l),
		
		/* DSIZE decoded signals */
		.dsize_byte_l(byte_l),
	
		/* SPW decoded signals */
		.spwb_h(spwb_en_h),
		.spww_h(spww_en_h),
		.spwl_h(spwl_en_h),
	
		/* DQ decoded signals */
		.dq_q_noshf_h(dq_q_noshf_h), /* was mux_dq2_dq3_l */
		.dq_q_shl_l(dq_q_shl_l),
		.dq_q_shr_l(dq_q_shr_l),
	
		/* ALU decoded signals */
		.alu_x0xx_l(alu_x0xx_l),
		.alu_01xx_h(alu_01xx_h),
		.alu_0xxx_l(alu_0xxx_l),	
	
		.alu_shift_op_l(alu_shift_op_l),
		.alu_shl_op_h(alu_shl_op_h),    
		.alu_shr_op_h(alu_shr_op_h),    
		.alu_sub_op_h(alu_sub_op_h),
		.alu_bcd_op_l(bcd_l),
	
		/* ALPCTL decoded signals */
		.alushf_force_sout0_h(alushf_force_sout0_h),
		.alpctl_divdbl_l(alpctl_divdbl_l),
		.alpctl_mul_l(alpctl_mul_l),
		.alpctl_div_l(alpctl_div_l),
		.alpctl_rem_l(alpctl_rem_l),
		.alpctl_mul_group_h(alpctl_mul_group_h),
		.alpctl_wx_srot_l(alpctl_wx_srot_l),
		
		.alpctl_shl_op_h(alpctl_shl_op_h),
		.alpctl_shr_op_h(alpctl_shr_op_h),
		.alpctl_wb_group_ld(alpctl_wb_group_ld),
		.alpctl_wb_aluf_h(alpctl_wb_aluf_h),
		.alpctl_wb_loopf_h(alpctl_wb_loopf_h),
		.alpctl_sub_or_logic_l(alpctl_sub_or_logic_l), /* alu_sub_or_logic_l */
	
	
		.alushf_dec_qsi1_l(alushf_dec_qsi1_l),
		.alushf_dec_shf_h(alushf_dec_shf_h),  
		.alushf_dec_rot_h(alushf_dec_rot_h),  
		.alushf_dec_asi1_l(alushf_dec_asi1_l),
		.alushf_dec_wbus30_h(alushf_dec_wbus30_h),
	
		.rot_modsp_l(rot_modsp_l), 
		.dblclk_h(dbl_h) /* was muldiv_fast_l */
	);
	
	alkasio a_sio_routing(
		/* Control signals */
		.alpctl_shl_op_h(alpctl_shl_op_h),
		.alpctl_shr_op_h(alpctl_shr_op_h),

		/* Shift input (from ALU shift mux) */
		.alu_sin_h      (alu_sin_h),
	
		/* Shift outputs (to muxes) */
		.alu_sout_shl_h (alu_sout_shl_h),
		.alu_sout_shr_h (alu_sout_shr_h),
	
		/* ALU_SIO[] pad inputs */
		.alu_sio0_in_l  (a_so0_l),
		.alu_sio31_in_l (a_so31_l),
	
		/* ALU_SIO[] pad outputs ( open drain ) */
		.alu_sio0_out_l (a_si0_l),
		.alu_sio31_out_l(a_si31_l) );
	
	alkqsio q_sio_routing(
		/* Control signals */
		.dsize_h( dsize_h ),
		.dq_q_shl_l(dq_q_shl_l),
		.dq_q_shr_l(dq_q_shr_l),
		.alushf_force_sout0_h(alushf_force_sout0_h),
		.alpctl_divdbl_l(alpctl_divdbl_l),
		.alpctl_mul_l(alpctl_mul_l),
		.alpctl_div_l(alpctl_div_l),
		.alpctl_rem_l(alpctl_rem_l),
	
		/* Shift input (from Q shift mux) */
		.q_sin_h(q_sin_h),
	
		/* Shift outputs (to muxes) */
		.q_sout_shl_h(q_sout_shl_h),
		.q_sout_shr_h(q_sout_shr_h),
	
		/* Q_SIO_L[] pad inputs ( polarity = pad polarity ) */
		.q_sio0_in_l (q_so0_l),
		.q_sio7_in_l (q_so7_l),
		.q_sio15_in_l(q_so15_l),
		.q_sio31_in_l(q_so31_l),
	
		/* Q_SIO_L[] pad outputs ( open drain, polarity = pad polarity ) */
		.q_sio0_out_l (q_si0_l),
		.q_sio7_out_l (q_si7_l),
		.q_sio15_out_l(q_si15_l),
		.q_sio31_out_l(q_si31_l) );
	
	wire aq_sin_pslc_wb30_l;
	
	alkasmux alu_sio_mux(
	
		/* ROT.ALUSHF microop field */
		.alushf_h     (rot_h[4:2]),
		
		/* MUX field decoded signals */
		.dq_dq1_h(dq_q_noshf_h),
		.dq_q_shl_l(dq_q_shl_l),
		.dq_q_shr_l(dq_q_shr_l),
		.alushf_dec_asi1_l(alushf_dec_asi1_l),
		.alushf_dec_shf_h(alushf_dec_shf_h),  
		.alushf_dec_rot_h(alushf_dec_rot_h),  
		.alushf_force_sout0_h(alushf_force_sout0_h),
		.alushf_dec_wbus30_h(alushf_dec_wbus30_h),
		.alu_x0xx_l(alu_x0xx_l),
		.alu_shl_op_h(alu_shl_op_h),    
		.alu_shr_op_h(alu_shr_op_h),    
		
		/* ALPCTL field decode outputs */
		.alpctl_divdbl_l(alpctl_divdbl_l),
		.alpctl_mul_l(alpctl_mul_l),
		.alpctl_div_l(alpctl_div_l),
		.alpctl_rem_l(alpctl_rem_l),
		
		/* ALU Carry In */
		.c32_in_h(c32_in_h),
		
		/* Loop flag */
		.loopf_h(loop_flag_h),
		
		/* ALUSO / ALUF flag */
		.aluso_h(aluso_flag_h),
		
		/* PSL.C macroarchitectural carry flag */
		.pslc_flag_h(pslc_h), 
		
		/* WBUS */
		.wb30_in_h(wbus_h[30]),
		
		/* Pre-gated WBUS[30]/PSLC */
		.aq_sin_pslc_wb30_l(aq_sin_pslc_wb30_l),
	
		/* Shift inputs (from ALU shifter routing) */
		.alu_sout_shl_h(alu_sout_shl_h),
		.alu_sout_shr_h(alu_sout_shr_h),
	
		/* Shift inputs (from Q shifter routing) */
		.q_sout_shl_h(q_sout_shl_h),
		.q_sout_shr_h(q_sout_shr_h),
		
		/* Shift output (to Q shifter routing) */
		.alu_sin_h(alu_sin_h) );
	
	alkqsmux q_sio_mux(	
		/* Control signals */
		.dq_q_shl_l(dq_q_shl_l),
		.dq_q_shr_l(dq_q_shr_l),
		.alushf_dec_qsi1_l(alushf_dec_qsi1_l),
		.alushf_dec_shf_h(alushf_dec_shf_h),  
		.alushf_dec_rot_h(alushf_dec_rot_h),  
		.alpctl_mul_l(alpctl_mul_l),
		.alpctl_mul_group_h(alpctl_mul_group_h),
		.alu_shift_op_l(alu_shift_op_l),
		.alu_shl_op_h(alu_shl_op_h),    
		.alu_shr_op_h(alu_shl_op_h),    
	
		/* ALU Carry In */
		.c32_in_h(c32_in_h),
	
		/* Loop flag */
		.loopf_h(loop_flag_h),
	
		/* WBUS */
		.wb31_in_h(wbus_h[31]),
	
		/* Pre-gated WBUS[30]/PSLC */
		.aq_sin_pslc_wb30_l(aq_sin_pslc_wb30_l),
	
		/* Shift inputs (from ALU shifter routing) */
		.alu_sout_shl_h(alu_sout_shl_h),
		.alu_sout_shr_h(alu_sout_shr_h),
	
		/* Shift inputs (from Q shifter routing) */
		.q_sout_shl_h(q_sout_shl_h),
		.q_sout_shr_h(q_sout_shr_h),
	
		/* Shift output (to Q shifter routing) */
		.q_sin_h( q_sin_h ) );

	alkaluf alu_flag(
		/* Clocks */
		.qdclk_l(qdck_l), /* was qdclk_l_b */

		/* Control signals */
		.alu_shift_op_l(alu_shift_op_l),
		.alpctl_shl_op_h(alpctl_shl_op_h),
		.alpctl_shr_op_h(alpctl_shr_op_h),
		.alpctl_divdbl_l(alpctl_divdbl_l),
		.alpctl_mul_group_h(alpctl_mul_group_h),
	
		/* Shift inputs (from ALU shifter routing) */
		.alu_sout_shl_h(alu_sout_shl_h),
		.alu_sout_shr_h(alu_sout_shr_h),
		
		.aluso_flag_h(aluso_flag_h) );

	alkcflag alkc_flag(
		/* Clocks */
		.qdclk_l(qdck_l), /* was qdclk_l_b */
	
		/* Control signals */
		.long_lit_l(llit_l),
		.alu_sub_op_h(alu_sub_op_h),
		.alu_01xx_h(alu_01xx_h),
		.alpctl_wx_srot_l(alpctl_wx_srot_l),
		.alpctl_mul_l(alpctl_mul_l),
		
		/* Carry input from ALU */
		.c32_in_h(c32_in_h),
		
		/* Shift input (from ALU shifter routing) */
		.alu_sout_shr_h(alu_sout_shr_h),
	
		.alkc_flag_h(alkc_flag_h) );
	
	wire carry_invert_h;
	
	alkcout cout_mux (
		/* Control signals */
		.mux_force_cout0_l(mux_force_cout0_l),
		.rot_modsp_l(rot_modsp_l),          
		.alpctl_divdbl_l(alpctl_divdbl_l),
		.aluci_h(rot_h[1:0]),
	
		/* Internal state machine output */
		.carry_invert_h(carry_invert_h),
	
		/* ALKC microarchitectural carry flag */
		.alkc_flag_h(alkc_flag_h), 
	
		/* PSL.C macroarchitectural carry flag */
		.pslc_flag_h(pslc_h), 
	
		/* COUT pad output  */
		.carry_out_l(cout_l) );
		
	
	alkmdsm mul_div_statemachine(
		/* Clocks */
		.qdclk_l(qdck_l), /* was qdclk_l_a */

		/* Control signals */
		.alpctl_h(alpctl_h),
		.alu_0xxx_l(alu_0xxx_l),
		.alu_x0xx_l(alu_x0xx_l),
		.alpctl_divdbl_l(alpctl_divdbl_l),
		.alpctl_wx_srot_l(alpctl_wx_srot_l),
		.alpctl_mul_l(alpctl_mul_l),
		.alpctl_div_l(alpctl_div_l),
		.alpctl_rem_l(alpctl_rem_l),
		.alpctl_wb_loopf_h(alpctl_wb_loopf_h),
		.alpctl_sub_or_logic_l(alpctl_sub_or_logic_l),
		
		/* ALKCTL output bits */
		.alkop_10_h(alk_op_10_h),
		.alkop_64_h(alk_op_64_h),

		.c32_in_h(c31_h),
		.q_sout_shr_h(q_sout_shr_h),
	
		/* Loop flag */
		.loop_flag_h(loop_flag_h),

		/* Carry inversion */
		.carry_invert_h(carry_invert_h) );
		
		
	alkwmux wbus_mux(
		/* Control signals */
		.alpctl_wb_group_ld(alpctl_wb_group_ld),
		.alpctl_wb_loopf_h(alpctl_wb_loopf_h),
		.alpctl_wb_aluf_h(alpctl_wb_aluf_h),
		
		/* WBUS */
		.wbus_out_h(wbus_h_out),
		
		/* Internal flag inputs */
		.alkc_flag_h(alkc_flag_h),
		.aluso_flag_h(aluso_flag_h),
		.loop_flag_h(loop_flag_h) );
		
endmodule