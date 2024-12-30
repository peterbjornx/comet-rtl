module ka750_dpm(
	/* ----- Micro op bits ----- */
	/* [ CS BUT    * H ]  { A77, A70, A86, A53, A55, A64 } */
	input       [5:0] cs_but_h,
	/* [ CS DTYPE  * H ]  { A33, A63 } */
	input       [1:0] cs_dtype_h,
	/* [ CS MSRC   * H ]  { A30, A26, A27, A36, A39 } */
	input       [4:0] cs_msrc_h,
	/* [ CS RSRC   * H ]  { A40, B61, A31, A28, A32, A35 } */
	input       [5:0] cs_rsrc_h,
	/* [ CS ROT    * H ]  { B73, B79, B78, B74, B67, B69 } */
	input       [5:0] cs_rot_h,
	/* [ CS ALPCTL * H ]  { B54, B84, B85, B53, B50, B46, B42, B41, B45, B49 } */
	input       [9:0] cs_alpctl_h,
	/* [ CS SPW    * H ]  { A49, A42  } */
	input       [1:0] cs_spw_h,
	/* [ CS PAR    * H ]  { A9 , A34 } */
	input       [1:0] cs_par_h,
	/* [ CS CC     * H ]  { B62, B63 } */
	input       [1:0] cs_cc_h,
	/* [ CS ISTRM    * H ]  A41 */
	input             cs_istrm_h,
	/* [ CS LIT      * H ]  {A93, A87} */
	input       [1:0] cs_lit_h,
	/* [ CS MISC CTL * H ]  {A48, A89, A46, A25, A90} */
	input       [4:0] cs_misc_ctl_h,
	/* [ CS CLKX H       ]  {A50} */
	input             cs_clkx_h,
	/* [ CS NEXT * H     ]  {A5, A4, A1, A3, A6, A7} */
	input       [5:0] cs_next_h,
	/* [ CS JSR H        ]  {A8} */
	input             cs_jsr_h,
	
	/* Clocks */
	/* [ DPM17 CPU OSC IN H ] B27 ( 75 ohm )*/
	input             cpu_osc_in_h,
	/* [ DPM17 BASE CLK L ] A73 */
	output            base_clk_l,
	/* [ DPM17 B CLK L ] B9 */
	output            b_clk_l,
	/* [ DPM17 B CLK L ] B5 */
	output            m_clk_l,
	/* [ DPM17 PHASE 1 H ] A78 */
	output            phase_1_h,

	/* Clock control */
	/* [ DPM17 M CLK ENABLE H] B15 */
	output            m_clk_enable_h,
	/* [ DPM17 D CLK ENABLE H] B25 */
	output            d_clk_enable_h,
	/* [ MIC   MEM STALL H   ] B10 */
	input             mic_mem_stall_h,

	/* ----- Control output bits ----- */
	output      [2:0] d_size_h,

	/* ----- Data buses ----- */
	/* Write bus */
	input      [31:0] wbus_h_in, /* on connector */
	output     [31:0] wbus_h_out,

	/* Memory bus, active low */
	input      [31:0] mbus_l_in, 
	output     [31:0] mbus_l_out, 

	/* Scratchpad write enables, per 8 bit byte */
	input      [3:0]  spw_l,
	/* Read enables, per register bank */
	input             mcs_tmp_l /* B93 */
	
);

	/* Clocks */
	wire base_clock_h;
	wire qd_clk_l;
	wire buf_b_clk_l;
	wire buf_m_clk_l;
	wire litreg_clk_h;
	wire mclk_h;
	wire dp_phase_h;

	/* Reg control */
	wire litreg_en_l;

	/* Clock control */
	wire double_enable_h;

	/* Write bus */
	wire [31:0]  wbus_h;
	wire [31:0]  _alu_wbus_h;

	/* Memory bus */
	wire [31:0] mbus_l;
	wire [31:0] _spad_mbus_l;

	/* Rotator bus */
	wire [31:0] rbus_l;
	wire [31:0] _spad_rbus_l;
	wire [31:0] _litr_rbus_l;

	/* Super rotator bus */
	wire [34:0] sbus_h;

	/* R Scratchpad address */
	wire [3:0] rspa_h;

	/* M Scratchpad address */
	wire [3:0] mspa_h;

	/* Scratchpad RAM write enables */
	wire [3:0] _ram_spw_l;

	wire       spwb_en_h, spww_en_h, spwl_en_h;

	/* [ DPM11 RCS * L ] Register file read strobes */
	wire rcs_tmp_l, rcs_gpr_l, rcs_ipr_l;

	/* [] */
	wire [9:0] alp_opc_h; /* ALPCTL / ALK OP */

	/* Condition code flags */
	wire pslc_h;
	wire [3:0] wmuxz_h;
	wire [3:0] aluv_h;

	/* Micro-op buffers */
	reg [5:0] but_h;
	reg [1:0] dtype_h;
	reg [5:0] rot_h;
	reg [9:0] alpctl_h;
	reg [5:0] rsrc_h;
	reg [4:0] msrc_h;
	reg [1:0] cc_h;
	reg [1:0] spw_h;
	reg [0:0] par_h;
	reg       istrm_h;
	reg [1:0] lit_h;
	reg [4:0] misc_ctl_h;
	reg [5:0] next_h;
	reg       clkx_h;
	reg       jsr_h;


	wire long_lit_l;

    wire alu_c31_l, alu_c15_l, alu_c7_l;
    wire alu_v31_h, alu_v15_h, alu_v7_h;

	/* Inout busses */
	assign wbus_h     = wbus_h_in & _alu_wbus_h;
	assign wbus_h_out = _alu_wbus_h;

	assign mbus_l     = mbus_l_in    & _spad_mbus_l;
	assign rbus_l     = _spad_rbus_l & _litr_rbus_l;

	/* Scratchpad RAM write enables */
	assign _ram_spw_l =
		{spwl_en_h, spwl_en_h, spww_en_h, spwb_en_h} &
		{4{ d_clk_enable_h }} &
	 	{4{ base_clock_h }} ;

	/* Scratchpad RAM */
	spadrarray spad_r( 
		.wbus_h(wbus_h),
		.rbus_l(_spad_rbus_l), 
		.spw_l(_ram_spw_l), 
		.rspa_h(rspa_h), 
		.rcs_gpr_l(rcs_gpr_l), 
		.rcs_ipr_l(rcs_ipr_l), 
		.rcs_tmp_l(rcs_tmp_l) );
		
	spadmarray spad_m( 
		.wbus_h   (wbus_h), 
		.mbus_l   (_spad_mbus_l), 
		.spw_l    (_ram_spw_l)  ,
		.mspa_h   (mspa_h), 
		.mcs_tmp_l(mcs_tmp_l) );
		
	/* ALU: ALP, ALK, CLA part of datapath */
	aludp alps(
		/* Clocks */
		.qd_clk_l       ( qd_clk_l ),
		.dp_phase_h     ( dp_phase_h ),

		/* Data buses */
		.wbus_h_out     ( _alu_wbus_h ),
		.wbus_h_in      ( wbus_h ),
		.rbus_l         ( rbus_l ), 
		.mbus_l         ( mbus_l ),
		.sbus_h         ( sbus_h ),

		/* Control signals */
		.alpctl_h       ( alpctl_h ),
		.shf_l          ( shf_l ),
		.rot_h          ( rot_h ),
		.dsize_h        ( d_size_h ),
		.spw_h          ( spw_h ),
		.long_lit_l     ( long_lit_l ),

		/* Control outputs */
		.double_enable_h( double_enable_h ),
		.spwl_en_h      ( spwl_en_h       ),
		.spww_en_h      ( spww_en_h       ),
		.spwb_en_h      ( spwb_en_h       ),
		.litreg_clk_h   ( litreg_clk_h    ),

		/* Flag input */
		.pslc_h         (pslc_h),

		.alu_c31_l      (alu_c31_l),
		.alu_c15_l      (alu_c15_l),
		.alu_c7_l       (alu_c7_l),
		.alu_v31_h      (alu_v31_h),
		.alu_v15_h      (alu_v15_h),
		.alu_v7_h       (alu_v7_h),

		/* Flag outputs */
		
		.wmuxz_h     ( wmuxz_h )	);

	always @ ( posedge buf_m_clk_l ) begin
		/* E44, bits {7,0,1,2,3} */
		but_h      = cs_but_h;
		/* E44, bits {5,6} */
		dtype_h    = cs_dtype_h;
		/* E86, bits {5,0,1,2,3,4} */
		rot_h      = cs_rot_h;
		/* E86, bits {6,7}, E74, bits {9,x,x,0,1,2,3,4,5,6} */
		alpctl_h   = cs_alpctl_h;
		/* E80, bits {5,0,1,2,3} */
		rsrc_h     = cs_rsrc_h;
		/* E80, bits {6,7} */
		cc_h       = cs_cc_h;
		/* E81, bits {0,1} */
		spw_h      = cs_spw_h;
		/* E81, bits {3,4,5,6} */
		msrc_h     = cs_msrc_h;
		/* E81, bits {7} */
		par_h      = cs_par_h;
		/* E29, bits {1,0} */
		lit_h      = cs_lit_h;
		/* E29, bits {2,3,4,5,6} */
		misc_ctl_h = cs_misc_ctl_h;
		/* E29, bits {7} */
		istrm_h    = cs_istrm_h;
		clkx_h     = cs_clkx_h;
		next_h     = cs_next_h;
		jsr_h      = cs_jsr_h;
	end

	/* Micro-op parity */
	wire [3:0] cs_par_chk; /* d,c,b,a */
	wire grp_a_p_error_l;

	assign cs_par_chk[0]   = ^{msrc_h[0], rsrc_h, cc_h};
	assign cs_par_chk[1]   = ^{par_h[0] , but_h , dtype_h};
	assign cs_par_chk[2]   = ^{msrc_h[1], alpctl_h[6:0], alpctl_h[9] };
	assign cs_par_chk[3]   = ^{1'b0     , alpctl_h[8:7], rot_h};

	assign grp_a_p_error_l = ^{cs_par_chk, spw_h, msrc_h[3:2]};

	/* Micro-op Long literal register [LONLIT] (E78,E71,E72,E73) */
	reg [31:0] _lonlit_l;

	always @ ( posedge litreg_clk_h ) begin
		_lonlit_l = {
				rot_h[4:0], alpctl_h, but_h,
				dtype_h, rsrc_h, istrm_h, cc_h} ;

	end

	assign _litr_rbus_l = litreg_en_l ? 32'hFFFFFFFF : _lonlit_l;

	/******************/

	/* [ DPM17 MKEN H ] M    Clock Enable from SAC*/
	wire mken_h;
	/* [ DPM17 DKEN H ] D    Clock Enable from SAC */
	wire dken_h;
	/* [ DPM17 QDEN H ] QD   Clock Enable from SAC */
	wire qden_h;
	/* Halt output from SAC */
	wire halt_l;
	/* PHAS output from SAC */
	wire phas_h;
	/* SETC output from SAC */
	wire setc_h;
	wire phase_1_l;

	/* E4, E2 */
	assign m_clk_enable_h = ~mic_mem_stall_h & ~mken_h;
	assign d_clk_enable_h = ~mic_mem_stall_h & ~dken_h;
	assign qd_clk_en_h    = ~mic_mem_stall_h & ~qden_h;

	/* [ E53 74S37 ] */
	assign base_clock_h = ~base_clk_l;

	/* [ E56 74S112 ] */
	sn74s112 e56_a (
		.j_h  (phas_h),
		.k_h  (m_clk_enable_h),
		.clk_l(base_clock_h),
		.q_h  (phase_1_h),
		.q_l() );

	sn74s112 e56_b (
		.j_h  (setc_h),
		.k_h  (1'b1  ),
		.clk_l(cpu_osc_in_h),
		.q_l  (base_clk_l),
		.q_h() );

	/* [ E65 74S37 ] */
	assign b_clk_l   = ~(base_clock_h & halt_l);
	assign m_clk_l   = ~(base_clock_h & m_clk_enable_h);
	assign qd_clk_l  = ~(base_clock_h & qd_clk_en_h);
	assign phase_1_h = ~phase_1_l; 

	/* [Q2 2N2369] */
	assign buf_b_clk_l = b_clk_l;

	/* [Q3 2N2369] */
	assign buf_m_clk_l = m_clk_l;

	/* [ E55 74S04 ] */
	assign mclk_h = ~buf_m_clk_l;

	/* [ E53 74S37 ] */
	assign dp_phase_h = ~phase_1_h;
endmodule