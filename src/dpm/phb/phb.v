`include "ucodedef.vh"
`include "chipmacros.vh"

module dc629_phb(
	 input           sac_reset_h,
    input           mclk_l,
    input           d_clk_en_h,

    input  [31:30]  wbus_31_30_h,
    output [31:30]  wbus_31_30_out_h,
    input           wbus_27_h,
    output          wbus_27_out_h,
    input  [5:0]    wbus_5_0_h,
    output reg [5:0]    wbus_5_0_out_h,

    input  [4:0]    misc_ctl_h,
    input  [2:0]    gd_sam_h,

    /* BUT Invalid L */
    input           ibut_l,

    /* Load IR L */
    input           ld_ir_l,
    
    input           do_service_l,

    input           ld_osr_l,

    input           interrupt_h,

    input           dis_cs_addr_h,

    input [5:0]     but_h,

    output [5:0]    cs_addr_l,

    output reg      psl_cm_h = 1'b0,
    output reg      psl_fpd_h = 1'b0,
    output reg      psl_tm_h = 1'b0,

    output [1:0]    ird_add_ctl,

    output          ird_ldrnum_h,

    /* unused */
    output          but_cc_h );
    wire [5:0] sf_s_h;
    wire [5:0] sf_c_h;
    reg [5:0] sf_q_h;
    
    /*
                            ; NOTE 03 : STEPC <- STEPC - 4 & Branch ON Original Value  CSA<2>  CSA<1>  CSA<0>
                        ;          ORIG VALUE = 0                                   0       0       0
                        ;          ORIG VALUE = 1                                   0       0       1
                        ;          ORIG VALUE = 2                                   0       1       0
                        ;          ORIG VALUE = 3                                   0       1       1
                        ;          ORIG VALUE >OR= 4, AND NO INT OR TIM OV          1       0       0
                        ;          ORIG VALUE >OR= 4, AND INT OR TIM OV             1       0       1
 */

    wire dec_br_sc4_intts_h = (but_h == 6'h0D) & ibut_l;
    wire dec_wr_stepc_h  = gd_sam_h == `GS_WRITE_STEPC;
    wire dec_wr_sflags_h = gd_sam_h == `GS_WRITE_STEPC;
    wire dec_wr_psl_h    = gd_sam_h == `GS_WRITE_PSL;
    wire dec_wr_psw_h    = gd_sam_h == `GS_WRITE_PSW;
    wire dec_rd_pslsf_h  = gd_sam_h == `GS_READ_PSL_SFLAGS;
    wire dec_rd_psl_h    = gd_sam_h == `GS_READ_PSL;
    wire dec_rd_pslsc_h  = gd_sam_h == `GS_READ_PSL_STEPC;
    wire dec_rd_pslhi_h  = dec_rd_pslsf_h | dec_rd_psl_h | dec_rd_pslsc_h;

    assign sf_c_h[0]       = misc_ctl_h == 5'h00;
    assign sf_c_h[1]       = misc_ctl_h == 5'h01;
    assign sf_c_h[2]       = misc_ctl_h == 5'h02;
    assign sf_c_h[3]       = misc_ctl_h == 5'h03;
    assign sf_c_h[4]       = misc_ctl_h == 5'h04;
    assign sf_c_h[5]       = misc_ctl_h == 5'h05;
    assign sf_s_h[0]       = misc_ctl_h == 5'h08;
    assign sf_s_h[1]       = misc_ctl_h == 5'h09;
    assign sf_s_h[2]       = misc_ctl_h == 5'h0A;
    assign sf_s_h[3]       = misc_ctl_h == 5'h0B;
    assign sf_s_h[4]       = misc_ctl_h == 5'h0C;
    assign sf_s_h[5]       = misc_ctl_h == 5'h0D;
    wire dec_clr_tp_h      = misc_ctl_h == 5'h12;
    wire dec_sc_d1_h       = (misc_ctl_h == 5'h13) | ibut_l & (but_h==6'h0C);
    wire dec_clr_fpd_h     = misc_ctl_h == 5'h1C;
    wire dec_set_fpd_h     = misc_ctl_h == 5'h1D;
    wire dec_mcwr_stepc_h  = misc_ctl_h[4:2] == 3'b101;

    wire dec_sc_d4_h = dec_br_sc4_intts_h;
    wire dec_sc_d_h = dec_sc_d1_h | dec_sc_d4_h;


    wire dec_sc_clr_h = 1'b0;
    wire dec_sc_ld_h = dec_sc_clr_h | dec_sc_d_h | dec_wr_stepc_h | dec_mcwr_stepc_h;





    wire [5:0]   _wbus_5_0_h   = wbus_5_0_h & wbus_5_0_out_h;
    wire [31:30] _wbus_31_30_h = wbus_31_30_h & wbus_31_30_out_h;
    wire         _wbus_27_h    = wbus_27_h & wbus_27_out_h;
    
    /* step counter */
    reg [4:0] sc_q_h = 4'b0000;

    wire [4:0] sc_d_h;
    wire [4:0] sc_dec_h;
    reg  [4:0] sc_ld_h;
    wire sc_en_h = d_clk_en_h & dec_sc_ld_h;

    `FF_EN_P( mclk_l, sc_en_h, sc_d_h, sc_q_h)

	 assign ird_ldrnum_h = (~ld_osr_l) | misc_ctl_h == 5'h11; //TODO: IRD Stuff

    assign sc_d_h   = dec_sc_d_h ? sc_dec_h : sc_ld_h;
    assign sc_dec_h = dec_sc_d4_h ? (sc_q_h - 5'h4) : (sc_q_h - 5'h1);

    always @ ( misc_ctl_h or _wbus_5_0_h[4:0] or dec_wr_stepc_h ) begin
        casez( { dec_wr_stepc_h, misc_ctl_h } )
            6'b1zzzzz: sc_ld_h <= _wbus_5_0_h[4:0];
            6'h14    : sc_ld_h <= 5'd2;
            6'h15    : sc_ld_h <= 5'd6;
            6'h16    : sc_ld_h <= 5'd14;
            6'h17    : sc_ld_h <= 5'd30;
            default  : sc_ld_h <= 5'b00000;
        endcase

    end

    wire psl_ld_en_h, psw_ld_en_h;
    assign psl_ld_en_h  = dec_wr_psl_h;
    assign psw_ld_en_h = psl_ld_en_h | dec_wr_psw_h;

    /* psl flags */
    reg psl_t_h = 1'b0; 
    `FF_EN_P( mclk_l, psl_ld_en_h, _wbus_31_30_h[31], psl_cm_h )
    `FF_EN_P( mclk_l, psl_ld_en_h, _wbus_31_30_h[30], psl_tm_h )
    `FF_EN_P( mclk_l, psw_ld_en_h, _wbus_5_0_h[4]   , psl_t_h )
    `FF_EN_P( mclk_l, psl_ld_en_h, _wbus_27_h       , psl_fpd_h )
    wire [5:0] sf_d_h = dec_wr_sflags_h ? _wbus_5_0_h : (sf_q_h | sf_s_h) & ~sf_c_h;
    `FF_RESET_SZ_EN_P( 6, mclk_l, sac_reset_h, d_clk_en_h, sf_d_h, sf_q_h )

    assign wbus_31_30_out_h = dec_rd_pslhi_h ? {psl_cm_h, psl_tm_h} : 2'b11;
    assign wbus_27_out_h    = dec_rd_pslhi_h ?  psl_fpd_h           : 1'b1;

    always @ ( dec_rd_pslsc_h or dec_rd_pslsf_h ) begin
        case ( { dec_rd_pslsc_h, dec_rd_pslsf_h } )
            2'b01   : wbus_5_0_out_h <= sf_q_h;
            2'b10   : wbus_5_0_out_h <= {sf_q_h[5], sc_q_h};
            2'b00   : wbus_5_0_out_h <= 6'b111111;
            default : wbus_5_0_out_h <= 6'bxxxxxx;
        endcase
    end

    wire [2:0] sc_bovi_h = interrupt_h ? 3'b101 : 3'b100;
    wire [2:0] sc_bov_h  = ( sc_q_h < 5'h4 ) ? sc_q_h[2:0] : sc_bovi_h;
    reg [5:0] _cs_addr_l;
    /*                         ; NOTE 04 : CSA<1> = (.NOT.MM.NOINT).AND.(INT.OR.TIMSERV)  */
    always @ ( but_h or sf_c_h or sc_q_h or psl_fpd_h or wbus_31_30_h or wbus_5_0_h ) begin
        case( but_h ) 
            6'h08: _cs_addr_l <=           ~wbus_5_0_h[5:0];
            6'h09: _cs_addr_l <= {4'b1111, ~wbus_5_0_h[1:0]};
            6'h0A: _cs_addr_l <= {5'b11111, ~wbus_5_0_h[0]};
            6'h0B: _cs_addr_l <= {4'b1111 , ~(interrupt_h & ~sf_q_h[4]), 1'b1};
            6'h0C: _cs_addr_l <= {5'b11111 ,   sc_q_h != 5'b01};
            6'h0D: _cs_addr_l <= {3'b111 ,  ~sc_bov_h };
            6'h0E: _cs_addr_l <= {5'b11111 ,   wbus_5_0_h[1:0] == 2'b00};
            6'h0F: _cs_addr_l <= {5'b11111, ~psl_fpd_h} ;
            6'h10: _cs_addr_l <= {5'b11111, ~sf_q_h[0]};
            6'h11: _cs_addr_l <= {5'b11111, ~sf_q_h[4]};
            6'h12: _cs_addr_l <= {3'b111,   ~sf_q_h[2], 2'b11};
            6'h13: _cs_addr_l <= {5'b11111, ~sf_q_h[3]};
            6'h14: _cs_addr_l <= {4'b1111,  ~sf_q_h[1:0]};
            6'h15: _cs_addr_l <= {4'b1111,   ~sf_q_h[1], ~(sf_q_h[2] ^sf_q_h[3])};
            6'h16: _cs_addr_l <= {3'b111,   ~sf_q_h[2:0]};
            6'h17: _cs_addr_l <= {4'b1111,  ~sf_q_h[1], 1'b1};
            6'h18: _cs_addr_l <= 6'b111111; //TODO BRANCH ON ADD MODE
            6'h19: _cs_addr_l <= 6'b111111; //IR.2TO0 not impl here
            6'h1A: _cs_addr_l <= {5'b11111, ~sf_q_h[5]};
            6'h1B: _cs_addr_l <= {4'b1111,  ~wbus_31_30_h};
            default: _cs_addr_l <= 6'b111111;
        endcase
    end
    assign cs_addr_l = (dis_cs_addr_h | ~ibut_l) ? 6'b111111 : _cs_addr_l;
endmodule