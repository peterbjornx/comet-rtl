/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    ---
 * FUB:     but ( Branch on Micro Test )
 * Purpose: Implement microcode branches dependent on system state.
 *
 *          Micro branches are implemented by wired AND of the low-
 *          order bits of the next CS ADDR with selectable boolean
 *          functions of various state signals. The BUT[] micro-
 *          order selects which set of functions is evaluated.
 *
 *          About half of the possible BUT functions are implemented
 *          by the PHB gate array (E68), while the rest is built from
 *          discrete logic.
 *
 *          Besides microcode branches, the PHB gate array also holds
 *          the microcode state flags STATUS[5:0], the microcode step
 *          counter SC[4:0], BUT SERVICE flop and the PSL.CM,
 *          PSL.TBIT, and, PSL.TP flags.
 *
 * Changes: 74 series discrete logic mapped to Verilog RTL.
 *
 * Spec.  : KA750 schematic L0002-0-15,16,17 (DPM15, DPM16, DPM17)
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/

module but(
    /*************************************/
    /*           System timing           */
    /*************************************/
    input        sac_reset_h,
    input        buf_m_clk_l,
    input        d_clk_enable_h,

    /*************************************/
    /*       Micro operation fields      */
    /*************************************/

    /* [ DPM10 CCBR * H ] */
    input  [1:0] ccbr_h,

    /* BUT micro order */
    /* [ DPM12 BUT 5..0 H ] */
    input [5:0]  but_h,
    /* [ DPM16 BUT 1 L ] */
    input        but_1_l,

    input        long_lit_l,

    /* [ DPM20 PHB GD SAM * H ] Good Samaritan ROM out (predec. WCTRL H) */
    input [2:0]  gd_sam_h,

    input [4:0]  misc_ctl_h,

    /************************************/
    /*  Microsequencer control signals  */
    /************************************/

    /* [ DPM17 LD IR L ] */
    input        ld_ir_l,

    /* [ DPM14 LD OSR A ] */
    input        ld_osr_l,

    /* [ DPM17 DO SRVC L ] B8 */
    input        do_service_l,

    /* [ UBI14 INT PEND L ] A74 */
    input        int_pend_l,
    input        tmr_svc_h,

    input        dst_rmode_h,
    input        non_bcd_h,
    input [1:0]  dsize_latch_h,
    input        dsize_latch_byte_l,
    input [7:0]  ir_h,

	output [1:0] ird_add_ctl_h,
	output       ird_ld_rnum_h,

    /************************************/
    /*      Data/microaddress buses     */
    /************************************/
    input  [31:0] wbus_h,
    output [31:0] wbus_out_h,
    output [5:0]  cs_addr_l,

    /************************************/
    /*         PSL flags in/out         */
    /************************************/
    input        pslc_h,
    output       psl_tp_h,
    output       psl_cm_h,
    output       psl_fpd_h,

    /************************************/
    /*        BUT function inputs       */
    /************************************/

    /* [ UBI14 SYNCHR ACLO H ] B33 */
    input        sync_aclo_h,

    /* [ UBI11 CON HALT L ] B31 */
    input        con_halt_l,

    /* [ WCS19 PRESENT L ] C7, pulled high if no WCS present */
    input        wcs_present_l,

    /* [ FPA21 FPA PRESENT L ] C81, pulled high if no FPU present */
    input        fpa_present_l,

    input        fpa_enabled_l,
    input        dis_cs_addr_h,

    /* [ MIC04 LATCHED MBUS15 L ] A75 */
    input        mic_latched_mbus_15_l,
    input        prev_dest_inh_l,

    /* [ FP BOOT 1,0 H ] {B35, } */
    input [1:0]  fp_boot_h,

    /* [ FP START 1,0 H ] {B57, } */
    input [1:0]  fp_start_h,
    input        frnt_pnl_lock_h,

    input [3:0]  wmuxz_h,
    input [1:0]  srk_st_h,
    input [1:0]  spa_st_h,

    /* [ DPM16 BUT CTRL CODE A H ] */
    output        but_cc_a_h,

	/* [ DPM16 IRD1 L ] */
    output        ird1_l,

	/* [ DPM16 INDEX MODE BUT L ] */
    output        index_mode_but_l
);

	/* [ DPM16 INTERRUPT H ] */
	wire interrupt_h;

    /*  [ E48 74S138 ] internal AND enable output */
	wire but_dec0_en;

    /* Enable signals for the BUT 8 to 1 muxes */
    wire en_but_6xxx_l;
    wire en_but_5xxx_l;
    wire en_but_4xxx_l;

    /* Output signals for the BUT 8 to 1 muxes */
	wire [2:0] csa_but_6xxx_h;
	wire [1:0] csa_but_5xxx_h;
	wire       csa_but_4xxx_h;

    /* Individual BUT function signals input to the MUXes */
	wire but_21_csa0_h;
	wire but_2C_csa0_h;

	wire [5:0] _cs_addr_phb_l;

	/* [ E49 SN74S10 ] */
	/* Matches BUT=000x11 (RET.DINH, LOD.BRA)  */
	//XXX: This would make more sense if it matched 6,7 instead...
	assign index_mode_but_l = ~(but_cc_a_h & &but_h[1:0]);

	/* [ E49 SN74S10 ] */
	/* Matches 00010x (IRD1, IRD1TST) */
	assign ird1_l           = ~(but_cc_a_h & but_h[2] & but_1_l);

	/* [ E4 SN74S04 ] */
	/* Matches BUT = 000xxx iff LONG LIT L */
	assign but_cc_a_h       = long_lit_l & (but_h[5:3] == 3'b000);

	/* [ E48 74S138 ] */
	assign but_dec0_en = long_lit_l & ~dis_cs_addr_h;
	assign en_but_4xxx_l = ~(but_dec0_en & ( but_h[5:3] == 3'b100 ));
	assign en_but_5xxx_l = ~(but_dec0_en & ( but_h[5:3] == 3'b101 ));
	assign en_but_6xxx_l = ~(but_dec0_en & ( but_h[5:3] == 3'b110 ));

	/* [ E77 SN74S151 ] */
	/* BUT 0x30 - 0x37 CS ADDR BIT 2 selector */
	sn74s151 but_6xxx_csa2_mux (
		.D  ( { 2'b00,
		        ccbr_h[1]       , con_halt_l,
		        4'b0000 } ),
		.SEL( but_h[2:0] ),
		.nEN( en_but_6xxx_l ),
		.B  ( csa_but_6xxx_h[2] ),
		.nB ()
	);

	/* [ E76 SN74S151 ] */
	/* BUT 0x30 - 0x37 CS ADDR BIT 1 selector */
	sn74s151 but_6xxx_csa1_mux (
		.D  ( { srk_st_h[1]     , ccbr_h[0],
		        ccbr_h[0]       , fp_start_h[1],
		        fp_boot_h[1]    , sync_aclo_h,
				dsize_latch_h[1], fpa_present_l } ),
		.SEL( but_h[2:0] ),
		.nEN( en_but_6xxx_l ),
		.B  ( csa_but_6xxx_h[1] ),
		.nB ()
	);

	/* [ E66 SN74S151 ] */
	/* BUT 0x30 - 0x37 CS ADDR BIT 0 selector */
	sn74s151 but_6xxx_csa0_mux (
		.D  ( { srk_st_h[0]     , srk_st_h[0],
		        ir_h[0]         , fp_start_h[0],
				fp_boot_h[0]    , frnt_pnl_lock_h,
				dsize_latch_h[0], fpa_enabled_l} ),
		.SEL( but_h[2:0] ),
		.nEN( en_but_6xxx_l ),
		.B  ( csa_but_6xxx_h[0] ),
		.nB ()
	);

	/* [ E62 74S20 ] */
	wire wmuxz_all_l   = ~&wmuxz_h;

	/* [ E57 74S04 ] */
	wire wmuxz_all_h   = ~wmuxz_all_l;

	/* [ E52 74S00 ] [ E57 74S04 ] */
	/* Either an interrupt or timer is pending */
	assign interrupt_h = ~int_pend_l | tmr_svc_h;

	/* [ E43 74S08 ] [ E57 74S04 ] */
	assign but_2C_csa0_h = interrupt_h & ~ccbr_h[1];

	/* [ E54 SN74S151 ] */
	/* BUT 0x28 - 0x2F CS ADDR BIT 1 selector */
	sn74s151 but_5xxx_csa1_mux (
		.D  ( { 1'b0            , spa_st_h[1],
		        ccbr_h[1]       , ccbr_h[1],
				int_pend_l      , mic_latched_mbus_15_l,
				2'b00 } ),
		.SEL( but_h[2:0] ),
		.nEN( en_but_5xxx_l ),
		.B  ( csa_but_5xxx_h[1] ),
		.nB () );

	/* [ E67 SN74S151 ] */
	/* BUT 0x28 - 0x2F CS ADDR BIT 0 selector */
	sn74s151 but_5xxx_csa0_mux (
		.D  ( { psl_tp_h        , spa_st_h[0],
			    ccbr_h[0]       , but_2C_csa0_h,
				tmr_svc_h       , wmuxz_all_l,
				 wmuxz_all_l    , wmuxz_all_h} ),
		.SEL( but_h[2:0] ),
		.nEN( en_but_5xxx_l ),
		.B  ( csa_but_5xxx_h[0] ),
		.nB () );

	/* BUT 0x21 CM.ODD.ADD */
	assign but_21_csa0_h = dsize_latch_byte_l & wbus_h[0];

	/* [ E46 SN74S151 ] */
	/* BUT 0x20 - 0x27 CS ADDR BIT 0 selector */
	sn74s151 but_4xxx_csa0_mux (
		.D  ( { 
			wcs_present_l       , non_bcd_h,
			pslc_h              , dst_rmode_h,
			ir_h[5]             , ir_h[2],
			but_21_csa0_h       , prev_dest_inh_l } ),
		.SEL( but_h[2:0] ),
		.nEN( en_but_4xxx_l ),
		.B  ( csa_but_4xxx_h ),
		.nB ()
	);

    /* CS ADDR wired AND */
	assign cs_addr_l[0]   = _cs_addr_phb_l[0] & ~csa_but_4xxx_h & ~csa_but_5xxx_h[0] & ~csa_but_6xxx_h[0];
	assign cs_addr_l[1]   = _cs_addr_phb_l[1] & ~csa_but_5xxx_h[1] & ~csa_but_6xxx_h[1];
	assign cs_addr_l[2]   = _cs_addr_phb_l[2] & ~csa_but_6xxx_h[2];
	assign cs_addr_l[5:3] = _cs_addr_phb_l[5:3];

    /* WBUS unused bits pulled high to allow wired-AND in parent fub */
	assign wbus_out_h[29:28] = 2'b11;
	assign wbus_out_h[26:6]  = 21'h1FFFFF;

    /* [ E68 DC629 PHB ] */
	dc629_phb PHB (
		.sac_reset_h(sac_reset_h),
		.mclk_l(buf_m_clk_l),
		.d_clk_en_h(d_clk_enable_h),
		.wbus_31_30_h(wbus_h[31:30]),
		.wbus_27_h(wbus_h[27]),
		.wbus_5_0_h(wbus_h[5:0]),
		.wbus_31_30_out_h(wbus_out_h[31:30]),
		.wbus_27_out_h(wbus_out_h[27]),
		.wbus_5_0_out_h(wbus_out_h[5:0]),
		.misc_ctl_h(misc_ctl_h),
		.gd_sam_h(gd_sam_h[2:0]),
		.ibut_l(long_lit_l),
		.ld_ir_l(ld_ir_l),
		.do_service_l(do_service_l),
		.ld_osr_l(ld_osr_l),
		.interrupt_h(interrupt_h),
		.dis_cs_addr_h(dis_cs_addr_h),
		.but_h(but_h),
		.psl_cm_h(psl_cm_h),
		.psl_fpd_h(psl_fpd_h),
		.psl_tm_h(psl_tp_h),
		.ird_add_ctl(ird_add_ctl_h),
		.ird_ldrnum_h(ird_ld_rnum_h),
		.cs_addr_l(_cs_addr_phb_l),
		.but_cc_h()	);

endmodule