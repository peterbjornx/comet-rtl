`include "alpmacros.vh"

module alpalum(
	/* Data buses */
	input      [3:0] amux_h,
	input      [3:0] bmux_h,
	output reg [3:0] wmux_l,
	
	/* Flag signals */
	input        carry_in_h,
	input        pg_in_h,
	output       g_out_ctl,
	output       g_out_in1,
	output       g_out_in2,
	output       p_out_ctl,
	output       p_out_in1,
	output       p_out_in2,
	output       v_out,
	output       wmuxz_l,
	
	/* Shift signals */
	input        shl_sin_h,
	input        shr_sin_h,
	output       shl_sout_h,
	output       shr_sout_h,
	output       shl_en_h,
	output       shr_en_h,
	
	/* Opcode */
	input  [3:0] alu_h,
	
	/* ALPCTL controls */
	input        dmove_h,
	input        pass_a_h );
	
	wire   [3:0] aluq_h;
	wire   [3:1] bcda_h;
	
	/* Decode outputs */
	wire         bcd_op_l;
	wire   [4:0] wmux_onehot_h;
	
	/* Decoder for wmux, bcd op */
	alpaludec dec(
		.alu_h        ( alu_h         ),
		.pg_in_h      ( pg_in_h       ),
		.pass_a_h     ( pass_a_h      ), 
		.dmove_h      ( dmove_h       ),
		
		.bcd_op_l     ( bcd_op_l      ),
		.wmux_onehot_h( wmux_onehot_h ),
		.shl_en_h     ( shl_en_h      ),
		.shr_en_h     ( shr_en_h      ) );
	
	/* ALU */
	alpalu alu(
		.amux_h( amux_h ),
		.bmux_h( bmux_h ),
		.aluq_h( aluq_h ),
		
		/* Flag signals */
		.carry_in_h ( carry_in_h ),
		.pg_in_h    ( pg_in_h    ),
		.g_out_ctl  ( g_out_ctl  ),
		.g_out_in1  ( g_out_in1  ),
		.g_out_in2  ( g_out_in2  ),
		.p_out_ctl  ( p_out_ctl  ),
		.p_out_in1  ( p_out_in1  ),
		.p_out_in2  ( p_out_in2  ),
		.v_out      ( v_out      ),
		
		/* Global controls */
		.alu_h      ( alu_h       ),
		.bcd_op_l   ( bcd_op_l    ),
		.pass_a_h   ( pass_a_h    ) );
	
	/* BCD adjust */
	alpbcd bcd(
		.aluq_h( aluq_h[3:1] ),
		.bcda_h( bcda_h[3:1] ),
		.add_h ( alu_h [2]   ));
	
	/* WMUX */
	always @ ( * ) begin
		casez ( wmux_onehot_h )
			`ALP_WMUX_NONE: wmux_l  = 4'b1111;
			`ALP_WMUX_BCDA: wmux_l  = ~{bcda_h[3:1], aluq_h[0]};
			`ALP_WMUX_BMUX: wmux_l  = ~bmux_h;
			`ALP_WMUX_ASHL: wmux_l  = ~{shr_sin_h  , aluq_h[3:1]};
			`ALP_WMUX_ASHR: wmux_l  = ~{aluq_h[2:0], shl_sin_h};
			`ALP_WMUX_ALUQ: wmux_l  = ~aluq_h;
			default       : wmux_l  = 4'bxxxx;
		endcase
	end

/* A Shifter pads */
	assign shr_sout_h = aluq_h[0];
	assign shl_sout_h = aluq_h[3];

/* WMUXZ */
	assign wmuxz_l = ~&wmux_l;

endmodule