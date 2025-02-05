module tlbarray( 
    input  [7:0]  A,
    input  [23:4] D,
    input   [2:0] Dp,
    output [23:4] Q,
    output  [2:0] Qp,
    input         nWE );


    `define RAM_NYB( i ) ram_93422 TLB``i ( .A(A), .Q(Q[3+i*4:i*4]), .D(D[3+i*4:i*4]), \
        .nOE(1'b0), .nCS(1'b0), .CS(1'b1), .nWE(nWE) )

    `RAM_NYB( 5 );
    `RAM_NYB( 4 );
    `RAM_NYB( 3 );
    `RAM_NYB( 2 );
    `RAM_NYB( 1 );

    wire _nc;
    ram_93422 TPAR (
         .A(A), .Q({_nc,Qp}), .D({1'b0, Dp}),
         .nOE(1'b0), .nCS(1'b0), .CS(1'b1), .nWE(nWE) );

endmodule
