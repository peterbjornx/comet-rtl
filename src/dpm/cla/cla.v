/* 
 * This module is re-implemented based on the documentation. All non-obvious features are for now unimplemented
 */
module dc612_cla(
    /* Control signals for CLA */
    input       bcd_l,

    /* Input P/G subcarrys */
    input       ci_l,
    input [7:0] p_l,
    input [7:0] g_a_l,
    input [7:0] g_b_l,

    /* Output carries */
    output [7:0] co_l,
    output       bin8_l,
    output       bcd8_l,

    output       c_h,

    /* Floating point inputs */
    input        sb_h,

    /* Floating point outputs */
    output       fs_h,
    output       fov_h,

    /* MUX auxiliary function */
    input       muxa_h,
    input       muxb_h,
    input       muxs_h,

    output      muxo_l );
    
    wire [7:0] pin_h = ~p_l;
    wire [7:0] gin_h = ~g_a_l & ~g_b_l; //TODO: G_A/G_B? assuming wire-AND of inverting io pads

    wire [8:0] cbus_h;

    /* Carry lookahead circuit */
    wire [8:0] ort0_h = {9{~ci_l    }} & {&pin_h[7:0],&pin_h[6:0],&pin_h[5:0],&pin_h[4:0],&pin_h[3:0],&pin_h[2:0],&pin_h[1:0], pin_h[0], 1'b1 };
    wire [8:0] ort1_h = {9{gin_h [0]}} & {&pin_h[7:1],&pin_h[6:1],&pin_h[5:1],&pin_h[4:1],&pin_h[3:1],&pin_h[2:1], pin_h[1]  , 1'b1    , 1'b0 };
    wire [8:0] ort2_h = {9{gin_h [1]}} & {&pin_h[7:2],&pin_h[6:2],&pin_h[5:2],&pin_h[4:2],&pin_h[3:2], pin_h[2]  , 1'b1      , 2'b00};
    wire [8:0] ort3_h = {9{gin_h [2]}} & {&pin_h[7:3],&pin_h[6:3],&pin_h[5:3],&pin_h[4:3], pin_h[3]  , 1'b1      , 3'b000};
    wire [8:0] ort4_h = {9{gin_h [3]}} & {&pin_h[7:4],&pin_h[6:4],&pin_h[5:4], pin_h[4]  , 1'b1      , 4'b0000};
    wire [8:0] ort5_h = {9{gin_h [4]}} & {&pin_h[7:5],&pin_h[6:5], pin_h[5]  , 1'b1      , 5'b00000};
    wire [8:0] ort6_h = {9{gin_h [5]}} & {&pin_h[7:6], pin_h[5]  , 1'b1      , 6'b000000};
    wire [8:0] ort7_h = {9{gin_h [6]}} & { pin_h[7]  , 1'b1      , 7'b0000000};
    wire [8:0] ort8_h =   {gin_h [7],8'b00000000} ;
    assign     cbus_h = ort0_h | ort1_h | ort2_h | ort3_h | ort4_h | ort5_h | ort6_h | ort7_h | ort8_h;

    assign co_l   = ~cbus_h[7:0];
    assign bin8_l = ~(cbus_h[8] &  bcd_l );
    assign bcd8_l = ~( 1'b0     & ~bcd_l ); // TODO: Implement BCD carry

    //TODO-FPA: Implement floating point CLA logic
    assign fs_h = 1'b0;
    assign fov_h = 1'b0;
 
    /* MUX functionality */
    assign muxo_l = ~( muxs_h == 1'b0 ? muxb_h : muxa_h );

endmodule