`include "alpmacros.vh"
/**
 * Implements non-ALU part of data path for DC608 ALP
 * The gate netlist has been lifted to partial RTL level for this,
 * to prevent relying on trinets, and to clarify the logic in certain
 * places.
 */
module alpdp(
	/* -----    Clocks     ----- */
	
	/* QD Register Clock */
	input            qdck_l,
	/* Latch clock */ 
	input            lck_l,

	/* -----   Data inputs ----- */
	
	/* M Bus */
	input      [3:0] mbus_l,
	
	/* R Bus */
	input      [3:0] rbus_l,
	
	/* Sign-extend data */
	input            extdata_l,
	
	/* Shifter bus */
	input      [6:0] sbus_l,
	
	/* -----  ALU interface ----- */
	
	output     [3:0] amux_h,
	output     [3:0] bmux_h,
	input      [3:0] wmux_l,
	
	/* ----- Control signals ----- */
	
	input [1:0]      shf_h,
	input [3:0]      amux_onehot_h,
	input [2:0]      bmux_onehot_h,
	input [3:0]      qmux_onehot_h,
	input            qreg_en_h,
	input            dreg_en_h,
	input            qshl_en_h,
	input            qshr_en_h,
	
	/* ----- Shift signals ----- */
	
	output           q_sio_l0_oe_h,
	output           q_sio_l0_out_h,
	input            q_sio_l0_in_h,
	
	output           q_sio_l3_oe_h,
	output           q_sio_l3_out_h,
	input            q_sio_l3_in_h );
	
/* Data buses */
	wire [3:0] dreg_h;
	reg  [3:0] qreg_h;
	wire [3:0] amux_ld;

/* Input latches */
	reg [3:0] mbus_h;
	reg [3:0] rbus_h;
	reg       extdata_h;

	`LATCH_N( lck_l, ~mbus_l    , mbus_h     )
	`LATCH_N( lck_l, ~rbus_l    , rbus_h     )
	`LATCH_N( lck_l, ~extdata_l , extdata_h  )

/* Shifter */
	reg  [3:0] smux_h;

	always @ ( * ) begin
		casez ( shf_h )
			2'b00  : smux_h  = ~sbus_l[3:0];
			2'b01  : smux_h  = ~sbus_l[4:1];
			2'b10  : smux_h  = ~sbus_l[5:2];
			2'b11  : smux_h  = ~sbus_l[6:3];
			default: amux_l  = 4'bxxxx;
		endcase
	end

/* A Multiplexer */
	reg  [3:0] amux_l;

	always @ ( * ) begin
		casez ( amux_onehot_h )
			`ALP_AMUX_NONE: amux_l  = 4'b1111;
			`ALP_AMUX_RBUS: amux_l  = ~rbus_h;
			`ALP_AMUX_MBUS: amux_l  = ~mbus_h;
			`ALP_AMUX_DREG: amux_l  = ~dreg_h;
			`ALP_AMUX_PAD : amux_l  = {4{~extdata_h}};
			default       : amux_l  = 4'bxxxx;
		endcase
	end

	assign amux_h  = ~amux_l;
	assign amux_ld = ~amux_h;

/* B Multiplexer */
	reg  [3:0] bmux_l;

	always @ ( * ) begin
		casez ( bmux_onehot_h )
			`ALP_BMUX_NONE: bmux_l  = 4'b1111;
			`ALP_BMUX_RBUS: bmux_l  = ~rbus_h;
			`ALP_BMUX_QREG: bmux_l  = ~qreg_h;
			`ALP_BMUX_SMUX: bmux_l  = ~smux_h;
			default       : bmux_l  = 4'bxxxx;
		endcase
	end

	assign bmux_h = ~bmux_l;

/* Q Multiplexer */
	reg  [3:0] qmux_h;
	wire [3:0] qreg_l = ~qreg_h;
	wire qmux_shl_sin_l, qmux_shr_sin_l;

	always @ ( * ) begin
		casez ( qmux_onehot_h )
			`ALP_QMUX_NONE: qmux_h  = 4'b1111;
			`ALP_QMUX_WMUX: qmux_h  = ~wmux_l;
			`ALP_QMUX_SHL : qmux_h  = ~{qreg_l[2:0], qmux_shl_sin_l};
			`ALP_QMUX_SHR : qmux_h  = ~{qmux_shr_sin_l, qreg_l[3:1]};
			`ALP_QMUX_AMUX: qmux_h  = ~amux_ld;
			default       : qmux_h  = 4'bxxxx;
		endcase
	end

/* Q Shifter pads */
	assign q_sio_l0_oe_h  = qshr_en_h;
	assign q_sio_l0_out_h = qreg_h[0];
	assign qmux_shl_sin_l = ~q_sio_l0_in_h;

	assign q_sio_l3_oe_h  = qshl_en_h;
	assign q_sio_l3_out_h = qreg_h[3];
	assign qmux_shl_sin_l = ~q_sio_l3_in_h;

/* Q Register */
	`FF_EN_N( qdck_l, qreg_en_h, qmux_h, qreg_h )

/* D Register */
	reg [3:0] dreg_l;
	`FF_EN_N( qdck_l, dreg_en_h, wmux_l, dreg_l )
	assign dreg_h = ~dreg_l;
		
endmodule