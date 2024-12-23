`include "chipmacros.vh"

module alpaludec(
	input  [3:0] alu_h,
	input        pg_in_h,
	
	/* ALPCTL controls */
	input        dmove_h,
	input        pass_a_h,
	
	/* Decode outputs */
	output       bcd_op_l,
	output [4:0] wmux_onehot_h,
	output       shl_en_h,
	output       shr_en_h );
	
	wire wmux_bcda_en_h, wmux_amux_en_h, 
		 wmux_aluq_en_h;
	
// Opcode predecodes

	//ALU BCD operation signal
	// Matches ALU = 0x01 ( SUB_BCD, ADD_BCD )
	assign bcd_op_l =
		~&( {alu_h[3],alu_h[1:0]} ^~ 3'b0_01 );
		
	wire bcd_op_h = ~bcd_op_l;
	
		
// W Mux decode
	
	//Inhibit if Matches ALU = xx00 or ALU = 1x0x
	//Thus matches shift/bcd ops, andnot ops
	wire aluop_shiftbcd_h = 
		(~&(  alu_h[1:0]         ^~ 2'b__00 )) & // Inhibit if SUB,SUB_BA,ADD,AND,OR,XOR
		(~&( {alu_h[3],alu_h[1]} ^~ 2'b1_0_ ));  
		
	//Matches ALU = 11xx ( bank without shift/bcd modifiers )
	wire aluop_11xx_l =
		~&( alu_h[3:2] ^~ 2'b11__ );
	
	//Matches ALU = ADD_BCD only when CELL_06_15_OUT and not DMOVE
	wire aluop_addbcd_C_l =
		~&{ ~dmove_h, bcd_op_h, ~pg_in_h,  alu_h[2] };

	//Matches ALU = SUB_BCD only when PAD_G_L_OUT    and not DMOVE
	wire aluop_subbcd_C_l =
		~&{ ~dmove_h, bcd_op_h,  pg_in_h, ~alu_h[2] };

	//ALU->WMUX decode
	// Inhibit if shifted
	// Inhibit if ADD_BCD and not CELL_06_15_OUT
	// Inhibit if SUB_BCD and not PAD_G_L_OUT
	assign wmux_aluq_en_h =
		~&{ aluop_11xx_l, aluop_shiftbcd_h, aluop_addbcd_C_l, aluop_subbcd_C_l };
		
	//Enable A Shift Left
	// Matches SUB_SL, ADD_SL, AND_SL
	assign shl_en_h = 
		&{ aluop_11xx_l, alu_h[1:0] ^~ 2'b__11 };
	
	//Matches 2{6,7}{A,B,E,F}
	wire  CELL_02_00_OUT = 
		~&{ pass_a_h, alu_h[3] };
	
	//Enable A Shift Right
	// Matches SUB_SR, ADD_SR. AND_SR (ALU=__10, ALU!=11__ )
	// Inhibited by 26{A,B} 1001 1010 1_ MUX=MUX_D_R2, ALU=AND_SR, DQ={2,3}
	//   Which may be part of the multiply ALK outputs
	assign shr_en_h =
		&{ aluop_11xx_l, alu_h[1:0] ^~ 2'b__10, CELL_02_00_OUT };


	// Enable A->W if data move ALPCTL
	assign wmux_amux_en_h =
		dmove_h;
		
	//Enable BCD Adjust
	// Match BCD ops
	// Inhibit if ALU = ADD_BCD and CELL_06_15_OUT
	// Inhibit if ALU = SUB_BCD and PAD_G_L_OUT
	assign wmux_bcda_en_h = 
		(~bcd_op_l) &
		(~&{ alu_h[2] ^~ 1'b_0__,  pg_in_h }) &
		(~&{ alu_h[2] ^~ 1'b_1__, ~pg_in_h });
		
	assign wmux_onehot_h = {
		wmux_bcda_en_h, wmux_amux_en_h, 
		shr_en_h, shl_en_h, wmux_aluq_en_h };

endmodule

