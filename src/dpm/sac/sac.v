`include "chipmacros.vh"

`define ORDERLATCH( e, f, q ) \
    always @ ( e or f ) begin \
        if ( e & f ) \
            q <= 1'b1; \
        else if ( ~f ) \
            q <= 1'b0; \
        else if ( ~e & ~q ) \
            q <= 1'b0; \
    end

/* 
    Assuming this is actually a SR flipflop: 
        Flop latches D when E active
        Flop reset     when D deasserts.  
        Clear when already clear is nonsensical!
    This creates a version of D whose rising edge is constrained to when E is active
*/
`define ORDERLATCH_ORIG( name, e, f, q ) \
    wire name``_s_h =  f & e; \
    wire name``_r_h = ~f | (~e & ~q); \
    `RSFF( name``_s_h, name``_r_h, q )

module dc617_sac(
        /* Clocks */
        input        osc_h,
        input        mclk_h,
        input        base_clk_h,
		input        sac_reset_h,

        input [1:0]  clk_ctl_h,
        input        mem_stall_h,
        input        clkx_h,
        input        fpa_wait_l,
        input        fpa_stall_l,
        input        gen_dest_inh_l,
        input        double_enable_h,
        input        micro_trap_l,
        input        cs_par_err_h,
        input        ld_osr_l,
        input        psl_cm_h,
        input        but_cc_a_h,
        input [2:0]  but_h,
        input        arith_trap_l,
        input        fpa_trap_l,
        input        tmr_svc_h,
        input        con_halt_l,
        input        int_pend_l,
        input        psl_tp_h,
        input        clr0_l,
        input        mseq_init_l,
        input        addr_inh_l,

        output       setc_h,
        output       halt_l,
        output       mken_h,
        output       dken_h,
        output       qden_h,
        output       phas_h,

        output       ifetch_h,
        output       do_service_l,
        output       uvector_h,
        output reg [2:0] cs_addr_l,
        output reg [2:0] ird_ctr_h,

        output       latch_utrap_l
        
    );
    wire mseq_init_h = ~mseq_init_l;
    wire clr_div3_h = 1'b0;
    wire mclk_l = ~mclk_h;
    wire internal_stop_m_h;
    wire internal_stop_d_h;

    reg clkx_ff_h = 1'b0;
    reg ret_inh_ff_h = 1'b0;
    reg cm_ird1_ff_h = 1'b0;
    reg ld_osr_buf_ff_l = 1'b1;
    reg utrap_ff_h = 1'b0;
    reg utrap_buf_ff_h = 1'b0;
    reg [1:0] delay_clk_ctrl_reg_h = 2'b0;
    reg cs_error_ff_h = 1'b0;
    reg but_svc_ff_h = 1'b0;
    reg [1:0] basic_clk_reg_h = 2'b00;
    reg clk_enable_ff_h = 1'b0;
    reg pset_ff_h = 1'b0;
    reg pclr_ff_h = 1'b1;
    reg phase_ff_h = 1'b0;
    reg m1_ff_h = 1'b0;
    reg m2_ff_h = 1'b0;
    reg d1_ff_h = 1'b0;
    reg d2_ff_h = 1'b0;
    reg halt_ff_h = 1'b0;


    wire ckx_ff_d_h = mseq_init_l ? clkx_h & pset_ff_h : 1'b0;
    `FF_N( base_clk_h,  ckx_ff_d_h, clkx_ff_h )

    wire rinh_ff_d_h = mseq_init_l ? but_cc_a_h & but_h == 3'd3 & ~utrap_ff_h : 1'b0;
    `FF_N( mclk_h,  rinh_ff_d_h, ret_inh_ff_h )

    wire cid1_ff_d_h =
        psl_cm_h & 
        but_cc_a_h & 
        (but_h == 3'd4 | but_h == 3'd5) & 
        ~phase_ff_h & pset_ff_h & 
        mseq_init_l;
    `FF_N( base_clk_h, cid1_ff_d_h, cm_ird1_ff_h )

    `FF_RESET_N( base_clk_h, mseq_init_h, ~micro_trap_l, utrap_ff_h )

    wire _utrap_del_d_h = mseq_init_l & ~micro_trap_l & utrap_ff_h;
    `FF_RESET_N( base_clk_h, micro_trap_l, _utrap_del_d_h, utrap_buf_ff_h )

    wire _csef_j_h = cs_par_err_h & mseq_init_l;
    wire _csef_k_h = mseq_init_h | ( but_cc_a_h & (but_h == 3'd4 | but_h == 3'd5 ));
    `JKFF_P( mclk_l, _csef_j_h, _csef_k_h, cs_error_ff_h )

    wire bsff_d_h = mseq_init_l & ifetch_h;
    `FF_P( mclk_l, bsff_d_h, but_svc_ff_h )

    wire [1:0] bscr_d_h = (clr_div3_h | basic_clk_reg_h == 2'b10) ? 2'b00 : ( basic_clk_reg_h + 2'b01 );
    `FF_N( osc_h, bscr_d_h, basic_clk_reg_h )

    `FF_PRESET_P( osc_h, clr_div3_h, basic_clk_reg_h == 2'b00, clk_enable_ff_h )

    assign setc_h = basic_clk_reg_h[1];

    assign phas_h = pset_ff_h | pclr_ff_h;

    /* HALT or INTERNAL STOP M asserted signal */
    wire hsm_h = internal_stop_m_h | ~halt_l;

    /* PSET is set when not BASE CLOCK H */
    /* Orders PSET to rise only while PCLR set */
    wire pset_e_h = pclr_ff_h;
    wire pset_f_h = ~base_clk_h          & ~clr_div3_h;
    `ORDERLATCH_ORIG( pset, pset_e_h, pset_f_h, pset_ff_h )

    /* Normal      : PCLR is set when PHASE set   */
    /* Halt/stall  : PCLR is set when PHASE clear */
    /* Orders PCLR to rise only while BASE CLOCK H or PSET set */
    wire pclr_e_h = base_clk_h | pset_ff_h;
    wire pclr_f_h = phase_ff_h == hsm_h  & ~clr_div3_h; // changed == to != 
    `ORDERLATCH_ORIG( pclr, pclr_e_h, pclr_f_h, pclr_ff_h )

    `JKFF_RESET_N( base_clk_h, clr_div3_h, ~hsm_h, ~hsm_h, phase_ff_h )

    assign mken_h = m1_ff_h | m2_ff_h;
    assign dken_h = d1_ff_h | d2_ff_h;

    /* D1/M1 FF follow DM1F, only going high during PHASE (potentially inhibiting D) */
    wire dm1_f_h = clk_enable_ff_h  & ~pclr_ff_h;
    wire m1_e_h = phase_ff_h;
    wire d1_e_h = phase_ff_h & ~internal_stop_d_h;
    `ORDERLATCH_ORIG( m1, m1_e_h, dm1_f_h, m1_ff_h )
    `ORDERLATCH_ORIG( d1, d1_e_h, dm1_f_h, d1_ff_h )

    /* D2/M2 FF follow PHASE when not halted/stalled, only going high while not CLK ENABLE FF */
    wire m2_f_h = phase_ff_h & ~hsm_h;
    wire d2_f_h = phase_ff_h & ~hsm_h & ~internal_stop_d_h;
    wire dm2_e_h = ~clk_enable_ff_h;
    `ORDERLATCH_ORIG( d2, dm2_e_h, d2_f_h, d2_ff_h )
    `ORDERLATCH_ORIG( m2, dm2_e_h, m2_f_h, m2_ff_h )



    assign qden_h = halt_l & ( double_enable_h | (
        ~internal_stop_m_h & ~internal_stop_d_h & phase_ff_h ));

    assign internal_stop_m_h = mseq_init_l & ( 
        mem_stall_h  | 
        clkx_ff_h    | 
        cm_ird1_ff_h |
        (~micro_trap_l & ~utrap_buf_ff_h ) |
        ( ld_osr_l     & ~ld_osr_buf_ff_l & phase_ff_h ) |
        ( ~fpa_wait_l  & ~fpa_stall_l) );

    assign internal_stop_d_h = ~gen_dest_inh_l | ~mseq_init_l | ret_inh_ff_h;

    assign halt_l = ~halt_ff_h;
    wire dblcse_h = cs_error_ff_h & cs_par_err_h;

    /* 
        Set halt flip flop if STOP->STEPB or STEPB or STEPM->STEPB
        Set halt flip flop if STEPM and PHASE L and not internal stop M
        Set halt flip flop if STOP  and PHASE L and not internal stop M
    */
    wire h_j_h =  dblcse_h | (
        clk_ctl_h == 2'd1 & ( delay_clk_ctrl_reg_h != 2'd3)     | 
        clk_ctl_h == 2'd2 & ( ~phase_ff_h & ~internal_stop_m_h) | 
        clk_ctl_h == 2'd0 & ( ~phase_ff_h & ~internal_stop_m_h) );

    /*
        Clear halt flip flop when CLKCTL = RUN or
        Clear halt flip flop when CLKCTL = STOP->STEPB or
        Clear halt flip flop when CLKCTL = STOP->STEPM
    */
    wire h_k_h = ~dblcse_h & (
        clk_ctl_h == 2'd3 |
        delay_clk_ctrl_reg_h == 2'd0 & ( clk_ctl_h == 2'd2 | clk_ctl_h == 2'd1 )); 

    `JKFF_RESET_N( base_clk_h, mseq_init_h, h_j_h, h_k_h, halt_ff_h)


    /*
        CLK     DELAY                       CS      CS       
        CTRL    CLK                         PARITY  ERROR    MSEQ   HALT         BASE
        <1:0>   CTRL    PHASE  INTERNAL     ERROR   FLIP     INIT   FLIP         CLOCK       HALT
        X       <1:0>   H      STOP M       H       FLOP     L      FLOP         H           L
        ---------------------------------------------------------------------------------------
        X       X       X      X            X       X        L      CLEAR        X           H
        
        X       X       L      UNASSERTED   H       SET      H      CLEAR->SET   H->L        H->L
        X       X       H      ASSERTED     H       SET      H      X            H->L        X->L
        X       X       H      X            H       SET      H      SET          H->L        L
        
        3       X       X      X            L   OR  CLEAR    H      SET->CLEAR   H->L        L->H
        2       0       X      X            L   OR  CLEAR    H      SET->CLEAR   H->L        L->H
        1       0       X      X            L   OR  CLEAR    H      SET->CLEAR   H->L        L->H

        1       0,1,2   X      X            L   OR  CLEAR    H      CLEAR->SET   H->L        H->L
        2       X       L      UNASSERTED   L   OR  CLEAR    H      CLEAR->SET   H->L        H->L
        0       X       L      UNASSERTED   L   OR  CLEAR    H      CLEAR->SET   H->L        H->L
                OTHERWISE                                           NO CHANGE    H->L        NO CHANGE
    */

    reg [2:0] tvec_h;
    wire [5:0] trap_bus_h = {
        ~arith_trap_l, ~fpa_trap_l, tmr_svc_h,  
        ~con_halt_l, ~int_pend_l, psl_tp_h };

    wire trap_pend_h = |trap_bus_h;
    wire only_int_pend_h = ~int_pend_l & (|trap_bus_h[5:2] | trap_bus_h[0]);
    /* 
                |  UVECTOR H  |  DO SRVC L 
     -----------+-------------+-------------
      Microtrap |  Asserted   | Deasserted 
      Trap      |  Deasserted | Asserted
      Interrupt |  Asserted   | Asserted    */
    /* Trap priority encoder */
    always @ ( trap_bus_h ) begin
                 if( trap_bus_h[0] ) tvec_h = 3'h1;
            else if( trap_bus_h[1] ) tvec_h = 3'h2;
            else if( trap_bus_h[2] ) tvec_h = 3'h4;
            else if( trap_bus_h[3] ) tvec_h = 3'h6;
            else if( trap_bus_h[4] ) tvec_h = 3'h0;
            else if( trap_bus_h[5] ) tvec_h = 3'h5;
            else                     tvec_h = 3'hX;
    end
    wire cs_addr_oe_h = ~cs_addr_oe_l;

    /* If BUT FF is set and no trap is pending, disable CS generation  */
    wire cs_addr_oe_l = ~( but_svc_ff_h & ~trap_pend_h & addr_inh_l & ~cs_par_err_h );

    /* Trap vector driver */
    `OPENDRAIN_DRV( cs_addr_oe_h, 3, cs_addr_l, tvec_h )

    assign do_service_l = ~( ~cs_par_err_h & but_svc_ff_h & trap_pend_h );

    assign uvector_h = phase_ff_h & mseq_init_l & (
            utrap_ff_h & do_service_l | 
            ~do_service_l & only_int_pend_h );

    assign latch_utrap_l = ~(phase_ff_h & utrap_ff_h);

    
    /* BUT CTRL CODE A is set when BUT=000xxx and not LONG LIT */
    /* That means, when BUT is one of 
      00 | NOP          | NO BRANCH                                           | 0 | unc
      01 | IRDX         | RETURN FROM OPERAND EVALUATION                      | 0 | inc if ld_osr_l==0
      02 | RETURN       |                                                     | 0 | unc
      03 | RET.DINH     | POP U-STK AND RET TO 'STK + NEXT'(MOD64)            | 0 | unc
      04 | IRD1         | EVALUATE OPCODE AND 1ST OPERAND OF NEXT INSTRUCTION | 1 | 7 at instr end
      05 | IRD1TST      | SAME AS IRD1 EXCEPT NEXT ADDRESS IS FROM 'NEXT'     | 7 | unc
      06 | LOD.INC.BRA  | LOAD OSR, INC IRDCNT, BRANCH ON ADD MODE            | 0 | inc
      07 | LOD.BRA      | LOAD OSR,           , BRANCH ON ADD MODE            | 0 | unc
    */
    /* Matches BUT/IRD1 microorder */
    assign ifetch_h = but_cc_a_h & ( but_h == 3'h4 | but_h == 3'h5) & ~gen_dest_inh_l;

    /* Matches BUT/IRD1 BUT/IRD1TST microorders */
    wire ird1_h    = but_cc_a_h & ( but_h == 3'h4 | but_h == 3'h5 );

    /* Matches BUT/IRDX microorders */
    wire _irdx_h   = but_cc_a_h & ( but_h == 3'h1 );

    /* Matches BUT/LOD.INC.BRA microorders */
    wire lodinc_h  = but_cc_a_h & ( but_h == 3'h5 );

    wire irdx_val_h = ird_ctr_h[ 2 : 1 ] == 2'h0;

    /* High when this is a IRDX microcycle */
    wire irdx_h    = _irdx_h & irdx_val_h;

    /* High when IRD_CNT must be incremented */
    wire ird_inc_h = ird1_h | irdx_h | lodinc_h;

    always @ ( posedge ird1_h or posedge mclk_l ) begin
        if ( ird1_h == 1'b1 && mclk_l == 1'b0 )
            ird_ctr_h = 3'h7;
        else if ( ird_inc_h == 1'b1 )
            ird_ctr_h = ird_ctr_h + 3'h1;
    end
endmodule
