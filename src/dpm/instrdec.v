
 `include "chipmacros.vh"
module instrdec(
    input  buf_b_clk_l,
    input  buf_m_clk_l,
    input  m_clk_en_h,
    input  base_clock_h,
    input  ld_ir_l,
    input  ld_osr_l,
    input  psl_fpd_h,
    input  psl_cm_h,
    input  [2:0] ird_ctr_h,
    input  wctrl_2_h,
    input  mem_stall_h,

    /* [ E51 pin 9 ] Good samaritan ROM output  */
    input  ird_wbus_op_h,

    /* [ DPM16 IRD 1 H ] */
    input ird1_h,

    /* [ DPM16 IRD 1 L ] */
    input ird1_l,

    /* [ DPM19 LD OSR A H ] */
    input ld_osr_a_h,

    /* [ DPM16 INDEX MODE BUT L ] */
    input index_mode_but_l,

    /* [ FPA21 FPA ENABLED L ] */
    input fpa_enabled_l,

    /* [ DPM14 ENABLE IRD ROM H ] */
    input en_ird_rom_h,

    input micro_addr_inh_l,

    /* [ DPM17 IRD ADD CTL * H ] */
    input  [1:0]  ird_add_ctl_h,

    /* [ DPM18 IR * H ] */
    output [7:0]  ir_h,

    /* [ XBUF * H ] */
    input  [15:0] xbuf_h,
    output [15:8] xbuf_out_h,

    /* [ IRD RNUM * H ] */
    output [3:0]  ird_rnum_h,

    /* [ CS ADDR * H ] */
    output [13:6] cs_addr_h,

    /* [ CS ADDR * L ] */
    output [5:0]  cs_addr_l,

    /* [ DPM18 DST RMODE H ]  */
    output        dst_rmode_h,

    /* [ DPM18 ROM OS INH H ] */
    output        rom_os_inh_h,

    /* [ DPM19 DSIZE LATCH * (1) H ] */
    output [1:0] dsize_lat_h,

    /* [ DPM19 DSIZE LATCH * (0) H ] */
    output [1:0] dsize_lat_l,

    /* [ DPM18 DISP ISIZE * H ] */
    output [1:0] disp_isize_h
);

    wire [13:6] _rom_cs_addr_h;
    wire [5:0] _rom_cs_addr_l;
    wire [5:0] _ird_cs_addr_l;

    assign cs_addr_l = _rom_cs_addr_l & _ird_cs_addr_l;

    /* [ E6 pins {4,7} ] Output of DSIZE ROM after deinterleave mux */
    wire [1:0] dsize_rom_h;

    /* [ DPM20 IRD ACTL * H ] */
    wire [1:0] ird_actl_h;

    /* [ DPM20 IRD CONTROL L ] */
    wire ird_control_l;

    wire psl_cm_l;

	/* [ E55 SN74S04 ] */
	assign psl_cm_l = ~psl_cm_h;

    /* [ E3 74S74 ] pins without net names */
    reg  _e3_a_Q;
    wire _e3_a_nQ;
    reg  _e3_b_Q = 1'b0;
    wire _e3_b_nQ;

    /* [ E3(A) 74S74 ] */
    `FF_P( buf_b_clk_l, m_clk_en_h, _e3_a_Q )
    assign _e3_a_nQ = ~_e3_a_Q;

    /* [ E3(B) 74S74 ] */
    always @ ( negedge _e3_a_nQ or posedge base_clock_h ) begin
        if ( !_e3_a_nQ )
            _e3_b_Q <= 1'b0;
        else
            _e3_b_Q <= _e3_a_nQ;
    end
    assign _e3_b_nQ = ~_e3_b_Q;
    
    /* [ E5 74S10 pin 12 ] When asserted (0) this forces IRD ACTL 0 H high  */
    wire ird_ctl_override_l;

    /* [ E5  74S10 ]  */
    assign ird_ctl_override_l = ~(en_ird_rom_h & ~ird_add_ctl_h[1] & _e3_b_nQ);
    
    /* [ E5  74S10 ]  */
    assign ird_actl_h = ird_add_ctl_h | {1'b0, ~ird_ctl_override_l};
    
    /* [ E52 74S00 ] */
    assign ird_control_l = ~(ird_wbus_op_h & ~mem_stall_h);

    wire reg_mode_h;

    assign _ird_cs_addr_l[5:4] = 2'b11;

    dc622_ird gate_array (
        .mclk_l       (buf_m_clk_l),

        .xbuf_h       (xbuf_h),
        .xbuf_out_h   (xbuf_out_h),
        .psl_cm_h     (psl_cm_h),
        .ld_ir_l      (ld_ir_l),
        .ld_osr_l     (ld_osr_l),
        .ctl_h        (ird_actl_h),
        .sel_h        ({ird_control_l, wctrl_2_h}),
        .ir_h         (ir_h),
        .cs_addr_l    (_ird_cs_addr_l[3:0]),
        .rnum_h       (ird_rnum_h),
        .isize_h      (disp_isize_h),
        .dst_rmode_h  (dst_rmode_h),
        .reg_mode_h   (reg_mode_h)
    );

    irdroms roms (
        .xbuf_h        (xbuf_h[7:0]),
        .ir_h          (ir_h),
        .ird_ctr_h     (ird_ctr_h),
        .psl_cm_h      (psl_cm_h),
        .psl_cm_l      (psl_cm_l),
        .psl_fpd_h     (psl_fpd_h),
        .en_ird_rom_h  (en_ird_rom_h),
        .ird1_h        (ird1_h),
        .ird1_l        (ird1_l),
        .reg_mode_h    (reg_mode_h),
        .fpa_enabled_l (fpa_enabled_l),
        .cs_addr_l     (_rom_cs_addr_l),
        .cs_addr_h     (_rom_cs_addr_h),
        .dsize_h       (dsize_rom_h),
        .rom_os_inh_h  (rom_os_inh_h) );

	/* [ E22 ] */
    assign cs_addr_h[13:11] = _rom_cs_addr_h[13:11];
	assign cs_addr_h[10] =_rom_cs_addr_h[10] & ~( psl_cm_l & ird1_h & micro_addr_inh_l );
    assign cs_addr_h[9:6] = _rom_cs_addr_h[9:6];
    /* DSIZE LATCH */
    //XXX: Why is this called a latch, and why do they use a shift reg
    //     datasheet describes it as a normal quad DFF...
    /* [ E30 74S194 ] */
    wire [3:0] dsize_ld_h;
    reg  [3:0] dsize_lq_h = 4'b0000;

    wire dsize_le_h;

    /* [ E43 74S08 ] D Size latch enable */
    assign dsize_le_h      = index_mode_but_l & ld_osr_a_h;

    assign dsize_ld_h[1:0] = {  dsize_rom_h[0], ~dsize_rom_h[0] };
    assign dsize_ld_h[3:2] = { ~dsize_rom_h[1],  dsize_rom_h[1] };

    /* [ E30 74S194 ] */
    `FF_EN_P( buf_m_clk_l, dsize_le_h, dsize_ld_h, dsize_lq_h)

    /* [ DPM19 DSIZE LATCH * (1) H ] */
    assign dsize_lat_h = { dsize_lq_h[2], dsize_lq_h[1] };

    /* [ DPM19 DSIZE LATCH * (0) H ] */
    assign dsize_lat_l = { dsize_lq_h[3], dsize_lq_h[0] };
   
endmodule