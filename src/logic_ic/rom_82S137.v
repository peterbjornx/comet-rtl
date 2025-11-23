/* 82S127 fast 1Kx4 PROM */
 module rom_82S137 (
	input      [9:0] A,
	output     [3:0] Q, //actually tristate
	input            nCE1,
	input            nCE2);

    parameter INIT_FILE = "romf.hex";

wire CE = ~nCE1 & ~nCE2;

reg [3:0] stor [0:1023];

assign Q = CE ? (~stor[A]) : {4'b1111};

initial $readmemh( INIT_FILE, stor );

endmodule