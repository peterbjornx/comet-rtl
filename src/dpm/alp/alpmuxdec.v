module alpmuxdec(
	/* Controls */
	input             ext_ena_h,
	
	/* Opcode */
	input       [3:0] mux_h,

	/* Decoded signals */
	output wire [3:0] amux_onehot_h,
	output wire [2:0] bmux_onehot_h );

// A Mux decode
	wire amux_mbus_en_h, amux_rbus_en_h;
	wire amux_dreg_en_h, amux_pad_en_h;

	// A Mux decode - M->A
	// Match 00xx, 0100                       : MBUS
	// Match if ext_ena low: 0110, 0111, 0101 : Ext MBUS
	assign amux_mbus_en_h = 
		(~&{ ext_ena_h, mux_h[2:1]         } ) & // Inhibit if x11x and ext_ena
		(~&{ ext_ena_h, mux_h[2], mux_h[0] } ) & // Inhibit if x1x1 and ext_ena
		(~              mux_h[3]             );  // Match      0xxx

	// A Mux decode - R->A
	assign amux_rbus_en_h =
		&mux_h[3:1]; // Matches 111x MUX codes ( R->A, {Q,S} -> B )
	
	// A Mux decode - D->A
	// These were NANDs feeding into a wire AND net followed by an inverter
	assign amux_dreg_en_h = 
		(&( mux_h[3:2]            ^~ 2'b10__ )) | // Match 10xx
		(&({mux_h[3], mux_h[1:0]} ^~ 3'b1_00 ));  // Match 1x00
		

	// A Mux decode - P->A , 
	//Matches 0101 0111 0110 (Ext MBus) if EXT ENA
	assign amux_pad_en_h = 
		(  &{ mux_h[3:2] ^~ 2'b01__, ext_ena_h }) & // Match 01xx
	    ( ~&( mux_h[1:0] ^~ 2'b__00 ));             // Inhibit if xx00;  
	
	assign amux_onehot_h = { 
		amux_rbus_en_h, amux_mbus_en_h, 
		amux_dreg_en_h, amux_pad_en_h };

// B Mux decode
	wire bmux_rbus_en_h, bmux_smux_en_h;
	wire bmux_qreg_en_h;
	
	// B Mux decode: R->B 
	// Matches 0000 0001 0101 1000 1001 ( RBUS )
	assign bmux_rbus_en_h = 
		(~&( mux_h[3:2]         ^~ 2'b11__ )) & // Inhibit if 11xx
		(~&({mux_h[3],mux_h[0]} ^~ 2'b_1_0 )) & // Inhibit if x1x0
		~mux_h[1];                              // Match xx0x
		
	// B Mux decode: S->B
	// Matches 0100 0111 1100 1101 1111 ( Shifter )
	assign bmux_smux_en_h = 
		(~&(           mux_h[1:0]  ^~ 2'b__10)) & // Inhibit if xx10
		(~&({mux_h[3], mux_h[1:0]} ^~ 3'b0_01)) & // Inhibit if 0x01
		 mux_h[2];                                // Match x1xx

	// B Mux decode Q->B
	// Matches 0010 0011 0110 1010 1011 1110 ( Q Register )
 	assign bmux_qreg_en_h =
		(~&({mux_h[2], mux_h[0]}   ^~ 2'b_1_1)) & // Inhibit if x1x1
		mux_h[1];                                 // Match xx1x
	
	assign bmux_onehot_h = 
		{ bmux_rbus_en_h, bmux_qreg_en_h, bmux_smux_en_h };
	
endmodule