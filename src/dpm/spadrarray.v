module spadrarray(
	/* R Scratchpad address */
	input      [3:0]  rspa_h,
	/* W Data bus */
	input      [31:0] wbus_h,
	/* R Data bus, active low */
	output reg [31:0] rbus_l, //actually tristate
	/* Write enables, per 8 bit byte */
	input      [3:0]  spw_l,
	/* Read enables, per register bank */
	input            rcs_tmp_l,
	input            rcs_gpr_l,
	input            rcs_ipr_l
);

genvar i;

/* "Virtual wires" used to simulate tri-state registers */
wire [31:0] _tmp_rbus_l;
wire [31:0] _gpr_rbus_l;
wire [31:0] _ipr_rbus_l;

/* The RAM models drive these high when highZ */
assign rbus_l = _tmp_rbus_l & _gpr_rbus_l & _ipr_rbus_l;

/* RTMP Register bank, chip select: rcs_tmp_l */
generate
	for(i = 0; i < 32; i += 8) begin
		/* Temp register bank low nybble:  E99, ... */
		ram_16x4 rtmp_l_ram(
			.A  (rspa_h), 
			.D  (wbus_h[i+3:i+0]), .nQ(_tmp_rbus_l[i+3:i+0]), 
			.nWE(spw_l [i/8]),
			.nCS(rcs_tmp_l));
		/* Temp register bank high nybble: E109, ... */
		ram_16x4 rtmp_h_ram(
			.A  (rspa_h), 
			.D  (wbus_h[i+7:i+4]), .nQ(_tmp_rbus_l[i+7:i+4]), 
			.nWE(spw_l [i/8]),
			.nCS(rcs_tmp_l));
	end
endgenerate

/* GPR Register bank, chip select: rcs_gpr_l */
generate
	for(i = 0; i < 32; i += 8) begin
		/* General register bank low nybble:  E102, ... */
		ram_16x4 gpr_l_ram(
			.A  (rspa_h), 
			.D  (wbus_h[i+3:i+0]), .nQ(_gpr_rbus_l[i+3:i+0]), 
			.nWE(spw_l [i/8]),
			.nCS(rcs_gpr_l));
		/* General register bank high nybble: E112, ... */
		ram_16x4 gpr_h_ram(
			.A  (rspa_h), 
			.D  (wbus_h[i+7:i+4]), .nQ(_gpr_rbus_l[i+7:i+4]), 
			.nWE(spw_l [i/8]),
			.nCS(rcs_gpr_l));
	end
endgenerate

/* IPR Register bank, chip select: rcs_ipr_l */
generate
	for(i = 0; i < 32; i += 8) begin
		/* IPR bank low nybble:  E100, ... */
		ram_16x4 ipr_l_ram(
			.A  (rspa_h), 
			.D  (wbus_h[i+3:i+0]), .nQ(_ipr_rbus_l[i+3:i+0]), 
			.nWE(spw_l [i/8]),
			.nCS(rcs_ipr_l));
		/* IPR bank high nybble: E110, ... */
		ram_16x4 ipr_h_ram(
			.A  (rspa_h), 
			.D  (wbus_h[i+7:i+4]), .nQ(_ipr_rbus_l[i+7:i+4]), 
			.nWE(spw_l [i/8]),
			.nCS(rcs_ipr_l));
	end
endgenerate

endmodule