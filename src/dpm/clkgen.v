module clkgen(
	
    input             mseq_init_l,
	 input             sac_reset_h,

    /*************************************/
    /*            Clock inputs           */
    /*************************************/

	/* [ DPM17 CPU OSC IN H ] B27 ( 75 ohm ) */
	input             cpu_osc_in_h,
    
    /*************************************/
    /*       Control signal inputs       */
    /*************************************/

	/* [ MIC   MEM STALL H   ] B10 */
	input             mic_mem_stall_h,


    input             double_enable_h,

    input             clkx_h,


    input             fpa_wait_l,

    input             fpa_stall_l,

    input             but_cc_a_h,
    input [2:0]       but_h,

    input             psl_cm_h,
    input             gen_dest_inh_l,
    input             ld_osr_l,



    /*************************************/
    /*            Trap signals           */
    /*************************************/

    input             mic_utrap_l,
    input             cs_par_err_h,
    input             psl_tp_h,
    input             arith_trap_l,
    input             fpa_trap_l,
    input             tmr_svc_h,
    input             int_pend_l,
    input             con_halt_l,

    /*************************************/
    /*             RDM signals           */
    /*************************************/
    input [1:0]       clk_ctrl_h,
    input             addr_inh_l,

    /*************************************/
    /*          Sequencer signals        */
    /*************************************/

    output            ifetch_h,
    output            do_service_l,
    output            uvector_h,
    output      [2:0] cs_addr_l,
    output      [2:0] ird_ctr_h,

    output            latch_utrap_l,

    /*************************************/
    /*    Clock outputs, system wide     */
    /*************************************/

	/* [ DPM17 BASE CLK L    ] A73 */
	output            base_clk_l,

	/* [ DPM17 B CLK L       ] B9 */
	output            b_clk_l,

	/* [ DPM17 M CLK L       ] B5 */
	output            m_clk_l,

	/* [ DPM17 PHASE 1 H     ] A78 */
	output            phase_1_h,

    /*************************************/
    /*    Clock outputs, DPM internal    */
    /*************************************/

	/* [ DPM17 PHASE 1 L     ]  */
	output            phase_1_l,

    /* [ DPM17 BUF B CLK L  ] */
    output            buf_b_clk_l,

    /* [ DPM17 BUF M CLK L  ] */
    output            buf_m_clk_l,

    /* [ DPM17 QD CLK L     ] */
    output            qd_clk_l,

    /* [ DPM11 MCLK H       ] */
    output            mclk_h,

    /* [ DPM11 DP PHASE H   ] */
    output            dp_phase_h,

	/* [ DPM17 BASE CLOCK H ] */
	output            base_clock_h,
    
    /*************************************/
    /*      Control signal outputs       */
    /*************************************/

	/* Clock control */
	
    /* [ DPM17 M CLK ENABLE H] B15 */
	output            m_clk_enable_h,

	/* [ DPM17 D CLK ENABLE H] B25 */
	output            d_clk_enable_h );

	/* Clocks */
    wire qd_clk_en_h;

	/******************/

	/* [ DPM17 MKEN H ] M    Clock Enable from SAC */
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

	/* E4, E2 */
	assign m_clk_enable_h = ~mic_mem_stall_h & mken_h;
	assign d_clk_enable_h = ~mic_mem_stall_h & dken_h;
	assign qd_clk_en_h    = ~mic_mem_stall_h & qden_h;

	/* [ E53 74S37 ] */
	assign base_clock_h = ~base_clk_l;

	/* [ E56 74S112 ] */
	sn74s112 e56_a (
		.j_h  (phas_h),
		.k_h  (m_clk_enable_h),
		.clk_l(base_clock_h),
		.q_h  (phase_1_l),
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

    wire clr0_l = 1'b1;
    
    dc617_sac sac (
        .osc_h(cpu_osc_in_h),
        .sac_reset_h(sac_reset_h),
        .mclk_h(mclk_h),
        .base_clk_h(base_clock_h),
        .clk_ctl_h(clk_ctrl_h),
        .mem_stall_h(mic_mem_stall_h),
        .clkx_h(clkx_h),
        .fpa_wait_l(fpa_wait_l),
        .fpa_stall_l(fpa_stall_l),
        .gen_dest_inh_l(gen_dest_inh_l),
        .double_enable_h(double_enable_h),
        .micro_trap_l(mic_utrap_l),
        .cs_par_err_h(cs_par_err_h),
        .ld_osr_l(ld_osr_l),
        .psl_cm_h(psl_cm_h),
        .but_cc_a_h(but_cc_a_h),
        .but_h(but_h),
        .arith_trap_l(arith_trap_l),
        .fpa_trap_l(fpa_trap_l),
        .tmr_svc_h(tmr_svc_h),
        .con_halt_l(con_halt_l),
        .int_pend_l(int_pend_l),
        .psl_tp_h(psl_tp_h),
        .clr0_l(clr0_l),
        .mseq_init_l(mseq_init_l),
        .addr_inh_l(addr_inh_l),
        .setc_h(setc_h),
        .halt_l(halt_l),
        .mken_h(mken_h),
        .dken_h(dken_h),
        .qden_h(qden_h),
        .phas_h(phas_h),
        .ifetch_h(ifetch_h),
        .do_service_l(do_service_l),
        .uvector_h(uvector_h),
        .cs_addr_l(cs_addr_l),
        .ird_ctr_h(ird_ctr_h),
        .latch_utrap_l(latch_utrap_l)
    );

endmodule