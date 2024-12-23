`include "chipmacros.vh"

module alpaluctl(
	input [3:0]  alu_h,
	input        bcd_op_l,
	input        pass_a_h,
	
	/* Global controls */
	output       carry_dis_h,
	output       bcd_add_h,
	
	/* X stage controls */
	output       xctl_nA_nB,
	output       xctl_nA_pB,
	output       xctl_pA_nB,
	output       xctl_pA_pB,
	
	/* Z stage controls */
	output       zctl_nA_pB,
	output       zctl_pA_nB,
	output       zctl_pA_pB );

// ALU control
	wire   CELL_02_11_OUT =
		`NAND( alu_h[1:0] ^~ 2'b__00 ); // SUB, ADD, AND, SUB_BA

	// Inhibited by AND, NOTAND, SUB_*, AND_SR, AND_SL
	// Thus match: ADD_*, OR, XOR, ANDNOT
	assign xctl_pA_nB =
		`NAND( {alu_h[3], alu_h[1:0]} ^~ 3'b1_00 ) & // AND, SUB_BA
		`NAND(  alu_h[3:2]            ^~ 2'b00__ ) & // SUB, SUB_BCD, SUB_SL, SUB_SR
		`NAND( {alu_h[2], alu_h[0]}   ^~ 2'b_0_0 ) & // AND, SUB, AND_SR, SUB_SR
		`NAND( {alu_h[3], alu_h[1:0]} ^~ 3'b1_11 );  // NOTAND, AND_SL
		
	// Inhibited by AND, ANDNOT, SUB_*, AND_SR, AND_SL
	// Thus match: ADD_*, OR, XOR, NOTAND
	assign xctl_nA_pB =
		`NAND( {alu_h[3], alu_h[0]  } ^~ 2'b1__0 ) & // AND, AND_SR, SUB_BA, ANDNOT
		`NAND(            alu_h[2:1]  ^~ 2'b_01_ ) & // SUB_SL, SUB_SR, AND_SL, AND_SR
		`NAND(  alu_h[3:2]            ^~ 2'b00__ );  // SUB, SUB_BCD, SUB_SL, SUB_SR
	
	// Inhibited by AND, OR, AND_SL, AND_SR, ADD_*, XOR, ANDNOT, NOTAND
	// Thus match: SUB, SUB_BCD, SUB_SL, SUB_SR, SUB_BA
	assign xctl_nA_nB =
		`NAND(   alu_h[3:2]            ^~ 2'b10__ ) &                // AND,OR,AND_SL,AND_SR
		`NAND(   alu_h[3:2]            ^~ 2'b01__ ) &                // ADD_*
		`NAND( { alu_h[2]              ^~ 1'b_1__, CELL_02_11_OUT }); // ADD_BCD, ADD_SL, ADD_SR, NOTAND, ANDNOT, XOR
	
	// Inhibited by ADD_*, XOR, ANDNOT, NOTAND
	// Thus match: SUB, SUB_BCD, SUB_SL, SUB_SR, SUB_BA, AND, OR, AND_SL, AND_SR
	assign xctl_pA_pB =
		`NAND(   alu_h[3:2]            ^~ 2'b01__ ) &                  // ADD_*
		`NAND( { alu_h[2]              ^~ 1'b_1__, CELL_02_11_OUT } ); // ADD_BCD, ADD_SL, ADD_SR, NOTAND, ANDNOT, XOR

	// Matches: bitwise, SUB_BA
	assign zctl_pA_pB = 
		   (~alu_h[3]) & 
		     alu_h[2];
	
	// Matches: ADD_*, SUB, SUB_SL, SUB_SR, SUB_BCD
	assign zctl_nA_pB =
		    alu_h[3];
	
	// Matches: SUB, SUB_SL, SUB_SR, SUB_BCD, 
	// AND, OR,     AND_SL, AND_SR
	assign zctl_pA_nB =
		~   alu_h[2];
		
	// Matches: AND, XOR, OR, AND_SL, AND_SR, ANDNOT, NOTAND
	assign carry_dis_h =
		`NAND( {            alu_h[2:0] ^~ 3'b_100 } ) & // SUB_BA, 
		`NAND( {~pass_a_h,  alu_h[3]   ^~ 1'b0___ } );  // SUB_*, ADD_*

	// Matches ADD_BCD
	assign bcd_add_h =
		(~bcd_op_l) & ~alu_h[2];

endmodule