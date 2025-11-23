module ka750_dpm(
	input             sac_reset_h,
	/* ----- Micro sequencer ----- */
	/* [ CS ADDR   * H ]  { , A81, A21, A68, A13, A82, A84 } */
	output     [13:0] cs_addr_h,
	input      [13:0] cs_addr_in_h,
	input             ubi_busf_par_h,

	/* [ MICRO VECTOR * H ] { A85, A61, A59, A79 } */
	input       [3:0] micro_vector_h,

	/* [ DPM14 DISABLE HI NEXT H ] A88 */
	output            disable_hi_next_h,

	/* [ DPM17 DO SRVC L ] B8 */
	output            do_service_l,

	/* [ MSEQ INIT L ] B80 */
	input             mseq_init_l,

	/* [ MICRO ADDR INH L ] B3 */
	input             micro_addr_inh_l,

	/* [ DPM16 IRD 1 H ] B6 */
	output            ird1_h,

	/* [ DPM14 UVCTR BRANCH H ] A54 */
	output            uvctr_branch_h,

	input  [15:0]     xbuf_h,
	output [15:8]     xbuf_out_h,

	output            cs_par_err_h,

	/* ----- BUT inputs ------ */
	/* [ UBI11 CON HALT L    ] B31 */
	input             con_halt_l,
	/* [ UBI11 FPA PRESENT L ] C81 */
	input             fpa_present_l,
	/* [ UBI14 SYNCHR ACLO H ] C81 */
	input             sync_aclo_h,
	/* [ FP BOOT  1  H] { C81, B16 } */
	input   [1:0]     fp_boot_h,
	/* [ FP START 1 H ] { B57, B7 } */
	input   [1:0]     fp_start_h,
	/* [ MIC04 LATCHED MBUS 15 L ] A75 */
	input             mic_latched_mbus_15_l,
	/* [ UBI14 INT PEND L        ] A74 */
	input             int_pend_l,
	/* [ FPA21 FPA ENABLED L     ] B17 */
	input             fpa_enabled_l,
	/* [ FRNT PNL LOCK H         ] B13 */
	input             frnt_pnl_lock_h,
	/* [ UBI14 PREV DEST INH L   ] C85 */
	input             prev_dest_inh_l,
	/* [ DPM18 DEST RMODE H      ] B26 */
	output            dst_rmode_h,
 	/* ----- PSL bits ------ */
	/* [ DPM17 PSL CM H ] A92 */
	output            psl_cm_h,

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
	input             cs_hnext_par_h,
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
	input       [5:0] cs_wctrl_h,
	
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
	output      [1:0] d_size_h,

	/* ----- Data buses ----- */
	/* Write bus */
	input      [31:0] wbus_h_in, /* on connector */
	output     [31:0] wbus_h_out,

	/* Memory bus, active low */
	input      [31:0] mbus_l_in, 
	output     [31:0] mbus_l_out, 
	output mcs_tmp_l,            

	input             msrc_xb_h,
	output            gen_dest_inh_l,
	input             mic_utrap_l,

	output            instr_fetch_h,
	input             fpa_trap_l,
	input             fpa_stall_l,

	input  [1:0]      clk_ctrl_h,
    output [1:0]      isize_l,
	output            ld_osr_l
	
);

	wire ird_ld_rnum_h;
	wire [3:0]  ird_rnum_h;
	/* Clocks */
	wire base_clock_h;
	wire qd_clk_l;
	wire buf_b_clk_l;
	wire buf_m_clk_l;
	wire litreg_clk_h;
	wire mclk_h;
	wire dp_phase_h;
	/* [ DPM17 PHASE 1 L ] */
	wire phase_1_l;

	/* Reg control */
	wire litreg_en_l;

	/* Clock control */
	wire double_enable_h;

	/* Write bus */
	wire [31:0]  wbus_h;
	wire [31:0]  _alu_wbus_h;
	wire [31:0]  _spa_wbus_h;
	wire [31:0]  _but_wbus_h;
	wire [31:0]  _ccc_wbus_h;
 
	/* Memory bus */
	wire [31:0] mbus_l;
	wire [31:0] _spad_mbus_l;

	/* Rotator bus */
	wire [31:0] rbus_l;
	wire [31:0] _spad_rbus_l;
	wire [31:0] _litr_rbus_l;

	/* R Scratchpad address */
	wire [3:0] rspa_h;

	/* M Scratchpad address */
	wire [3:0] mspa_h;

	/* Scratchpad RAM write enables */
	wire [3:0] _ram_spw_l;

	wire       spwb_en_h, spww_en_h, spwl_en_h;

	/* [ DPM11 RCS * L ] Register file read strobes */
	wire rcs_tmp_l, rcs_gpr_l, rcs_ipr_l;

	/* Condition code flags */
	wire pslc_h;
	wire [3:0] wmuxz_h;
	wire arith_trap_l;


	/* Micro-op buffers */
	reg [5:0] but_h;
	reg [1:0] dtype_h;
	reg [5:0] rot_h;
	reg [9:0] alpctl_h;
	reg [5:0] rsrc_h;
	reg [4:0] msrc_h;
	reg [1:0] cc_h;
	reg [1:0] spw_h;
	reg [1:0] par_h;
	reg       istrm_h;
	reg [1:0] lit_h;
	reg [4:0] misc_ctl_h;
	reg [5:0] next_h;
	reg       clkx_h;
	reg       jsr_h;
	reg       long_lit_l;
	reg [5:0] wctrl_h;
	wire [8:0] litrl_h;

    wire alu_c31_l, alu_c15_l, alu_c7_l;
    wire alu_v31_h, alu_v15_h, alu_v7_h;
	wire [1:0] spa_st_h;
	wire [1:0] srk_st_h;

	/* Inout busses */
	assign wbus_h     = wbus_h_in & _alu_wbus_h & _spa_wbus_h & _but_wbus_h;
	assign wbus_h_out = _alu_wbus_h & _spa_wbus_h & _but_wbus_h;

	assign mbus_l     = mbus_l_in    & _spad_mbus_l;
	assign rbus_l     = _spad_rbus_l & _litr_rbus_l;
	wire spwm_l = ~&spw_h;
	assign _spa_wbus_h[31:4] = 28'hFFFFFFF;
	assign litrl_h[8:0] = {rsrc_h, istrm_h, cc_h}; //XXX: LIT support w/o SRK/SRM

	dc616_spa SPA (
		.m_clk_l(m_clk_l),
		.phase_h(dp_phase_h),
		.d_clk_en_h(d_clk_enable_h),
		.rsrc_h(rsrc_h),
		.msrc_h(msrc_h),
		.lit_0_h(lit_h[0]),
		.spwm_l(spwm_l),
		.dst_rmode_h(dst_rmode_h),
		.dsize_h(d_size_h),
		.ird_rnum_h(ird_rnum_h),
		.ird_ld_rnum_h(ird_ld_rnum_h),
		.ifetch_h(instr_fetch_h),
		.wbus_in_h(wbus_h[3:0]),
		.rspa_h(rspa_h),
		.mspa_h(mspa_h),
		.mcs_tmp_l(mcs_tmp_l),
		.rcs_tmp_l(rcs_tmp_l),
		.rcs_gpr_l(rcs_gpr_l),
		.rcs_ipr_l(rcs_ipr_l),
		.litr_l(litreg_en_l),
		.wbus_out_h(_spa_wbus_h[3:0]),
		.spa_st_h(spa_st_h)
	);

	/* Scratchpad RAM write enables */
	assign _ram_spw_l =
		~({spwl_en_h, spwl_en_h, spww_en_h, spwb_en_h} &
		{4{ d_clk_enable_h }} &
	 	{4{ base_clock_h }}) ;

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
		.litrl_h        ( litrl_h ),

		/* Control signals */
		.alpctl_h       ( alpctl_h ),
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
		.srk_sta_h       ( srk_st_h ),

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

	always @ ( sac_reset_h or posedge buf_m_clk_l ) begin
		if ( sac_reset_h ) begin
			/* E44, bits {7,0,1,2,3} */
			but_h      <= 5'b00000;
			/* E44, bits {5,6} */
			dtype_h    <= 2'b0;
			/* E86, bits {5,0,1,2,3,4} */
			rot_h      <= 6'b000000;
			/* E86, bits {6,7}, E74, bits {9,x,x,0,1,2,3,4,5,6} */
			alpctl_h   <= 10'b0000000000;
			/* E80, bits {5,0,1,2,3} */
			rsrc_h     <= 5'b00000;
			/* E80, bits {6,7} */
			cc_h       <= 2'b00;
			/* E81, bits {0,1} */
			spw_h      <= 2'b00;
			/* E81, bits {3,4,5,6} */
			msrc_h     <= 4'b0000;
			/* E81, bits {7} */
			par_h      <= 2'b00;
			/* E29, bits {1,0} */
			lit_h      <= 2'b00;
			/* E29, bits {2,3,4,5,6} */
			misc_ctl_h <= 5'b00000;
			/* E29, bits {7} */
			istrm_h    <= 1'b0;
			clkx_h     <= 1'b0;
			next_h     <= 6'b000000;
			jsr_h      <= 1'b0;
			wctrl_h    <= 6'b000000;
			long_lit_l <= 1'b1;
		end else if ( buf_m_clk_l ) begin			
			/* E44, bits {7,0,1,2,3} */
			but_h      <= cs_but_h;
			/* E44, bits {5,6} */
			dtype_h    <= cs_dtype_h;
			/* E86, bits {5,0,1,2,3,4} */
			rot_h      <= cs_rot_h;
			/* E86, bits {6,7}, E74, bits {9,x,x,0,1,2,3,4,5,6} */
			alpctl_h   <= cs_alpctl_h;
			/* E80, bits {5,0,1,2,3} */
			rsrc_h     <= cs_rsrc_h;
			/* E80, bits {6,7} */
			cc_h       <= cs_cc_h;
			/* E81, bits {0,1} */
			spw_h      <= cs_spw_h;
			/* E81, bits {3,4,5,6} */
			msrc_h     <= cs_msrc_h;
			/* E81, bits {7} */
			par_h      <= cs_par_h;
			/* E29, bits {1,0} */
			lit_h      <= cs_lit_h;
			/* E29, bits {2,3,4,5,6} */
			misc_ctl_h <= cs_misc_ctl_h;
			/* E29, bits {7} */
			istrm_h    <= cs_istrm_h;
			clkx_h     <= cs_clkx_h;
			next_h     <= cs_next_h;
			jsr_h      <= cs_jsr_h;
			wctrl_h    <= cs_wctrl_h;
			long_lit_l <= ~(&cs_lit_h);		
		end
	end

	/* Micro-op parity */
	wire [3:0] cs_par_a_chk; /* d,c,b,a */
	wire [1:0] cs_par_b_chk; /* d,c,b,a */
	wire grp_a_p_error_l;
	wire grp_b_p_error_l;

	assign cs_par_a_chk[0]   = ~^{msrc_h[0], rsrc_h, cc_h};
	assign cs_par_a_chk[1]   = ~^{par_h[0] , but_h , dtype_h};
	assign cs_par_a_chk[2]   = ~^{msrc_h[1], alpctl_h[6:0], alpctl_h[9] };
	assign cs_par_a_chk[3]   = ~^{1'b0     , alpctl_h[8:7], rot_h};

	/* [ E82 74S280 ] Group A parity check IC */
	assign grp_a_p_error_l = ~^{cs_par_a_chk, spw_h, msrc_h[4:2]};

	/* [ E28 74S280 ] Group B sub 0 parity check IC */
	assign cs_par_b_chk[0] = ^{misc_ctl_h, next_h[5:2]};

	/* [ E16 74S280 ] Group B sub 1 parity check IC */
	assign cs_par_b_chk[1] = ^{wctrl_h, istrm_h, lit_h};

	/* [ E12 74S280 ] Group B parity check IC */
	assign grp_b_p_error_l = ~^{cs_par_b_chk, next_h[1:0], jsr_h, clkx_h, par_h[1], cs_hnext_par_h, ubi_busf_par_h};

	assign cs_par_err_h = ~grp_a_p_error_l | ~grp_b_p_error_l;

	/* [ E78,E71,E72,E73 ] Micro-op Long literal register [LONLIT] */
	reg [31:0] _lonlit_l;

	always @ ( posedge litreg_clk_h ) begin
		_lonlit_l = {
				rot_h[4:0], alpctl_h, but_h,
				dtype_h, rsrc_h, istrm_h, cc_h} ;

	end

	assign _litr_rbus_l = litreg_en_l ? 32'hFFFFFFFF : _lonlit_l;

	wire [3:0] cc_ctrl_h;
	wire [1:0] ccbr_h;
	wire tmr_svc_h;
	wire psl_tp_h;
	wire non_bcd_h;

	msid msid_instance (
		.sac_reset_h(sac_reset_h),
		.cpu_osc_in_h(cpu_osc_in_h),
		.base_clk_l(base_clk_l),
		.b_clk_l(b_clk_l),
		.m_clk_l(m_clk_l),
		.phase_1_h(phase_1_h),
		.phase_1_l(phase_1_l),
		.buf_b_clk_l(buf_b_clk_l),
		.buf_m_clk_l(buf_m_clk_l),
		.qd_clk_l(qd_clk_l),
		.mclk_h(mclk_h),
		.dp_phase_h(dp_phase_h),
		.base_clock_h(base_clock_h),
		.m_clk_enable_h(m_clk_enable_h),
		.d_clk_enable_h(d_clk_enable_h),
		.mic_mem_stall_h(mic_mem_stall_h),
		.double_enable_h(double_enable_h),
		.mic_utrap_l(mic_utrap_l),
		.cs_par_err_h(cs_par_err_h),
		.psl_tp_h(psl_tp_h),
		.arith_trap_l(arith_trap_l),
		.fpa_trap_l(fpa_trap_l),
		.tmr_svc_h(tmr_svc_h),
		.int_pend_l(int_pend_l),
		.con_halt_l(con_halt_l),
		.cs_addr_h(cs_addr_h),
		.cs_addr_in_h(cs_addr_in_h),
		.micro_vector_h(micro_vector_h),
		.disable_hi_next_h(disable_hi_next_h),
		.do_service_l(do_service_l),
		.mseq_init_l(mseq_init_l),
		.micro_addr_inh_l(micro_addr_inh_l),
		.ird1_h(ird1_h),
		.instr_fetch_h(instr_fetch_h),
		.uvctr_branch_h(uvctr_branch_h),
		.xbuf_h(xbuf_h),
		.xbuf_out_h(xbuf_out_h),
		.fpa_present_l(fpa_present_l),
		.sync_aclo_h(sync_aclo_h),
		.fp_boot_h(fp_boot_h),
		.fp_start_h(fp_start_h),
		.mic_latched_mbus_15_l(mic_latched_mbus_15_l),
		.fpa_enabled_l(fpa_enabled_l),
		.fpa_stall_l(fpa_stall_l),
		.frnt_pnl_lock_h(frnt_pnl_lock_h),
		.prev_dest_inh_l(prev_dest_inh_l),
		.dst_rmode_h(dst_rmode_h),
		.psl_cm_h(psl_cm_h),
		.mem_stall_h(mic_mem_stall_h),
		.ccbr_h(ccbr_h),
		.cc_ctrl_h(cc_ctrl_h),
		.wmuxz_h(wmuxz_h),
		.srk_st_h(srk_st_h),
		.spa_st_h(spa_st_h),
		.wctrl_h(wctrl_h),
		.cc_h(cc_h),
		.dtype_h(dtype_h),
		.lit_h(lit_h),
		.but_h(but_h),
		.next_h(next_h),
		.istrm_h(istrm_h),
		.clkx_h(clkx_h),
		.long_lit_l(long_lit_l),
		.jsr_h(jsr_h),
		.non_bcd_h(non_bcd_h),
		.pslc_h(pslc_h),
		.misc_ctl_h(misc_ctl_h),
		.msrc_xb_h(msrc_xb_h),
		.clk_ctrl_h(clk_ctrl_h),
		.gen_dest_inh_l(gen_dest_inh_l),
		.ird_ld_rnum_h(ird_ld_rnum_h),
		.ird_rnum_h(ird_rnum_h),
		.dsize_h(d_size_h),
		.isize_l(isize_l),
		.wbus_h(wbus_h),
		.wbus_out_h(_but_wbus_h),
		.ld_osr_l(ld_osr_l)
	);

	dc610_ccc dc610_ccc_instance (
		.b_clk_l(b_clk_l),
		.d_clk_en_h(d_clk_enable_h),
		.cc_ctrl_h(cc_ctrl_h),
		.d_size_h(d_size_h),
		.wmuxz_h(wmuxz_h),
		.ir_h(8'h00),
		.fpa_z_l(1'b1),
		.fpa_v_l(1'b1),
		.fpa_present_l(fpa_present_l),
		.wbus_31_h(wbus_h[31]),
		.wbus_15_h(wbus_h[15]),
		.wbus_h(wbus_h[7:0]),
		.aluv_31_h(alu_v31_h),
		.aluv_15_h(alu_v15_h),
		.aluv_7_h(alu_v7_h),
		.aluc_31_l(alu_c31_l),
		.aluc_15_l(alu_c15_l),
		.aluc_7_l(alu_c7_l),
		.wbus_out_31_h(_ccc_wbus_h[31]),
		.wbus_out_15_h(_ccc_wbus_h[15]),
		.wbus_out_h(_ccc_wbus_h[7:0]),
		.ccbr_h(ccbr_h),
		.arith_trap_l(arith_trap_l),
		.pslc_h(pslc_h)
	);
	assign _ccc_wbus_h[30:16] = 15'h7FFF;
	assign _ccc_wbus_h[14:8]  = 7'h7F;
endmodule