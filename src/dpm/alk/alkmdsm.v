`include "chipmacros.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK ( ALU Control )
 * FUB:     alkmdsm (Multiply/Divide state machine / ALKCTL op gen)
 * Purpose: Generates ALKCTL opcode driven to ALU bitslices and
 *          implements multiply/divide state machine.
 *
 *          The LOOP flag allows ALK to implement a set-up cycle for
 *          the multiply / divide state machine. It is cleared when
 *          not in a multiply/divide op, and gets set upon the first
 *          negative edge on QDCLK during a multiply or divide.
 *          
 *          The LOOP flag behaves as follows:
 *            operation     |  next value of LOOP (falling QDCLK)
 *           ---------------+--------------------
 *            LOOPF->WBUS[] | no change
 *            MUL* , DIV*   | set   (goto LOOP)
 *            DIVD*, others | reset (goto SETUP)
 *          
 *          Output ALKOP generation for multiply and divide:
 *           Fast/Slow bit gets masked off so all decode as FAST, it is
 *           routed onto DBL output instead.
 *
 *           ALPCTL         | Cycle |TOG| ALKCTL | ALU  | MUX  | DQ 
 *          ----------------+-------+---+--------+------+------+----------
 *           MULFAST+ (279) | SETUP |   |  26B   |bypass| D.R2 | SQR.D_WX
 *                          | LOOP  | 1 |  259   |ADD.SR| D.R2 | SQR.D_WX
 *                          | LOOP  | 0 |  25B   |bypass| D.R2 | SQR.D_WX
 *          ----------------+-------+---+--------+------+------+----------
 *           MULFAST- (269) | SETUP |   |  26B   |bypass| D.R2 | SQR.D_WX
 *                          | LOOP  | 1 |  249   |SUB.SR| D.R2 | SQR.D_WX
 *                          | LOOP  | 0 |  24B   |bypass| D.R2 | SQR.D_WX
 *          ----------------+-------+---+--------+------+------+----------
 *           DIVFAST+ (26C) | SETUP |   |  24C   |SUB.SR| D.R2 | SQL.D_WX
 *                          | LOOP  | 1 |  24C   |SUB.SR| D.R2 | SQL.D_WX
 *                          | LOOP  | 0 |  25C   |ADD.SR| D.R2 | SQL.D_WX
 *          ----------------+-------+---+--------+------+------+----------
 *           DIVFAST- (27C) | SETUP |   |  25C   |ADD.SR| D.R2 | SQL.D_WX
 *                          | LOOP  | 1 |  24C   |SUB.SR| D.R2 | SQL.D_WX
 *                          | LOOP  | 0 |  25C   |ADD.SR| D.R2 | SQL.D_WX
 *
 *          For these operations TOG gets loaded as follows:
 *
 *           ALPCTL         | Next TOG value
 *          ----------------+-----------------
 *           MULFAST+ (279) | q_sout_shr_h
 *           MULFAST- (269) | q_sout_shr_h
 *           DIVFAST+ (26C) | c32_in_h
 *           DIVFAST- (27C) | c32_in_l
 *
 *          Output ALKOP generation for the other micro-ops
 *
 *           ALPCTL           | ALKCTL | ALU  | MUX  | DQ 
 *          ------------------+--------+------+------+----------
 *           REM        (26A) |  20A   |SUB.SL| D.R1 | D_WX
 *           DIVDA      (27F) |  25C   |ADD.SR| D.R2 | SQL.D_WX
 *           DIVDS      (26F) |  24C   |SUB.SR| D.R2 | SQL.D_WX
 *           WX_*_S     (37x) |  35x   | ADD  | D.R2 | 
 *           WX_*_NOT_S (36x) |  34x   | SUB  | D.R2 | 
 *           
 *
 * Changes: merge of wire-ANDed gates, D flip flop lifted.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/
 
module alkmdsm(

	/* Clocks */
	input qdclk_l, /* was qdclk_l_a */
	input alu_0xxx_l,         /* ALU bit 3 was 0, and was valid  (alpctl_h[5] derived)*/
	input alu_x0xx_l,         /* ALU bit 2 was 0, and was valid was alu_x0xx_l_b */
	
	/* ALPCTL field decoded signals */
	input alpctl_wb_loopf_h,  /* ALPCTL op is LOOPF readback */
	input alpctl_mul_l,       /* ALPCTL op is MUL* , was alpctl_mul_h_b */
	input alpctl_div_l,       /* ALPCTL op is DIV* (not DIVD* or REM)  */
	input alpctl_rem_l,       /* ALPCTL op is REM  */
	input alpctl_divdbl_l,    /* ALPCTL op is DIVD* */
	input alpctl_wx_srot_l,   /* ALPCTL is wx_srot */
	input alpctl_sub_or_logic_l,
	
	/* Carry input from ALU */
	input c32_in_h,

	/* Shift out from Q register */
	input q_sout_shr_h,

	/* ALPCTL input bits */
	input  [6:0] alpctl_h,
	
	/* ALKCTL output bits */
	output [1:0] alkop_10_h,
	output [6:4] alkop_64_h,
	
	/* Loop flag */
	output loop_flag_h,

	/* Carry inversion */
	output carry_invert_h);
	
	reg tog_flag_h = 1'b0;
	reg loopf_q_h = 1'b0;
	
	/********************************************************/
	/* Loop flag register - Selects SETUP/LOOP cycles       */
	/********************************************************/
	
	/* alpctl_muldiv_h */
	wire is_mul_div_h = ~(alpctl_mul_l & alpctl_div_l);
	
	wire loopf_d_l = ~( loopf_q_h & alpctl_wb_loopf_h ) &
	                 ~( 1'b1      & is_mul_div_h      );
					 
	wire loopf_d_h = ~loopf_d_l;
	
	`FF_P( qdclk_l, loopf_d_h, loopf_q_h )
	
	assign loop_flag_h = loopf_q_h;
	
	/* Low when DIV and LOOP */
	wire div_loop_cycle_l  = ~(~alpctl_div_l &  loopf_q_h); // preset_a_h
	wire mul_loop_cycle_l  = ~(~alpctl_mul_l &  loopf_q_h); // preset_b_h
	wire mul_setup_cycle_l = ~(~alpctl_mul_l & ~loopf_q_h);
	wire div_setup_cycle_l = ~(~alpctl_div_l & ~loopf_q_h);
	
	/********************************************************/
	/* Toggle flag register                                 */
	/********************************************************/
	
	/* These were unkf preset a and b ( merged ) */
	
	/* Toggle flag input mux */
	wire togf_d_h      =  
		(~c32_in_h    & ~alpctl_div_l &  alu_x0xx_l  ) |
		( c32_in_h    & ~alpctl_div_l & ~alpctl_h[4] ) |
		(q_sout_shr_h & ~alpctl_mul_l );
	
	/* Preset toggle flag whenever we're not inside the mul/div loop
	 * that means: current op is not mul/div, or current cycle is set-up */
	wire togf_preset_h = div_loop_cycle_l & mul_loop_cycle_l;
	
	/* not bug-exact. behavior in half cycle after clocking in 0 differs */
	`FF_PRESET_P( qdclk_l, togf_preset_h, togf_d_h, tog_flag_h )
	
	/* carry output inversion */
	assign carry_invert_h = 
		~(  alpctl_sub_or_logic_l                      ) & // CELL_06_04_INV
		~(  alu_x0xx_l & ~alpctl_mul_l                 ) & // CELL_06_06_NAND
		~(  alu_x0xx_l & ~div_setup_cycle_l            ) & // CELL_09_08_NAND
		~(  alu_x0xx_l & ~loopf_q_h & ~alpctl_divdbl_l ) & // CELL_09_08_NAND
		~( ~tog_flag_h & ~div_loop_cycle_l             );  // CELL_03_09_NAND
	
	/********************************************************/
	/* ALKOP generation                                     */
	/********************************************************/
	
	wire [1:0] alkop_pt_10_h;
	wire [6:4] alkop_pt_64_h;
	
	/* ALKOP mux ( passthrough part ) */
	assign alkop_pt_10_h[0] = alpctl_h[0] & alpctl_divdbl_l;
	assign alkop_pt_10_h[1] = alpctl_h[1] & alpctl_divdbl_l    & alpctl_mul_l & alpctl_div_l;
	assign alkop_pt_64_h[4] = alu_x0xx_l  & mul_setup_cycle_l  & div_loop_cycle_l  ;
	assign alkop_pt_64_h[5] = alu_0xxx_l  & alpctl_divdbl_l    & alpctl_div_l & alpctl_rem_l & mul_loop_cycle_l & alpctl_wx_srot_l; 
	assign alkop_pt_64_h[6] = alpctl_h[6] & alpctl_rem_l;
	
	/* ALKOP mux ( override part ), lifted from pad logic */
	assign alkop_10_h[0] = alkop_pt_10_h[0] ;
	/* ALKOP[1] gets forced high if we're in MUL loop and TOG is set */
	assign alkop_10_h[1] = alkop_pt_10_h[1] | 
	                       (~tog_flag_h  & ~mul_loop_cycle_l ) |
						   ~mul_setup_cycle_l;
	/* ALKOP[4] gets forced high if we're in DIV loop and TOG is set */
	assign alkop_64_h[4] = alkop_pt_64_h[4] | (~tog_flag_h & ~div_loop_cycle_l);
	assign alkop_64_h[5] = alkop_pt_64_h[5] ;
	assign alkop_64_h[6] = alkop_pt_64_h[6] ;
	
endmodule