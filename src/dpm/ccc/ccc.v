
`include "chipmacros.vh"

module dc610_ccc(
        input b_clk_l,
        input d_clk_en_h,

        input [3:0]  cc_ctrl_h,

        input [1:0]  d_size_h,

        input [3:0]  wmuxz_h,

        input [7:0]  ir_h,

        input        fpa_z_l,
        input        fpa_v_l,
        input        fpa_present_l,

        input        wbus_31_h,
        input        wbus_15_h,
        input [7:0]  wbus_h,

        input        aluv_31_h,
        input        aluv_15_h,
        input        aluv_7_h,

        input        aluc_31_l,
        input        aluc_15_l,
        input        aluc_7_l,
        
        output       wbus_out_31_h,
        output       wbus_out_15_h,
        output [7:0] wbus_out_h,
        output       pslc_h,

        output reg [1:0] ccbr_h,
        output       arith_trap_l
    );

    reg         comp_h = 1'b0;
    reg   [2:0] psl_fid_h = 2'b00;
    reg   [3:0] atcr_h = 4'b0000;
    reg   [3:0] dz_psw_h;
    reg   [3:0] cc_h = 4'b0000;
    reg   [3:0] cc_d_h;
    reg   [3:0] cc_op1_h;
    reg   [3:0] cc_op2_h;
    wire  [3:0] atcr_d_h;
    wire        atcr_e_h;
    reg   [1:0] alu_state_h;
    reg  [3:0] wmux_h;

    assign wbus_out_15_h = 1'b1;
    assign wbus_out_31_h = 1'b1;
    assign arith_trap_l  = 1'b1;
    assign pslc_h = cc_h[0];

    wire iv_op_h =
        &( {ir_h[7:6],ir_h[4:2]}         ^~ 5'b01_010__) | 
        &( {ir_h[7]  ,ir_h[4]  }         ^~ 2'b1__0____) | 
        &( {ir_h[4:3],ir_h[1:0]}         ^~ 4'b___10_00) | 
        &( {ir_h[6:5],ir_h[3:0]}         ^~ 6'b_10_1000) | 
        &( {ir_h[7]  ,ir_h[5]  }         ^~ 2'b1_0_____) | 
        &( {ir_h[6]  ,ir_h[4:3]}         ^~ 3'b_0_10___) | 
        &( {ir_h[7:5],ir_h[3]}           ^~ 4'b111_0___) | 
        &( {ir_h[7]  ,ir_h[5:2]}         ^~ 5'b0_1111__) |
        &(  ir_h[7:3]                    ^~ 5'b01111___);

    wire dv_op_h =
        &( {ir_h[7:6],ir_h[3:2]}         ^~ 4'b00__10__) | 
        &( {ir_h[7:5],ir_h[3:2]}         ^~ 5'b111_10__) |
        &(  ir_h[7:3]                    ^~ 5'b00100___);

    wire fpa_op_h =
        &( {ir_h[7:6],ir_h[4]}           ^~ 3'b01_0____) | 
        &( {ir_h[7:6],ir_h[3],ir_h[1:0]} ^~ 5'b01__0_01) |
        &( {ir_h[7:6],ir_h[3:1]}         ^~ 5'b01__010_);

    wire        ccm_atcr_rd_h   = cc_ctrl_h == 4'h2;
    wire        ccm_psl_rd_h    = cc_ctrl_h == 4'h3;
    wire        ccm_psl_wr_h    = cc_ctrl_h == 4'h9;
    wire        ccm_cc_wr_h     = cc_ctrl_h == 4'hA;
    wire        ccm_psw_wr_h    = cc_ctrl_h == 4'hB | ccm_psl_wr_h;
    wire        ccm_cc_op1_h    = cc_ctrl_h == 4'hC;
    wire        ccm_cc_op2_h    = cc_ctrl_h == 4'hE;
    wire        ccm_setv_h      = cc_ctrl_h == 4'hF;

    wire        cc_op_h         = ccm_cc_op1_h | ccm_cc_op2_h;
    wire        cc_wr_h         = ccm_cc_wr_h | ccm_psw_wr_h;
    wire        cc_en_h         = cc_wr_h | ccm_setv_h | cc_op_h;

    wire trap_cc_ctrl_h = (cc_ctrl_h == 4'hA) | (cc_ctrl_h == 4'hC ) |
                          (cc_ctrl_h == 4'hE) | (cc_ctrl_h == 4'hF);
    assign atcr_e_h = trap_cc_ctrl_h & ( iv_op_h | dv_op_h ) & ~comp_h;
    assign atcr_d_h = dv_op_h ? 4'h6 : 4'h1;

    wire d_clk_l = b_clk_l | ~d_clk_en_h;
    wire psw_clk_l = d_clk_l | ~ccm_psw_wr_h;
    wire psl_clk_l = d_clk_l | ~ccm_psl_wr_h;

    `LATCH_N( psw_clk_l, wbus_h[7:5], psl_fid_h )
    `FF_EN_N( d_clk_l  , atcr_e_h   , atcr_d_h, atcr_h )
    `LATCH_N( psl_clk_l, wbus_31_h  , comp_h )
    `FF_EN_P( d_clk_l  , cc_en_h    , cc_d_h, cc_h )

    wire [3:0] cmux_sel_h = { cc_wr_h, ccm_setv_h, ccm_cc_op1_h, ccm_cc_op2_h };

    always @ ( cmux_sel_h ) begin
        casez( cmux_sel_h )
            4'b1000: cc_d_h <= wbus_h[3:0];
            4'b0100: cc_d_h <= {cc_h[3:2], 1'b1, cc_h[0]};
            4'b0010: cc_d_h <= cc_op1_h;
            4'b0001: cc_d_h <= cc_op2_h;
            default: cc_d_h <= 4'bxxxx;
        endcase
    end

    wire [1:0] wmux_sel_h = { ccm_atcr_rd_h, ccm_psl_rd_h };

    always @ ( wmux_sel_h ) begin
        casez( wmux_sel_h )
            2'b01:   wmux_h <= cc_h;
            2'b10:   wmux_h <= atcr_h;
            default: wmux_h <= 4'b1111;
        endcase
    end

    assign wbus_out_h[3:0] = wmux_h;
    assign wbus_out_h[7:5] = ccm_psl_rd_h  ? psl_fid_h : 3'b111;

    always @ (  d_size_h or
                aluc_31_l or aluc_15_l or aluc_7_l or
                aluv_31_h or aluv_15_h or aluv_7_h or
                wbus_31_h or wbus_15_h or wbus_h[7] or
                wmuxz_h ) begin
        
        casez ( d_size_h )
            2'b00: dz_psw_h <= { wbus_h[7],  wmuxz_h[  0], aluv_7_h, aluc_7_l };
            2'b01: dz_psw_h <= { wbus_15_h, &wmuxz_h[1:0], aluv_15_h, aluc_15_l };
            2'b1z: dz_psw_h <= { wbus_31_h, &wmuxz_h[3:0], aluv_31_h, aluc_31_l };
            default: dz_psw_h <= 4'bxxxx;
        endcase
                    
    end
    wire alus_5_1_h = wbus_h[3:0] == 4'h1 | wbus_h[3:0] == 4'h3 | wbus_h[3:0] == 4'h9 |
                      wbus_h[3:0] == 4'hB | wbus_h[3:0] == 4'hD;
    always @ ( posedge d_clk_l ) begin
        casez( cc_ctrl_h )
            4'h5: alu_state_h <= { alus_5_1_h, 1'bx };
            4'h6: alu_state_h <= { 2'bxx };
            4'h7: alu_state_h <= { dz_psw_h[0], dz_psw_h[2]};
            default: alu_state_h <= 2'bxx;
        endcase
    end

    always @ ( cc_ctrl_h or dz_psw_h or alu_state_h ) begin
        casez( cc_ctrl_h )
            4'b0000: ccbr_h <= {dz_psw_h[3] ^ dz_psw_h[1], dz_psw_h[2]};
            4'b0001: ccbr_h <= 2'bxx; // 
            4'b001z: ccbr_h <= {dz_psw_h[3] ^ dz_psw_h[1], dz_psw_h[2]};
            4'b01zz: ccbr_h <= alu_state_h;

            4'b1000: ccbr_h <= {alu_state_h[1], dz_psw_h[3] & dz_psw_h[1]};
            4'b1001: ccbr_h <= alu_state_h;
            4'b101z: ccbr_h <= alu_state_h;
            4'b1100: ccbr_h <= {dz_psw_h[3] ^ dz_psw_h[1], dz_psw_h[2]};
            4'b1101: ccbr_h <= 2'bxx;
            4'b111z: ccbr_h <= {dz_psw_h[3] ^ dz_psw_h[1], dz_psw_h[2]};
            default: ccbr_h <= 2'bxx;
        endcase
    end

    wire set_arith_trap = ( trap_cc_ctrl_h & atcr_h[1] & ~(fpa_op_h & ~fpa_present_l) & 
                            ~comp_h & ( (psl_fid_h[0] & dv_op_h) | ( psl_fid_h[1] & iv_op_h ) ) );

endmodule