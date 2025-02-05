module cachearray(
    input  [ 9:0] A,
    input  [31:0] D,
    input   [3:0] Dp,
    output [31:0] Q,
    output  [3:0] Qp,
    input   [3:0] ena_byte_l,
    input         nWE );

`define RAM_BIT( i ) ram_93425 CAD``i ( .A(A), .Q(Q [i]), .D(D[ i]), .nCS( ena_byte_l[i/8]), .nWE(nWE) )
`define PAR_BIT( i ) ram_93425 CAP``i ( .A(A), .Q(Qp[i]), .D(Dp[i]), .nCS( ena_byte_l[i  ]), .nWE(nWE) )

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
    `RAM_BIT(14);
    `RAM_BIT(15);
    `RAM_BIT(16);
    `RAM_BIT(17);
    `RAM_BIT(18);
    `RAM_BIT(19);
    `RAM_BIT(20);
    `RAM_BIT(21);
    `RAM_BIT(22);
    `RAM_BIT(23);
    `RAM_BIT(24);
    `RAM_BIT(25);
    `RAM_BIT(26);
    `RAM_BIT(27);
    `RAM_BIT(28);
    `RAM_BIT(29);
    `RAM_BIT(30);
    `RAM_BIT(31);
    `PAR_BIT(0);
    `PAR_BIT(1);
    `PAR_BIT(2);
    `PAR_BIT(3);

endmodule