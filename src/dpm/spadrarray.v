module spadrarray(
	/* R Scratchpad address */
	input      [3:0]  rspa_h,
	/* W Data bus */
	input      [31:0] wbus_h,
	/* R Data bus, active low */
	output     [31:0] rbus_l, //actually tristate
	/* Write enables, per 8 bit byte */
	input      [3:0]  spw_l,
	/* Read enables, per register bank */
	input            rcs_tmp_l,
	input            rcs_gpr_l,
	input            rcs_ipr_l
);

/* "Virtual wires" used to simulate tri-state registers */
wire [31:0] _tmp_rbus_l;
wire [31:0] _gpr_rbus_l;
wire [31:0] _ipr_rbus_l;

/* The RAM models drive these high when highZ */
assign rbus_l = _tmp_rbus_l & _gpr_rbus_l & _ipr_rbus_l;

`define R_RAM_BYTE( name, i )  \
	ram_16x4 name``_``i``_l( \
			.A  (rspa_h), \
			.D  (wbus_h[i+3:i+0]), .nQ(_``name``_rbus_l[i+3:i+0]), \
			.nWE(spw_l [i/8]), \
			.nCS(rcs_``name``_l)); \
	ram_16x4 name``_``i``_h( \
			.A  (rspa_h), \
			.D  (wbus_h[i+7:i+4]), .nQ(_``name``_rbus_l[i+7:i+4]), \
			.nWE(spw_l [i/8]), \
			.nCS(rcs_``name``_l));
			
`define R_RAM_BANK( name ) \
	`R_RAM_BYTE( name, 0 ) \
	`R_RAM_BYTE( name, 8 ) \
	`R_RAM_BYTE( name, 16 ) \
	`R_RAM_BYTE( name, 24 )
	
/* RTMP Register bank, chip select: rcs_tmp_l */
`R_RAM_BANK( tmp )

/* GPR Register bank, chip select: rcs_gpr_l */
`R_RAM_BANK( gpr )

/* IPR Register bank, chip select: rcs_ipr_l */
`R_RAM_BANK( ipr )

endmodule