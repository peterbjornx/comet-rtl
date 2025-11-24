`include "chipmacros.vh"
`include "ucodedef.vh"

`define UTR_CS_PAR_ERR      5'd01
`define UTR_FPA_RSVD_OP     5'd02
`define UTR_MSRC_XB_TB_ERR  5'd03
`define UTR_MSRC_XB_BUS_ERR 5'd04
`define UTR_BUS_ERROR       5'd05
`define UTR_UNALIGN_UB_DATA 5'd06
`define UTR_MSRC_XB_TB_MISS 5'd07
`define UTR_MSRC_XB_ACV     5'd08
`define UTR_TB_ERROR        5'd09
`define UTR_TB_MISS_READ    5'd10
`define UTR_TB_MISS_WRITE   5'd11
`define UTR_ACV_READ        5'd12
`define UTR_ACV_WRITE       5'd13
`define UTR_WRITE_X_PAGEBND 5'd14
`define UTR_WR_UL_X_PAGEBND 5'd15
`define UTR_UNALIGN_DATA_R  5'd16
`define UTR_UNALIGN_DATA_W  5'd17
`define UTR_UNALIGN_DATA_WU 5'd18
`define UTR_BUT_XB_TB_ERROR 5'd19
`define UTR_BUT_XB_BUS_ERROR 5'd20
`define UTR_BUT_XB_TB_MISS  5'd21
`define UTR_BUT_XB_ACV      5'd22


