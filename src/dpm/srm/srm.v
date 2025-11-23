`include "srkmacros.vh"
`include "chipmacros.vh"

module dc613_srm(
    input       phase_h,

    input [7:0] rbus_l,
    input [7:0] mbus_l,
    input       mbxx_l,
    input [2:0] litrl_h,
    input [1:0] cid_l,
    input       mb31_l,

    input [4:2] shf_l,

    input [1:0] pri_l,
    input [5:0] sec_l,
    
    input [8:0] sbus_h,
    output [8:0] sbus_out_h
);
    reg  [ 7:0] _rbus_l = 8'h00;
    reg  [ 7:0] _mbus_l = 8'h00;
    reg         _mb31_l = 1'b0;
    reg         _mbxx_l = 1'b0;
    wire [ 2:0] start_nyb_h = ~shf_l;
    wire [15:0]  extz_shf_h;
    wire [17:0]  extz_mask_h;
    reg  [15:0] extz_bus_h;
    wire [8:0]  extz_result_h;
    reg  [15:0]  sec_bus_h;
    wire        dis_lo_byte_h;
    wire        sec_valid_h;
    reg [8:0] sbus_sec_h;

    `LATCH_N( phase_h, rbus_l, _rbus_l )
    `LATCH_N( phase_h, mbus_l, _mbus_l )
    `LATCH_N( phase_h, mb31_l, _mb31_l )
    `LATCH_N( phase_h, mbxx_l, _mbxx_l )

    wire [2:0] litrl1_h = ~sec_l[4] ? 3'b111 : litrl_h;
    assign sec_valid_h = (~pri_l) == `PRI_SECOND;
    assign dis_lo_byte_h = sec_valid_h & ((~sec_l[3:0]) == `SEC_LOB_OFF);

    always @ ( sec_l[3:0] or litrl_h or litrl1_h or _rbus_l or _mbus_l or _mb31_l ) begin
        case ( ~sec_l[3:0] )
            `SEC_LITZERO: sec_bus_h   <= { 5'b00000, litrl_h  , 5'b00000, litrl_h  }; /* Correct per GA RM SRM Table 3 */
            `SEC_LITONE : sec_bus_h   <= { 5'b11111, litrl1_h , 5'b11111, litrl1_h }; /* Correct per GA RM SRM Table 3 */
            `SEC_ASL_R  : sec_bus_h   <= { ~_rbus_l           , {8{1'b0}}          }; /* Correct per GA RM SRM Table 3 */
            `SEC_ASL_M  : sec_bus_h   <= { ~_mbus_l           , {8{1'b0}}          }; /* Correct per GA RM SRM Table 3 */
            `SEC_ASR_M  : sec_bus_h   <= { {8{~_mb31_l}}      , ~_mbus_l           }; /* Correct per GA RM SRM Table 3 */
            //TODO: FPLIT
            //TODO: FPPACK
            //TODO: CVTPN
            //TODO: CVTNP
            default     : sec_bus_h   <= {16{1'bx}};
        endcase
    end

    always @ ( pri_l or sec_bus_h or _mbus_l or _rbus_l ) begin
        case ( pri_l )
            ~`PRI_EXTZ_MM: extz_bus_h <= { ~_mbus_l  , ~_mbus_l }; /* Correct per GA RM SRM Table 3 */
            ~`PRI_EXTZ_RR: extz_bus_h <= { ~_mbus_l  , ~_mbus_l }; /* Correct per GA RM SRM Table 3 */
            ~`PRI_EXTZ_MR: extz_bus_h <= { ~_mbus_l  , ~_rbus_l }; /* Correct per GA RM SRM Table 3 */
            default      : extz_bus_h <= sec_bus_h;
        endcase
    end

    /* shf indicates start bit (thus, shf[4:2] indicates start nybble) */
    assign extz_shf_h  = extz_bus_h >> start_nyb_h;
    wire [5:0] sec_cnt_h = { ~sec_l[5], sec_l[5] & ~sec_l[4], ~sec_l[3:0] };

    wire [5:0] mask_shf_h = sec_cnt_h - {4'b0, ~cid_l} + 6'h04;

    assign extz_mask_h = 18'b1111_1111_1_0000_0000_0 << mask_shf_h[5:2];

    reg [8:0] mask_h  ;

    /* SRK TABLE 4 CONT */
    always @ ( sec_l or extz_mask_h ) begin
        casez( sec_l )
            6'b000110: mask_h <= 9'h000;
            6'b000101: mask_h <= 9'h000;
            6'b000011: mask_h <= 9'h000;
            6'b000001: mask_h <= 9'h000;
            6'b000000: mask_h <= 9'h000;
            default  : mask_h <= extz_mask_h[17:9];
        endcase
    end

    assign extz_result_h = extz_shf_h[8:0] &  ~mask_h;
    wire c8f_h = cid_l == 2'b00;
    wire id2_h = cid_l == 2'b01;
    always @ ( extz_shf_h or sec_l or c8f_h or mbus_l) begin
        case( ~sec_l[3:0] )
            `SEC_LOB_OFF: sbus_sec_h <= 9'b0_00_00_00_11;
            `SEC_CONST8 : sbus_sec_h <= {8'b0, c8f_h};
            `SEC_CLR1BM : sbus_sec_h <= {1'b0, ~_mbus_l[7:2], 2'b00};
            `SEC_CLR2BM : sbus_sec_h <= {1'b0, ~_mbus_l[7:4], 4'b00_00};
            `SEC_CLR3BM : sbus_sec_h <= {1'b0, ~_mbus_l[7:6], 6'b00_00_00};
            `SEC_LITZERO: sbus_sec_h <= extz_shf_h[8:0];
            `SEC_LITONE : sbus_sec_h <= extz_shf_h[8:0];
            `SEC_ASL_M  : sbus_sec_h <= extz_shf_h[8:0];
            `SEC_ASL_R  : sbus_sec_h <= extz_shf_h[8:0];
            `SEC_ASR_M  : sbus_sec_h <= extz_shf_h[8:0];
            `SEC_BCDSWAP: sbus_sec_h <= {1'b0, ~_mbus_l[1] & c8f_h, ~mbus_l[0], ~_mbus_l[3:2], ~_mbus_l[5:4], ~_mbus_l[7:6]}; /* Correct per GA RM SRM Table 3 */
            `SEC_FPFRACT: sbus_sec_h <= {1'b0, ~_mbus_l[1:0], ~_mbus_l[7:6], ~_mbus_l[5:4], ~_rbus_l[7:6]}; /* Correct per GA RM SRM Table 3 */ //TODO ID=3 should force sbus[7] = 1
            `SEC_FPPACK : sbus_sec_h <= {      ~_mbus_l[6:3], ~_mbxx_l     , ~_rbus_l[1:0], ~_mbus_l[7:6]}; /* Correct per GA RM SRM Table 3 */
            //`SEC_FPLIT  : sbus_sec_h <= {6'b0, ~_mbus_l[1:0], 1'b0}; /* Correct per GA RM SRM Table 3 */
            `SEC_FPLIT  : sbus_sec_h <= {5'b0, id2_h, ~_mbus_l[1:0], 1'b0}; /* Correct per GA RM SRM Table 3 */

            //TODO: FPLIT
            //TODO: CVTPN
            //TODO: CVTNP
            default     : sbus_sec_h <= {9{1'bx}};
        endcase
    end

    assign sbus_out_h = sec_valid_h ? sbus_sec_h : extz_result_h;
  

endmodule 