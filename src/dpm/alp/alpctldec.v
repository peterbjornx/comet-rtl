module alpctldec(
	input [9:0] opc_h,
	output      dmove_h,
	output      wmux_oe_h,
	output      pass_a_h,
	output      dreg_inh_l );

// General predicates

	// Match xxx1 0x01 11 ( ? {4,5,C,D} 7 ALPCTL
	assign dmove_h = 
		&( {opc_h[6:5],opc_h[3:0]} ^~ 6'b___10_0111 );
	// Was: ~&{ opcode_h[6], opcode_l[5], opcode_dl[3], opcode_dh[2], opcode_h[1:0] };

	//D register inhibit
	// Disable D register when data move ALPCTL and xxxx x0xx 11 ( 3,7,B,F )`
	assign dreg_inh_l =
		~(dmove_h & &({opc_h[4], opc_h[1:0]} ^~ 3'b_____0__11));

	//ALU bypass signal
	// Matches ALPCTL_WX_*
	// Matches 2{5,6,7}{A,B,E,F}
	assign pass_a_h = 
		&( {opc_h[9:6], opc_h[3], opc_h[1]} ^~ 6'b1001__1_1_ );
	
	//WMUX drive control
	// Matches 1x01 1xxx xx (MUX=9/D and 1xxx ALU code)
	// 1x 011x xxxx {2,3}{6,7}*
	//
	assign wmux_oe_h =
		~&({opc_h[9], opc_h[7:5]} ^~ 4'b1_011_____);
endmodule