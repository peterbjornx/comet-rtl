/* 82S185 fast 1Kx4 PROM */
module rom_82S185 (
	input      [10:0] A,
	output     [3:0]  Q, //actually tristate
	input             nCE);

    parameter INIT_FILE = "romf.hex";

wire CE = ~nCE;

reg [3:0] stor [0:2047];

assign Q = CE ? (~stor[A]) : {4'b1111};

initial $readmemh( INIT_FILE, stor );

endmodule