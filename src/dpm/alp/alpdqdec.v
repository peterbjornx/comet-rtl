module alpdqdec(
	input             dmove_h,
	input             dreg_inh_l,
	input       [1:0] dq_h,
	input       [3:0] mux_h,

	output wire [3:0] qmux_onehot_h,
	output wire       qreg_en_h,
	output wire       dreg_en_h,
	output wire       qshl_en_h,
	output wire       qshr_en_h);

// Derived inputs
	wire dmove_l = ~dmove_h;

// Q Mux decode
	wire qmux_amux_en_h, qmux_wmux_en_h;
	
	// Q Register write enable
	assign qreg_en_h = 
		(~&( {mux_h[2], dq_h[0]} ^~ 2'b_1_______0 )) &
		(~&( {mux_h[0], dq_h[0]} ^~ 2'b___0_____0 ));
	
	// Q Shift Left
	// Matches DQ=x0
	assign qshl_en_h  = ~dq_h[0];

	// Q Shift Right
	// Matches MUX=xxx0 DQ=x0 always (but Q write is disabled, why?)
	// Matches MUX=xxx1 DQ=x1 if not DMOVE
	assign qshr_en_h  =
		(&({                    mux_h[0], dq_h[0]} ^~ 2'b____0_____0)) |
		(&({ dmove_l, mux_h[2], mux_h[0], dq_h[0]} ^~ 4'b1_0_1_____1));

	// Q Load from A mux if DMOVE ALPCTL
	assign qmux_amux_en_h = ~dmove_l;
	
	// Q Load from W mux
	// Matches MUX=x1xx if not DMOVE
	// Matches MUX=x0x0
	assign qmux_wmux_en_h =
		( ( dmove_l & mux_h[2]                       )) |            
		 &(          {mux_h[2], mux_h[0]} ^~ 2'b_0_0 ); 
		 
	assign qmux_onehot_h = 
		{ qmux_wmux_en_h, qshl_en_h, 
	      qshr_en_h     , qmux_amux_en_h};
	 
// D Mux decode
	wire dreg_dq3_l = ~&(mux_h ^~ 4'b1001);    // Matches MUX=1001
	
	// Disable D register when DQ=0x in DQ1 and DQ2
	// Disable D register when ALPCTL inhibits it
	assign dreg_en_h = 
		(~&{ ~dq_h[1], dreg_dq3_l }) & 
		dreg_inh_l;

endmodule