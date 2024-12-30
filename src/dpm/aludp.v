module aludp(
	
	/* Clocks */

	/* QD Clock? */
	input            qd_clk_l,
	
	/* L Clock ? */ 
	input            dp_phase_h,

	/* ----- ucode control ----- */
	
	/* Opcode */
	input      [9:0] alpctl_h,
	
	/* Rotate */
	input      [5:0] rot_h,
	
	input      [1:0] spw_h,

    input            long_lit_l,

    /* ----- From decode logic ----- */
	
	/* Data Size */
	input      [1:0] dsize_h,

    /* ----- From SRK ----- */
	
	input      [1:0] shf_l,

	/* ----- Data buses    ----- */
	
	/* Write Bus (Input) */
	input      [31:0] wbus_h_in,
	
	/* Write Bus (Output) */
	output     [31:0] wbus_h_out,
	
	/* Rotator Bus */
	input      [31:0] rbus_l,
	
	/* Memory Bus */
	input      [31:0] mbus_l,
	
	/* Super-Rotator Bus */
	input      [34:0] sbus_h,

    /* Control outputs */
	output            spwb_en_h,
    output            spww_en_h,
    output            spwl_en_h,
    output            double_enable_h,
    output            litreg_clk_h,

    /* Inputs from flag register */
    input             pslc_h,

    /* Outputs to flag register */
    output            alu_c31_l,
    output            alu_v31_h,
    output            alu_c15_l,
    output            alu_v15_h,
    output            alu_c7_l,
    output            alu_v7_h,

    output [3:0]      wmuxz_h


	
);

    wire bcd_l;

	/* Reg control */
	wire x_15_08_en_l;

	/* Write bus */
	wire [31:0]  wbus_h;
	wire [31:0]  _alp_wbus_h;
	wire [31:30] _alk_wbus_h;

	/* [] */
	wire [9:0] alp_opc_h; /* ALPCTL / ALK OP */

	/* ALU Flag routing */
	wire [3:0] aluv_h;
    wire [7:0] p_l;
    wire [7:0] g_l;
	wire [8:0] aluc_l;
	wire alk_cout_l;

	/* ALU / Q Shift routing */
	wire q_sio_31_l, q_sio_15_l, q_sio_7_l, q_sio_0_l;
	wire a_sio_31_l, a_sio_0_l;

	wire _alk_qsi_31_l, _alk_qsi_15_l, _alk_qsi_7_l, _alk_qsi_0_l;
	wire _alk_asi_31_l, _alk_asi_0_l;

	/* Inout busses */
	assign wbus_h     = wbus_h_in & wbus_h_out; //TODO: Outside??
	assign wbus_h_out = _alp_wbus_h & {_alk_wbus_h, {30{1'b1}}};
		
	/* ALU */
	alparray alps(
		/* Clocks */
		.qdck_l      ( qd_clk_l ),
		.lck_l       ( dp_phase_h ),
		/* Data buses */
		.wbus_h_out  ( _alp_wbus_h ),
		.rbus_l      ( rbus_l ), 
		.mbus_l      ( mbus_l ),
		.sbus_h      ( sbus_h ),
		/* Control signals */
		.opc_h       ( alp_opc_h ),
		.shf_l       ( shf_l ),
		.x_15_08_en_l( x_15_08_en_l ),
		.d_size_h    ( dsize_h ),
		.rot_5_h     ( rot_h[5] ),

		/* Shifter signals */

		/* Shifter outputs (result of wire-AND) */
		.a_so31_l    ( a_sio_31_l    ),
		.a_so0_l     ( a_sio_0_l     ),
		.q_so31_l    ( q_sio_31_l    ),
		.q_so15_l    ( q_sio_15_l    ),
		.q_so7_l     ( q_sio_7_l     ),
		.q_so0_l     ( q_sio_0_l     ),	

		/* Shifter inputs from ALK (into wire-AND) */
		.a_si31_l    ( _alk_asi_31_l ),
		.a_si0_l     ( _alk_asi_0_l  ),
		.q_si31_l    ( _alk_qsi_31_l ),
		.q_si15_l    ( _alk_qsi_15_l ),
		.q_si7_l     ( _alk_qsi_7_l  ),
		.q_si0_l     ( _alk_qsi_0_l  ),

		/* Carry signals */
		.p_l         ( p_l ),
		.g_l         ( g_l ),
		.aluc_l      ( aluc_l[7:0] ),
		/* Flag outputs */
		.wmuxz_h     ( wmuxz_h ),
		.aluv_h      ( aluv_h )	);

    /* ALU Carry outputs */
    assign alu_c31_l = aluc_l[8];
    assign alu_c15_l = aluc_l[4];
    assign alu_c7_l  = aluc_l[2];

    /* ALU Overflow outputs */
    assign alu_v31_h = aluv_h[3];
    assign alu_v15_h = aluv_h[1];
    assign alu_v7_h  = aluv_h[0];

	/* [ E35 (4,5,6) ] */
	wire e35_11 = ~(alp_opc_h[1] & double_enable_h);
	wire e35_3  = ~alu_c31_l;
	wire alk_c31_in_l = ~(e35_11 & e35_3);

	dc615_alk dc615_alk_instance (
		.qdck_l     (qd_clk_l),
		.alpctl_h   (alpctl_h),
		.rot_h      (rot_h),
		.dsize_h    (dsize_h),
		.spw_h      (spw_h),
		.pslc_h     (pslc_h),
		.llit_l     (long_lit_l),
		.c31_l      (alk_c31_in_l),
        /* ALU Shift I/O */
		.a_so31_l   (a_sio_31_l),
		.a_so0_l    (a_sio_0_l ),
		.a_si31_l   (_alk_asi_31_l ),
		.a_si0_l    (_alk_asi_0_l  ),
        /* Q Shift I/O */
		.q_so31_l   (q_sio_31_l),
		.q_so15_l   (q_sio_15_l),
		.q_so7_l    (q_sio_7_l ),
		.q_so0_l    (q_sio_0_l ),
		.q_si31_l   (_alk_qsi_31_l ),
		.q_si15_l   (_alk_qsi_15_l ),
		.q_si7_l    (_alk_qsi_7_l  ),
		.q_si0_l    (_alk_qsi_0_l  ),
		.bcd_l      (bcd_l),
		.byte_l     (x_15_08_en_l),
		/* Scratch pad write gates */
		.spwb_en_h  (spwb_en_h),
		.spww_en_h  (spww_en_h),
		.spwl_en_h  (spwl_en_h),
		/* Double-clock enable */
		.dbl_h      (double_enable_h),
		.alk_op_64_h(alp_opc_h[6:4]),
		.alk_op_10_h(alp_opc_h[1:0]),
		.wbus_h     (wbus_h),
		.wbus_h_out (_alk_wbus_h),
		.cout_l     (alk_cout_l)
	);

	assign alp_opc_h[9:5] = alpctl_h[9:5];
	assign alp_opc_h[3:2] = alpctl_h[3:2];
    wire cla_sb_h = 1'b1;
    wire cla_muxa_h = 1'b1;
    wire cla_bin8_l, cla_bcd8_l;
    wire non_bcd_h;

    dc612_cla cla(
        .p_l   ( p_l ),
        .g_a_l ( g_l ),
        .g_b_l ( g_l ),
        .bcd_l ( bcd_l ),
        .ci_l  ( alk_cout_l ),
        .sb_h  ( cla_sb_h ),
        .bin8_l( cla_bin8_l ),
        .bcd8_l( cla_bcd8_l ),
        .co_l  ( aluc_l[7:0] ),
        .c_h   ( non_bcd_h ),
        .fs_h  (),
        .fov_h (),
        .muxa_h( cla_muxa_h ),
        .muxb_h( qd_clk_l ),
        .muxs_h( long_lit_l ),
        .muxo_l( litreg_clk_h ) );

    assign aluc_l[8] = cla_bin8_l & cla_bcd8_l;

endmodule