module spadmarray(
	/* M Scratchpad address */
	input      [3:0]  mspa_h,
	/* W Data bus */
	input      [31:0] wbus_h,
	/* M Data bus, active low */
	output     [31:0] mbus_l, //actually tristate
	/* Write enables, per 8 bit byte */
	input      [3:0]  spw_l,
	/* Read enables, per register bank */
	input             mcs_tmp_l
);

`define M_RAM_BANK( name, i, cs )  \
	ram_16x4 name``_``i``_l( \
			.A  (mspa_h), \
			.D  (wbus_h[i+3:i+0]), .nQ(mbus_l[i+3:i+0]), \
			.nWE(spw_l [i/8]), \
			.nCS(cs)); \
	ram_16x4 name``_``i``_h( \
			.A  (mspa_h), \
			.D  (wbus_h[i+7:i+4]), .nQ(mbus_l[i+7:i+4]), \
			.nWE(spw_l [i/8]), \
			.nCS(cs)); 
/* MTMP Register bank, chip select: rcs_tmp_l */
`M_RAM_BANK( mtmp_ram, 0, mcs_tmp_l )
`M_RAM_BANK( mtmp_ram, 8, mcs_tmp_l )
`M_RAM_BANK( mtmp_ram, 16, mcs_tmp_l )
`M_RAM_BANK( mtmp_ram, 24, mcs_tmp_l )

endmodule