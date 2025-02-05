`include "chipmacros.vh"

module ka750_mic(
	 input sac_reset_h,
    input  b_clk_l,
	 input  dpm_mcs_tmp_l,
    input  dpm_phase1_h,
    input         dpm_do_service_l,
    input         dpm_m_clk_en_h,
    input         dpm_d_clk_en_h,
    input         dpm_dst_rmode_h,
    input  [1:0]  dpm_d_size_h,
    input         dpm_mseq_init_l,
    input         cs_parity_error_h,
    input         fp_res_op_l,
    input         ubi_force_tb_pe_l,
    input         ubi_force_cache_pe_l,
    output [3:0]  micro_vector_h,
    input  [4:0] cs_msrc_h,
    input  [5:0] cs_wctrl_h,
    input  [4:0] cs_bus_h,

    input  [31:0] mbus_l,
    output [31:0] mbus_out_l,
    input  [31:0] wbus_h,
    output [31:0] wbus_out_h,

    input ubi_int_grant_h,

    input dpm_psl_cm_h,
    input dpm_ld_osr_l,

    output [15:0] xbuf_out_h,
    input  [15:8] xbuf_h,

    output msrc_xb_h,
    output utrap_l,
    input  dpm_ird1_h,
    input  ubi_rtut_dinh_l,
    output status_valid_h,
    output proc_init_l,
    input         cmi_wait_l,
    input  [31:0] cmi_data_h,
    output [31:0] cmi_data_out_h,
    input  [ 7:0] cmi_arb_l,
    input         cmi_dbbz_l,
    input         cmi_hold_l,
    input  [1:0]  cmi_status_l,
    output [1:0]  cmi_status_out_l,
    output        cmi_dbbz_out_l,
    output        cmi_hold_out_l,
    input         ubi_cmi_ub_inh_l,
    input         dpm_instr_fetch_h,
    input  [1:0]  dpm_isize_l,
    output  reg   latched_mbus15_l,
    output        ub_req_h,
    input         sncd_ub_h,
    output        mem_stall_h,
    output        pte_check_or_probe_h,
    output        interrupt_inh_h,
    output        gen_dest_inh_l,
    output        wr_bus_err_int_l);

    wire [2:0] enc_utrap_l;
    wire [23:0] pad_h;
    wire io_address_l;
    wire cs_clk_l;
    wire mclk_ena_l;
    wire      add_reg_ena_l;
    reg [4:0] latched_msrc_h;
    reg [4:0] latched_msrc_l;
    reg [5:0] latched_wctrl_h;
    reg       latched_wctrl_3_l;
    reg [4:0] latched_bus_h;
    wire      latched_bus0_l;
    wire      wctrl_HHLXXX_l;
    wire [2:0] asrc_sel_h;
    wire       ird1_l;
    wire       proc_init_h;
    wire       rtut_dinh_h;
    wire       status_valid_l;
    wire       phase1_l;
    wire       cmi_cpu_pri_l;
    wire       ld_osr_l;
    wire       ena_pc_backup_l;
    wire       ena_prot_bits_l;
    wire       msrc_mi_h;
    wire       msrc_mi_l;
    wire       mmux_sel_s1_h;
    wire       mbus_ena_h;
    wire       ena_smdr_l;
    wire       smdr_dec_h;
    wire       clk_smdr_l;
    wire       stall_l;
    wire       x_stall_l, x_stall_h;
    reg        latched_utrap_h = 1'b0;
    reg        e25_6_h = 1'b0;
    wire       acv_h;
    wire       tb_data_perr_h;
    wire       tb_parity_ena_h;
    wire       ena_acv_stall_h;
    wire [3:0] ac_h;
    wire       tb_val_h;
    wire       m_bit_h;
    wire [31:0] mad_h;
    wire        ca_data_par_err_l;
    wire        ca_tag_par_err_h;
    wire        inval_pref_l;
    wire        snapshot_cmi_l;
    wire        cache_int_l;
    wire        cache_valid_0_h;
    wire        cache_grp_0_wr_h;
    wire [1:0]  dbus_rot_h;
    wire [3:0]  ena_byte_l;
    wire        ca_hit_h = _cak_ca_hit_h & _cdp_ca_hit_h;
    wire        _cak_ca_hit_h;
    wire        _cdp_ca_hit_h;
    wire        comp_mode_h;
    wire        pte_check_l;
    wire        ena_va_l;
    wire  [1:0] amux_sel_h;
    wire  [1:0] bsrc_sel_h;
    wire  [1:0] clk_sel_h;
    wire  [1:0] dbus_sel_h;
    wire  [1:0] _adk_dbus_sel_h;
    wire  [1:0] tb_grp_wr_h;
    wire        tb_output_ena_l;
    wire  [1:0] tb_hit_h = _adk_tb_hit_h & _tlb_tb_hit_h;
    wire  [1:0] _adk_tb_hit_h;
    wire  [1:0] _tlb_tb_hit_h;
    wire        write_vect_occ_l;
    wire        ena_pc_l;
    wire        ena_va_save_l;
    wire        latch_ma_l;
    wire        _prk_latch_ma_l;
    wire [1:0]  ma_select_h;
    wire [1:0]  xb_in_use_l;
    wire        prefetch_l;
    wire        xb_select_h;
    reg         inh_latch_ma_h = 1'b0;
    wire [1:0]  xb_pc_h;
    wire        grant_stall_l;
    wire        inhibit_cmi_h;
    wire        ena_cmi_l;
    wire [1:0]  status_h;
    wire        corr_data_int_l;
    wire        page_bndry_h;
    wire        force_ma_09_h;
    wire        tb_valid_h;
    wire [3:0]  _utr_micro_vector_h;
    wire [1:0]  _acv_micro_vector_h;
    wire        ca_hit_inh_h;
    wire        ena_cache_h;
    wire [1:0]  tb_tag_perr_h;
    wire        b_clk_h = ~b_clk_l;
    wire        wait_h;

    assign micro_vector_h = {2'b11,_acv_micro_vector_h} & _utr_micro_vector_h;

    wire [27:24] _cak_wbus_h;
    wire [27:24] _adk_wbus_h;
    wire [27:24] _utr_wbus_h;
    wire [31:0] _wbus_h = wbus_out_h & wbus_h;
    wire [23:0] _tlb_pad_h;
    wire [23:0] _pad_pbits_h;
    wire [23:0] _mdp_pad_h;
    wire [31:0] _mdp_cache_h;
    wire [31:0] _cdp_cache_h;
    wire [31:0] cache_h = _mdp_cache_h & _cdp_cache_h;

    assign pad_h = _pad_pbits_h & _mdp_pad_h & _tlb_pad_h;

    wire [31:25] _cmk_cmi_h;
    wire [31:0 ] _mdp_cmi_h;
    assign cmi_data_out_h = _mdp_cmi_h & { _cmk_cmi_h, 25'h1FFFFF };

    assign wbus_out_h = {4'b1111, _cak_wbus_h & _adk_wbus_h & _utr_wbus_h, 24'hFF_FFFF};

    always @ ( sac_reset_h or posedge cs_clk_l ) begin
		  if ( sac_reset_h ) begin
		     latched_bus_h <= 5'h00;
			  latched_msrc_h <= 5'h00;
			  latched_msrc_l <= 5'h1F;
			  latched_wctrl_h <= 6'h00;
			  latched_wctrl_3_l <= 1'b1;
		  end else if ( cs_clk_l ) begin
			  latched_bus_h   <=  cs_bus_h;
			  latched_msrc_h  <=  cs_msrc_h;
			  latched_msrc_l  <= ~cs_msrc_h;
			  latched_wctrl_h <=  cs_wctrl_h;
			  latched_wctrl_3_l <= ~cs_wctrl_h[3];
		  end 
    end
    assign latched_bus0_l = ~latched_bus_h[0];

    assign mclk_ena_l = ~dpm_m_clk_en_h;
    assign cs_clk_l   = ~(~b_clk_l & ~mclk_ena_l);

    assign io_address_l = ~&pad_h[23:20];
    /* UB REQ H matches if both:
       PAD in 0xF80000. 0xF8FFFF ( if scnd_ub_h ) or 0xFC0000 .. 0xFCFFFF 
       BUS == 1x1x0 ()
    */
    assign ub_req_h = ~io_address_l  & ( sncd_ub_h | pad_h[18] ) & pad_h[19] & 
                      ~add_reg_ena_l & ( latched_bus_h[4] | latched_bus0_l & ~latched_bus_h[2]);

    assign wctrl_HHLXXX_l = ~&{latched_wctrl_h[5:4], latched_wctrl_3_l};

    assign ird1_l = ~dpm_ird1_h;

    assign rtut_dinh_h = ~ubi_rtut_dinh_l;

    assign status_valid_h = ~status_valid_l;

    assign phase1_l = ~dpm_phase1_h;

    assign proc_init_l = ~proc_init_h;

    wire pha1_msrc_xb_h  = msrc_xb_h & dpm_phase1_h;
    wire pha1_nmsrc_xb_h = dpm_phase1_h & ~msrc_xb_h;

    assign asrc_sel_h[2] = ~latched_wctrl_h[1] & ~dpm_phase1_h;
    assign asrc_sel_h[1] = ~( (dpm_isize_l[1] & pha1_msrc_xb_h  ) | 
                              (ird1_l         & pha1_nmsrc_xb_h ) );
    assign asrc_sel_h[0] = ~( (dpm_isize_l[0] & pha1_msrc_xb_h  ) | 
                              (dpm_ird1_h     & pha1_nmsrc_xb_h ) |
                              (ld_osr_l       & pha1_nmsrc_xb_h ));

    assign msrc_mi_l = ~msrc_mi_h;
    assign msrc_mi_h = ( ~latched_msrc_l[3] | ~latched_msrc_l[1] ) & 
                       ( ~latched_msrc_l[4] ) & 
                       ( ~latched_msrc_h[2] | ~latched_msrc_l[1] ) & 
                       ( ~latched_msrc_h[2] | ~latched_msrc_l[0] );
    assign msrc_xb_h = msrc_mi_h & latched_msrc_h[2] & latched_msrc_l[3];

    assign ena_prot_bits_l = ~(mmux_sel_s1_h & latched_msrc_h[2]);

    assign ena_pc_backup_l = ~(dpm_instr_fetch_h & mclk_ena_l );

    assign mbus_ena_h = msrc_mi_h & ( ~smdr_dec_h | ~rtut_dinh_h ) & dpm_mcs_tmp_l;

    assign ena_smdr_l = ~(smdr_dec_h & rtut_dinh_h & dpm_mcs_tmp_l );

    assign smdr_dec_h = ~(~msrc_mi_l & ~latched_msrc_h[3] & ~latched_msrc_h[0] & 
                                       ~latched_bus_h[3]  & ~latched_bus_h[1] );
    
    assign clk_smdr_l = b_clk_l | ~( dpm_phase1_h & smdr_dec_h );

    always @ ( mbus_l[15] or phase1_l )
        if ( ~phase1_l )
            latched_mbus15_l = mbus_l[15];

    assign mem_stall_h = dpm_mseq_init_l & (
        ( ~latched_utrap_h                                  | ~stall_l            ) &
        ( acv_h | tb_data_perr_h		           |  x_stall_h | ~stall_l | ~utrap_l ) &
        ( (ena_acv_stall_h & tb_parity_ena_h ) |  x_stall_h | ~stall_l | ~utrap_l ));

    assign wait_h = ~cmi_wait_l;
    assign cmi_cpu_pri_l = ~&{cmi_arb_l, ubi_cmi_ub_inh_l};
    assign _pad_pbits_h[23:9] = 15'h7FFF;
    assign _pad_pbits_h[2:0] = 3'h7;
    assign _pad_pbits_h[8:3] = ena_prot_bits_l ? 6'b111111 : { tb_val_h, ac_h[3:0], m_bit_h };

    assign ena_cache_h = dbus_sel_h == 2'b00;
    assign ca_hit_inh_h = ~ena_pc_l & ~prefetch_l & ~add_reg_ena_l;

    wire _e26_6_l = ~((ena_pc_l & inh_latch_ma_h ) | latched_utrap_h);
    wire _e22_6_l = _e26_6_l | mclk_ena_l;
    wire _e22_8_l = mclk_ena_l | utrap_l;

    `FF_RESET_P( b_clk_l, sac_reset_h, ~_e26_6_l, inh_latch_ma_h )
    `FF_RESET_P( b_clk_l, sac_reset_h, ~_e22_6_l, e25_6_h )
    `FF_RESET_P( b_clk_l, sac_reset_h, ~_e22_8_l, latched_utrap_h )

    reg e4a_q_h = 1'b0;
    reg e4b_q_h = 1'b0;
    wire _nc_l = 1'b0;

    `FF_PRESET_RESET_EN_P( add_reg_ena_l, e4b_q_h, sac_reset_h, 1'b1, 1'b0, e4a_q_h )
    `FF_PRESET_RESET_EN_P( _nc_l, status_valid_h, b_clk_h , 1'b0, 1'b0, e4b_q_h )
    

    wire e4_6_h =  ~e4a_q_h;

    assign x_stall_h = ( ~grant_stall_l | e25_6_h | e4_6_h) & 
                       ( ~grant_stall_l | (latched_bus_h[4:3] == 3'b11 & ~latched_bus_h[0]));
    assign x_stall_l = ~x_stall_h;

    assign interrupt_inh_h = dpm_instr_fetch_h &  add_reg_ena_l & io_address_l;

    assign ld_osr_l = dpm_ld_osr_l | ( dpm_psl_cm_h & ird1_l );

    wire _cgw1;
    wire _cv1;
    wire _ch1;
    dc627_cak CAK (
        .b_clk_l(b_clk_l),
        .d_clk_en_h(dpm_d_clk_en_h),
        .m_clk_en_h(dpm_m_clk_en_h),
        .d_size_h(dpm_d_size_h),
        .data_par_err_l(ca_data_par_err_l),
        .dst_rmode_h(dpm_dst_rmode_h),
        .io_address_l(io_address_l),
        .bus_h(latched_bus_h),
        .wctrl_h(latched_wctrl_h),
        .mad_h(mad_h[1:0]),
        .mmux_sel_s1_h(mmux_sel_s1_h),
        .prefetch_l(inval_pref_l),
        .snapshot_cmi_l(snapshot_cmi_l),
        .status_valid_l(status_valid_l),
        .tag_par_err_h({1'b0, ca_tag_par_err_h}),
        .hit_h({1'b0, ca_hit_h}),
        .hit_out_h({_ch1, _cak_ca_hit_h}),
        .wbus_h(_wbus_h[27:24]),
        .wbus_out_h(_cak_wbus_h),
        .cache_int_l(cache_int_l),
        .cache_grp_wr_h({_cgw1, cache_grp_0_wr_h}),
        .cache_valid_h({_cv1, cache_valid_0_h}),
        .dbus_rot_h(dbus_rot_h),
        .ena_byte_l(ena_byte_l)
    );

    dc626_adk ADK (
        .b_clk_l(b_clk_l),
        .d_clk_en_h(dpm_d_clk_en_h),
        .m_clk_en_h(dpm_m_clk_en_h),
        .lbus_h(latched_bus_h[3:0]),
        .bus_4_h(cs_bus_h[4]),
        .wctrl_h(latched_wctrl_h),
        .dst_rmode_h(dpm_dst_rmode_h),
        .mmux_sel_s1_h(mmux_sel_s1_h),
        .phase_1_h(dpm_phase1_h),
        .prefetch_l(inval_pref_l),
        .psl_cm_h(dpm_psl_cm_h),
        .snapshot_cmi_l(snapshot_cmi_l),
        .status_valid_l(status_valid_l),
        .rtut_dinh_l(ubi_rtut_dinh_l),
        .write_vect_occ_l(write_vect_occ_l),
        .tb_hit_h(tb_hit_h),
        .tb_hit_out_h(_adk_tb_hit_h),
        .wbus_h(_wbus_h[27:24]),
        .wbus_out_h(_adk_wbus_h[27:24]),
        .amux_sel_h(amux_sel_h),
        .bsrc_sel_h(bsrc_sel_h),
        .clk_sel_h(clk_sel_h),
        .comp_mode_h(comp_mode_h),
        .dbus_sel_h(_adk_dbus_sel_h),
        .ena_va_l(ena_va_l),
        .pte_check_l(pte_check_l),
        .tb_grp_wr_h(tb_grp_wr_h),
        .tb_output_ena_l(tb_output_ena_l),
        .tb_parity_ena_h(tb_parity_ena_h) );

    assign dbus_sel_h = _adk_dbus_sel_h & { write_vect_occ_l, 1'b1 };

    dc624_prk PRK (
        .b_clk_l(b_clk_l),
        .d_clk_en_h(dpm_d_clk_en_h),
        .m_clk_en_h(dpm_m_clk_en_h),
        .dst_rmode_h(dpm_dst_rmode_h),
        .lbus_h(latched_bus_h[3:0]),
        .bus_4_h(cs_bus_h[4]),
        .msrc_h(latched_msrc_h),
        .wctrl_h(latched_wctrl_h),
        .ld_osr_l(ld_osr_l),
        .mseq_init_l(dpm_mseq_init_l),
        .phase_1_h(dpm_phase1_h),
        .psl_cm_h(dpm_psl_cm_h),
        .snapshot_cmi_l(snapshot_cmi_l),
        .status_valid_l(status_valid_l),
        .utrap_l(utrap_l),
        .xb_pc_h(xb_pc_h),
        .isize_l(dpm_isize_l),
        .ird1_h(dpm_ird1_h),
        .ena_pc_l(ena_pc_l),
        .ena_va_save_l(ena_va_save_l),
        .enable_acv_stall_h(ena_acv_stall_h),
        .latch_ma_l(_prk_latch_ma_l),
        .ma_select_h(ma_select_h),
        .mmux_sel_s1_h(mmux_sel_s1_h),
        .prefetch_l(prefetch_l),
        .stall_l(stall_l),
        .xb_select_h(xb_select_h),
        .xb_in_use_l(xb_in_use_l)
    );

    assign latch_ma_l = _prk_latch_ma_l | inh_latch_ma_h;

    reg _e46a_q_h = 1'b0;
    reg _e46b_q_h = 1'b0;

    assign inval_pref_l = prefetch_l & ~_e46a_q_h;

    wire _e46a_d_h = &( ~snapshot_cmi_l & ~grant_stall_l & ~dpm_phase1_h );
    wire _e46a_r_h = _e46b_q_h;


    `FF_RESET_P( b_clk_l, _e46a_r_h, _e46a_d_h, _e46a_q_h)
    `FF_P( b_clk_l, _e46a_q_h, _e46b_q_h)

    dc623_cmk CMK (
        .b_clk_l(b_clk_l),
        .d_clk_en_h(dpm_d_clk_en_h),
        .m_clk_en_h(dpm_m_clk_en_h),
        .bus_4_h(cs_bus_h[4]),
        .cmi_cpu_priority_l(cmi_cpu_pri_l),
        .dst_rmode_h(dpm_dst_rmode_h),
        .hit_h(ca_hit_h),
        .wait_h(wait_h),
        .phase_1_h(dpm_phase1_h),
        .mseq_init_l(dpm_mseq_init_l),
        .mmux_sel_s1_h(mmux_sel_s1_h),
        .mad_h(mad_h[1:0]),
        .lbus_h(latched_bus_h[3:0]),
        .int_grant_h(ubi_int_grant_h),
        .inhibit_cmi_h(inhibit_cmi_h),
        .cache_int_l(cache_int_l),
        .dsize_h(dpm_d_size_h),
        .prefetch_l(prefetch_l),
        .cmi_h(cmi_data_h[27:25]),
        .cmi_out_h(_cmk_cmi_h),
        .dbbz_l(cmi_dbbz_l),
        .dbbz_out_l(cmi_dbbz_out_l),
        .hold_l(cmi_hold_l),
        .hold_out_l(cmi_hold_out_l),
        .st_l(cmi_status_l),
        .st_out_l(cmi_status_out_l),
        .add_reg_ena_l(add_reg_ena_l),
        .corr_data_int_l(corr_data_int_l),
        .ena_cmi_l(ena_cmi_l),
        .grant_stall_l(grant_stall_l),
        .snapshot_cmi_l(snapshot_cmi_l),
        .status_h(status_h),
        .status_valid_l(status_valid_l),
        .write_vect_occ_l(write_vect_occ_l)
    );

    dc625_acv ACV (
        .ac_h(ac_h),
        .b_clk_l(b_clk_l),
        .bus_4_h(cs_bus_h[4]),
        .cs_parity_error_h(cs_parity_error_h),
        .d_clk_en_h(dpm_d_clk_en_h),
        .d_size_h(dpm_d_size_h),
        .fp_res_op_l(fp_res_op_l),
        .lbus_h(latched_bus_h[3:0]),
        .wctrl_h(latched_wctrl_h),
        .m_clk_en_h(dpm_m_clk_en_h),
        .mad_h(mad_h[2:0]),
        .page_bndry_h(page_bndry_h),
        .phase_1_h(dpm_phase1_h),
        .prefetch_l(prefetch_l),
        .tb_valid_h(tb_valid_h),
        .ub_address_h(1'b0),
        .utrap_l(utrap_l),
        .wbus_h(_wbus_h[27:24]),
        .acv_h(acv_h),
        .enc_utrap_l(enc_utrap_l),
        .force_ma_09_h(force_ma_09_h),
        .micro_vector_h(_acv_micro_vector_h),
        .proc_init_h(proc_init_h),
        .pte_check_or_probe_h(pte_check_or_probe_h)
    );

    dataroute MDP (
        .b_clk_l(b_clk_l),
        .xb_select_h(xb_select_h),
        .xb_pc_h(xb_pc_h),
        .mmux_sel_s1_h(mmux_sel_s1_h),
        .latched_msrc_2_h(latched_msrc_h[2]),
        .amux_sel_h(amux_sel_h),
        .dbus_sel_h(dbus_sel_h),
        .dbus_rot_h(dbus_rot_h),
        .clk_sel_h(clk_sel_h),
        .mbus_ena_h(mbus_ena_h),
        .ena_cmi_l(ena_cmi_l),
        .snapshot_cmi_l(snapshot_cmi_l),
        .add_reg_ena_l(add_reg_ena_l),
        .ena_smdr_l(ena_smdr_l),
        .clk_smdr_l(clk_smdr_l),
        .wbus_h(_wbus_h),
        .mad_h(mad_h),
        .mbus_l(mbus_l),
        .mbus_out_l(mbus_out_l),
        .cache_out_h(_mdp_cache_h),
        .cache_h(cache_h),
        .pad_out_h(_mdp_pad_h),
        .pad_h(pad_h),
        .xbuf_out_h(xbuf_out_h),
        .xbuf_h(xbuf_h),
        .cmi_data_out_h(cmi_data_out_h),
        .cmi_data_h(cmi_data_h)
    );

    memaddr ADP (
        .b_clk_l(b_clk_l),
        .wbus_h(_wbus_h),
        .ma_h(mad_h),
        .ma_select_h(ma_select_h),
        .bsrc_sel_h(bsrc_sel_h),
        .asrc_sel_h(asrc_sel_h),
        .ena_pc_l(ena_pc_l),
        .ena_pc_backup_l(ena_pc_backup_l),
        .ena_va_l(ena_va_l),
        .ena_va_save_l(ena_va_save_l),
        .latch_ma_l(latch_ma_l),
        .force_ma_09_h(force_ma_09_h),
        .comp_mode_h(comp_mode_h),
        .page_boundary_h(page_bndry_h),
        .xb_pc_h(xb_pc_h),
        .va_0_h()
    );

    cachedp CDP (
        .b_clk_l(b_clk_l),
        .ena_cache_h(ena_cache_h),
        .cache_grp0_wr_h(cache_grp_0_wr_h),
        .force_cache_pe_l(ubi_force_cache_pe_l),
        .ena_byte_l(ena_byte_l),
        .ca_hit_h(ca_hit_h),
        .cache_valid_0_h(cache_valid_0_h),
        .pad_h(pad_h),
        .cache_h(cache_h),
        .cache_out_h(_cdp_cache_h),
        .ca_hit_out_h(_cdp_ca_hit_h),
        .ca_hit_inh_h(ca_hit_inh_h),
        .ca_tag_par_err_h(ca_tag_par_err_h),
        .ca_data_par_err_l(ca_data_par_err_l) );

    tlb TLB (
        .pad_h(pad_h),
        .mad_h(mad_h),
        .b_clk_l(b_clk_l),
        .tb_grp_wr_h(tb_grp_wr_h),
        .pte_check_l(pte_check_l),
        .tb_output_ena_l(tb_output_ena_l),
        .force_tb_pe_l(ubi_force_tb_pe_l),
        .tb_hit_h(tb_hit_h),
        .tb_data_perr_h(tb_data_perr_h),
        .tb_tag_perr_h(tb_tag_perr_h),
        .pad_out_h(_tlb_pad_h),
        .tb_val_h(tb_val_h),
        .tb_valid_h(tb_valid_h),
        .ac_h(ac_h),
        .tb_hit_out_h(_tlb_tb_hit_h),
        .m_bit_h(m_bit_h)
    );

    dc628_utr UTR (
        .acv_h(acv_h),
        .add_reg_ena_l(add_reg_ena_l),
        .b_clk_l(b_clk_l),
        .d_clk_ena_h(dpm_d_clk_en_h),
        .do_srvc_l(dpm_do_service_l),
        .enc_utrap_l(enc_utrap_l),
        .latched_bus_3_h(latched_bus_h[3]),
        .wctrl_h(latched_wctrl_h[2:0]),
        .wctrl_hhlxxx_l(wctrl_HHLXXX_l),
        .m_bit_h(m_bit_h),
        .msrc_xb_h(msrc_xb_h),
        .phase_1_h(dpm_phase1_h),
        .prefetch_l(prefetch_l),
        .proc_init_l(proc_init_l),
        .pte_check_or_probe_h(pte_check_or_probe_h),
        .rtut_dinh_l(ubi_rtut_dinh_l),
        .status_h(status_h),
        .status_valid_l(status_valid_l),
        .tb_data_perr_h(tb_data_perr_h),
        .tb_hit_h(tb_hit_h),
        .tb_parity_ena_h(tb_parity_ena_h),
        .tb_tag_perr_h(tb_tag_perr_h),
        .xb_select_h(xb_select_h),
        .xb_in_use_l(xb_in_use_l),
        .micro_vector_h(micro_vector_h),
        .wbus_h(_wbus_h[27:24]),
        .micro_vector_out_h(_utr_micro_vector_h),
        .wbus_out_h(_utr_wbus_h),
        .gen_dest_inh_l(gen_dest_inh_l),
        .inhibit_cmi_h(inhibit_cmi_h),
        .utrap_l(utrap_l),
        .write_bus_error_int_l(wr_bus_err_int_l)
    );


endmodule