`include "chipmacros.vh"
`include "ucodedef.vh"

module dc626_adk(
    input b_clk_l,
    input m_clk_en_h,
    input d_clk_en_h,
    input [3:0] lbus_h,
    input  bus_4_h,
    input [5:0] wctrl_h,

    input dst_rmode_h,
    input mmux_sel_s1_h,
    input phase_1_h,
    input prefetch_l,
    input psl_cm_h,
    input snapshot_cmi_l,
    input status_valid_l,
    input rtut_dinh_l,
    input write_vect_occ_l,

    input [1:0] tb_hit_h,
    output [1:0] tb_hit_out_h,
    input [27:24] wbus_h,
    output [27:24] wbus_out_h,

    output [1:0] amux_sel_h,
    output [1:0] bsrc_sel_h,
    output [1:0] clk_sel_h,
    output       comp_mode_h,
    output [1:0] dbus_sel_h,
    output       ena_va_l,
    output       pte_check_l,
    output [1:0] tb_grp_wr_h,
    output       tb_output_ena_l,
    output       tb_parity_ena_h );

    wire phys_dec_h;
    reg status_val_h = 1'b0;
    reg latched_bus_4_h = 1'b0;
    reg bus_cyc_dec_h;
    wire bus_grant_dec_h;
    wire proc_init_h;
    reg [1:0] latched_hit_h = 2'b0;
    wire write_if_not_rmode_h;
    wire write_tb_h;
    wire ca_inval_h;
    wire pte_check_h;
    wire bus_req_h;
    wire dest_va_h;
    wire full_add_h;
    reg [3:0] sc_add_h = 4'b0;
    reg mme_h = 1'b0;
    reg wr_vect_h = 1'b0;
    reg [3:0] tb_ctl_h = 4'b0;
    reg [1:0] cur_mode_h = 2'b0;
    reg replace_0_h = 1'b0;
    reg read_h = 1'b0;
    wire phys_add_h;
    wire cache_cyc_h;
    reg [3:0] saved_mode_h = 4'b0;
    reg scnd_ref_h = 1'b0;
    wire ena_wbus_h;
    wire pa_wbus_h;
    wire pa_bus_data_h;
    wire clk_wdr_h;
    wire clk_mdr_h;
    wire force_dbus_cmi_h;


    wire [4:0] latched_bus_h = {latched_bus_4_h, lbus_h};


    wire _lb4_j_h = m_clk_en_h &  bus_4_h;
    wire _lb4_k_h = m_clk_en_h & ~bus_4_h;
    `JKFF_P( b_clk_l, _lb4_j_h, _lb4_k_h, latched_bus_4_h )

    `FF_RESET_P( b_clk_l, status_valid_l, ~status_valid_l, status_val_h )

