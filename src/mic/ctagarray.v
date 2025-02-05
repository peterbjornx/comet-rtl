module ctagarray(
    input  [ 9:0] A, 
    input  [13:0] D,
    output [13:0] Q,
    input         nWE );

`define RAM_BIT( i ) ram_93425 CTAG``i ( .A(A), .Q(Q[i]), .D(D[i]), .nCS(1'b0), .nWE(nWE) )

    `RAM_BIT(0);
    `RAM_BIT(1);
    `RAM_BIT(2);
    `RAM_BIT(3);
    `RAM_BIT(4);
    `RAM_BIT(5);
    `RAM_BIT(6);
    `RAM_BIT(7);
    `RAM_BIT(8);
    `RAM_BIT(9);
    `RAM_BIT(10);
    `RAM_BIT(11);
    `RAM_BIT(12);
    `RAM_BIT(13);

endmodule