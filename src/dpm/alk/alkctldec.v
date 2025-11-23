`include "ucodedef.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK
 * FUB:     alkctldec
 * Purpose: Decode ALPCTL micro-op field.
 *          
 *          Provides signals indicating ALPCTL special operations
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, vector-XNORization of
 *          NAND decode terms.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/

module alkctldec(
	input [9:0] alpctl_h,
	input       alu_0xxx_l,
	input       alu_x0xx_l,
	input       alu_01xx_l,
	input       alu_shl_op_h,
	input       alu_shr_op_h,
	input       loop_flag_h,
	output      shl_op_h,
	output      shr_op_h,
	output      wb_group_ld,
	output      wb_aluf_h,
	output      wb_loopf_h,
	output      muldiv_fast_l, /* M/D FAST LOOP cycle */
	output      rem_l,
	output      mul_l,
	output      div_l,
	output      divdbl_l,
	output      mul_group_h,
	output      sub_or_logic_l, /* alu_sub_or_logic_l */
	output      wx_srot_l );
	
	/*********************************************************************/
	/* Flag readout group decodes                                        */
	/*********************************************************************/
	
	/* Matches ALPCTL=1101_111x_xx ( 37{8-F} UC_ALPCTL_WB_*) */
	wire   wb_group_l  = 
	   ~(alu_0xxx_l & alu_x0xx_l & &( {alpctl_h[9:6], alpctl_h[3]} ^~ 5'b1101__1___) );
	wire   wb_group_h  = ~wb_group_l;	
	assign wb_group_ld = ~wb_group_h;
	
	/* Matches ALPCTL=UC_ALPCTL_WB_ALUF_* */
	assign wb_aluf_h  = wb_group_h & alpctl_h[2];
	
	/* Matches ALPCTL=UC_ALPCTL_WB_LOOPF_* */
	assign wb_loopf_h = wb_group_h & ~alpctl_h[2];
	
	/*********************************************************************/
	/* Fast multiply / divide decode                                     */
	/*********************************************************************/
	wire   dbl_pg_h = 
	    /* Inhibit if ALPCTL=xxxx_xxx1_x1 */
		~( &({alpctl_h[2],alpctl_h[0]} ^~ 2'b_______1_1)) &
		/* Inhibit if ALPCTL=xxxx_xxx0_x0 */
		~( &({alpctl_h[2],alpctl_h[0]} ^~ 2'b_______0_0)) &
        /* Inhibit if ALPCTL=xxx0_xxxx_xx */
		~( &alpctl_h[6]);
		
	/* Match ALPCTL=1001_1x1y_0y AND loop flag: */
    /* ALPCTL=1001 1011 00(26C), 1001 1111 00 (27C),
              1001 1010 01(269), 1001 1110 01 (279) */
	/* Thus, matches 2{6,7}{9,C} = {MUL,DIV}FAST{P,N} loop cycles */
	assign muldiv_fast_l =
		~(dbl_pg_h & alu_0xxx_l & loop_flag_h &
		&({alpctl_h[9:7],alpctl_h[3],alpctl_h[1]} ^~ 5'b100___1_1_));
	
	/*********************************************************************/
	/* Multiply / divide / remainder group decodes                       */
	/*********************************************************************/
	 
	/*  */
	wire alpctl_1001_1x1x_xx_h =
	        (alu_0xxx_l & &( {alpctl_h[9:6], alpctl_h[3]} ^~ 5'b1001__1___) );
	
	/* Matches ALPCTL=1001_1010_10 ( 26A UC_ALPCTL_REM ) */
	assign rem_l =
		~(alpctl_1001_1x1x_xx_h & 
		&({alpctl_h[4],alpctl_h[2:0]} ^~ 4'b_____0_010));
		
	/* Matches ALPCTL=1001_1x11_x0 ( 2{6,7}{C,E} UC_ALPCTL_DIV{FAST,SLOW}{N,P}) */
	assign div_l =
		~(alpctl_1001_1x1x_xx_h & 
		&({alpctl_h[2],alpctl_h[0]}   ^~ 2'b_______1_0));
		
	/* Matches ALPCTL=1001_1x10_x1 ( 2{6,7}{9,B} UC_ALPCTL_MUL{FAST,SLOW}{N,P}) */
	assign mul_l =
		~(alpctl_1001_1x1x_xx_h & 
		&({alpctl_h[2],alpctl_h[0]}   ^~ 2'b_______0_1));
	
	/* Matches ALPCTL=1001_1x11_11 ( 2{6,7}F     UC_ALPCTL_DIVD{A,S}) */
	assign divdbl_l =
		~(alpctl_1001_1x1x_xx_h & 
		&(alpctl_h[2:0]   ^~ 3'b_______111));
	
	/* Matches the MUL,DIV,DIVD,REM instructions */
	assign mul_group_h = ~(mul_l & divdbl_l & div_l & rem_l);

	/* Matches ALPCTL=1101_1x00_xx ( 3{6,7}{0,1,2,3}, ALPCTL_WX_*_S ) */
	assign wx_srot_l =
	        ~(alu_0xxx_l & &( {alpctl_h[9:6], alpctl_h[3:2]} ^~ 6'b1101__00_) );
			
	/* 
	# Inhibited by ALU=01xx (ADD)
	# Inhibited by ALPCTL=1101_1x00_xx ( 3{6,7}{0,1,2,3}, ALPCTL_WX_*_S )
	# ALU matches: 11xx, 10xx, 00xx
	*/
	assign sub_or_logic_l = ~&( alu_01xx_l & wx_srot_l );
	
	/* Match shift left ops, including DIV, DIVD ops */
	assign shl_op_h = alu_shl_op_h | ~divdbl_l | ~div_l;

	/* Match shift right ops, including MUL ops */
	assign shr_op_h = alu_shr_op_h | ~mul_l;

endmodule