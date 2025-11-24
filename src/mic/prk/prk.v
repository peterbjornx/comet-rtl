`include "chipmacros.vh"
`include "ucodedef.vh"

module dc624_prk(
    input b_clk_l,
    input d_clk_en_h,
    input m_clk_en_h,

    input       dst_rmode_h,
    input [3:0] lbus_h,
    input       bus_4_h,
    input [4:0] msrc_h,
    input [5:0] wctrl_h,

    input       ld_osr_l,
    input       mseq_init_l,
    input       phase_1_h,
    input       psl_cm_h,
    input       snapshot_cmi_l,
    input       status_valid_l,
    input       utrap_l,
    input [1:0] xb_pc_h,
    input [1:0] isize_l,
    input       ird1_h,

    output       ena_pc_l,
    output       ena_va_save_l,
    output       enable_acv_stall_h,
    output       latch_ma_l,
    output [1:0] ma_select_h,
    output       mmux_sel_s1_h,
    output       prefetch_l,
    output       stall_l,
    output       xb_select_h,
    output [1:0] xb_in_use_l );

    wire b_clk_h = ~b_clk_l;
    wire mseq_init_h = ~mseq_init_l;
    wire utrap_h = ~utrap_l;
    wire ld_osr_h = ~ld_osr_l;
    reg bus_cyc_dec_h;
    reg latched_bus_4_h = 1'b0;
    reg ena_ld_osr_h = 1'b0;
    reg clk_osr_h = 1'b0;
    wire dest_mdr_h;
    wire dest_wdr_h;
    wire bus_req_h;
    wire bus_grant_dec_h;
    wire msrc_xb_h;
    wire pa_bus_req_h;
    wire bytes_req_0_h ;
    wire bytes_req_1_h ;
    wire bytes_req_h;
    wire dest_pc_h;
    wire pc_enable_h;
    wire load_pc_h;
    reg pc_clk_req_h = 1'b0;
    wire toggle_2_h;
    wire steer_comp_dump_h;
    wire steer_dump_h;
    reg phase_2_del_h = 1'b0;
    reg latched_utrap_h = 1'b0;
    reg status_val_h = 1'b0;
    reg status_val_del_h = 1'b0;
    reg aborted_cyc_h = 1'b0;
    reg force_bus_add_h = 1'b0;
    wire steer_va_h;
    wire ena_msrc_add_h;
    wire prefetch_inh_h;
    reg read_h = 1'b0;
    wire read_cyc_h;
    reg mmux_s1_h = 1'b0;
    reg delay_h = 1'b0;
    wire load_mdr_h;
    reg mdr_ldd_h = 1'b0;
    reg xb_sel_del_h = 1'b0;
    reg xb1_ldd_h = 1'b0;
    reg xb0_ldd_h = 1'b0;
    reg reset_xb1_ldd_h = 1'b0;
    reg reset_xb0_ldd_h = 1'b0;
    reg xb_sel_h = 1'b0;
    wire xb_req_h;
    wire fill_xb_req_h;
    wire prefetch_req_h;
    wire ena_pre_add_h;
    wire force_va_h;
    reg ma_sel_s1_h = 1'b0;
    reg ma_sel_s0_h = 1'b0;
    reg latch_ma_h = 1'b0;
    reg latch_ma_del_h = 1'b0;
    reg tim_acv_stall_h = 1'b0;
    reg latched_xb_stall_h = 1'b0;
    wire xb_stall_h;
    wire delay_stall_h;
    wire bus_cyc_stall_h;
    wire pa_bus_ph1_stall_h;
    wire pa_bus_ph2_stall_h;
    wire msrc_stall_h;
    wire mdr_stall_h;
    wire mem_cyc_stall_h;
    reg  init_a_h = 1'b0;
    wire no_prefetch_h;
    wire no_prefetch_a_h;
    wire prefetch_h;
    wire both_xbs_req_h;
    wire init_h = mseq_init_h; /* TODO: where is INIT supposed to come from */

    `define CHIP_PRK
    `include "cycseq.vh"

    wire _svh_p_h = b_clk_l & ~status_valid_l & ( mseq_init_h | ~status_val_del_h );
    `FF_PRESET_P( b_clk_l, _svh_p_h, mseq_init_h, status_val_h)

    `FF_P( b_clk_l, status_val_h, status_val_del_h )

    wire _lb4_j_h = m_clk_en_h &  bus_4_h;
    wire _lb4_k_h = m_clk_en_h & ~bus_4_h;
    `JKFF_P( b_clk_l, _lb4_j_h, _lb4_k_h, latched_bus_4_h )

    wire [4:0] latched_bus_h = {latched_bus_4_h, lbus_h};

    always @ ( latched_bus_h ) begin
        case( latched_bus_h )
            `UC_BUS_READ         : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_PHY     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_NT      : bus_cyc_dec_h <= 1'b1;
             5'h04               : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_SEC     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_LNG     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_MOD_LCK : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_MOD     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_LNG_MOD : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE        : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_LNG    : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_UL     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_PHY    : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_SEC    : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_UL_SEC : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_NT     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_NT_LNG : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_GRANT        : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_NOREG  : bus_cyc_dec_h <= ~dst_rmode_h;
            default: bus_cyc_dec_h <= 1'b0;
        endcase
    end

    assign bus_grant_dec_h = latched_bus_h == `UC_BUS_GRANT;

    assign bus_req_h = (
        wctrl_h == `UC_WCTRL_MDR_WB       |
        wctrl_h == `UC_WCTRL_MBUS_WDR     |
        wctrl_h == `UC_WCTRL_MDR_0        |
        wctrl_h == `UC_WCTRL_TB_WB        |
        wctrl_h == `UC_WCTRL_CLRTB_VA_WB  |
        wctrl_h == `UC_WCTRL_WDR_WB_UR    |
        wctrl_h == `UC_WCTRL_MDR_IR       |
        wctrl_h == `UC_WCTRL_CLRCH_VA_WB  |
        wctrl_h == `UC_WCTRL_WDR_WB       |
        wctrl_h == `UC_CCPSL_MDR_OSR_CCBR_BRATST ) | (
            latched_bus_h != `UC_BUS_PRINIT &
            latched_bus_h != `UC_BUS_IOINIT &
            latched_bus_h != `UC_BUS_NOP  );
    
    assign dest_mdr_h = (
        wctrl_h == `UC_WCTRL_MDR_WB |
        wctrl_h == `UC_WCTRL_MDR_0  | 
        wctrl_h == `UC_WCTRL_MDR_IR  | 
        wctrl_h == `UC_CCPSL_MDR_OSR_CCBR_BRATST );

    assign dest_wdr_h = (
        wctrl_h == `UC_WCTRL_WDR_WB |
        wctrl_h == `UC_WCTRL_WDR_WB_UR );

    assign msrc_xb_h = msrc_h == 5'h17;

    assign pa_bus_req_h = (
        latched_bus_h == `UC_BUS_PRB_WR_PTE |
        latched_bus_h == `UC_BUS_PRB_RD_PTE |
        latched_bus_h == `UC_BUS_PRB_RD_PTE_K |
        latched_bus_h == `UC_BUS_PRB_WR_MODE |
        latched_bus_h == `UC_BUS_PRB_WR |
        latched_bus_h == `UC_BUS_PRB_RD_MODE |
        latched_bus_h == `UC_BUS_PRB_RD ) | (
            wctrl_h == `UC_WCTRL_TB_WB |
            wctrl_h == `UC_WCTRL_CLRTB_VA_WB |
            wctrl_h == `UC_WCTRL_CLRCH_VA_WB  // Should the VA <- WBUS be here too?
        );
    wire either_xb_stall_h = xb_stall_h | latched_xb_stall_h;

    wire _elo_s_h = ~b_clk_l & ~phase_1_h;
    wire _elo_r_h = ~b_clk_l &  phase_1_h;
    always @ (  _elo_s_h or  _elo_r_h )
        if ( _elo_s_h )
            ena_ld_osr_h <= 1;
        else
            ena_ld_osr_h <= 0;

    `LATCH_P( ena_ld_osr_h, ld_osr_h, clk_osr_h )

    assign bytes_req_0_h = ( ~isize_l[0] & msrc_xb_h ) |
        ( ~msrc_xb_h & ( ld_osr_h ^ ird1_h ));
    
    assign bytes_req_1_h = ( ~isize_l[1] & msrc_xb_h ) |
        ( ~msrc_xb_h & ld_osr_h & ird1_h );
    
    assign bytes_req_h = phase_1_h & ( bytes_req_0_h | bytes_req_1_h );
    
    assign both_xbs_req_h = 
        ( xb_pc_h[1] | bytes_req_1_h  & bytes_req_0_h ) &  
        ( xb_pc_h[0] | bytes_req_1_h  & bytes_req_0_h ) &
        ( &xb_pc_h[1:0] | bytes_req_1_h );
    
    assign dest_pc_h = ( wctrl_h == 6'h24 | wctrl_h == 6'h2C);

    assign pc_enable_h = utrap_l & ( bytes_req_1_h | bytes_req_0_h | dest_pc_h );

    assign load_pc_h = dest_pc_h & pc_enable_h & m_clk_en_h;

    wire _pcr_j = phase_1_h & pc_enable_h;
    wire _pcr_k = (phase_1_h & ~pc_enable_h) | (m_clk_en_h & cyc_in_prog_h);
    `JKFF_P( b_clk_l, _pcr_j, _pcr_k, pc_clk_req_h )

    assign toggle_2_h = 
        pc_enable_h & m_clk_en_h & 
        ( xb_pc_h[1] | bytes_req_1_h ) &  
        ( xb_pc_h[0] | bytes_req_1_h ) &
        ( xb_pc_h[1] | bytes_req_0_h ) &   
        ( bytes_req_1_h | bytes_req_0_h );
    
    assign steer_comp_dump_h = 
        bus_cyc_dec_h & ~bus_grant_dec_h & latched_bus_h[3] & psl_cm_h & d_clk_en_h;
    
    assign steer_dump_h =
        load_pc_h | steer_comp_dump_h;

    `FF_RESET_P( b_clk_l, phase_1_h, ~phase_1_h, phase_2_del_h )

    wire _lut_k_h = bytes_req_h | load_pc_h;
    `JKFF_PRESET_P( b_clk_l, mseq_init_h, utrap_h, _lut_k_h, latched_utrap_h )

    wire _ac_j_h = prefetch_del_h & steer_dump_h & ~status_val_h;
    wire _ac_k_h = status_val_h | mseq_init_h;
    `JKFF_P( b_clk_l, _ac_j_h, _ac_k_h, aborted_cyc_h )

    wire _fba_j = prefetch_l &   m_clk_en_h &  bus_4_h;
    wire _fba_k = prefetch_h | ( m_clk_en_h & ~bus_4_h );
    `JKFF_P( b_clk_l, _fba_j, _fba_k, force_bus_add_h )
    
    assign steer_va_h = bus_4_h & m_clk_en_h & prefetch_l;

    assign ena_msrc_add_h = ( prefetch_l & phase_1_h ) & (
        msrc_h == 5'h18 |
        msrc_h == 5'h1A | 
        msrc_h == 5'h19 |
        msrc_h == 5'h1B );

    assign prefetch_inh_h = latched_utrap_h & ~prefetch_del_h & ~bytes_req_h;

    wire _rd_d_h = prefetch_h | ~latched_bus_h[3];
    `LATCH_P( add_reg_ena_h, _rd_d_h, read_h )

    assign read_cyc_h = prefetch_h | replacement_h |
        ( cyc_in_prog_h & ~add_reg_ena_h & read_h );

    wire _mms1_d_h = ( snapshot_cmi_l & ~either_xb_stall_h ) &
        ( ena_msrc_add_h | ( cyc_in_prog_h & prefetch_l & msrc_h == 5'h1F));
    wire _mms1_r_h = ~phase_1_h;
    `FF_RESET_P( b_clk_l, _mms1_r_h, _mms1_d_h, mmux_s1_h )
    assign mmux_sel_s1_h = mmux_s1_h | ( ~phase_1_h & pa_bus_req_h );

    wire _dly_d_h = inval_check_h & pa_bus_req_h;
    `FF_P( b_clk_l, _dly_d_h, delay_h )
    
    assign load_mdr_h = status_val_h & read_h & ~prefetch_cyc_h;

    wire _mld_k_h = bus_cyc_dec_h & latched_bus_h[3] & d_clk_en_h;
    `JKFF_P( b_clk_l, load_mdr_h, _mld_k_h, mdr_ldd_h )

    `FF_P( b_clk_l, xb_sel_h, xb_sel_del_h )
    
    wire _xb_ldd_d_l = steer_comp_dump_h | load_pc_h;
    wire _xb_ldd_j_h = status_val_h & prefetch_cyc_h & ~aborted_cyc_h & ~_xb_ldd_d_l;
    wire _xb_ldd_k_h = _xb_ldd_d_l | mseq_init_h;

    wire _x1l_j_h = _xb_ldd_j_h & xb_sel_del_h;
    wire _x1l_k_h = _xb_ldd_k_h | 
                    ( toggle_2_h & ~xb_sel_h );
    `JKFF_P( b_clk_l, _x1l_j_h,  _x1l_k_h, xb1_ldd_h )
    
    wire _x0l_j_h = _xb_ldd_j_h & ~xb_sel_del_h;
    wire _x0l_k_h = _xb_ldd_k_h | 
                    ( toggle_2_h & xb_sel_h );
    `JKFF_P( b_clk_l, _x0l_j_h,  _x0l_k_h, xb0_ldd_h )

    wire _rxb1_d_h = _xb_ldd_d_l | (
        (xb1_ldd_h | aborted_cyc_h | ~xb_sel_h | ~prefetch_cyc_h | ~status_val_h) &
        (~xb1_ldd_h | mseq_init_h | toggle_2_h & ~xb_sel_h ) );
    `LATCH_P( b_clk_h, _rxb1_d_h, reset_xb1_ldd_h )

    wire _rxb0_d_h = _xb_ldd_d_l | (
        (xb0_ldd_h | aborted_cyc_h | xb_sel_h | ~prefetch_cyc_h | ~status_val_h) &
        (~xb0_ldd_h | mseq_init_h | toggle_2_h & xb_sel_h ) );
    `LATCH_P( b_clk_h, _rxb0_d_h, reset_xb0_ldd_h )

    wire _xbs_j_h = reset_xb0_ldd_h & ~reset_xb0_ldd_h;
    `JKFF_P( b_clk_h, _xbs_j_h, reset_xb0_ldd_h, xb_sel_h )

    wire _xb1_sel_h = xb_sel_h | both_xbs_req_h;
    wire _xb0_sel_h = ~xb_sel_h | both_xbs_req_h;

    assign xb_req_h = 
        ( ~xb1_ldd_h | _xb1_sel_h ) &
        ( ~xb0_ldd_h | _xb0_sel_h) &
        ( bytes_req_1_h | bytes_req_0_h ) &
        ( ~xb1_ldd_h | ~xb0_ldd_h );

    assign fill_xb_req_h =
        status_val_h & prefetch_cyc_h & ~aborted_cyc_h & (
            xb1_ldd_h | xb0_ldd_h );
    
    assign prefetch_req_h = 
        ( ~xb1_ldd_h & ~xb0_ldd_h ) |
        ( (~xb1_ldd_h | ~xb0_ldd_h) & ( prefetch_cyc_h | aborted_cyc_h ));

    assign ena_pre_add_h = toggle_2_h | steer_comp_dump_h | load_pc_h | 
        ( prefetch_req_h & ( m_clk_en_h | prefetch_h));

    assign force_va_h = 
        ( ~ena_msrc_add_h & ~ena_pre_add_h) |
        (  ena_msrc_add_h &  msrc_h[1:0] == 2'b00);

    wire _mss1_d_h = 
        steer_va_h |
        force_va_h |
        ( ena_msrc_add_h | msrc_h[1] ) |
        ( ena_pre_add_h & 
        ( ~cyc_in_prog_h | ~prefetch_cyc_h | aborted_cyc_h )) &
        ( toggle_2_h & ( ~xb1_ldd_h | ~xb0_ldd_h ) | 
        steer_dump_h | ( ~xb0_ldd_h & ~xb1_ldd_h ));

    `FF_P( b_clk_l, _mss1_d_h, ma_sel_s1_h )

    wire _mss0_d_h = 
        steer_va_h | force_va_h |
        ( ena_msrc_add_h & msrc_h[0] );
    `FF_P( b_clk_l, _mss0_d_h, ma_sel_s0_h )

    wire _lma_j_h = 
        utrap_h |
        ( ~ena_msrc_add_h & 
        ( ma_sel_s1_h | prefetch_h ) &
        ( ma_sel_s0_h | prefetch_h ) &
        ( ~inval_check_h & inval_write_h) &
        ( add_reg_ena_h & ~cyc_in_prog_h)) &
        ((pa_bus_req_h & prefetch_l) | mem_req_h );
    
    wire _lma_k_h =
        (~utrap_h & dest_pc_h &
         m_clk_en_h & latched_utrap_h) |
        (~utrap_h & ~latched_utrap_h) &
        ((m_clk_en_h & prefetch_l) |
        (prefetch_cyc_h & add_reg_ena_h)) |
        (latched_utrap_h & phase_1_h ) &
        ( bytes_req_h | pa_bus_req_h | /*?*/
        bus_cyc_dec_h | ena_msrc_add_h );
    `JKFF_RESET_P( b_clk_h, init_h, _lma_j_h, _lma_k_h, latch_ma_h )

    `FF_P( b_clk_l, latch_ma_l, latch_ma_del_h )

    wire _tas_j_h = ~phase_1_h & enable_acv_stall_h;
    `JKFF_P( b_clk_l, _tas_j_h, phase_1_h, tim_acv_stall_h )

    assign enable_acv_stall_h = 
        ~phase_1_h & prefetch_l & add_reg_ena_h &
        latch_ma_del_h & ~tim_acv_stall_h & bus_cyc_dec_h;
    
    wire _lxs_s_h = prefetch_h & ~prefetch_inh_h &
        ~fill_xb_req_h & xb_req_h & b_clk_h;
    wire _lxs_r_h = prefetch_inh_h | prefetch_l | fill_xb_req_h;
    always @ ( _lxs_s_h or _lxs_r_h ) begin
        if (_lxs_s_h)
            latched_xb_stall_h <= 1'b1;
        else if (_lxs_r_h)
            latched_xb_stall_h <= 1'b0;
    end

    assign xb_stall_h =  ~prefetch_inh_h & ~fill_xb_req_h & xb_req_h;

    assign delay_stall_h = delay_h & ~phase_1_h;

    wire bus_cyc_stall_a_h = ( bus_cyc_dec_h & ~ena_msrc_add_h &  phase_1_h ) & ( ~ma_sel_s1_h   | ~ma_sel_s0_h     |  prefetch_h );
    wire bus_cyc_stall_b_h = ( bus_cyc_dec_h &                   ~phase_1_h ) & ( ~add_reg_ena_h  | ~latch_ma_del_h |  prefetch_h );

    assign bus_cyc_stall_h = bus_cyc_stall_a_h | bus_cyc_stall_b_h;
    
    assign pa_bus_ph1_stall_h = 
        ( pa_bus_req_h & ~ena_msrc_add_h & phase_1_h ) &
        ( ~ma_sel_s1_h | ~ma_sel_s0_h | prefetch_h |
         inval_check_h | status_val_h | cyc_in_prog_h );

    assign pa_bus_ph2_stall_h =
        ( pa_bus_req_h & ~phase_1_h ) &
        ( inval_check_h & ~latch_ma_del_h );


    /* MSRC STALL because MMUX overridden */
    wire msrc_stall_group_a_h = 
        ~mmux_sel_s1_h & (
            msrc_h == 5'h1F | /* TB DATA -> PAD -> MBUS */
            msrc_h == 5'h18 | /* MA      -> MBUS */
            msrc_h == 5'h19 | /* PC SAVE -> MAD -> MBUS */
            msrc_h == 5'h1A | /* PC      -> MAD -> MBUS */
            msrc_h == 5'h1B   /* VA      -> MAD -> MBUS */
        );

    /* MSRC STALL because WDR -> MBUS during read ?!? */
    wire msrc_stall_group_b_h =
        read_cyc_h & msrc_h == 5'h13;

    assign msrc_stall_h =
        phase_1_h  & (msrc_stall_group_a_h | msrc_stall_group_b_h);

    assign mdr_stall_h = ~load_mdr_h & ~mdr_ldd_h & (msrc_h == 5'h12);

    assign mem_cyc_stall_h =
        ( read_cyc_h & ~phase_1_h & 
        (dest_mdr_h | dest_wdr_h ) ) |
        (( dest_wdr_h & ~phase_1_h) &
        (~ma_sel_s1_h | ~ma_sel_s0_h |
        cyc_in_prog_h & ~read_h & ~add_reg_ena_h)) ;

    always @ ( init_h, status_valid_l ) begin
        if (init_h)
            init_a_h <= 1'b1;
        else if (status_valid_l)
            init_a_h <= 1'b0;
    end
/*
11000
11001
11010
11011
110xx

1xx11
10011
10111
11111

*/
    wire no_prefetch_msrc_h = (
            msrc_h == 5'h18 | /* MA      -> MBUS */
            msrc_h == 5'h1A | /* PC      -> MAD -> MBUS */
            msrc_h == 5'h19 | /* PC SAVE -> MAD -> MBUS */
            msrc_h == 5'h1B | /* VA      -> MAD -> MBUS */
            msrc_h == 5'h1F | /* TB DATA -> PAD -> MBUS */
            msrc_h == 5'h17 | /* XB             -> MBUS */
            msrc_h == 5'h13   /* WDR            -> MBUS */ );
    
    
    assign no_prefetch_h = 
        ( xb1_ldd_h & xb0_ldd_h ) | /*  */
        (no_prefetch_msrc_h & phase_1_h &
            ~either_xb_stall_h & ~msrc_xb_h &
            (status_val_h | ~prefetch_del_h))    | 
        (cyc_in_prog_h & ~prefetch_cyc_h)        | /* Prefetch inhibited if CMI performing non prefetch cycle */
        ((bus_req_h & ~either_xb_stall_h)      
            & ( status_val_h | ~prefetch_del_h)) |
        ( utrap_h & prefetch_l );

    assign no_prefetch_a_h = 
        ( ~cyc_in_prog_h & inval_check_h & ~inval_write_h ) | 
        ( ~cyc_in_prog_h & ~phase_1_h & pc_clk_req_h & latch_ma_l ) |
        ( ~bytes_req_h & latched_utrap_h & ~prefetch_del_h ) |
        ( status_val_h & ( utrap_h | ~prefetch_req_h ) ) |
        ( prefetch_cyc_h & ~add_ena_del_h & status_val_h & read_h ) |
         init_a_h;
    assign prefetch_h = ~no_prefetch_h & ~no_prefetch_a_h;

    assign ena_pc_l = ~( m_clk_en_h & pc_enable_h );
    assign ena_va_save_l = ~( phase_1_h | dest_pc_h );
    assign latch_ma_l = ~latch_ma_h;
    assign ma_select_h = { ma_sel_s1_h, ma_sel_s0_h };
    assign prefetch_l = ~prefetch_h;
    assign stall_l = ~(
        mseq_init_l & 
        ( delay_stall_h | bus_cyc_stall_h | xb_stall_h | pa_bus_ph1_stall_h | pa_bus_ph2_stall_h
         | msrc_stall_h | mdr_stall_h | mem_cyc_stall_h ));
    assign xb_select_h = xb_sel_h;
    assign xb_in_use_l[1] = ~( ~reset_xb1_ldd_h & (bytes_req_1_h | bytes_req_0_h ) & _xb1_sel_h);
    assign xb_in_use_l[0] = ~( ~reset_xb0_ldd_h & (bytes_req_1_h | bytes_req_0_h ) & _xb0_sel_h);
endmodule