module dc628_utr(
    input acv_h,
    input add_reg_ena_l,
    input b_clk_l,
    input d_clk_ena_h,
    input do_srvc_l,
    input [2:0] enc_utrap_l,
    input latched_bus_3_h,
    input [2:0] wctrl_h,
    input       wctrl_hhlxxx_l,
    input m_bit_h,
    input msrc_xb_h,
    input phase_1_h,
    input prefetch_l,
    input proc_init_l,
    input pte_check_or_probe_h,
    input rtut_dinh_l,
    input [1:0] status_h,
    input status_valid_l,
    input tb_data_perr_h,
    input [1:0] tb_hit_h,
    input tb_parity_ena_h,
    input [1:0] tb_tag_perr_h,
    input xb_select_h,
    input [1:0] xb_in_use_l,

    input [3:0]   micro_vector_h,
    input [27:24] wbus_h,

    output [3:0]   micro_vector_out_h,
    output [27:24] wbus_out_h,

    output gen_dest_inh_l,
    output inhibit_cmi_h,
    output utrap_l,
    output write_bus_error_int_l );

    wire utrap_h;
    wire utrap_pend_h;
    wire enc_utrap_h;
    wire bus_utrap_ena_h;
    wire tb_tag_error_h;
    reg tag_1_perr_h = 1'b0;
    wire func_latch_ena_h;
    reg tag_0_perr_h = 1'b0;
    reg data_perr_h = 1'b0;
    reg [1:0] hit_h = 2'b0;
    reg ac_vio_h = 1'b0;
    wire tb_miss_h;
    wire xb1_utrap_h;
    wire xb0_utrap_h;
    wire xb0_utrap_pend_h;
    wire xb1_utrap_pend_h;
    wire xb1_mult_hit_h;
    wire xb0_mult_hit_h;
    wire xb1_tb_miss_h;
    wire xb0_tb_miss_h;
    reg latched_ub_unal_h = 1'b0;
    reg prefetch_cyc_h = 1'b0;
    reg read_cyc_h = 1'b0;
    wire xb1_err_ena_h;
    wire xb0_err_ena_h;
    wire phase_2_clk_h;
    wire exam_tb_err_h;
    wire set_non_exist_h;
    reg [1:0] stat_h = 2'b0;
    wire set_uncorr_h;
    wire set_corr_data_h;
    wire set_tag_1_perr_h;
    wire set_tag_0_perr_h;
    wire set_data_1_perr_h;
    wire set_data_0_perr_h;
    wire ena_wbus_h;
    reg  write_err_set_h = 1'b0;
    reg  add_reg_ena_del_h = 1'b0;
    reg  status_val_h = 1'b0;
    reg  bus_err_utrap_h = 1'b0;
    reg  bus_error_set_h = 1'b0;
    reg  latched_utrap_h = 1'b0;
    reg acv_perr_del_h = 1'b0;
    reg write_bus_err_h = 1'b0;
    reg [3:0] sc_add_h = 4'b0;
    reg bus_error_bit_h = 1'b0;
    reg tb_error_bit_h = 1'b0;
    reg ub_unal_bit_h = 1'b0;
    reg xb_mach_chk_bit_h = 1'b0;
    reg non_exist_mem_h = 1'b0;
    reg uncorr_data_h = 1'b0;
    reg lost_error_h = 1'b0;
    reg corr_data_h = 1'b0;
    reg tag_1_perr_bit_h = 1'b0;
    reg tag_0_perr_bit_h = 1'b0;
    reg data_1_perr_bit_h = 1'b0;
    reg data_0_perr_bit_h = 1'b0;
    reg last_ref_hit_h = 1'b0;
    reg disable_cmi_reg_h = 1'b0;
    reg [1:0] xb1_tb_hit_h = 2'b0;
    reg [1:0] xb1_status_h = 2'b0;
    reg       xb1_acv_h = 1'b0;
    reg       xb1_tag_1_perr_h = 1'b0;
    reg       xb1_tag_0_perr_h = 1'b0;
    reg       xb1_data_perr_h = 1'b0;
    reg       xb1_ub_unaligned_h = 1'b0;
    reg [1:0] xb0_tb_hit_h = 2'b0;
    reg [1:0] xb0_status_h = 2'b0;
    reg       xb0_acv_h = 1'b0;
    reg       xb0_tag_1_perr_h = 1'b0;
    reg       xb0_tag_0_perr_h = 1'b0;
    reg       xb0_data_perr_h = 1'b0;
    reg       xb0_ub_unaligned_h = 1'b0;
    reg [4:0] utr_trap_pri_h;
    wire      proc_init_h = ~proc_init_l;
    reg [3:0] uvector_h = 4'b0;


    wire bus_grant_dec_h = wbus_h == 3'h3 & ~wctrl_hhlxxx_l;
    wire ena_uvctr_hi_h  =  utrap_h & pte_check_or_probe_h;
    wire ena_uvctr_h     =  utrap_h & do_srvc_l;
    assign utrap_h       = ~phase_1_h & utrap_pend_h;
    assign utrap_pend_h  =  enc_utrap_h | tb_tag_error_h | tb_miss_h | acv_perr_del_h | 
                            bus_err_utrap_h | xb1_utrap_h | xb0_utrap_h | ~do_srvc_l | latched_utrap_h;
    
	 assign func_latch_ena_h = ~add_reg_ena_l & ~add_reg_ena_del_h;
	 
    assign enc_utrap_h = 
        ( &(~enc_utrap_l[2:1]) ) |
        bus_utrap_ena_h & ( enc_utrap_l == 3'b000);
    
    assign bus_utrap_ena_h = ~add_reg_ena_l & rtut_dinh_l & prefetch_l & ~bus_grant_dec_h;
    assign tb_tag_error_h = bus_utrap_ena_h & 
        ((hit_h[1] & hit_h[0]) | tag_1_perr_h | tag_0_perr_h);
    
    wire _t1p_d_h = tb_tag_perr_h[1] & tb_parity_ena_h;
    `LATCH_P( func_latch_ena_h, _t1p_d_h, tag_1_perr_h )

    wire _t0p_d_h = tb_tag_perr_h[0] & tb_parity_ena_h;
    `LATCH_P( func_latch_ena_h, _t0p_d_h, tag_0_perr_h )

    wire _dpe_d_h = tb_data_perr_h & tb_parity_ena_h;
    `LATCH_P( func_latch_ena_h, _dpe_d_h, data_perr_h )
    
    wire _h_d_h = tb_hit_h | ~{2{tb_parity_ena_h}};
    `LATCH_P( func_latch_ena_h, _h_d_h, hit_h )

    wire _acv_d_h = acv_h & tb_parity_ena_h;
    `LATCH_P( func_latch_ena_h, _acv_d_h, ac_vio_h )

    assign tb_miss_h = bus_utrap_ena_h & 
        ( ( latched_bus_3_h & ~m_bit_h & tb_parity_ena_h )
        + (hit_h == 2'b00));
    
    assign xb1_utrap_h = xb1_utrap_pend_h & ~xb_in_use_l[1] & (~xb_select_h | ~xb0_utrap_pend_h);
    assign xb0_utrap_h = xb0_utrap_pend_h & ~xb_in_use_l[0] & ( xb_select_h | ~xb1_utrap_pend_h);
    
    assign xb1_utrap_pend_h = xb1_acv_h | ~xb1_status_h[1] | xb1_ub_unaligned_h |
        xb1_tag_1_perr_h | xb1_tag_0_perr_h | xb1_data_perr_h | xb1_mult_hit_h | xb1_tb_miss_h;
    assign xb0_utrap_pend_h = xb0_acv_h | ~xb0_status_h[1] | xb0_ub_unaligned_h |
        xb0_tag_1_perr_h | xb0_tag_0_perr_h | xb0_data_perr_h | xb0_mult_hit_h | xb0_tb_miss_h;

    assign xb1_tb_miss_h = ~(|xb1_tb_hit_h);
    assign xb0_tb_miss_h = ~(|xb0_tb_hit_h);
    
    assign xb1_mult_hit_h = &xb1_tb_hit_h;
    assign xb0_mult_hit_h = &xb0_tb_hit_h;

    wire _luu_d_h = enc_utrap_l == 3'b100 & 
        (  ~tb_parity_ena_h | (^tb_hit_h) & ~acv_h & ~|tb_tag_perr_h & ~tb_data_perr_h) ;
    `LATCH_P( func_latch_ena_h, _luu_d_h, latched_ub_unal_h )

    wire prefetch_h = ~prefetch_l;
    `LATCH_P( func_latch_ena_h, prefetch_h, prefetch_cyc_h )

    wire _rc_d_h = ~latched_bus_3_h | prefetch_h;
    `LATCH_P( func_latch_ena_h, _rc_d_h, read_cyc_h )

    assign xb1_err_ena_h = prefetch_cyc_h & status_val_h & xb_select_h;
    assign xb0_err_ena_h = prefetch_cyc_h & status_val_h & ~xb_select_h;
    assign phase_2_clk_h = ~phase_1_h & ~b_clk_l;
    assign exam_tb_err_h = add_reg_ena_del_h & bus_utrap_ena_h & ~b_clk_l;
    assign set_non_exist_h = phase_2_clk_h & 
        ((xb1_status_h == 2'b00 & xb1_utrap_h)  |
         (xb0_status_h == 2'b00 & xb0_utrap_h)) |
         (stat_h == 2'b00 & status_val_h );

    `LATCH_P( status_val_h, status_h, stat_h )

    assign set_uncorr_h = phase_2_clk_h & 
        ((xb1_status_h == 2'b01 & xb1_utrap_h)  |
        (xb0_status_h == 2'b01 & xb0_utrap_h)) |
        (stat_h == 2'b01 & status_val_h );

    assign set_corr_data_h = phase_2_clk_h & 
        ((xb1_status_h == 2'b10 & xb1_utrap_h)  |
        (xb0_status_h == 2'b10 & xb0_utrap_h)) |
        (stat_h == 2'b10 & status_val_h );

    assign set_tag_1_perr_h = phase_2_clk_h & 
        ((xb1_tag_1_perr_h & xb1_utrap_h)  |
        (xb0_tag_1_perr_h & xb0_utrap_h)) |
        (tag_1_perr_h & status_val_h );

    assign set_tag_0_perr_h = phase_2_clk_h & 
        ((xb1_tag_0_perr_h & xb1_utrap_h)  |
        (xb0_tag_0_perr_h & xb0_utrap_h)) |
        (tag_0_perr_h & status_val_h );

    assign set_data_1_perr_h = phase_2_clk_h & 
        ((xb1_data_perr_h & xb1_tb_hit_h[1] & xb1_utrap_h)  |
        (xb0_data_perr_h & xb0_tb_hit_h[1] & xb0_utrap_h)) |
        (data_perr_h & hit_h[1] & exam_tb_err_h );

    assign set_data_0_perr_h = phase_2_clk_h & 
        ((xb1_data_perr_h & xb1_tb_hit_h[0] & xb1_utrap_h)  |
        (xb0_data_perr_h & xb0_tb_hit_h[0] & xb0_utrap_h)) |
        (data_perr_h & hit_h[0] & exam_tb_err_h );

    assign ena_wbus_h = ~phase_1_h & sc_add_h[3] & 
        ~wctrl_hhlxxx_l & wctrl_h == 3'h2;

    wire _wes_s_h = write_bus_err_h & ~phase_1_h & ~b_clk_l;
    wire _wes_r_h = write_bus_err_h & ~phase_1_h & ~b_clk_l;
    `RSFF( _wes_s_h, _wes_r_h, write_err_set_h )

    wire _ared_d_h = ~add_reg_ena_l & ( prefetch_h | ~phase_1_h );
    wire _ared_r_h = add_reg_ena_l;
    `FF_RESET_N( b_clk_l, _ared_r_h, _ared_d_h, add_reg_ena_del_h )

    wire _sv_d_h = ~status_valid_l;
    `FF_RESET_P( b_clk_l, status_valid_l, _sv_d_h, status_val_h )

    wire _be_r_h = ~bus_error_bit_h;
    `FF_RESET_P( b_clk_l, _be_r_h, bus_error_bit_h, bus_error_set_h )

    wire _beu_d_h = ( read_cyc_h & ~prefetch_cyc_h & ~stat_h[1] & status_val_h ) | bus_err_utrap_h;
    wire _beu_r_h = ~proc_init_l | ( latched_utrap_h & phase_1_h & b_clk_l );
    `FF_RESET_P( b_clk_l, _beu_r_h, _beu_d_h, bus_err_utrap_h )

    wire _lut_d_h = utrap_h & do_srvc_l & ~phase_1_h;
    `FF_P( b_clk_l, _lut_d_h, latched_utrap_h )

    wire _apd_d_h = add_reg_ena_del_h & ( data_perr_h | ac_vio_h );
    wire _apd_r_h = ~add_reg_ena_del_h;
    `FF_RESET_P( b_clk_l, _apd_r_h, _apd_d_h, acv_perr_del_h )

    wire _wbe_d_h = ~read_cyc_h & status_val_h & ~stat_h[1];
    wire _wbe_r_h = ~proc_init_l | ( write_err_set_h | phase_1_h );
    `FF_RESET_P( b_clk_l, _wbe_r_h, _wbe_d_h, write_bus_err_h )

    wire _sca_e_h = d_clk_ena_h & ~wctrl_hhlxxx_l & wctrl_h == 3'h4;
    `FF_EN_P( b_clk_l, _sca_e_h, wbus_h, sc_add_h ) // was latch

    wire _esr_e_h = d_clk_ena_h & sc_add_h == 4'b1000 & ~wctrl_hhlxxx_l & wctrl_h == 3'h0;
    wire _beb_s_h = set_non_exist_h | set_uncorr_h | set_corr_data_h;
    wire _teb_s_h = phase_2_clk_h & 
        ( (&xb1_tb_hit_h & xb1_utrap_h ) |
          (&xb0_tb_hit_h & xb0_utrap_h )) |
          ( &hit_h & exam_tb_err_h );
    wire _uub_s_h = phase_2_clk_h & 
    ( (xb1_ub_unaligned_h & xb1_utrap_h ) |
      (xb0_ub_unaligned_h & xb0_utrap_h )) |
      ( latched_ub_unal_h & exam_tb_err_h );
    wire _xmc_s_h = phase_2_clk_h & (
        utr_trap_pri_h == `UTR_MSRC_XB_TB_ERR |
        utr_trap_pri_h == `UTR_MSRC_XB_BUS_ERR |
        utr_trap_pri_h == `UTR_BUT_XB_TB_ERROR |
        utr_trap_pri_h == `UTR_BUT_XB_BUS_ERROR );
    wire _xmc_c_h = phase_2_clk_h & (
        utr_trap_pri_h == `UTR_BUS_ERROR |
        utr_trap_pri_h == `UTR_UNALIGN_UB_DATA |
        utr_trap_pri_h == `UTR_TB_ERROR ) | proc_init_h;
    `FF_PRESET_RESET_EN_P( b_clk_l, _beb_s_h, proc_init_h, _esr_e_h, wbus_h[27], bus_error_bit_h )
    `FF_PRESET_RESET_EN_P( b_clk_l, _teb_s_h, proc_init_h, _esr_e_h, wbus_h[26], tb_error_bit_h )
    `FF_PRESET_RESET_EN_P( b_clk_l, _uub_s_h, proc_init_h, _esr_e_h, wbus_h[25], ub_unal_bit_h )
    `FF_PRESET_RESET_EN_P( b_clk_l, _xmc_s_h, _xmc_c_h, _esr_e_h, wbus_h[24], xb_mach_chk_bit_h )

    wire _le_s_h = bus_error_set_h & ( set_non_exist_h | set_uncorr_h | set_corr_data_h );
    wire _ber_r_h = ~bus_error_bit_h;
    `RSFF( set_non_exist_h, _ber_r_h, non_exist_mem_h )
    `RSFF( set_uncorr_h, _ber_r_h, uncorr_data_h )
    `RSFF( _le_s_h, _ber_r_h, lost_error_h )
    `RSFF( set_corr_data_h, _ber_r_h, corr_data_h )

    wire _per_r_h = ~tb_error_bit_h;
    `RSFF( set_tag_1_perr_h, _per_r_h, tag_1_perr_bit_h )
    `RSFF( set_tag_0_perr_h, _per_r_h, tag_0_perr_bit_h )
    `RSFF( set_data_1_perr_h, _per_r_h, data_1_perr_bit_h )
    `RSFF( set_data_0_perr_h, _per_r_h, data_0_perr_bit_h )

    wire _lrh_d_h = ^hit_h;
    `LATCH_P( exam_tb_err_h, _lrh_d_h, last_ref_hit_h )

    wire _rco_e_h = d_clk_ena_h & sc_add_h == 4'b1110 & ~wctrl_hhlxxx_l & wctrl_h == 3'h0;
    `FF_RESET_EN_P( b_clk_l, proc_init_h, _rco_e_h, wbus_h[24], disable_cmi_reg_h )

    `LATCH_P( xb1_err_ena_h, hit_h, xb1_tb_hit_h )
    `LATCH_P( xb1_err_ena_h, stat_h, xb1_status_h )
    `LATCH_P( xb1_err_ena_h, ac_vio_h, xb1_acv_h )
    `LATCH_P( xb1_err_ena_h, tag_1_perr_h, xb1_tag_1_perr_h )
    `LATCH_P( xb1_err_ena_h, tag_0_perr_h, xb1_tag_0_perr_h )
    `LATCH_P( xb1_err_ena_h, data_perr_h, xb1_data_perr_h )
    `LATCH_P( xb1_err_ena_h, latched_ub_unal_h, xb1_ub_unaligned_h )

    `LATCH_P( xb0_err_ena_h, hit_h, xb0_tb_hit_h )
    `LATCH_P( xb0_err_ena_h, stat_h, xb0_status_h )
    `LATCH_P( xb0_err_ena_h, ac_vio_h, xb0_acv_h )
    `LATCH_P( xb0_err_ena_h, tag_1_perr_h, xb0_tag_1_perr_h )
    `LATCH_P( xb0_err_ena_h, tag_0_perr_h, xb0_tag_0_perr_h )
    `LATCH_P( xb0_err_ena_h, data_perr_h, xb0_data_perr_h )
    `LATCH_P( xb0_err_ena_h, latched_ub_unal_h, xb0_ub_unaligned_h )

    reg [3:0] uvector_d_h;
    always @ ( utr_trap_pri_h ) begin
        casez( utr_trap_pri_h )
            5'd01:  uvector_d_h <= 4'b0000;
            5'd02:  uvector_d_h <= 4'b1100;
            5'd03:  uvector_d_h <= 4'b1000;
            5'd04:  uvector_d_h <= 4'b1000;
            5'd05:  uvector_d_h <= 4'b1000;
            5'd06:  uvector_d_h <= 4'b1000;
            5'd07:  uvector_d_h <= 4'b0010;
            5'd08:  uvector_d_h <= 4'b0011;
            5'd09:  uvector_d_h <= 4'b1000;
            5'd10:  uvector_d_h <= 4'b1010;
            5'd11:  uvector_d_h <= 4'b1011;
            5'd12:  uvector_d_h <= 4'b1110;
            5'd13:  uvector_d_h <= 4'b1111;
            5'd14:  uvector_d_h <= 4'b0111;
            5'd15:  uvector_d_h <= 4'b0110;
            5'd16:  uvector_d_h <= 4'b0001;
            5'd17:  uvector_d_h <= 4'b0101;
            5'd18:  uvector_d_h <= 4'b0100;
            5'd19:  uvector_d_h <= 4'b1000;
            5'd20:  uvector_d_h <= 4'b1000;
            5'd21:  uvector_d_h <= 4'b1001;
            5'd22:  uvector_d_h <= 4'b1101;
            default: uvector_d_h <= 4'bxxxx;
        endcase
    end

    assign utrap_pri_enc_h[`UTR_BUS_ERROR  ] = bus_err_utrap_h;
    assign utrap_pri_enc_h[`UTR_CS_PAR_ERR ] = (~enc_utrap_l) == 3'b111;
    assign utrap_pri_enc_h[`UTR_FPA_RSVD_OP] = (~enc_utrap_l) == 3'b110;
    assign utrap_pri_enc_h[`UTR_MSRC_XB_TB_ERR]  = msrc_xb_h & 
        ( xb1_utrap_h & (xb1_tag_1_perr_h | xb1_tag_0_perr_h | xb1_data_perr_h | xb1_mult_hit_h) |
          xb0_utrap_h & (xb0_tag_1_perr_h | xb0_tag_0_perr_h | xb0_data_perr_h | xb0_mult_hit_h));
    assign utrap_pri_enc_h[`UTR_MSRC_XB_BUS_ERR] = msrc_xb_h &
        ( xb1_utrap_h & ~xb1_status_h[1] + xb0_utrap_h & ~xb1_status_h[1] );    
    assign utrap_pri_enc_h[`UTR_UNALIGN_UB_DATA] = 
        ( xb1_utrap_h & xb1_ub_unaligned_h |
          xb0_utrap_h & xb0_ub_unaligned_h |
          latched_ub_unal_h & bus_utrap_ena_h );
    assign utrap_pri_enc_h[`UTR_MSRC_XB_TB_MISS] = msrc_xb_h &
        ( xb1_utrap_h & xb1_tb_miss_h |
        xb0_utrap_h & xb0_tb_miss_h );
    assign utrap_pri_enc_h[`UTR_MSRC_XB_ACV] = msrc_xb_h &
        ( xb1_utrap_h & xb1_acv_h |
        xb0_utrap_h & xb0_acv_h );
    assign utrap_pri_enc_h[`UTR_TB_ERROR]      = bus_utrap_ena_h &
        ( tag_1_perr_h | tag_0_perr_h | data_perr_h | (&hit_h) );
    assign utrap_pri_enc_h[`UTR_TB_MISS_READ]  = bus_utrap_ena_h & ~latched_bus_3_h & hit_h == 2'b00;
    assign utrap_pri_enc_h[`UTR_TB_MISS_WRITE] = bus_utrap_ena_h &  latched_bus_3_h & ( hit_h == 2'b00 | ~m_bit_h & tb_parity_ena_h );
    assign utrap_pri_enc_h[`UTR_ACV_READ]      = acv_perr_del_h & ac_vio_h & ~latched_bus_3_h;
    assign utrap_pri_enc_h[`UTR_ACV_WRITE]     = acv_perr_del_h & ac_vio_h &  latched_bus_3_h;
    assign utrap_pri_enc_h[`UTR_WRITE_X_PAGEBND]= bus_utrap_ena_h & (~enc_utrap_l) == 3'b010;
    assign utrap_pri_enc_h[`UTR_WR_UL_X_PAGEBND] = bus_utrap_ena_h & (~enc_utrap_l) == 3'b011;
    assign utrap_pri_enc_h[`UTR_UNALIGN_DATA_R ] = bus_utrap_ena_h & ~latched_bus_3_h & (~enc_utrap_l) == 3'b001;
    assign utrap_pri_enc_h[`UTR_UNALIGN_DATA_W ] = bus_utrap_ena_h &  latched_bus_3_h & (~enc_utrap_l) == 3'b001;
    assign utrap_pri_enc_h[`UTR_UNALIGN_DATA_WU] = bus_utrap_ena_h &  latched_bus_3_h & (~enc_utrap_l) == 3'b101;
    assign utrap_pri_enc_h[`UTR_BUT_XB_TB_ERROR] = ~msrc_xb_h & 
        ( xb1_utrap_h & (xb1_tag_1_perr_h | xb1_tag_0_perr_h | xb1_data_perr_h | xb1_mult_hit_h) |
          xb0_utrap_h & (xb0_tag_1_perr_h | xb0_tag_0_perr_h | xb0_data_perr_h | xb0_mult_hit_h));
    assign utrap_pri_enc_h[`UTR_BUT_XB_BUS_ERROR] = ~msrc_xb_h &
        ( xb1_utrap_h & ~xb1_status_h[1] + xb0_utrap_h & ~xb1_status_h[1] );    
    assign utrap_pri_enc_h[`UTR_BUT_XB_TB_MISS] = ~msrc_xb_h &
        ( xb1_utrap_h & xb1_tb_miss_h |
        xb0_utrap_h & xb0_tb_miss_h );
    assign utrap_pri_enc_h[`UTR_BUT_XB_ACV]= ~msrc_xb_h &
        ( xb1_utrap_h & xb1_acv_h |
        xb0_utrap_h & xb0_acv_h );

    wire [22:1] utrap_pri_enc_h;

    always @ ( utrap_pri_enc_h ) begin
        casez( utrap_pri_enc_h )
            22'bzzzz_zzzz_zzzz_zzzz_zzzz_z1: utr_trap_pri_h = 5'd1;
            22'bzzzz_zzzz_zzzz_zzzz_zzzz_10: utr_trap_pri_h = 5'd2;
            22'bzzzz_zzzz_zzzz_zzzz_zzz1_00: utr_trap_pri_h = 5'd3;
            22'bzzzz_zzzz_zzzz_zzzz_zz10_00: utr_trap_pri_h = 5'd4;
            22'bzzzz_zzzz_zzzz_zzzz_z100_00: utr_trap_pri_h = 5'd5;
            22'bzzzz_zzzz_zzzz_zzzz_1000_00: utr_trap_pri_h = 5'd6;
            22'bzzzz_zzzz_zzzz_zzz1_0000_00: utr_trap_pri_h = 5'd7;
            22'bzzzz_zzzz_zzzz_zz10_0000_00: utr_trap_pri_h = 5'd8;
            22'bzzzz_zzzz_zzzz_z100_0000_00: utr_trap_pri_h = 5'd9;
            22'bzzzz_zzzz_zzzz_1000_0000_00: utr_trap_pri_h = 5'd10;
            22'bzzzz_zzzz_zzz1_0000_0000_00: utr_trap_pri_h = 5'd11;
            22'bzzzz_zzzz_zz10_0000_0000_00: utr_trap_pri_h = 5'd12;
            22'bzzzz_zzzz_z100_0000_0000_00: utr_trap_pri_h = 5'd13;
            22'bzzzz_zzzz_1000_0000_0000_00: utr_trap_pri_h = 5'd14;
            22'bzzzz_zzz1_0000_0000_0000_00: utr_trap_pri_h = 5'd15;
            22'bzzzz_zz10_0000_0000_0000_00: utr_trap_pri_h = 5'd16;
            22'bzzzz_z100_0000_0000_0000_00: utr_trap_pri_h = 5'd17;
            22'bzzzz_1000_0000_0000_0000_00: utr_trap_pri_h = 5'd18;
            22'b0001_0000_0000_0000_0000_00: utr_trap_pri_h = 5'd19;
            22'b0010_0000_0000_0000_0000_00: utr_trap_pri_h = 5'd20;
            22'b0100_0000_0000_0000_0000_00: utr_trap_pri_h = 5'd21;
            22'b1000_0000_0000_0000_0000_00: utr_trap_pri_h = 5'd22;
            22'b0000_0000_0000_0000_0000_00: utr_trap_pri_h = 5'd0;
            default                        : utr_trap_pri_h = 5'BXXXXX;
        endcase
    end

    wire _uvec_en_h = ~latched_utrap_h & utrap_h;
    `LATCH_P( _uvec_en_h, uvector_d_h, uvector_h )

    wire [3:2] mvec_d_h;

    assign mvec_d_h[3] =
         ~do_srvc_l |
          ( utrap_l & enc_utrap_l[0] & micro_vector_h[1] & micro_vector_h[0] ) |
          ( utrap_h & uvector_h[3] );

    assign mvec_d_h[2] =
        ( utrap_l & m_bit_h & micro_vector_h[1] & micro_vector_h[0] ) |
        ( utrap_h & uvector_h[2] );
        
    assign micro_vector_out_h = ena_uvctr_hi_h ? mvec_d_h  : 2'b11;
    assign micro_vector_out_h = ena_uvctr_h    ? uvector_h : 2'b11;

    reg [3:0] wmux_h;

    wire [3:0] _esr_q_h = { bus_error_bit_h, tb_error_bit_h, ub_unal_bit_h, xb_mach_chk_bit_h };
    wire [3:0] _ber_q_h = { non_exist_mem_h, uncorr_data_h , lost_error_h , corr_data_h };
    wire [3:0] _per_q_h = { tag_1_perr_bit_h, tag_0_perr_bit_h, data_1_perr_bit_h, data_0_perr_bit_h };

    always @ ( sc_add_h or _esr_q_h or _ber_q_h or _per_q_h or disable_cmi_reg_h or last_ref_hit_h ) begin
    
        casez( sc_add_h )
            4'bz0z0: wmux_h <= _esr_q_h;
            4'bz0z1: wmux_h <= _ber_q_h;
            4'bz110: wmux_h <= {3'b000, disable_cmi_reg_h };
            4'bz111: wmux_h <= _per_q_h | {3'b000, disable_cmi_reg_h };
            4'bz100: wmux_h <= {3'b000, last_ref_hit_h };
            4'bz101: wmux_h <= _per_q_h;
            default: wmux_h <= 4'bxxxx;
        endcase
    end

    assign wbus_out_h = ena_wbus_h ? wmux_h : 4'b1111;

    assign gen_dest_inh_l = ~( utrap_pend_h & 
        ( ~do_srvc_l | ( utr_trap_pri_h <= `UTR_UNALIGN_DATA_WU) ) );
    assign inhibit_cmi_h = disable_cmi_reg_h | ( ~rtut_dinh_l & prefetch_l ) |
        prefetch_h & ( ac_vio_h | tag_1_perr_h | tag_0_perr_h | data_perr_h | &hit_h | hit_h == 2'b00 );
    assign utrap_l = ~utrap_h;
    assign write_bus_error_int_l = ~write_bus_err_h;
endmodule