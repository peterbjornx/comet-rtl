module alpalu(
	/* Data buses */
	input  [3:0] amux_h,
	input  [3:0] bmux_h,
	output [3:0] aluq_h,
	
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
	
	/* Global controls */
	input  [3:0] alu_h,
	input        bcd_op_l,


	/* Mux controls */
	input        pass_a_h );

	/* Carry controls */
	wire         bcd_add_h;
	
	/* X stage controls */
	wire         xctl_nA_nB;
	wire         xctl_nA_pB;
	wire         xctl_pA_nB;
	wire         xctl_pA_pB;
	
	/* Z stage controls */
	wire         zctl_nA_pB;
	wire         zctl_pA_nB;
	wire         zctl_pA_pB;
	wire         carry_dis_h;

	alpaluctl ctl(
		.alu_h      ( alu_h       ),
		.bcd_op_l   ( bcd_op_l    ),
		.pass_a_h   ( pass_a_h    ),
		
		/* Global controls */
		.carry_dis_h( carry_dis_h ),
		.bcd_add_h  ( bcd_add_h   ),
		
		/* X stage controls */
		.xctl_nA_nB ( xctl_nA_nB  ),
		.xctl_nA_pB ( xctl_nA_pB  ),
		.xctl_pA_nB ( xctl_pA_nB  ),
		.xctl_pA_pB ( xctl_pA_pB  ),
		
		/* Z stage controls */
		.zctl_nA_pB ( zctl_nA_pB  ),
		.zctl_pA_nB ( zctl_pA_nB  ),
		.zctl_pA_pB ( zctl_pA_pB  )
		
	);

	alpaludp dp(
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
		.carry_dis_h( carry_dis_h ),
		.bcd_add_h  ( bcd_add_h   ),
		.bcd_op_l   ( bcd_op_l    ),
		
		/* X stage controls */
		.xctl_nA_nB ( xctl_nA_nB  ),
		.xctl_nA_pB ( xctl_nA_pB  ),
		.xctl_pA_nB ( xctl_pA_nB  ),
		.xctl_pA_pB ( xctl_pA_pB  ),
		
		/* Z stage controls */
		.zctl_nA_pB ( zctl_nA_pB  ),
		.zctl_pA_nB ( zctl_pA_nB  ),
		.zctl_pA_pB ( zctl_pA_pB  ),
		
		/* Mux controls */
		.pass_a_h   ( pass_a_h    )
	);

endmodule
