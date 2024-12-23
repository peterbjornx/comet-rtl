/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK ( ALU Control )
 * FUB:     alkcout (ALK ALU Carry input generation)
 * Purpose: Provide the ALU carry input
 *          
 *          
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, inlining of PAD receiver
 *          gates as ANDs.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/
 
module alkcout(
	/* MUX field decoded signals */
	input  mux_force_cout0_l,   /* MUX value forces COUT=0 */
		
	/* ROT decode outputs */
	input rot_modsp_l,          /* ROT specifies an op that modifies S or P latch */
	
	/* Internal state machine output */
	input carry_invert_h,
	
	/* ROT.ALUCI microop field */
	input  [1:0] aluci_h,
	
	/* ALPCTL field decode outputs */
	input  alpctl_divdbl_l,
	
	/* ALKC microarchitectural carry flag */
	input  alkc_flag_h, 
	
	/* PSL.C macroarchitectural carry flag */
	input  pslc_flag_h, 
	
	/* COUT pad output  */
	output carry_out_l
	);
	
	/* Force COUT=0 for ROT modifies SP ops or if MUX forces COUT=0 */
	wire force_cout0_h = ~(rot_modsp_l & mux_force_cout0_l);
	wire force_cout0_l = ~force_cout0_h;
	
	/* Carry out multiplexer */
	wire carry_out_h = 
		/* ROT.ALUCI=01 (COUT=ALKC flag) */
		~( alkc_flag_h & force_cout0_l & &(aluci_h[1:0] ^~ 2'b01) ) &
		/* ROT.ALUCI=10 (COUT=1) */
		~( 1'b1        & force_cout0_l & &(aluci_h[1:0] ^~ 2'b10) ) &
		/* ROT.ALUCI=11 (COUT=PSL<C>) */
		~( pslc_flag_h & force_cout0_l & &(aluci_h[1:0] ^~ 2'b11) ) &
		/* ALPCTL=DIVDBL (COUT=ALKC flag) */
		~( alkc_flag_h & ~alpctl_divdbl_l );

	/* Selectable carry invert XOR */
	wire carry_makelow_h = ~(carry_invert_h & carry_out_h);
	assign carry_out_l =
		~(carry_invert_h & carry_makelow_h) &
		~(carry_out_h & carry_makelow_h);
		
endmodule