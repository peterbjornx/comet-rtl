module msid(
	input sac_reset_h,
	/* Clocks */

    /*************************************/
    /*            Clock inputs           */
    /*************************************/

	/* [ DPM17 CPU OSC IN H ] B27 ( 75 ohm ) */
	input             cpu_osc_in_h,

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
    /*  Clock control signal outputs     */
    /*************************************/

	/* Clock control */
	
    /* [ DPM17 M CLK ENABLE H] B15 */
	output            m_clk_enable_h,

	/* [ DPM17 D CLK ENABLE H] B25 */
	output            d_clk_enable_h,
    
    /*************************************/
    /*       Control signal inputs       */
    /*************************************/

	/* [ MIC   MEM STALL H   ] B10 */
	input             mic_mem_stall_h,


    input             double_enable_h,


    /*************************************/
    /*            Trap signals           */
    /*************************************/

    input             mic_utrap_l,
    input             cs_par_err_h,
    output            psl_tp_h,
    input             arith_trap_l,
    input             fpa_trap_l,
    input             tmr_svc_h,
    input             int_pend_l,
    input             con_halt_l,

	/* ----- Micro sequencer ----- */
	/* [ CS ADDR   * H ]  { , A81, A21, A68, A13, A82, A84 } */
	output     [13:0] cs_addr_h,
	input      [13:0] cs_addr_in_h,

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

    output            instr_fetch_h,

	/* [ DPM14 UVCTR BRANCH H ] A54 */
	output            uvctr_branch_h,

	input  [15:0]     xbuf_h,
	output [15:8]     xbuf_out_h,

	/* ----- BUT inputs ------ */
	/* [ UBI11 FPA PRESENT L ] C81 */
	input             fpa_present_l,
	/* [ UBI14 SYNCHR ACLO H ] C81 */
	input             sync_aclo_h,
	/* [ FP BOOT  1  H] { C81, B16 } */
	input     [1:0]   fp_boot_h,
	/* [ FP START 1 H ] { B57, B7 } */
	input     [1:0]   fp_start_h,
	/* [ MIC04 LATCHED MBUS 15 L ] A75 */
	input             mic_latched_mbus_15_l,
	/* [ FPA21 FPA ENABLED L     ] B17 */
	input             fpa_enabled_l,
	/* [      ]  */
	input             fpa_stall_l,
	/* [ FRNT PNL LOCK H         ] B13 */
	input             frnt_pnl_lock_h,
	/* [ UBI14 PREV DEST INH L   ] C85 */
	input             prev_dest_inh_l,
	/* [ DPM18 DEST RMODE H      ] B26 */
	output            dst_rmode_h,
 	/* ----- PSL bits ------ */
	/* [ DPM17 PSL CM H ] A92 */
	output            psl_cm_h,

    
    input         mem_stall_h,

    input  [1:0] ccbr_h,
    output [3:0] cc_ctrl_h,
    input  [3:0] wmuxz_h,
    input  [1:0] srk_st_h,
    input  [1:0] spa_st_h,
    
    /* Micro op fields */
    input [5:0]   wctrl_h,
    input [1:0]   cc_h,
    input [1:0]   dtype_h,
    input [1:0]   lit_h,
    input [5:0]   but_h,
    input [5:0]   next_h,
    input         istrm_h,
    input         clkx_h,
    input         long_lit_l,
    input         jsr_h,
    input         non_bcd_h,
    input         pslc_h,
    input [4:0]  misc_ctl_h,

    input         msrc_xb_h,
    input  [1:0]  clk_ctrl_h,

    output        gen_dest_inh_l,
    output        ird_ld_rnum_h,
    output [3:0]  ird_rnum_h,
    output [1:0]  dsize_h,
    output [1:0]  isize_l,
    input  [31:0] wbus_h,
	output [31:0] wbus_out_h,
	output ld_osr_l
);

	wire dsize_latch_byte_l;

	/* [ DPM17 DIS CS ADDR H ] */
	wire dis_cs_addr_h;

	/* [ DPM16 IRD1 L ] */
	wire ird1_l;


	/* [ DPM17 LD IR L ] */
	wire ld_ir_l;

	/* [ DPM17 LATCH UTRAP L ] */
	wire latch_utrap_l;

	/* [ DPM16 BUT 1 L ] */
	wire but_1_l;
	
	/* [ E57 pins 12,13 ] */
	assign but_1_l = ~but_h[1];

	/* [ DPM19 LD OSR A H ] */
	wire ld_osr_a_h;

	/* [ DPM18 ROM OS INH H ] */
	wire rom_os_inh_h;

	/* [ DPM17 ENABLE UVECT H ] */
	wire en_uvect_h;

	/* [ DPM16 BUT UVECT L ] */
	wire but_uvect_l;
    
	/* [ DPM14 USTK ADDR [3:0] H ] */
	wire [3:0] ustk_addr_h;

	/* [ DPM14 ENABLE IRD ROM H ] */
	wire en_ird_rom_h;

	/* [ DPM14 USTK OUT ENABLE L ] */
	wire ustk_out_en_l;

	/* [ DPM14 ZERO HI NEXT L ] */
	wire zero_hi_next_l;

	/* [ DPM14 FPA WAIT L ] */
	wire fpa_wait_l;

	assign ird1_h = ~ird1_l;

	assign ld_ir_l = ~(latch_utrap_l & ird1_h);

	assign dis_cs_addr_h = ~latch_utrap_l | ~mseq_init_l | ~micro_addr_inh_l;

    wire psl_fpd_h;
    wire [2:0] ird_ctr_h;
    wire ird_wbus_op_h;
    wire but_cc_a_h;
    wire index_mode_but_l;
    wire [1:0] ird_add_ctl_h;
    wire ld_osr_a_l;
    wire [7:0] ir_h;
    wire [1:0] dsize_lat_h;
    wire [1:0] dsize_lat_l;
    wire [1:0] disp_isize_h;
    wire [2:0] gd_sam_h;

	/* [ DPM13 CS ADDR H ] */
	wire [ 13 : 6 ] _cs_addr_z_h;
	wire [ 13 : 6 ] _cs_addr_ird_h;
	wire [ 13 : 6 ] _cs_addr_ustk_h;
	wire [  5 : 0 ] _cs_addr_msq_h;

	/* [ DPM14 CS ADDR [5:0] L ] */
	wire [  5 : 0 ] cs_addr_l;
	wire [  5 : 0 ] _cs_addr_sac_l;
	wire [  5 : 0 ] _cs_addr_msq_l;
	wire [  5 : 0 ] _cs_addr_ird_l;
	wire [  5 : 0 ] _cs_addr_uvec_l;
	wire [  5 : 0 ] _cs_addr_but_l;
	wire [  13 : 0 ] _cs_addr_h;
    
    /* [ E45 74S04 ] */
    assign ld_osr_a_h = ~ld_osr_a_l;

	/* [ E17 4,5,6 E24 12,13,11 ] */
	wire csa_13_11_z_h = en_ird_rom_h | ~zero_hi_next_l;

	assign _cs_addr_h[13 : 6] = cs_addr_in_h[13:6] & _cs_addr_ird_h & _cs_addr_ird_h & _cs_addr_z_h & _cs_addr_ustk_h;
	assign _cs_addr_h[ 5 : 0] = cs_addr_in_h[ 5:0] & _cs_addr_msq_h;

	assign cs_addr_h[13 : 6] = _cs_addr_ird_h & _cs_addr_ird_h & _cs_addr_z_h & _cs_addr_ustk_h;
	assign cs_addr_h[ 5 : 0] = _cs_addr_msq_h;

	/* [ E41 74S241 pins 3,5,7 ] */
	assign _cs_addr_z_h[13:11] = csa_13_11_z_h ? 3'b000 : 3'b111;
	
	/* [ E22, E23 ] */
	assign _cs_addr_z_h[10]    = zero_hi_next_l; 
	
	/* [ E41 74S241 pins 12,14,16,18 ] */
	assign _cs_addr_z_h[9:6]   = (~zero_hi_next_l) ? 4'b0000 : 4'b1111;

	/* E40 [ SN74S240 ] */
	assign _cs_addr_msq_h = micro_addr_inh_l ? ~cs_addr_l : 6'b111111; 

	assign cs_addr_l = _cs_addr_msq_l   & _cs_addr_uvec_l  &
					_cs_addr_but_l   & _cs_addr_ird_l;

	/******************/
	assign _cs_addr_sac_l[5:4] = 2'b11;

	clkgen clkgen_instance (
		.sac_reset_h(sac_reset_h),
		.mseq_init_l(mseq_init_l),
		.cpu_osc_in_h(cpu_osc_in_h),
		.mic_mem_stall_h(mic_mem_stall_h),
		.double_enable_h(double_enable_h),
		.clkx_h(clkx_h),
		.fpa_wait_l(fpa_wait_l),
		.fpa_stall_l(fpa_stall_l),
		.but_cc_a_h(but_cc_a_h),
		.but_h(but_h[2:0]),
		.psl_cm_h(psl_cm_h),
		.gen_dest_inh_l(gen_dest_inh_l),
		.ld_osr_l(ld_osr_l),
		.mic_utrap_l(mic_utrap_l),
		.cs_par_err_h(cs_par_err_h),
		.psl_tp_h(psl_tp_h),
		.arith_trap_l(arith_trap_l),
		.fpa_trap_l(fpa_trap_l),
		.tmr_svc_h(tmr_svc_h),
		.int_pend_l(int_pend_l),
		.con_halt_l(con_halt_l),
		.clk_ctrl_h(clk_ctrl_h),
		.addr_inh_l(micro_addr_inh_l),
		.ifetch_h(instr_fetch_h),
		.do_service_l(do_service_l),
		.uvector_h(en_uvect_h),
		.cs_addr_l(_cs_addr_sac_l[2:0]),
		.ird_ctr_h(ird_ctr_h),
		.latch_utrap_l(latch_utrap_l),
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
		.d_clk_enable_h(d_clk_enable_h)
	);


    instrdec instrdec_instance (
        .buf_b_clk_l(buf_b_clk_l),
        .buf_m_clk_l(buf_m_clk_l),
        .m_clk_en_h(m_clk_enable_h),
        .base_clock_h(base_clock_h),
		.micro_addr_inh_l(micro_addr_inh_l),
        .ld_ir_l(ld_ir_l),
        .ld_osr_l(ld_osr_l),
        .psl_fpd_h(psl_fpd_h),
        .psl_cm_h(psl_cm_h),
        .ird_ctr_h(ird_ctr_h),
        .wctrl_2_h(wctrl_h[2]),
        .mem_stall_h(mem_stall_h),
        .ird_wbus_op_h(ird_wbus_op_h),
        .ird1_h(ird1_h),
        .ird1_l(ird1_l),
        .ld_osr_a_h(ld_osr_a_h),
        .index_mode_but_l(index_mode_but_l),
        .fpa_enabled_l(fpa_enabled_l),
        .en_ird_rom_h(en_ird_rom_h),
        .ird_add_ctl_h(ird_add_ctl_h),
        .ir_h(ir_h),
        .xbuf_h(xbuf_h),
        .xbuf_out_h(xbuf_out_h),
        .ird_rnum_h(ird_rnum_h),
        .cs_addr_h(_cs_addr_ird_h),
        .cs_addr_l(_cs_addr_ird_l),
        .dst_rmode_h(dst_rmode_h),
        .rom_os_inh_h(rom_os_inh_h),
        .dsize_lat_h(dsize_lat_h),
        .dsize_lat_l(dsize_lat_l),
        .disp_isize_h(disp_isize_h)
    );

    microdec microdec_instance (
        .wctrl_h(wctrl_h),
        .cc_h(cc_h),
        .dtype_h(dtype_h),
        .lit_h(lit_h),
        .istrm_h(istrm_h),
        .msrc_xb_h(msrc_xb_h),
        .long_lit_l(long_lit_l),
        .dsize_lat_h(dsize_lat_h),
        .disp_isize_h(disp_isize_h),
        .dsize_h(dsize_h),
        .isize_l(isize_l),
        .gd_sam_h(gd_sam_h),
        .cc_ctrl_h(cc_ctrl_h),
        .ird_wbus_op_h(ird_wbus_op_h)
    );

    but but_instance (
		.sac_reset_h(sac_reset_h),
        .buf_m_clk_l(buf_m_clk_l),
        .d_clk_enable_h(d_clk_enable_h),
        .ld_ir_l(ld_ir_l),
        .ld_osr_l(ld_osr_l),
        .do_service_l(do_service_l),
        .int_pend_l(int_pend_l),
        .tmr_svc_h(tmr_svc_h),
        .ccbr_h(ccbr_h),
        .but_h(but_h),
        .but_1_l(but_1_l),
        .long_lit_l(long_lit_l),
        .gd_sam_h(gd_sam_h),
        .misc_ctl_h(misc_ctl_h),
        .wbus_h(wbus_h),
        .non_bcd_h(non_bcd_h),
        .pslc_h(pslc_h),
        .dst_rmode_h(dst_rmode_h),
        .sync_aclo_h(sync_aclo_h),
        .con_halt_l(con_halt_l),
        .fpa_present_l(fpa_present_l),
        .fpa_enabled_l(fpa_enabled_l),
        .dis_cs_addr_h(dis_cs_addr_h),
        .mic_latched_mbus_15_l(mic_latched_mbus_15_l),
        .prev_dest_inh_l(prev_dest_inh_l),
        .fp_boot_h(fp_boot_h),
        .fp_start_h(fp_start_h),
        .frnt_pnl_lock_h(frnt_pnl_lock_h),
        .wmuxz_h(wmuxz_h),
        .srk_st_h(srk_st_h),
        .spa_st_h(spa_st_h),
        .dsize_latch_h(dsize_lat_h),
        .dsize_latch_byte_l(dsize_latch_byte_l),
        .ir_h(ir_h),
        .psl_tp_h(psl_tp_h),
        .psl_cm_h(psl_cm_h),
        .psl_fpd_h(psl_fpd_h),
        .ird_add_ctl_h(ird_add_ctl_h),
        .ird_ld_rnum_h(ird_ld_rnum_h),
        .wbus_out_h(wbus_out_h),
        .cs_addr_l(_cs_addr_but_l),
        .but_cc_a_h(but_cc_a_h),
        .ird1_l(ird1_l),
        .index_mode_but_l(index_mode_but_l)
    );

	/* [ E37 85S68 ] */
	ram_85S68 ustk_ram_13_10 (
		.A(ustk_addr_h),
		.D(_cs_addr_h[13:10]),
		.Q(_cs_addr_ustk_h[13:10]),
		.nOS(phase_1_h),
		.nWE(1'b0),
		.OD(ustk_out_en_l),
		.clk(mclk_h) );

	/* [ E36 85S68 ] */
	ram_85S68 ustk_ram_9_6 (
		.A(ustk_addr_h),
		.D(_cs_addr_h[9:6]),
		.Q(_cs_addr_ustk_h[9:6]),
		.nOS(phase_1_h),
		.nWE(1'b0),
		.OD(ustk_out_en_l),
		.clk(mclk_h) );

	wire [5:0] ustk_q_h;
	wire [1:0] ustk_nc_h;

	/* [ E38 85S68 ] */
	ram_85S68 ustk_ram_5_2 (
		.A(ustk_addr_h),
		.D(_cs_addr_h[5:2]),
		.Q(ustk_q_h[5:2]),
		.nOS(phase_1_h),
		.nWE(1'b0),
		.OD(1'b0),
		.clk(mclk_h) );

	/* [ E39 85S68 ] */
	ram_85S68 ustk_ram_2_1 (
		.A(ustk_addr_h),
		.D({_cs_addr_h[1:0], 2'b0}),
		.Q({ustk_q_h[1:0], ustk_nc_h}),
		.nOS(phase_1_h),
		.nWE(1'b0),
		.OD(1'b0),
		.clk(mclk_h) );

	/* DPM14 predecodes */
	wire [7:0] e18_d_h;
	wire [2:0] e18_sel_h;
	assign e18_sel_h[2] = phase_1_h;
	assign e18_sel_h[1] = ~(but_1_l & but_h[0]); 
	assign e18_sel_h[0] = but_h[2];
	assign e18_d_h[3:0] = {4{ld_osr_a_h}};
	assign e18_d_h[5:4] = {2{but_cc_a_h}};
	assign e18_d_h[6]   =    1'b0;
	assign e18_d_h[7]   =    but_cc_a_h;
	sn74s151 E18 (
		.D  ( e18_d_h ),
		.SEL( e18_sel_h ),
		.nEN(1'b0),
		.B  (),
		.nB (ld_osr_l) );

	wire msq_osin_l = ~( rom_os_inh_h & phase_1_l & ~( psl_cm_h & ird1_h ));
	
	assign but_uvect_l = ~(but_h[5:1] == 5'b01111 & long_lit_l & ~dis_cs_addr_h);

	/* E52, E55 */
	assign uvctr_branch_h = en_uvect_h | ~but_uvect_l;

	/* [ E42 SN74S03 ] */
	assign _cs_addr_uvec_l = uvctr_branch_h ?  {2'b11, ~(micro_vector_h)} : 6'b111111;

	dc621_msq MSQ (
		.cs_addr_l(_cs_addr_msq_l),
		.bclk_l(buf_b_clk_l),
		.mclk_l(buf_m_clk_l),
		.next_h(next_h),
		.ustk_h(ustk_q_h),
		.jsr_h(jsr_h),
		.micro_addr_inh_l(micro_addr_inh_l),
		.but_cc_a_h(but_cc_a_h),
		.but_h(but_h[2:0]),
		.do_service_l(do_service_l),
		.uvector_h(en_uvect_h),
		.irdctr_h(ird_ctr_h[2:1]),
		.lit_h(lit_h),
		.init_l(mseq_init_l),
		.rom_os_inh_h(msq_osin_l),
		.zero_hi_next_l(zero_hi_next_l),
		.dis_hi_next_h(disable_hi_next_h),
		.ustk_out_en_l(ustk_out_en_l),
		.en_ird_rom_h(en_ird_rom_h),
		.ld_osr_l(ld_osr_a_l),
		.fpa_wait_l(fpa_wait_l),
		.ustk_addr_h(ustk_addr_h) );

endmodule