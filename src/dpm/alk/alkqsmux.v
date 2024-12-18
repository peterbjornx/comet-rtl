/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK ( ALU Control )
 * FUB:     alkqsmux (ALK Q Shift In Multiplexer)
 * Purpose: Provide the Q register shift input.
 *          
 *          Depending on the micro-op fields this FUB will route any
 *          of the following signals onto Q shift input:
 *          
 *           Signal            | Condition
 *          -------------------+---------------------------------
 *           alu_sout_shl_h    | ALUSHF:Rotate, ALU:*.SL    
 *           alu_sout_shr_h    | ALUSHF:Rotate, ALU:*.SR    , DQ: Q SR
 *           q_sout_shl_h      | ALUSHF:Rotate, ALU:no shift, DQ: Q SL  
 *           q_sout_shr_h      | ALUSHF:Rotate, ALU:no shift, DQ: Q SR 
 *           alu_sout_shr_h    | ALUSHF:Shift , ALU:*.SL 
 *           WBUS[31]          | ALUSHF:Shift , ALU:no shift
 *           Constant 1        | ALUSHF: Force 1 
 *           c32_in_h          | ALPCTL specifies divide or remainder
 *           alu_sout_shr_h    | ALPCTL specifies multiply, LOOPF set     
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
 
module alkqsmux(	
	/* DQ field decode outputs */
	input dq_q_shl_h,           /* DQ field specifies Q shift left  */
	input dq_q_shr_h,           /* DQ field specifies Q shift right */
	
	/* ALUSHF field decode outputs */
	input alushf_dec_qsi1_l,    /* ALUSHF dictates 1 -> Q shift in  */
	input alushf_dec_shf_h,     /* ALUSHF decodes to shift func     */
	input alushf_dec_rot_h,     /* ALUSHF decodes to rotate func    */
	
	/* ALPCTL field decode outputs */
	input alpctl_mul_l,         /* ALPCTL specifies one of the MULtiply ops */
	input alpctl_mul_group_h,   /* ALPCTL specifies a special op in the MUL group */
	
	/* ALU field decode outputs */
	input alu_shift_op_l,       /* ALU op specifies A shift left or right */
	input alu_shl_op_h,         /* ALU op specifies A shift left */
	input alu_shr_op_h,         /* ALU op specifies A shift right */
	
	/* ALU Carry In */
	input  c32_in_h,
	
	/* Loop flag */
	input  loopf_h, /* was loopf_q_l_b */
	
	/* WBUS */
	input  [31] wbus_in_h,
	
	/* Pre-gated WBUS[30]/PSLC */
	input  aq_sin_pslc_wb30_l,
	
	/* Shift inputs (from ALU shifter routing) */
	input  alu_sout_shl_h,
	input  alu_sout_shr_h,
	
	/* Shift inputs (from Q shifter routing) */
	input  q_sout_shl_h,
	input  q_sout_shr_h,
	
	/* Shift output (to Q shifter routing) */
	output q_sin_h );
	
	wire   q_sin_a_l = 
	      /* Rotate, ALU SL      : ALU SIO[31]   -> Q SHIFT IN */
	      ~(alu_sout_shl_h & alushf_dec_rot_h & alu_shl_op_h ) &
		  /* Shift,  ALU SR, Q SR: ALU SIO[0]    -> Q SHIFT IN */
		  ~(alu_sout_shr_h & alushf_dec_shf_h & alu_shr_op_h & dq_q_shr_h ) &
		  /* ALUSHF              : 1             -> Q SHIFT IN */
		  ~( 1'b1          & alushf_dec_qsi1_l );

	wire   q_sin_b_l =
		  /* Divide or remainder:  Carry[32]     -> Q SHIFT IN */
		  ~(c32_in_h       &  alpctl_mul_l & alpctl_mul_group_h ) &
		  /* Multiply, LOOPF=1:    ALU SIO[0]    -> Q SHIFT IN */
		  ~(alu_sout_shr_h & ~alpctl_mul_l & loopf_h ) &
		  /* Rotate, ALU SR:       ALU SIO[0]    -> Q SHIFT IN */
		  ~(alu_sout_shr_h & alushf_dec_rot_h & alu_shr_op_h );
		  
	      /* Shift, no ALU shift:  WBUS[31]      -> Q SHIFT IN */
	wire q_sin_wb31_gate_l = ~( alu_shift_op_l & alushf_dec_shf_h );
	wire q_sin_wb31_gate_h = ~q_sin_wb31_gate_l;
	
	/* Pad logic for WBUS[31] plus two NANDS */
	wire   q_sin_noalu_l = 
	      /* Shift, no ALU shift:  WBUS[31]      -> Q SHIFT IN */
		  ~(wbus_in_h[31] & q_sin_wb31_gate_h) &
		  /* Rotate, no ALU, Q SR: Q SIO[0]      -> Q SHIFT IN */
		  ~(q_sout_shr_h & alushf_dec_rot_h & alu_shift_op_l & dq_q_shr_h) &
		  /* Rotate, no ALU, Q SL: Q SIO[SIZE-1] -> Q SHIFT IN */
		  ~(q_sout_shl_h & alushf_dec_rot_h & alu_shift_op_l & dq_q_shl_h);
	
	/* Combine the different terms */
	assign q_sin_h = 
		(~q_sin_a_l) |
		(~q_sin_b_l) |
		(~q_sin_noalu_l) |
		/* PSLC flag gated by ROT = 111xx */
		/* WBUS[30]  gated by ROT = 110xx */
		(~aq_sin_pslc_wb30_l) ;

endmodule