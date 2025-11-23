`include "chipmacros.vh"

module dc608_alp(
	/* -----    Clocks     ----- */
	
	/* QD Register Clock */
	input            qdck_l,
	/* Latch clock */ 
	input            lck_l,

	/* -----   Data buses   ----- */
	
	/* Write Bus (Output) */
	output reg [3:0] wbus_h_out,
	
	/* Rotator Bus */
	input      [3:0] rbus_l,
	
	/* Memory Bus */
	input      [3:0] mbus_l,
	
	/* Super-Rotator Bus */
	input      [6:0] sbus_h,
	
	/* ----- Control signals ----- */
	
	/* Opcode */
	input      [9:0] opc_h,
	
	/* Shift select */
	input      [1:0] shf_l,
	
	/* Carry input */
	input            cyin_l,
	
	/* EXT? */
	input            ext_l,
	
	/* Memory bus extend enable  */
	input            mbxe_l,
	
	/* ----- Shift signals ----- */
	output reg       a_so0_l,
	input            a_si0_l,
	output reg       a_so3_l,
	input            a_si3_l,
	
	output reg       q_so0_l,
	input            q_si0_l,
	output reg       q_so3_l,
	input            q_si3_l,
	
	/* ----- Flag outputs ----- */
	
	/* Generate and Propagate carry */
	output reg       g_l,
	output reg       p_l,
	/* Zero flag */
	output reg       z_h,
	/* V? */
	output           v_h );
	
	/* WMUX signals */
	wire       wmux_oe_h;
	wire [3:0] wmux_l;
	
	/* SIO signals */
	wire            q_sio_l0_oe_h;
	wire            q_sio_l0_out_h;
	wire            q_sio_l0_in_h;
	
	wire            q_sio_l3_oe_h;
	wire            q_sio_l3_out_h;
	wire            q_sio_l3_in_h;
	
	wire            a_sio_l0_oe_h;
	wire            a_sio_l0_out_h;
	wire            a_sio_l0_in_h;
	
	wire            a_sio_l3_oe_h;
	wire            a_sio_l3_out_h;
	wire            a_sio_l3_in_h;
	
	wire       g_out_ctl;
	wire       g_out_in1;
	wire       g_out_in2;
	wire       p_out_ctl;
	wire       p_out_in1;
	wire       p_out_in2;
	wire       v_out;
	
	wire carry_in_h;
	
	/* Flag signals */
	wire wmuxz_l;
	
	wire [9:0] opc_l;
	wire [1:0] shf_h;
	wire [6:0] sbus_l;
	wire pg_in_h;
	
 	alptl alp(
		/* Clock inputs */
		.qdck_l     ( qdck_l     ),
		.lck_l      ( lck_l      ),
	
		/* Data inputs */
		.mbus_l     ( mbus_l     ),
		.rbus_l     ( rbus_l     ),
		.extdata_l  ( ext_l      ),
		.sbus_l     ( sbus_l     ),
		
		/* -----    WMUX buffer  ----- */
		.wmux_l     ( wmux_l     ),
		.wmux_oe_h  ( wmux_oe_h  ),
	
		/* ----- Control signals ----- */
		.opc_l      ( opc_l      ),
		.shf_h      ( shf_h      ),
		.ext_ena_h  ( mbxe_l     ),
	
		/* -----  Carry signals  ----- */
		.carry_in_h ( carry_in_h ),
		.pg_in_h    ( pg_in_h    ),
		.g_out_ctl  ( g_out_ctl  ),
		.g_out_in1  ( g_out_in1  ),
		.g_out_in2  ( g_out_in2  ),
		.p_out_ctl  ( p_out_ctl  ),
		.p_out_in1  ( p_out_in1  ),
		.p_out_in2  ( p_out_in2  ),
	
	
		/* -----  Flag outputs  ----- */
		.v_out      ( v_out      ),
		.wmuxz_l    ( wmuxz_l    ),
		
		/* ----- Shift signals ----- */
		
		/* Q Shifter */
		.q_sio_l0_oe_h ( q_sio_l0_oe_h  ),
		.q_sio_l0_out_h( q_sio_l0_out_h ),
		.q_sio_l0_in_h ( q_sio_l0_in_h  ),
		.q_sio_l3_oe_h ( q_sio_l3_oe_h  ),
		.q_sio_l3_out_h( q_sio_l3_out_h ),
		.q_sio_l3_in_h ( q_sio_l3_in_h  ),
		
		/* A Shifter */
		.a_sio_l0_oe_h ( a_sio_l0_oe_h  ),
		.a_sio_l0_out_h( a_sio_l0_out_h ),
		.a_sio_l0_in_h ( a_sio_l0_in_h  ),
		.a_sio_l3_oe_h ( a_sio_l3_oe_h  ),
		.a_sio_l3_out_h( a_sio_l3_out_h ),
		.a_sio_l3_in_h ( a_sio_l3_in_h  ) );
	
	assign sbus_l = ~sbus_h;
	assign shf_h  = ~shf_l;
	assign opc_l  = ~opc_h;
	
	/* carry */
	assign carry_in_h = ~cyin_l;
	
	/* P */
	wire p_in_l = p_l, g_in_l = g_l;
	
	assign pg_in_h =
		`NAND( { ~p_in_l, p_out_ctl } ) &
		`NAND( { ~g_in_l, g_out_ctl } );
	
	`OPENDRAIN_DRV( p_out_in1, 1, p_l, ~p_out_in2 )
	
	/* G */
	`OPENDRAIN_DRV( g_out_in1, 1, g_l, ~g_out_in2 )
	
	/* V flag */
	assign v_h = ~v_out;
	
	/* Z flag */
	`OPENDRAIN_DRV( wmuxz_l, 1, z_h, 1'b0 )
	
	/* Q SIO 0 */
	`OPENDRAIN_DRV( q_sio_l0_oe_h, 1, q_so0_l, ~q_sio_l0_out_h )
	assign q_sio_l0_in_h = ~q_si0_l;
	
	/* Q SIO 3 */
	`OPENDRAIN_DRV( q_sio_l3_oe_h, 1, q_so3_l, ~q_sio_l3_out_h )
	assign q_sio_l3_in_h = ~q_si3_l;
	
	/* A SIO 0 */
	`OPENDRAIN_DRV( a_sio_l0_oe_h, 1, a_so0_l, ~a_sio_l0_out_h )
	assign a_sio_l0_in_h = ~a_si0_l;
	
	/* A SIO 3 */
	`OPENDRAIN_DRV( a_sio_l3_oe_h, 1, a_so3_l, ~a_sio_l3_out_h )
	assign a_sio_l3_in_h = ~a_si0_l;
	

/**************************     Output drivers    ************************/
	`TRISTATE_DRV( wmux_oe_h, 4, wbus_h_out, ~wmux_l )

endmodule