// ADK
    `define CHIP_ADK
    `include "cycseq.vh"

    always @ ( latched_bus_h  or dst_rmode_h ) begin
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

    /* BUS GRANT DEC H is asserted when microcode wants to relinquish control of the bus */
    assign bus_grant_dec_h = latched_bus_h == `UC_BUS_GRANT;

    /* PHYS DEC H is asserted when bus request uses a physical address  */
    assign phys_dec_h      = latched_bus_h == `UC_BUS_READ_PHY | 
                             latched_bus_h == `UC_BUS_WRITE_PHY;

    assign proc_init_h     = ~phase_1_h & latched_bus_h == `UC_BUS_PRINIT;

    assign write_if_not_rmode_h = ~dst_rmode_h & latched_bus_h == `UC_BUS_WRITE_NOREG;
    
    /* WRITE TB H indicates a micro order that writes the TLB */
    assign write_tb_h  = wctrl_h == `UC_WCTRL_TB_WB       | 
                         wctrl_h == `UC_WCTRL_CLRTB_VA_WB ;

    /* CA INVAL H indicates a micro order that invalidates a cache line */
    assign ca_inval_h  = wctrl_h == `UC_WCTRL_CLRCH_VA_WB;

    /* PTE CHECK H indicates a micro order that validates a PTE */
    assign pte_check_h = latched_bus_h == `UC_BUS_PRB_RD_PTE |
                         latched_bus_h == `UC_BUS_PRB_WR_PTE |   
                         latched_bus_h == `UC_BUS_PRB_RD_PTE_K;
    
    /* BUS REQ H indicates that we are requesting the bus for a memory micro-order */
    assign bus_req_h = bus_cyc_dec_h & prefetch_l;

    /* DEST VA H indicates a micro order that writes the VA register */
    assign dest_va_h = 
        wctrl_h == `UC_WCTRL_VA_PC_I_W_PC_PC_I |
        wctrl_h == `UC_WCTRL_VA_VASAVE_WB |
        wctrl_h == `UC_WCTRL_VA_VA_4 |
        wctrl_h == `UC_WCTRL_VA_WB |
        wctrl_h == `UC_WCTRL_CLRTB_VA_WB |
        wctrl_h == `UC_WCTRL_CLRCH_VA_WB;

    /* FULL ADD H */
    assign full_add_h = 
        latched_bus_h == `UC_BUS_READ_PHY |
        latched_bus_h == `UC_BUS_WRITE_PHY |
        latched_bus_h == `UC_BUS_READ_NT |
        latched_bus_h == `UC_BUS_WRITE_NT |
        latched_bus_h == `UC_BUS_WRITE_NT_LNG |
        latched_bus_h == `UC_BUS_PRB_RD |
        latched_bus_h == `UC_BUS_PRB_WR |
        latched_bus_h == `UC_BUS_PRB_RD_MODE |
        latched_bus_h == `UC_BUS_PRB_WR_MODE;

    /* LATCHED HIT * H */
    `LATCH_P( phase_1_h, tb_hit_h, latched_hit_h)

    //NOTE: ADD REG ENA H and INVAL CHECK H not yet defined

    /* Status/Control Address Register */
    wire _scar_w_h = d_clk_en_h & wctrl_h == `UC_WCTRL_MEMSCAR_WB;
    `FF_EN_P( b_clk_l, _scar_w_h, wbus_h, sc_add_h ) // Was LATCH!

    wire memscr_en_h = d_clk_en_h & wctrl_h == `UC_WCTRL_MEMSCR_WB;

    /* MME H Memory map enable register (MEMSCR[0]) */
    wire _mme_w_h  =  memscr_en_h & sc_add_h == 4'b0000;
    `FF_RESET_EN_P( b_clk_l, proc_init_h, _mme_w_h, wbus_h[24], mme_h )

    /* WVOR H register (MEMSCR[2]) */
    wire _wvor_w_h = memscr_en_h & sc_add_h == 4'b0010;
    wire _wvor_r_h = proc_init_h | ( bus_grant_dec_h & phase_1_h & ~b_clk_l );
    wire _wvor_p_h = ~write_vect_occ_l;
    `FF_PRESET_RESET_EN_P( b_clk_l, _wvor_p_h, _wvor_r_h, _wvor_w_h, wbus_h[24], wr_vect_h )

    /* TB CTL H register (MEMSCR[3]) */
    wire _tgd_w_h = memscr_en_h & sc_add_h == 4'b0011;
    `FF_RESET_SZ_EN_P(4, b_clk_l, proc_init_h, _tgd_w_h, wbus_h, tb_ctl_h )

    
    /* CUR MODE H register (PSL bits 25:24) */
    wire _cmr_w_h = d_clk_en_h & ( 
        wctrl_h == `UC_WCTRL_PREV_CUR_ISCUR_WB | 
        wctrl_h == `UC_CCPSL_PSL_WB_CCBR_ALUS );
    `FF_RESET_SZ_EN_P(4, b_clk_l, proc_init_h, _cmr_w_h, wbus_h[25:24], cur_mode_h )

    wire _r0_d_h = tb_ctl_h[3] ? ~tb_ctl_h[2] : ~replace_0_h;
    `FF_PRESET_P( b_clk_l, proc_init_h, _r0_d_h, replace_0_h )
    
    wire _rd_d_h = ~prefetch_l | ~latched_bus_h[3];
    `LATCH_P( add_reg_ena_h, _rd_d_h, read_h )

    assign cache_cyc_h = 
        (add_reg_ena_h | ~cyc_in_prog_h) &
        (prefetch_del_h | bus_req_h ) &
        (add_ena_del_h | ~status_val_h | ~read_h);

    assign phys_add_h = 
        ( ~inval_check_h & cache_cyc_h ) &
        ( ~mme_h | phys_dec_h );

    wire _smr_w_h = d_clk_en_h & wctrl_h == `UC_WCTRL_MEMSCR_WB & sc_add_h == 4'b0001;
    wire _smr3_w_h = _smr_w_h | ( add_ena_del_h & read_h & latched_bus_4_h & prefetch_l );
    wire _smr20_w_h = _smr_w_h | ( d_clk_en_h & bus_cyc_dec_h & ~bus_grant_dec_h & rtut_dinh_l );
    wire [3:0] _smr_d_h;
    assign _smr_d_h[3]   = bus_cyc_dec_h ? &(~latched_bus_h[2:1])   : wbus_h[27];
    assign _smr_d_h[2:0] = bus_cyc_dec_h ? {phys_add_h, cur_mode_h} : wbus_h[26:24]; 
    `FF_RESET_EN_P( b_clk_l, proc_init_h, _smr3_w_h, _smr_d_h[3], saved_mode_h[3] )
    `FF_RESET_EN_P( b_clk_l, proc_init_h, _smr20_w_h, _smr_d_h[2:0], saved_mode_h[2:0] )

    assign ena_wbus_h = ~phase_1_h & sc_add_h[3:2] == 2'b00 & wctrl_h == `UC_WCTRL_MEMSCR;

    assign pa_wbus_h = ~inval_check_h & ~status_val_h & ~cyc_in_prog_h & prefetch_l &
        ( write_tb_h | ca_inval_h | pte_check_h );

    assign pa_bus_data_h = ~status_val_h & ~cyc_in_prog_h & prefetch_l & 
        ( write_tb_h | pte_check_h );

    assign clk_wdr_h = ( ~rtut_dinh_l & add_reg_ena_h & prefetch_l & ~latched_bus_h[3] ) |
        ( m_clk_en_h & ( wctrl_h == 6'h2A | wctrl_h == 6'h2E ) );

    assign clk_mdr_h =
        ( d_clk_en_h & ( wctrl_h == 6'h23 | wctrl_h == 6'h27 | wctrl_h == 6'h2B | wctrl_h == 6'h2F)) |
        ( cyc_in_prog_h & ~status_val_h & ~prefetch_del_h & ~scnd_ref_h & 
            ( bus_grant_dec_h | ~add_reg_ena_h | d_clk_en_h ) &
            ( ~phase_1_h | ~add_reg_ena_h) &
            ( read_h | bus_grant_dec_h) );
    
            
    wire _sr_d_h = latched_bus_h == 5'h04 | latched_bus_h == `UC_BUS_READ_SEC;
    `LATCH_P( add_reg_ena_h, _sr_d_h, scnd_ref_h )

    assign force_dbus_cmi_h = (~add_reg_ena_h & read_h & cyc_in_prog_h) |
        ( bus_grant_dec_h & ~prefetch_del_h & ~phase_1_h ) |
        ( status_val_h & ~add_ena_del_h & read_h );

    wire sdfsdfsdfsdf =
        ( ~add_reg_ena_h | ~read_h) &
        (  add_reg_ena_h | ~bus_cyc_dec_h ) &
        ( ~cache_cyc_h  | ~prefetch_del_h );

    /* When sdfsdfsdfsdf:
        MBUS_WDR    : DBUS SEL=11 XB.DEC BUS
        MDR_0       : DBUS SEL=11 XB.DEC BUS
        MDR_IR      : DBUS SEL=11 XB.DEC BUS
        MDR_OSR     : DBUS SEL=11 XB.DEC BUS

        MDR_WB      : DBUS SEL=10 WBUS
        TB_WB       : DBUS SEL=10 WBUS
        CLRTB_VA_WB : DBUS SEL=10 WBUS
        WDR_WB_UR   : DBUS SEL=10 WBUS
        WDR_WB      : DBUS SEL=10 WBUS
        MBUS_WDR    : DBUS SEL=10 WBUS
       When force_dbus_cmi_h : 
        DBUS SEL=01 CMI DATA
       When cycle in progress, not READ and not ARE: 10 WBUS
       When PA BUS DATA: 01 CMI DATA
         */

    assign dbus_sel_h[1] = 
        pa_bus_data_h |
        ( cyc_in_prog_h & ~add_reg_ena_h & ~read_h ) |
        ~force_dbus_cmi_h & sdfsdfsdfsdf & (
            wctrl_h == `UC_WCTRL_MDR_WB      |          /* MDR <- DBUS <- WBUS */
            wctrl_h == `UC_WCTRL_TB_WB       |          /* PAD <- DBUS <- WBUS */
            wctrl_h == `UC_WCTRL_CLRTB_VA_WB |          /* VA <- WBUS */
            wctrl_h == `UC_WCTRL_WDR_WB_UR   |          /* WDR <- DBUS <- WBUS UN ROTATED */
            wctrl_h == `UC_WCTRL_WDR_WB      |          /* WDR <- DBUS <- WBUS */
            wctrl_h == `UC_WCTRL_MBUS_WDR    |          /* MBUS <- WDR */
            wctrl_h == `UC_WCTRL_MDR_0       |          /* MDR <- DBUS <- 0 */
            wctrl_h == `UC_WCTRL_MDR_IR      |          /* MDR <- DBUS <- DECODE BUS <- IR */
            wctrl_h == `UC_CCPSL_MDR_OSR_CCBR_BRATST ); /* MDR <- DBUS <- DECODE BUS <- ZEROEXT OSR */
    
    assign dbus_sel_h[0] = 
        force_dbus_cmi_h | sdfsdfsdfsdf & (
            wctrl_h == `UC_WCTRL_MBUS_WDR |
            wctrl_h == `UC_WCTRL_MDR_0    |
            wctrl_h == `UC_WCTRL_MDR_IR   |
            wctrl_h == `UC_CCPSL_MDR_OSR_CCBR_BRATST );
    
    assign tb_hit_out_h = ~tb_ctl_h[1:0];

    reg [3:0] _wb_out_h;
    always @ (  sc_add_h or saved_mode_h or tb_ctl_h or wr_vect_h or mme_h ) begin
        case( sc_add_h[1:0] )
            2'b11  : _wb_out_h <= tb_ctl_h;
            2'b01  : _wb_out_h <= saved_mode_h;
            2'b10  : _wb_out_h <= {3'b0, wr_vect_h };
            2'b00  : _wb_out_h <= {3'b0, mme_h };
            default: _wb_out_h <= 4'b0000;
        endcase
    end

    assign wbus_out_h = ena_wbus_h ? _wb_out_h : 4'b1111;
    assign amux_sel_h[1] = pa_wbus_h | phys_add_h;
    assign amux_sel_h[0] = inval_check_h | pa_bus_data_h;

    assign bsrc_sel_h[1] = ~wctrl_h[3] & ~wctrl_h[2] & ~phase_1_h;
    assign bsrc_sel_h[0] = phase_1_h | 
        (wctrl_h[3] & ~wctrl_h[0]) |
        (wctrl_h[1] & ~wctrl_h[0]);

    assign clk_sel_h[1] = clk_wdr_h | ( prefetch_del_h & ~status_val_h );
    assign clk_sel_h[0] = clk_wdr_h | clk_mdr_h;
    assign comp_mode_h  = psl_cm_h & ( ~prefetch_l | ~full_add_h ); 
    assign ena_va_l = ~(dest_va_h & d_clk_en_h );
    assign pte_check_l = ~((pte_check_h | write_tb_h) & prefetch_l);
    wire clrtb_nochk_h = ~inval_check_h & wctrl_h == `UC_WCTRL_CLRTB_VA_WB;
    wire ena_tb_wr_h   = d_clk_en_h     & wctrl_h == `UC_WCTRL_TB_WB;
    assign tb_grp_wr_h[1] = clrtb_nochk_h |
        ( ena_tb_wr_h & ( latched_hit_h[1] | (~latched_hit_h[0] & ~replace_0_h) ) );
    assign tb_grp_wr_h[0] = clrtb_nochk_h |
        ( ena_tb_wr_h & ( latched_hit_h[0] | (~latched_hit_h[1] &  replace_0_h) ) );
    assign tb_output_ena_l = ~(
        ~inval_check_h & ~pa_wbus_h & ~phys_add_h & ~pa_bus_data_h & // OR or AND ?
        ( add_reg_ena_h | ( dbus_sel_h == 2'b00 & ~force_dbus_cmi_h ) ) );
    assign tb_parity_ena_h = (
        mme_h & ( prefetch_del_h | (~bus_grant_dec_h & ~phys_dec_h) ) );
 endmodule