`include "ucodedef.vh"
module microdec(
    
    /*************************************/
    /*       Micro operation fields      */
    /*************************************/

    /* [ DPM20 WCTRL * H  ] WCTRL micro op field */
    input [5:0]   wctrl_h,

    /* [ DPM12 CC * H     ] CC    micro op field */
    input [1:0]   cc_h,

    /* [ DPM12 DTYPE * H  ] DTYPE micro op field */
    input [1:0]   dtype_h,

    /* [ DPM17 LIT * H    ] LIT   micro op field */
    input [1:0]   lit_h,

    /* [ DPM17 ISTRM H    ] ISTRM micro op field */
    input         istrm_h,

    /* [ DPM20 LONG LIT L ]  LIT/LONLIT micro order */
    input         long_lit_l,
    
    /*************************************/
    /*     Control signals from MIC      */
    /*************************************/

    /* [ MIC04 MSRC XB H ] */
    input         msrc_xb_h,
    
    /*************************************/
    /*     Control signals from IRD      */
    /*************************************/

    /* [ DPM19 DSIZE LATCH * (1) H ] */
    input [1:0]   dsize_lat_h,

    /* [ DPM18 DISP ISIZE * H ] */
    input [1:0]   disp_isize_h,
    
    /*************************************/
    /*              Outputs              */
    /*************************************/

    /* [ DPM19 D SIZE * H ] */
    output reg [1:0]  dsize_h = 2'b00,

    /* [ DPM19 ISIZE * L ] */
    output [1:0]  isize_l,

    /* [ DPM20 PHB GD SAM * H ] */
    output [2:0]  gd_sam_h,

    /* [ DPM20 CC CTRL * H ] */
    output [3:0]  cc_ctrl_h,

    /* [ E51 pin 9 ] Good samaritan ROM output  */
    output        ird_wbus_op_h );

    wire force_dtype_l, dsize_lat_byte_l, dsize_lat_word_l;

    assign force_dtype_l = ~(istrm_h & ~lit_h[0]);

    /* [ E31 74S00 ] */
    assign dsize_lat_byte_l = ~(dsize_lat_h == 2'b00);
    /* [ E31 74S00 ] */
    assign dsize_lat_word_l = ~(dsize_lat_h == 2'b01);
    
    wire force_dsize_isize_l = ~(msrc_xb_h & force_dtype_l);
    wire [1:0] _dsz_sel_h;
    assign _dsz_sel_h[1] = (long_lit_l & (dtype_h == 2'b11));
    assign _dsz_sel_h[0] = ~long_lit_l;
    wire [1:0] dsize_sel_h = {2{~force_dsize_isize_l}} | _dsz_sel_h;
    /* 
       force      : DSIZE <- decoded ISIZE
       long_lit   : DSIZE <- DSIZE/LONGWORD
       DTYPE/IDEP : DSIZE <- ROM DSIZE
       else       : DSIZE <- DTYPE
    */
    always @ ( dtype_h or disp_isize_h or dsize_sel_h )
    case ( dsize_sel_h )
        2'h0 : dsize_h <= dtype_h;
        2'h1 : dsize_h <= 2'h2; /* LONG WORD */
        2'h2 : dsize_h <= dsize_lat_h;
        /* [ E34 74S08 ], [ E45 74S04 ] */
        2'h3 : dsize_h <= { &disp_isize_h, ~disp_isize_h[0] };
        default : dsize_h <= 2'bxx;
    endcase
    
    /* ISIZE microdecode */
    reg [1:0] isize_h;
    wire [1:0] isize_idep_h;
    assign isize_idep_h[1] = dsize_lat_byte_l;
    assign isize_idep_h[0] = dsize_lat_word_l;
    always @ ( dtype_h or disp_isize_h or isize_idep_h or force_dtype_l )
    casez ( {force_dtype_l, dtype_h} )
        3'b1zz  : isize_h <= disp_isize_h;
        3'b000  : isize_h <= 2'b01; /* BYTE  -> 1 BYTE  */
        3'b001  : isize_h <= 2'b10; /* WORD  -> 2 BYTES */
        3'b010  : isize_h <= 2'b11; /* LWORD -> 3 BYTES */
        3'b011  : isize_h <= isize_idep_h; /* IDEP */
        default : isize_h <= 2'bxx; 
    endcase
    assign isize_l = ~isize_h;

    /* Good Samaritan ROM */
    reg [3:0] gd_sam_q_h;
    always @ ( wctrl_h ) begin
        case( wctrl_h )
            `UC_CCPSL_PSL_WB_CCBR_ALUS    : gd_sam_q_h <= 4'h7; /* WRITE PSW */
            `UC_CCPSL_PSW_WB_CCBR_ALUS    : gd_sam_q_h <= 4'h4; /* WRITE PSL */
            `UC_CCPSL_WB_PSL_CCBR_SIGND   : gd_sam_q_h <= 4'h2; /* READ PSL  */
            `UC_WCTRL_STEPC_WB            : gd_sam_q_h <= 4'h6; /* STEP COUNTER <- WBUS<4:0> */
            `UC_WCTRL_CM_TP_FPD_F5_STEPC  : gd_sam_q_h <= 4'h3; /* WBUS<31:30,27,5:0> <- PSL<CM,TP,FPD>, FLAG5, STEP COUNTER */
            `UC_WCTRL_FLAGS_WB            : gd_sam_q_h <= 4'h5; /* STATUS FLAGS <- WBUS<5:0> */
            `UC_WCTRL_CM_TP_FPD_FLAGS     : gd_sam_q_h <= 4'h1; /* WBUS<31:30,27,5:0> <- PSL<CM.TP.FPD>, STATUS FLAGS */
            `UC_WCTRL_MDR_IR              : gd_sam_q_h <= 4'h8; /* MDR <- IR ZERO-EXTENDED */
            `UC_CCPSL_MDR_OSR_CCBR_BRATST : gd_sam_q_h <= 4'h8; /* MDR <- ZEXT OSR         */
            default                       : gd_sam_q_h <= 4'h0; /*  */
        endcase
    end
    assign ird_wbus_op_h = gd_sam_q_h[3];
    assign gd_sam_h = gd_sam_q_h[2:0];

    wire [8:0] cc_rom_a_h = {wctrl_h, cc_h, lit_h[0]};
    reg  [3:0] cc_rom_q_h;
    always @ ( cc_rom_a_h ) begin
        casez( cc_rom_a_h )
            9'b000000_zz_z  : cc_rom_q_h <= 4'h9; // PSL_WB      CCBR_ALUS=1
            9'b000001_zz_z  : cc_rom_q_h <= 4'hB; // PSW_WB      CCBR_ALUS=0
            9'b000100_zz_z  : cc_rom_q_h <= 4'h3; // WB_PSL      CCBR_SIGND
            9'b000101_zz_z  : cc_rom_q_h <= 4'hA; // CC_WB       CCBR_ALUS
            9'b000110_00_0  : cc_rom_q_h <= 4'h5; // ALUS__DSDC  CCBR_SIGND
            9'b000110_01_0  : cc_rom_q_h <= 4'h8; // NOP         CCBR_CSIGN
            9'b000110_10_0  : cc_rom_q_h <= 4'h7; // ALUS_UNSGN  CCBR_ALUS
            9'b000110_11_0  : cc_rom_q_h <= 4'h6; // ALUS_SIGND  CCBR_ALUS
            9'b000110_zz_1  : cc_rom_q_h <= 4'h0;
            9'b000111_00_0  : cc_rom_q_h <= 4'h2; // WB__ATRC    CCBR_SIGND
            9'b000111_01_0  : cc_rom_q_h <= 4'hF; // SETV        CCBR_SIGND
            9'b000111_10_0  : cc_rom_q_h <= 4'h0; // ?
            9'b000111_11_0  : cc_rom_q_h <= 4'h1; // NOP         CCBR_BRATST
            9'b000111_zz_1  : cc_rom_q_h <= 4'h0;
            9'bzzz01z_00_0  : cc_rom_q_h <= 4'h0;
            9'bzzz01z_01_0  : cc_rom_q_h <= 4'hC;
            9'bzzz01z_10_0  : cc_rom_q_h <= 4'hE;
            9'bzzz01z_11_0  : cc_rom_q_h <= 4'h4;
            default         : cc_rom_q_h <= 4'h0;
        endcase
    end

    assign cc_ctrl_h = cc_rom_q_h;

endmodule