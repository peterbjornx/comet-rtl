module alpaludp(
	input  [3:0] amux_h,
	input  [3:0] bmux_h,
	output [3:0] aluq_h,
	
	/* Flag signals */
	input        carry_in_h,
	input        pg_in_h,
	output       g_out_ctl,
	output       g_out_in1,
	output       g_out_in2,
	output       p_out_ctl,
	output       p_out_in1,
	output       p_out_in2,
	output       v_out,
	
	/* Global controls */
	input        carry_dis_h,
	input        bcd_add_h,
	input        bcd_op_l,
	
	/* X stage controls */
	input        xctl_nA_nB,
	input        xctl_nA_pB,
	input        xctl_pA_nB,
	input        xctl_pA_pB,
	
	/* Z stage controls */
	input        zctl_nA_pB,
	input        zctl_pA_nB,
	input        zctl_pA_pB,

	/* Mux controls */
	input        pass_a_h );

wire carry_en_h = ~carry_dis_h;

//CELL_06_15_OUT = g_in_l;
//PAD_G_L_OUT    = g_in_h;
//decoder_unk0   = bcd_add_h;
wire pg_in_l = ~pg_in_h;

wire [3:0] aluX_h;
wire [3:0] aluX_l;
wire [3:0] aluZ_h;
wire [3:0] aluZ_l;
wire       cin0_h;
wire       cin1_l;
wire       cin2_l;
wire       cin3_l;
wire [3:0] cin_l;
wire [3:0] cin_h;
wire [3:0] amux_l = ~amux_h;
wire [3:0] bmux_l = ~bmux_h;
/* Drive X bus */
// This construct selectively combines NANDs of the input buses with
// varying inversion. 
	assign aluX_h = 
		(~( amux_l & bmux_l & {4{xctl_nA_nB}} )) &
		(~( amux_l & bmux_h & {4{xctl_nA_pB}} )) &
		(~( amux_h & bmux_l & {4{xctl_pA_nB}} )) &
		(~( amux_h & bmux_h & {4{xctl_pA_pB}} ));

	assign aluX_l = ~aluX_h;

/* Drive Z bus */
	assign aluZ_l = 
		(~( amux_l & bmux_h & {4{zctl_nA_pB}} )) &
		(~( amux_h & bmux_l & {4{zctl_pA_nB}} )) &
		(~( amux_h & bmux_h & {4{zctl_pA_pB}} ));

	assign aluZ_h = ~aluZ_l;

/* Generate carry in */
	assign cin0_h =
		carry_en_h & carry_in_h;
	
	assign cin1_l =
		(~&{ cin0_h       , aluX_l[0  ] } ) &
		(~&{ carry_en_h   ,              aluZ_h[  0] } );
	
	assign cin2_l =
		(~&{ cin0_h       , aluX_l[1:0] } ) &
		(~&{ carry_en_h   , aluX_l[1  ], aluZ_h[  0] } ) &
		(~&{ carry_en_h   ,              aluZ_h[  1] } );
	
	assign cin3_l =
		(~&{ cin0_h       , aluX_l[2:0] } ) &
		(~&{ carry_en_h   , aluX_l[2:1], aluZ_h[  0] } ) &
		(~&{ carry_en_h   , aluX_l[2  ], aluZ_h[  1] } ) &
		(~&{ carry_en_h   ,              aluZ_h[  2] } );
		
	assign cin_h[3:0] = {~cin3_l, ~cin2_l, ~cin1_l, cin0_h};
	assign cin_l[3:0] = { cin3_l,  cin2_l,  cin1_l,~cin0_h};

	wire CELL_23_10_OUT = 
		(~( amux_h[2] & bmux_h[2])) &
		 ~( amux_h[3] | bmux_h[3]);

/* Propagate output */
	
	assign p_out_ctl =
		~g_out_in1;

	assign p_out_in1 =
		(~&{aluX_h[0]            }) &
		(~&{aluX_h[1], ~bcd_add_h}) &
		(~&{aluX_h[2], ~bcd_add_h}) &
		(~&{aluX_h[3], ~bcd_add_h});
	
	assign p_out_in2 =
		(~&{ bcd_add_h, CELL_23_10_OUT, aluZ_l[1] }) &
		(~&{ bcd_add_h, CELL_23_10_OUT, aluX_h[2] });
	
/* Generate carry output */
	assign g_out_ctl =
		cin_l[0];

	// IN1
	assign g_out_in1 =
		(~&{ bcd_add_h, aluX_h[2:1], aluZ_l[1:0], aluZ_l[3] }) &
		(~&{ bcd_add_h, CELL_23_10_OUT, aluZ_l[0] }) &
		(~&{ bcd_add_h, CELL_23_10_OUT, aluZ_l[1] }) &
		(~&{ bcd_add_h, CELL_23_10_OUT, aluX_h[2] });
	// IN2
	assign g_out_in2 =
		(~&{ ~bcd_add_h, aluZ_l[3:0]            }) &
		(~&{ ~bcd_add_h, aluZ_l[2:1], aluX_h[1] }) &
		(~&{             aluZ_l[3:2], aluX_h[2] }) &
		(~&{ ~bcd_add_h, aluZ_l[3  ], aluX_h[3] });

/* Generate overflow output */
	assign v_out =
		(~(bcd_op_l & pg_in_l & cin_h[3]             )) &
		(~(bcd_op_l & pg_in_h & cin_l[3] & carry_en_h));

/* ALU MUX */
	assign aluq_h = 
		(~( amux_l         & {4{ pass_a_h}} )) &
		(~( aluX_h & cin_l & {4{~pass_a_h}} )) &
		(~( aluX_l & cin_h & {4{~pass_a_h}} ));

endmodule
