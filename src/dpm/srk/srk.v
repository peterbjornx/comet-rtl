`include "srkmacros.vh"
`include "ucodedef.vh"
`include "chipmacros.vh"

module dc614_srk(
    input       qd_clk_l,
    input [7:0] wbus_h,
    input [5:0] rot_h,
    input [3:0] wmuxz_h,
    input [1:0] dsize_h,

    output reg [1:0] sta_h,

    output [4:0] shf_l,
    output [1:0] pri_l,
    output [5:0] sec_l,

    input [7:0] sbus_h,
    output reg [7:0] sbus_out_h );
    
    wire dec_pl_mss_h= rot_h == `UC_ROT_PL_MSS;
    wire dec_pl43_wb = rot_h == `UC_ROT_OLIT0_PL43_WB;
    wire dec_pl_wb   = rot_h == `UC_ROT_SL_PL_WB;
    wire dec_sl_sb   = rot_h[5:1] == 5'b10111; /* 2E / 2F */
    wire dec_pl_sb   = rot_h[5:1] == 5'b10110; /* 2C / 2D */
    wire dec_sl_wb   = rot_h == `UC_ROT_PL_SL_WB;
    wire dec_pl_lit  = rot_h == `UC_ROT_OLIT0_PL_LIT;
    wire dec_sl_lit  = rot_h == `UC_ROT_OLIT0_SL_LIT;

    wire [3:0] dec_pld_sel_h = {dec_pl_mss_h, dec_pl43_wb, dec_pl_wb, dec_pl_lit};
    wire [1:0] dec_sld_sel_h = {dec_sl_wb, dec_sl_lit};

    reg [1:0] plmss_43_h;
    reg [2:0] plmss_20_h;
    reg [5:0] pl_d;
    reg [5:0] pl_q = 6'b000000;
    reg [5:0] sl_d;
    reg [5:0] sl_q = 6'b000000;

    `FF_P( qd_clk_l, pl_d, pl_q )
    `FF_P( qd_clk_l, sl_d, sl_q )

    always @ ( wmuxz_h ) begin
        casez ( wmuxz_h )
            4'b0zzz: plmss_43_h <= 2'd3;
            4'b10zz: plmss_43_h <= 2'd2;
            4'b110z: plmss_43_h <= 2'd1;
            4'b1110: plmss_43_h <= 2'd0;
            default: plmss_43_h <= 2'dx;
        endcase
        
    end

    always @ ( sbus_h ) begin
        casez( sbus_h ) 
            8'b1zzzzzzz: plmss_20_h <= 3'd7;
            8'b01zzzzzz: plmss_20_h <= 3'd6;
            8'b001zzzzz: plmss_20_h <= 3'd5;
            8'b0001zzzz: plmss_20_h <= 3'd4;
            8'b00001zzz: plmss_20_h <= 3'd3;
            8'b000001zz: plmss_20_h <= 3'd2;
            8'b0000001z: plmss_20_h <= 3'd1;
            8'b00000001: plmss_20_h <= 3'd0;
            default    : plmss_20_h <= 3'bxxx;
        endcase
    end

    /* PL load */
    always @ ( dec_pld_sel_h or pl_q or wbus_h or sbus_h or plmss_43_h or plmss_20_h ) begin
        casez( dec_pld_sel_h )
            4'b1000 : pl_d <= { 1'b0, plmss_43_h , plmss_20_h };
            4'b0100 : pl_d <= { pl_q[5], wbus_h[1:0], pl_q[2:0]  };
            4'b0010 : pl_d <= wbus_h[5:0];
            4'b0001 : pl_d <= sbus_h[5:0];
            4'b0000 : pl_d <= pl_q;
            default: pl_d <= 6'bxxxxxx;
        endcase
    end

    /* SL load */
    always @ ( dec_sld_sel_h or pl_q or wbus_h or sbus_h ) begin
        casez( dec_sld_sel_h )
            2'b10 : sl_d <= wbus_h[5:0];
            2'b01 : sl_d <= sbus_h[5:0];
            2'b00 : sl_d <= sl_q;
            default: sl_d <= 6'bxxxxxx;
        endcase
    end

    /* PL / SL readback */
    always @ ( dec_sl_sb or dec_pl_sb or pl_q or sl_q ) begin
        casez( {dec_sl_sb,dec_pl_sb} )
            2'b10 : sbus_out_h <= { 2'b0, sl_q };
            2'b01 : sbus_out_h <= { 2'b0, pl_q };
            2'b00 : sbus_out_h <= 8'hFF;
            default: sbus_out_h <= 8'bxxxxxxxx;
        endcase
    end

    reg [12:0] dec_h;

    /* TD Figure 2-107  */
    wire [5:0] sec_result_h = sl_q + {3'b0000, pl_q[1:0]} - 6'b000001;
    wire [5:0] sec_sl_enc_h = sec_result_h | {1'b0, sec_result_h[5], 4'b0000};

    assign pri_l = ~dec_h[12:11];
    assign sec_l = ~dec_h[10: 5];
    assign shf_l = ~dec_h[ 4: 0];
    wire [5:0] pl_plus_sl_h = pl_q + sl_q;

    /* TD Table 2-55   */
    always @ ( rot_h or pl_q or sl_q or plmss_43_h or pl_plus_sl_h or dsize_h ) begin
        casez( rot_h )
            `UC_ROT_XZ_MR         : dec_h <= {`PRI_EXTZ_MR, sec_sl_enc_h        , pl_q[4:0]};
            `UC_ROT_XZ_MM         : dec_h <= {`PRI_EXTZ_MM, sec_sl_enc_h        , pl_q[4:0]};
            `UC_ROT_XZ_RR         : dec_h <= {`PRI_EXTZ_RR, sec_sl_enc_h        , pl_q[4:0]};
            `UC_ROT_ASR_M_P       : dec_h <= {`PRI_SECOND , 2'h3, `SEC_ASR_M    , pl_q[4:0]};
     
            `UC_ROT_RR_MR_P       : dec_h <= {`PRI_EXTZ_MR, 6'h3F               , pl_q[4:0]};
            `UC_ROT_RR_MM_P       : dec_h <= {`PRI_EXTZ_MM, 6'h3F               , pl_q[4:0]};
            `UC_ROT_RR_RR_P       : dec_h <= {`PRI_EXTZ_RR, 6'h3F               , pl_q[4:0]};
            `UC_ROT_RR_MR_S       : dec_h <= {`PRI_EXTZ_MR, 6'h3F               , sl_q[4:0]};
     
            `UC_ROT_RL_RM_4       : dec_h <= {`PRI_EXTZ_MR, 6'h3C               , 5'h1C};
            `UC_ROT_RR_MR_4       : dec_h <= {`PRI_EXTZ_MR, 6'h3C               , 5'h04};
            `UC_ROT_RR_RR_SIZ     : dec_h <= {`PRI_EXTZ_RR, 6'h3C               , dsize_h + 2'b01, 3'b000 };
            `UC_ROT_RR_MR_9       : dec_h <= {`PRI_EXTZ_MR, 6'h3E               , 5'h09};
    
            `UC_ROT_XZ_PTX        : dec_h <= {`PRI_EXTZ_MM, 6'h19               , 5'h07};
            `UC_ROT_XZ_VPN        : dec_h <= {`PRI_EXTZ_MM, 6'h15               , 5'h09};
            `UC_ROT_RR_MM_SIZ     : dec_h <= {`PRI_EXTZ_MM, 6'h39               , dsize_h + 2'b01, 3'b000 };
            `UC_ROT_GETNIB        : dec_h <= {`PRI_EXTZ_MM, 6'h3                , 5'h00};
     
            `UC_ROT_GETEXP        : dec_h <= {`PRI_EXTZ_MM, 6'hA                , 5'h07};
            `UC_ROT_RL_MM_PTE     : dec_h <= {`PRI_EXTZ_MM, 6'h3A               , 5'h17};
            `UC_ROT_CLR2BM        : dec_h <= {`PRI_SECOND , 2'h3, `SEC_CLR2BM   , 5'h00};
            `UC_ROT_CLR1BM        : dec_h <= {`PRI_SECOND , 2'h3, `SEC_CLR1BM   , 5'h10};
                
            `UC_ROT_CLR3BM        : dec_h <= {`PRI_SECOND , 2'h0, `SEC_CLR3BM   , 5'h00};
            `UC_ROT_ASL_R_7       : dec_h <= {`PRI_SECOND , 2'h2, `SEC_ASL_R    , 5'h19};
            `UC_ROT_ZERO          : dec_h <= {`PRI_SECOND , 2'h3, `SEC_ASL_M    , 5'h00};
            `UC_ROT_ASL_R_SIZ     : dec_h <= {1'b1, dsize_h != 0, 6'h34, 5'h00 - {3'b00, dsize_h}}; /* TD 2-237 first table */
                
            `UC_ROT_BCDSWP        : dec_h <= {`PRI_SECOND , 2'h0, `SEC_BCDSWAP  , 5'h00};
            `UC_ROT_GETFPF        : dec_h <= {`PRI_SECOND , 2'h3, `SEC_FPFRACT  , 5'h01};
            `UC_ROT_FPACK         : dec_h <= {`PRI_SECOND , 2'h2, `SEC_FPPACK   , 5'h01};
            `UC_ROT_CVTPN         : dec_h <= {`PRI_SECOND , 2'h2, `SEC_CVTPN    , 5'h00};
      
            `UC_ROT_CONX_SIZ      : dec_h <= {`PRI_SECOND , 2'h0, `SEC_CONST8   , 3'h00, 2'b11 - dsize_h};
            `UC_ROT_ASR_M_3       : dec_h <= {`PRI_SECOND , 2'h0, `SEC_ASR_M    , 5'h03};
            `UC_ROT_FPLIT         : dec_h <= {`PRI_SECOND , 2'h2, `SEC_FPLIT    , 5'h00};
            `UC_ROT_CVTNP         : dec_h <= {`PRI_SECOND , 2'h0, `SEC_CVTNP    , 5'h00};
  
            `UC_ROT_RL_RM_PS      : dec_h <= {`PRI_EXTZ_MR, 6'h3F               , 5'h00 - pl_plus_sl_h[4:0] };
            `UC_ROT_RL_MM_P       : dec_h <= {`PRI_EXTZ_MM, 6'h3F               , 5'h00 - pl_q[4:0] };
            `UC_ROT_RL_RR_P       : dec_h <= {`PRI_EXTZ_RR, 6'h3F               , 5'h00 - pl_q[4:0] };
            `UC_ROT_RL_RM_P       : dec_h <= {`PRI_EXTZ_MR, 6'h3F               , 5'h00 - pl_q[4:0] /* note 2?? */ };
                
            `UC_ROT_RR_MR_PS      : dec_h <= {`PRI_EXTZ_MR, 6'h3F               , pl_plus_sl_h[4:0] /* note 2?? */  };
            `UC_ROT_RR_MM_PS      : dec_h <= {`PRI_EXTZ_MM, 6'h3F               , pl_plus_sl_h[4:0] /* note 2?? */  };
            `UC_ROT_RR_RR_PS      : dec_h <= {`PRI_EXTZ_RR, 6'h3F               , pl_plus_sl_h[4:0] /* note 2?? */  };
            `UC_ROT_PL_MSS        : dec_h <= {`PRI_EXTZ_MM, 6'h3F               , 3'b00, plmss_43_h   };
   
            `UC_ROT_ASL_R_P       : dec_h <= {`PRI_SECOND , 2'h3, `SEC_ASL_R    , 5'h00 - pl_plus_sl_h[4:0] };
            `UC_ROT_ASL_M_P       : dec_h <= {`PRI_SECOND , 2'h3, `SEC_ASL_M    , 5'h00 - pl_q[4:0] };
            `UC_ROT_ASR_M_NEG_P   : dec_h <= {`PRI_SECOND , 2'h3, `SEC_ASR_M    , 5'h00 - pl_q[4:0] };
            `UC_ROT_ZLITPL        : dec_h <= {`PRI_SECOND , 2'h3, `SEC_LITZERO  , 5'h00 - pl_q[4:0] /* note 2?? */ };
                
            `UC_ROT_PL            : dec_h <= {`PRI_SECOND , 2'h1, `SEC_LOB_OFF  , 5'h0C };
            `UC_ROT_PL_SL_WB      : dec_h <= {`PRI_SECOND , 2'h1, `SEC_LOB_OFF  , 5'h08 };
            `UC_ROT_SL            : dec_h <= {`PRI_SECOND , 2'h3, `SEC_LOB_OFF  , 5'h18 };
            `UC_ROT_SL_PL_WB      : dec_h <= {`PRI_SECOND , 2'h0, `SEC_LOB_OFF  , 3'b00, plmss_43_h};
      
            `UC_ROT_ZLIT0         : dec_h <= {`PRI_SECOND , 2'h0, `SEC_LITZERO  , 5'h00 };
            `UC_ROT_ZLIT28        : dec_h <= {`PRI_SECOND , 2'h3, `SEC_LITZERO  , 5'h04 };
            `UC_ROT_ZLIT24        : dec_h <= {`PRI_SECOND , 2'h3, `SEC_LITZERO  , 5'h08 };
            `UC_ROT_ZLIT20        : dec_h <= {`PRI_SECOND , 2'h3, `SEC_LITZERO  , 5'h0C };
    
            `UC_ROT_ZLIT16        : dec_h <= {`PRI_SECOND , 2'h0, `SEC_LITZERO  , 5'h10 };
            `UC_ROT_ZLIT12        : dec_h <= {`PRI_SECOND , 2'h2, `SEC_LITZERO  , 5'h14 };
            `UC_ROT_ZLIT8         : dec_h <= {`PRI_SECOND , 2'h3, `SEC_LITZERO  , 5'h18 };
            `UC_ROT_ZLIT4         : dec_h <= {`PRI_SECOND , 2'h3, `SEC_LITZERO  , 5'h1C };
      
            `UC_ROT_OLIT0         : dec_h <= {`PRI_SECOND , 2'h0, `SEC_LITONE   , 5'h00 };
            `UC_ROT_MINUS1        : dec_h <= {`PRI_SECOND , 2'h3, `SEC_LITONE   , 5'h00 };
            `UC_ROT_OLIT24        : dec_h <= {`PRI_SECOND , 2'h2, `SEC_LITONE   , 5'h08 };
            `UC_ROT_OLIT0_PL_LIT  : dec_h <= {`PRI_SECOND , 2'h2, `SEC_LITONE   , 5'h00 };
  
            `UC_ROT_OLIT16        : dec_h <= {`PRI_SECOND , 2'h0, `SEC_LITONE   , 5'h10 };
            `UC_ROT_OLIT0_SL_LIT  : dec_h <= {`PRI_SECOND , 2'h0, `SEC_LITONE   , 5'h00 };
            `UC_ROT_OLIT8         : dec_h <= {`PRI_SECOND , 2'h2, `SEC_LITONE   , 5'h18 };
            `UC_ROT_OLIT0_PL43_WB : dec_h <= {`PRI_SECOND , 2'h0, `SEC_LITONE   , 5'h00 };

            default               : dec_h <= 13'bxxxxxxxxxxxxx;
        endcase
    end

    wire [5:0] vield_add_h = {1'b0, pl_q[4:0]}+sl_q;
    wire [1:0] bcdsign_h = { sbus_h[3:0] != 4'h0, (sbus_h[3:0] != 4'd11) & (sbus_h[3:0] != 4'd13) };
    wire [1:0] vield_h = { sl_q == 6'h00, vield_add_h >= 6'd32 };
    wire [1:0] wxne_h = { ~&wmuxz_h[3:2], ~&wmuxz_h[1:0] };
    wire [1:0] pleq_h = { pl_q[4:0] == 5'h00, pl_q[5]  };

    reg [1:0] asciisign_h;

    /* TD Table 2-57  */
    always @ ( wbus_h ) begin
        case ( wbus_h )
            8'd45  : asciisign_h <= 2'b00; /* - */
            8'd32  : asciisign_h <= 2'b01; /*   */
            8'd43  : asciisign_h <= 2'b01; /* + */
            default: asciisign_h <= 2'b11;
        endcase
    end

    reg  [1:0] wbrange_h;
    always @ ( wbus_h ) begin
        casez ( wbus_h )
            8'b00000001: wbrange_h <= 2'b00;
            8'b0000001z: wbrange_h <= 2'b00;
            8'b000001zz: wbrange_h <= 2'b00;
            8'b00001zzz: wbrange_h <= 2'b00;
            8'b0001zzzz: wbrange_h <= 2'b00;
            8'b00000000: wbrange_h <= 2'b01;
            8'b00100000: wbrange_h <= 2'b10;
            default    : wbrange_h <= 2'b11;
        endcase
    end

    reg [1:0] absval_h;
    always @ ( wbus_h ) begin
        casez ( wbus_h )
            8'b11100001: absval_h <= 2'b00; /* -31  */
            8'b1110001z: absval_h <= 2'b00; /* -29, -30 */
            8'b111001zz: absval_h <= 2'b00; /* -25 ... -28 */
            8'b11101zzz: absval_h <= 2'b00; /* -24 ... -17 */
            8'b1111zzzz: absval_h <= 2'b00; /* -16 ...  -1 */
            8'b11100000: absval_h <= 2'b01; /* -32 */
            8'b101zzzzz: absval_h <= 2'b01; 
            8'b1z0zzzzz: absval_h <= 2'b01;
            8'b000zzzzz: absval_h <= 2'b10; /* 0 ... 31 */
            default    : absval_h <= 2'b11;
        endcase
    end

    /* TD Table 2-55   */
    always @ ( rot_h or  pleq_h or wxne_h or asciisign_h or
               vield_h or bcdsign_h or vield_add_h or wbrange_h or
               absval_h ) begin
        casez( rot_h )
            6'b00_0z0z: sta_h <= vield_h;
            6'b00_0z10: sta_h <= vield_h;
            6'b00_0z11: sta_h <= { 1'b0, pleq_h[0] };
    
            6'b00_1zzz: sta_h <= dsize_h;

            6'b01_00zz: sta_h <= bcdsign_h;
            6'b01_01zz: sta_h <= asciisign_h;

            6'b10_0000: sta_h <= { vield_h[1], 1'bx };
            6'b10_0001: sta_h <= { vield_h[1], pleq_h[0] };
            6'b10_0010: sta_h <= { vield_h[1], pleq_h[0] };
            6'b10_0011: sta_h <= wxne_h;

            6'b10_010z: sta_h <= vield_h;
            6'b10_0110: sta_h <= vield_h;
            6'b10_0111: sta_h <= wxne_h;

            6'b10_100z: sta_h <= pleq_h;
            6'b10_1010: sta_h <= pleq_h;
            6'b10_1011: sta_h <= {pleq_h[1], 1'b0 };

            6'b10_11zz: sta_h <= wbrange_h;
            6'b11_zzzz: sta_h <= absval_h;

            default               : sta_h <= 2'bxx;
        endcase
    end

endmodule
