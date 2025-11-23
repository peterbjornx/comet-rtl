module sn74s112 (
    input  j_h,
    input  k_h,
    input  clk_l,
    output q_h,
    output q_l );

    reg q = 1'b0;

    always @ ( negedge clk_l )
        case ( { j_h, k_h } )
            2'b00 :  q <= q;
            2'b01 :  q <= 0;
            2'b10 :  q <= 1;
            2'b11 :  q <= ~q;
        endcase
    
    assign q_h = q;
    assign q_l = ~q;
endmodule