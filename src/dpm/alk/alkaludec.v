`include "ucodedef.vh"

/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK
 * FUB:     alkaludec
 * Purpose: Decode ALU micro-op field.
 *          
 *          Provides signals indicating ALU operations, provided no
 *          ALPCTL special function applies.
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals, vector-XNORization of
 *          NAND decode terms.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/

module alkaludec(
	input [3:0] alu_h,
	input       long_lit_l, /* was long_lit_ld */
	
	/* ALU bits gated on LONG_LIT */
	output      alu_x0xx_l,
	output      alu_01xx_l,
	output      alu_01xx_h,
	output      alu_0xxx_l,	
	
	output      sub_op_h,
	output      shift_op_l,
	output      shl_op_h,
	output      shr_op_h,
	output      bcd_op_l );
		
	assign alu_x0xx_l     = ~( long_lit_l & ~alu_h[2]);
	assign alu_01xx_l     = ~( long_lit_l & &(alu_h[3:2] ^~ 2'b01__));
	assign alu_01xx_h     = ~alu_01xx_l;
	assign alu_0xxx_l     = ~( long_lit_l & ~alu_h[3]);
	wire   alu_11xx_l     = ~(~long_lit_l | &(alu_h[3:2] ^~ 2'b11__));
	wire   alu_0x0x_l     = ~( long_lit_l & ~alu_h[3] & ~alu_h[1]);
	
	/* Matches subtract (regular and reversed operands) even when forced by long_lit */
	wire       sub_op_l   = ~( long_lit_l & &(alu_h[3:2] ^~ 2'b00__)) &
	                        ~( long_lit_l & &(alu_h[3:0] ^~ 4'b1100)) &
	                        ~(~long_lit_l | &(alu_h[1:0] ^~ 4'b__00));
	assign     sub_op_h   = ~sub_op_l;
	
	/* Matches ALU=001x,011x,101x (*.SL, *.SR) (predicated on not LONG_LIT) */
	assign     shift_op_l = ~(alu_11xx_l  &  (alu_h[1]   ^~ 1'b__1_));
	
	/* Matches ALU=0011,0111,1011 (*.SL) (predicated on not LONG_LIT) */
	assign     shl_op_h   = (alu_11xx_l  & &(alu_h[1:0] ^~ 1'b__11));
	
	/* Matches ALU=0010,0110,1010 (*.SR) (predicated on not LONG_LIT) */
	assign     shr_op_h   = (alu_11xx_l  & &(alu_h[1:0] ^~ 1'b__10));
	
	/* Matches ALU=0x01 (*.BCD) (predicated on not LONG_LIT) */
	assign     bcd_op_l   = ~&(~alu_0x0x_l & alu_h[0]);

endmodule