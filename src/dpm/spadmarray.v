module spadmarray(
	/* M Scratchpad address */
	input      [3:0]  mspa_h,
	/* W Data bus */
	input      [31:0] wbus_h,
	/* M Data bus, active low */
	output reg [31:0] mbus_l, //actually tristate
	/* Write enables, per 8 bit byte */
	input      [3:0]  spw_l,
	/* Read enables, per register bank */
	input             mcs_tmp_l
);

genvar i;

/* MTMP Register bank, chip select: rcs_tmp_l */
generate
	for(i = 0; i < 32; i += 8) begin
		/* Temp register bank low nybble:  E101, ... */
		ram_16x4 mtmp_l_ram(
			.A  (mspa_h), 
			.D  (wbus_h[i+3:i+0]), .nQ(mbus_l[i+3:i+0]), 
			.nWE(spw_l [i/8]),
			.nCS(mcs_tmp_l));
		/* Temp register bank high nybble: E111, ... */
		ram_16x4 mtmp_h_ram(
			.A  (mspa_h), 
			.D  (wbus_h[i+7:i+4]), .nQ(mbus_l[i+7:i+4]), 
			.nWE(spw_l [i/8]),
			.nCS(mcs_tmp_l));
	end
endgenerate

endmodule