module irdroms(
    input [7:0]   xbuf_h,
    input [7:0]   ir_h,
    input [2:0]   ird_ctr_h,
    input         psl_cm_h, 
	input         psl_cm_l,
    input         psl_fpd_h,
    input         en_ird_rom_h,
    input         ird1_h,
    input         ird1_l,
    input         reg_mode_h,
    input         fpa_enabled_l,

    output [5:0]  cs_addr_l,
    output [13:6] cs_addr_h,
    output [1:0]  dsize_h,
    output        rom_os_inh_h
);

    wire [5:0]  _cs_addr_ird1n_l;
    wire [5:0]  _cs_addr_irdxn_l;
    wire [5:0]  _cs_addr_irdcm_l;
    
    wire [9:0]  nm_ird1_addr_h;
	wire [10:0] nm_irdx_addr_h;
	wire [10:0] cm_ird_addr_h;
	wire [10:0] dsize_addr_h;

    wire [10:6] _cs_addr_ird1n_h;
    wire [10:6] _cs_addr_irdxn_h;
    wire [10:6] _cs_addr_irdc_h;
    wire        _rom_os_inh_nm_h;
    wire        _rom_os_inh_nmx_h;
	wire        cm_ird_unused_h;

    wire [3:0]  dsize_q_h;

    assign rom_os_inh_h = _rom_os_inh_nm_h & _rom_os_inh_nmx_h;
    assign cs_addr_h[10:6]  = _cs_addr_ird1n_h & _cs_addr_irdxn_h & _cs_addr_irdc_h;
    assign cs_addr_h[13:11] = 3'b111;
    assign cs_addr_l        = _cs_addr_ird1n_l & _cs_addr_irdxn_l & _cs_addr_irdcm_l;

	/* NATIVE MODE IRD1 ROM */
	assign nm_ird1_addr_h[9:2] = xbuf_h[7:0];
	assign nm_ird1_addr_h[1]   = fpa_enabled_l;
	assign nm_ird1_addr_h[0]   = psl_fpd_h;
	wire nm_ird1_en_l = ~(en_ird_rom_h & psl_cm_l);

	/* [ E20 82S137 ] */
	rom_82S137 #(
		.INIT_FILE("rom/nm_ird1_hi.hex")
	) NATIVE_MODE_IRD1_hi (
		.A(nm_ird1_addr_h),
		.Q(_cs_addr_ird1n_h[9:6]),
		.nCE1(ird1_l),
		.nCE2(nm_ird1_en_l)
	);

	/* [ E21 82S136 ] */
	rom_82S137 #(
		.INIT_FILE("rom/nm_ird1_lo.hex")
	) NATIVE_MODE_IRD1_lo (
		.A(nm_ird1_addr_h),
		.Q({_rom_os_inh_nm_h, _cs_addr_ird1n_l[5:3]}),
		.nCE1(ird1_l),
		.nCE2(nm_ird1_en_l)
	);
	assign _cs_addr_ird1n_h[10] = 1'b1;
	assign _cs_addr_ird1n_l[2:0] = 3'b111;

	/* NATIVE MODE IRDX ROM */
	assign nm_irdx_addr_h[10:3] = ir_h[7:0];
	assign nm_irdx_addr_h[2]   = ird_ctr_h[0];
	assign nm_irdx_addr_h[1]   = fpa_enabled_l;
	assign nm_irdx_addr_h[0]   = reg_mode_h;
	wire nm_irdx_en_l = ~(en_ird_rom_h & psl_cm_l & ird1_l);

	/* [ E27 82S185 ] */
	rom_82S185 #(
		.INIT_FILE("rom/nm_irdx_hi.hex")
	) NATIVE_MODE_IRDX_hi (
		.A(nm_irdx_addr_h),
		.Q({_cs_addr_irdxn_h[6],_cs_addr_irdxn_h[9],_cs_addr_irdxn_h[8:7]}),
		.nCE(nm_irdx_en_l)
	);

	/* [ E10 82S184 ] */
	rom_82S185 #(
		.INIT_FILE("rom/nm_irdx_mid.hex")
	) NATIVE_MODE_IRDX_mid (
		.A(nm_irdx_addr_h),
		.Q({_cs_addr_irdxn_h[10],_cs_addr_irdxn_l[5:3]}),
		.nCE(nm_irdx_en_l)
	);

	/* [ E11 82S184 ] */
	rom_82S185 #(
		.INIT_FILE("rom/nm_irdx_lo.hex")
	) NATIVE_MODE_IRDX_lo (
		.A(nm_irdx_addr_h),
		.Q({_cs_addr_irdxn_l[2:0],_rom_os_inh_nmx_h}),
		.nCE(nm_irdx_en_l)
	);


	/* COMPATIBILITY MODE IRD1 ROM */
	assign cm_ird_addr_h[10:3] = ir_h[7:0];
	assign cm_ird_addr_h[2]   = ird1_h;
	assign cm_ird_addr_h[1]   = ird_ctr_h[0];
	assign cm_ird_addr_h[0]   = reg_mode_h;
	wire   cm_ird_en_l = ~(en_ird_rom_h & psl_cm_h);

	/* [ E25 82S185 ] */
	rom_82S185 #(
		.INIT_FILE("rom/cm_ird_hi.hex")
	) COMPAT_MODE_IRD_hi (
		.A(cm_ird_addr_h),
		.Q({_cs_addr_irdc_h[6],_cs_addr_irdc_h[9],_cs_addr_irdc_h[8:7]}),
		.nCE(cm_ird_en_l)
	);

	/* [ E9 82S184 ] */
	rom_82S185 #(
		.INIT_FILE("rom/cm_ird_mid.hex")
	) COMPAT_MODE_IRD_mid (
		.A(cm_ird_addr_h),
		.Q({_cs_addr_irdc_h[10],_cs_addr_irdcm_l[5:3]}),
		.nCE(cm_ird_en_l)
	);

	/* [ E8 82S184 ] */
	rom_82S185 #(
		.INIT_FILE("rom/cm_ird_lo.hex")
	) COMPAT_MODE_IRD_lo (
		.A(cm_ird_addr_h),
		.Q({_cs_addr_irdcm_l[2:0],cm_ird_unused_h}),
		.nCE(cm_ird_en_l)
	);

    assign dsize_addr_h[10]  = psl_cm_h;
	assign dsize_addr_h[9:2] = ir_h[7:0];
	assign dsize_addr_h[1:0] = ird_ctr_h[2:1];

    /* [ E7 82S185 ] */
    rom_82S185 #(
        .INIT_FILE("rom/dsize.hex")
    ) DSIZE_ROM (
        .A(dsize_addr_h),
        .Q(dsize_q_h),
        .nCE(1'b0)
    );

    /* [ E6 75S157 ] */
    assign dsize_h[0] = ird_ctr_h[0] ? dsize_q_h[2] : dsize_q_h[3];
    assign dsize_h[1] = ird_ctr_h[0] ? dsize_q_h[0] : dsize_q_h[1];

endmodule