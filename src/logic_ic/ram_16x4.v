/* 16 x 4 bit asynchronous RAM
 * Chip equivalent: 74S189
 */
module ram_16x4 (
	input      [3:0] A,
	input      [3:0] D,
	output reg [3:0] nQ, //actually tristate
	input            nWE,
	input            nCS);

reg [3:0] stor [0:15];

assign nQ = (!nCS) ? (~stor[A]) : {4'b1111};

always @(nCS or nWE)
  if (!nCS && !nWE)
    stor[A] = D;

endmodule