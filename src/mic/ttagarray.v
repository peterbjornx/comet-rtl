module ttagarray( 
    input  [7:0]  A,
    input  [15:0] D,
    input         Dp,
    output [15:0] Q,
    output        nQp,
    input         nWE );


    `define RAM_NYB( i ) ram_93422 TTAG``i ( .A(A), .Q(Q[3+i*4:i*4]), .D(D[3+i*4:i*4]), \
        .nOE(1'b0), .nCS(1'b0), .CS(1'b1), .nWE(nWE) )

    `RAM_NYB( 3 );
    `RAM_NYB( 2 );
    `RAM_NYB( 1 );
    `RAM_NYB( 0 );

    ram_93421 TPAR (
         .A(A), .nQ(nQp), .D(Dp),
         .nCS(3'b000), .nWE(nWE) );

endmodule
