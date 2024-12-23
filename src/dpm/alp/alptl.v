/**
 * Implements DC608 ALP internals, but not IO cell specifics.
 * The gate netlist has been lifted to partial RTL level for this,
 * to prevent relying on trinets, and to clarify the logic in certain
 * places.
 */
module alptl(
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
	
	/* -----    WMUX buffer  ----- */
	output     [3:0] wmux_l,
	output           wmux_oe_h,
	
	/* ----- Control signals ----- */
	input      [9:0] opc_l,
	input      [1:0] shf_h,
	input            ext_ena_h,
	
	/* -----  Carry signals  ----- */
	input            carry_in_h,
	input            pg_in_h,
	output           g_out_ctl,
	output           g_out_in1,
	output           g_out_in2,
	output           p_out_ctl,
	output           p_out_in1,
	output           p_out_in2,
	
	
	/* -----  Flag outputs  ----- */
	output           v_out,
	output           wmuxz_l,
	
	/* ----- Shift signals ----- */
	
	output           q_sio_l0_oe_h,
	output           q_sio_l0_out_h,
	input            q_sio_l0_in_h,
	
	output           q_sio_l3_oe_h,
	output           q_sio_l3_out_h,
	input            q_sio_l3_in_h,
	
	output           a_sio_l0_oe_h,
	output           a_sio_l0_out_h,
	input            a_sio_l0_in_h,
	
	output           a_sio_l3_oe_h,
	output           a_sio_l3_out_h,
	input            a_sio_l3_in_h
);

/* Opcode split */
	wire [9:0] opc_h = ~opc_l;
	wire [3:0] alu_h =  opc_h[5:2];
	wire [3:0] mux_h =  opc_h[9:6];
	wire [1:0] dq_h  =  opc_h[1:0];
	
/* Data buses */
	wire [3:0] amux_h;
	wire [3:0] bmux_h;

/* Control signals */
	wire [3:0] amux_onehot_h;
	wire [2:0] bmux_onehot_h;
	wire [3:0] qmux_onehot_h;
	wire       qreg_en_h;
	wire       dreg_en_h;
	wire       dmove_h;
	wire       pass_a_h;
	wire       dreg_inh_l;
	wire       qshl_en_h;
	wire       qshr_en_h;
	
/* ALPCTL decoder */
	alpctldec alpctl(
		.opc_h         ( opc_h      ),
		.dmove_h       ( dmove_h    ),
		.wmux_oe_h     ( wmux_oe_h  ),
		.pass_a_h      ( pass_a_h   ),
		.dreg_inh_l    ( dreg_inh_l ));

/* Mux decoder */
	alpmuxdec muxdec(
		.ext_ena_h     ( ext_ena_h      ),
		.mux_h         ( mux_h          ),
		.amux_onehot_h ( amux_onehot_h  ),
		.bmux_onehot_h ( bmux_onehot_h  ) );

/* DQ decoder */
	alpdqdec dqdec(
		.dmove_h       ( dmove_h        ),
		.dreg_inh_l    ( dreg_inh_l     ),
		.mux_h         ( mux_h          ),
		.dq_h          ( dq_h           ),
		.qmux_onehot_h ( qmux_onehot_h  ),
		.qreg_en_h     ( qreg_en_h      ),
		.dreg_en_h     ( dreg_en_h      ),
		.qshl_en_h     ( qshl_en_h      ),
		.qshr_en_h     ( qshr_en_h      ));
	

/* Upper data path */
	alpdp dp(
		/* Clock inputs */
		.qdck_l   ( qdck_l     ),
		.lck_l    ( lck_l      ),
		
		/* Data inputs */
		.mbus_l   ( mbus_l    ),
		.rbus_l   ( rbus_l    ),
		.extdata_l( extdata_l ),
		.sbus_l   ( sbus_l    ),
		
		/* ALU */
		.amux_h   ( amux_h    ),
		.bmux_h   ( bmux_h    ),
		.wmux_l   ( wmux_l    ),
		
		/* Control */
		.shf_h         ( shf_h          ),
		.amux_onehot_h ( amux_onehot_h  ),
		.bmux_onehot_h ( bmux_onehot_h  ),
		.qmux_onehot_h ( qmux_onehot_h  ),
		.qreg_en_h     ( qreg_en_h      ),
		.dreg_en_h     ( dreg_en_h      ),
		.qshl_en_h     ( qshl_en_h      ),
		.qshr_en_h     ( qshr_en_h      ),
		
		/* Q Shifter */
		.q_sio_l0_oe_h ( q_sio_l0_oe_h  ),
		.q_sio_l0_out_h( q_sio_l0_out_h ),
		.q_sio_l0_in_h ( q_sio_l0_in_h  ),
		.q_sio_l3_oe_h ( q_sio_l3_oe_h  ),
		.q_sio_l3_out_h( q_sio_l3_out_h ),
		.q_sio_l3_in_h ( q_sio_l3_in_h  ) );
		
/* ALU, BCD adjust, WMUX */
	alpalum alu(
		/* Data buses */
		.amux_h( amux_h ),
		.bmux_h( bmux_h ),
		.wmux_l( wmux_l ),
		
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
		.wmuxz_l    ( wmuxz_l    ),
		
		/* Shift signals */
		.shl_sin_h  ( a_sio_l0_in_h  ),
		.shl_sout_h ( a_sio_l3_out_h ),
		.shl_en_h   ( a_sio_l3_oe_h  ),
		
		.shr_sin_h  ( a_sio_l3_in_h  ),
		.shr_sout_h ( a_sio_l0_out_h ),
		.shr_en_h   ( a_sio_l0_oe_h  ),
		
		/* Opcode */
		.alu_h      ( alu_h       ),
		
		/* ALPCTL controls */
		.dmove_h    ( dmove_h     ),
		.pass_a_h   ( pass_a_h    ) );
		
endmodule