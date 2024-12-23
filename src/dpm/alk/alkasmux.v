/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK ( ALU Control )
 * FUB:     alkasmux (ALK ALU Shift In Multiplexer)
 * Purpose: Provide the ALU output shift input.
 *          
 *          Depending on the micro-op fields this FUB will route any
 *          of the following signals onto ALU shift input:
 *                    
 *           Signal            | Condition
 *          -------------------+---------------------------------
 *           alu_sout_shl_h    | ALUSHF:Rotate, ALU:*.SL      DQ: No Q
 *           alu_sout_shr_h    | ALUSHF:Rotate, ALU:*.SR    , DQ: No Q
 *           q_sout_shl_h      | ALUSHF:Rotate,               DQ: Q SL  
 *           q_sout_shr_h      | ALUSHF:Rotate,               DQ: Q SR 
 *           q_sout_shl_h      | ALUSHF:Shift ,               DQ: Q not shift right
 *           q_sout_shr_h      | ALUSHF:Shift , ALU:*.SL      DQ: Q SR
 *           Constant 0        | ALUSHF: Force 0 
 *           Constant 1        | ALUSHF: Force 1 
 *           c32_in_h          | ALPCTL specifies MUL+, LOOPF set
 *           q_sout_shl_h      | ALPCTL specifies DIV
 *           ALUSO flag        | ALPCTL specifies DIVD* or REM
 *           PSL.C             | ALUSHF specifies PSL.C
 *           WBUS[30]          | ALUSHF specifies WBUS[30]
 *
 *          For more information consult doc/alkrot.txt
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, inlining of PAD receiver
 *          gates as ANDs.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/
 
module alkasmux(
	
	/* ROT.ALUSHF microop field */
	input  [2:0] alushf_h,
	
	/* MUX field decoded signals */
	input  dq_dq1_h, /* was dq_dq2_dq3_l (apply DQ1 map for DQ field) */
	
	/* DQ field decode outputs */
	input dq_q_shl_l,           /* DQ field specifies Q shift left  */
	input dq_q_shr_l,           /* DQ field specifies Q shift right */
	
	/* ALU field decode outputs */
	input alu_shl_op_h,
	input alu_shr_op_h,
	input alu_x0xx_l,

	/* ALUSHF field decode outputs */
	input alushf_force_sout0_h, /* ALUSHF dictates 0 -> A shift in  */
	input alushf_dec_asi1_l,    /* ALUSHF dictates 1 -> A shift in  */
	input alushf_dec_shf_h,     /* ALUSHF decodes to shift func     */
	input alushf_dec_rot_h,     /* ALUSHF decodes to rotate func    */
	input alushf_dec_wbus30_h,  /* ALUSHF specifies WBUS[30] shift in */
	
	/* ALPCTL field decode outputs */
	input  alpctl_divdbl_l,
	input  alpctl_mul_l,
	input  alpctl_div_l,
	input  alpctl_rem_l,
	
	/* ALU Carry In */
	input  c32_in_h,
	
	/* Loop flag */
	input  loopf_h, /* was loopf_q_l_b */
	
	/* ALUSO / ALUF flag */
	input  aluso_h, /* was aluso_ff_q_h */
	
	/* PSL.C macroarchitectural carry flag */
	input  pslc_flag_h, 
	
	/* WBUS */
	input  wb30_in_h,
	
	/* Pre-gated WBUS[30]/PSLC */
	output aq_sin_pslc_wb30_l,
	
	/* Shift inputs (from ALU shifter routing) */
	input  alu_sout_shl_h,
	input  alu_sout_shr_h,
	
	/* Shift inputs (from Q shifter routing) */
	input  q_sout_shl_h,
	input  q_sout_shr_h,
	
	/* Shift output (to Q shifter routing) */
	output alu_sin_h );
	
	/* EEK: this does not match the CPU TD document */
	wire asin_mux_aluso_gate_h = ~alpctl_divdbl_l | ~alpctl_rem_l;
	
	wire alu_sin_l_a = 
		/* Multiply +, LOOPF=1 :    Carry[32]     -> A SHIFT IN */
		 ~(c32_in_h       &  ~alpctl_mul_l & alu_x0xx_l & loopf_h ) &
		/* Divide              :    Q SIO[SIZE-1] -> A SHIFT IN */
		 ~(q_sout_shl_h   &  ~alpctl_div_l        ) &
		/* DIVDBL or REM       :    ALUSO         -> A SHIFT IN */
		 ~(aluso_h        &  asin_mux_aluso_gate_h) &
		/* Rotate, ALU SL, No Q: ALU SIO[31]      -> A SHIFT IN */
		 ~(alu_sout_shl_h &  alushf_dec_rot_h & alu_shl_op_h & dq_dq1_h );
		 
	wire alu_sin_l_b = 
		/* Shift , ALU   , Q nR: Q SIO[SIZE-1]   -> A SHIFT IN */
		 ~(q_sout_shl_h   &  alushf_dec_shf_h &  dq_q_shr_l ) &
		/* Rotate, ALU   , Q SL: Q SIO[SIZE-1]   -> A SHIFT IN */
		 ~(q_sout_shl_h   &  alushf_dec_rot_h & ~dq_q_shl_l ) &
		/* ALUSHF              : 1               -> A SHIFT IN */
		~( 1'b1           & ~alushf_dec_asi1_l);
		 
	wire alu_sin_l_c = 
		/* Shift , ALU SL, Q SR : Q SIO[0]       -> A SHIFT IN */
		 ~(q_sout_shr_h   &  alushf_dec_shf_h & ~dq_q_shr_l & alu_shl_op_h ) &
		/* Rotate,         Q SR : Q SIO[0]       -> A SHIFT IN */
		 ~(q_sout_shr_h   &  alushf_dec_rot_h & ~dq_q_shr_l ) &
		/* Rotate, ALU SR, No Q : ALU SIO[0]     -> A SHIFT IN */
		~( alu_sout_shr_h &  alushf_dec_rot_h &  dq_dq1_h   & alu_shr_op_h  );

	wire aq_sin_pslc_l = ~(pslc_flag_h & (alushf_h ^~ 3'b111));
	
	/* Merged in WBUS[30] pad logic */
	assign aq_sin_pslc_wb30_l = ~(
		/* ALUSHF:PSLC          : PSL.C          -> A,Q SHIFT IN */
		~aq_sin_pslc_l | 
		/* ALUSHF:WB30          : WBUS[30]       -> A,Q SHIFT IN */
		(wb30_in_h & alushf_dec_wbus30_h));

	/* Combine partial mux outputs and apply forced zero if needed */
	assign alu_sin_h =
		  (~alushf_force_sout0_h &
			( ~alu_sin_l_a |
			  ~alu_sin_l_b |
			  ~alu_sin_l_c |
			  ~aq_sin_pslc_wb30_l));
endmodule