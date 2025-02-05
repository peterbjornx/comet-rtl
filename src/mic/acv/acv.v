`include "chipmacros.vh"
`include "ucodedef.vh"

module dc625_acv(
    input [3:0] ac_h,
    input b_clk_l,
    input bus_4_h,
    input cs_parity_error_h,
    input d_clk_en_h,
    input [1:0] d_size_h,
    input fp_res_op_l,
    input [3:0] lbus_h,
    input [5:0] wctrl_h,
    input m_clk_en_h,
    input [2:0] mad_h,
    input page_bndry_h,
    input phase_1_h,
    input prefetch_l,
    input tb_valid_h,
    input ub_address_h,
    input utrap_l,
    input [27:24] wbus_h,

    output acv_h,
    output reg [2:0] enc_utrap_l,
    output force_ma_09_h,
    output [1:0] micro_vector_h, 
    output reg proc_init_h = 1'b0,
    output pte_check_or_probe_h );

    wire b_clk_h = ~b_clk_l;
    reg       latched_bus_4_h = 1'b0;
    reg       boundary_h = 1'b0;
    reg       mme_add_h = 1'b0;
    reg       mme_h = 1'b0;
    wire      cross_page_h;
    wire      unal_u_h;
    reg [1:0] cur_mode_h = 2'b0;
    reg       inval_latch_h = 1'b0;
    wire[4:0] latched_bus_h = { latched_bus_4_h, lbus_h };
    wire      pte_access_check_h = (
        latched_bus_h == `UC_BUS_PRB_RD_PTE |
        latched_bus_h == `UC_BUS_PRB_RD_PTE_K |
        latched_bus_h == `UC_BUS_PRB_WR_PTE );
    wire      access_probe_h = (
        latched_bus_h == `UC_BUS_PRB_RD |
        latched_bus_h == `UC_BUS_PRB_RD_MODE |
        latched_bus_h == `UC_BUS_PRB_WR |
        latched_bus_h == `UC_BUS_PRB_WR_MODE );

    wire _lb4_j_h = m_clk_en_h &  bus_4_h;
    wire _lb4_k_h = m_clk_en_h & ~bus_4_h;
    `JKFF_P( b_clk_l, _lb4_j_h, _lb4_k_h, latched_bus_4_h )

    wire _pi_j_h = phase_1_h & latched_bus_h == `UC_BUS_PRINIT;
    wire _pi_k_h = phase_1_h & latched_bus_h != `UC_BUS_PRINIT;
    `JKFF_P( b_clk_h, _pi_j_h, _pi_k_h, proc_init_h )

    `FF_P( b_clk_h, page_bndry_h, boundary_h )

    wire _mma_e_h = d_clk_en_h & wctrl_h == `UC_WCTRL_MEMSCAR_WB;
    wire _mma_d_h = wbus_h[27:24] == 4'b0000;
    `FF_RESET_EN_P( b_clk_l, proc_init_h, _mma_e_h, _mma_d_h, mme_add_h )

    wire _mme_e_h = d_clk_en_h & wctrl_h == `UC_WCTRL_MEMSCR_WB & mme_add_h;
    `FF_RESET_EN_P( b_clk_l, proc_init_h, _mme_e_h, wbus_h[24], mme_h )

    wire _cm_e_h = d_clk_en_h & (
        wctrl_h == `UC_WCTRL_PREV_CUR_ISCUR_WB | 
        wctrl_h == `UC_CCPSL_PSL_WB_CCBR_ALUS );
    `FF_EN_P( b_clk_l, _cm_e_h, wbus_h[25:24], cur_mode_h )

    wire unaligned_data_en_h = (
        latched_bus_h == `UC_BUS_WRITE |
        latched_bus_h == `UC_BUS_WRITE_UL |
        latched_bus_h == `UC_BUS_WRITE_NOREG  |
        latched_bus_h == `UC_BUS_READ |
        latched_bus_h == `UC_BUS_READ_MOD |
        latched_bus_h == `UC_BUS_READ_MOD_LCK |
        latched_bus_h == `UC_BUS_PRB_RD |
        latched_bus_h == `UC_BUS_PRB_RD_MODE |
        latched_bus_h == `UC_BUS_PRB_WR |
        latched_bus_h == `UC_BUS_PRB_WR_MODE |
        latched_bus_h == `UC_BUS_PRB_RD_PTE |
        latched_bus_h == `UC_BUS_PRB_RD_PTE_K |
        latched_bus_h == `UC_BUS_PRB_WR_PTE );

    wire unal_d_h = 
        ( mad_h[1:0] != 2'b00 & d_size_h[1] ) |
        ( mad_h[1:0] == 2'b11 & d_size_h == 2'b01 );
    
    wire unaligned_data_utrap_h = unal_d_h & unaligned_data_en_h;
    wire unaligned_data_wu_utrap_h = unaligned_data_utrap_h & 
        latched_bus_h == `UC_BUS_WRITE_UL;
    
    wire unaligned_ub_data_utrap_h = latched_bus_h != `UC_BUS_GRANT & ub_address_h &
        ~cross_page_h & ( ~prefetch_l | ( ~access_probe_h & ~pte_access_check_h ) ) & unal_u_h;


    assign unal_u_h = d_size_h[1] | (d_size_h[0] & mad_h[0 ]);

    wire write_xpage_utrap_h = cross_page_h & (
        latched_bus_h == `UC_BUS_WRITE | 
        latched_bus_h == `UC_BUS_WRITE_NOREG |
        latched_bus_h == `UC_BUS_PRB_RD |  
        latched_bus_h == `UC_BUS_PRB_RD_MODE |  
        latched_bus_h == `UC_BUS_PRB_WR |  
        latched_bus_h == `UC_BUS_PRB_WR_MODE );

    wire eop_h = 
        (d_size_h == 2'b01 & mad_h == 3'b111) |
        (d_size_h == 2'b10 & mad_h[2] & |mad_h[1:0]) |
        (d_size_h == 2'b11 & mad_h != 3'b000 );

    assign cross_page_h = mme_h & boundary_h & prefetch_l & fp_res_op_l & eop_h & (
        latched_bus_h == `UC_BUS_WRITE | 
        latched_bus_h == `UC_BUS_WRITE_UL |
        latched_bus_h == `UC_BUS_WRITE_NOREG |
        latched_bus_h == `UC_BUS_PRB_RD |  
        latched_bus_h == `UC_BUS_PRB_RD_MODE |  
        latched_bus_h == `UC_BUS_PRB_WR |  
        latched_bus_h == `UC_BUS_PRB_WR_MODE );

    wire write_ul_xpage_utrap_h = cross_page_h & (
        latched_bus_h == `UC_BUS_WRITE_UL |
        latched_bus_h == `UC_BUS_PRB_RD |  
        latched_bus_h == `UC_BUS_PRB_RD_MODE |  
        latched_bus_h == `UC_BUS_PRB_WR |  
        latched_bus_h == `UC_BUS_PRB_WR_MODE );

    wire force_k_h = latched_bus_h == `UC_BUS_PRB_RD_PTE_K;
    wire mode_spec_h =
        latched_bus_h == `UC_BUS_PRB_RD_MODE | 
        latched_bus_h == `UC_BUS_PRB_WR_MODE;

    reg [1:0] cm_h;

    always @ ( prefetch_l or cur_mode_h or force_k_h or mode_spec_h or wbus_h[25:24] ) begin
        casez( { prefetch_l, force_k_h, mode_spec_h})
            3'b0zz : cm_h <= cur_mode_h;
            3'b110 : cm_h <= 2'b00; /* kernel mode */
            3'b101 : cm_h <= wbus_h[25:24];
            default: cm_h <= cur_mode_h;
        endcase
    end

    wire no_chk_h = prefetch_l & (
        latched_bus_h == `UC_BUS_READ_NT |
        latched_bus_h == `UC_BUS_WRITE_NT |
        latched_bus_h == `UC_BUS_WRITE_NT_LNG |
        latched_bus_h == `UC_BUS_GRANT |
        latched_bus_h == `UC_BUS_IOINIT );
    
    wire rd_chk_h = ~prefetch_l | (
        latched_bus_h == `UC_BUS_READ |
        latched_bus_h == `UC_BUS_READ_SEC |
        latched_bus_h == `UC_BUS_READ_LNG |
        latched_bus_h == `UC_BUS_READ_PHY |
        latched_bus_h == `UC_BUS_PRB_RD |
        latched_bus_h == `UC_BUS_PRB_RD_MODE |
        latched_bus_h == `UC_BUS_PRB_RD_PTE |
        latched_bus_h == `UC_BUS_PRB_RD_PTE_K |
        latched_bus_h == `UC_BUS_PRINIT );

    wire [6:0] utrap_encbus_h = {
        cs_parity_error_h, ~fp_res_op_l, unaligned_ub_data_utrap_h,
        write_xpage_utrap_h, write_ul_xpage_utrap_h, unaligned_data_wu_utrap_h,
        unaligned_data_utrap_h };
    wire notrap_eut0_l = ~( utrap_l & (pte_access_check_h | access_probe_h & cross_page_h ) );
    always @ ( utrap_encbus_h or notrap_eut0_l) begin
        casez( utrap_encbus_h )
            7'b1zzzzzz: enc_utrap_l <= ~3'h7;
            7'b01zzzzz: enc_utrap_l <= ~3'h6;
            7'b001zzzz: enc_utrap_l <= ~3'h4;
            7'b0001zzz: enc_utrap_l <= ~3'h2;
            7'b00001zz: enc_utrap_l <= ~3'h3;
            7'b000001z: enc_utrap_l <= ~3'h5;
            7'b0000001: enc_utrap_l <= ~3'h1;
            7'b0000000: enc_utrap_l <= { 2'b11, notrap_eut0_l };
            default   : enc_utrap_l <= 3'bxxx;
        endcase
    end

    assign force_ma_09_h = ~phase_1_h & inval_latch_h;

    wire _ivl_d_h = wctrl_h == 6'h29;
    `LATCH_P( phase_1_h, _ivl_d_h, inval_latch_h )

    wire uvec_en_h = utrap_l & (pte_access_check_h | access_probe_h);
    wire uvec_d_1_h = access_probe_h & ( tb_valid_h | ~mme_h ) | 
        tb_valid_h & ~acv_h;

    wire uvec_d_0_h = access_probe_h & ~mme_h |
        tb_valid_h & pte_access_check_h;

    assign micro_vector_h = uvec_en_h ? {uvec_d_1_h, uvec_d_0_h} : 2'b11;

    
    assign pte_check_or_probe_h = (access_probe_h | pte_access_check_h) & utrap_l;

    assign acv_h = ~(
        ( ac_h != 4'b0000 ) &
        (
            ac_h == 4'b0100 | 
            cm_h < ~ac_h[1:0] | 
            rd_chk_h & ( cm_h <= ac_h[3:2])
        ) | no_chk_h);

 endmodule