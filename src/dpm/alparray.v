module alparray(
	/* ----- Clocks ----- */
	/* QD Clock? */
	input            qdck_l,
	
	/* L Clock ? */ 
	input            lck_l,

	/* ----- Data buses ----- */
	
	/* Write Bus (Output) */
	output     [31:0] wbus_h_out,
	
	/* Rotator Bus */
	input      [31:0] rbus_l,
	
	/* Memory Bus */
	input      [31:0] mbus_l,
	
	/* Super-Rotator Bus */
	input      [34:0] sbus_h,
	
	/* ----- Control signals ----- */
	/* ALPCTL/ALKOP Opcode */
	input      [9:0] opc_h,
	
	/* [ DPM09 SHF * L ]        : Shift select */
	input      [1:0] shf_l,
	
	/* [ DPM10 X (15:08) EN L ] : 16-bit extend enable */
	input            x_15_08_en_l,

	/* [ DPM19 D SIZE * H ]     : D SIZE from microword */
	input      [1:0] d_size_h,
	
	input            rot_5_h,
	
	/* ----- Carry signals ----- */
	
	/* Carry input */
	input      [7:0] aluc_l,
	
	/* Generate and Propagate carry */
	output     [7:0] p_l,
	output     [7:0] g_l,
	
	/* ----- ALU Shifter ----- */
	/* Shift input  for bit 31 (SHR) */
	input            a_si31_l,
	/* Shift output for bit 31 (SHL) */
	output           a_so31_l,
	/* Shift input  for bit 0  (SHL) */
	input            a_si0_l,
	/* Shift output for bit 0  (SHR) */
	output           a_so0_l, 
	
	/* ----- Q Shifter ----- */
	/* Shift input  for bit 31 (SHR) */
	input            q_si31_l,
	/* Shift output for bit 31 (SHL) */
	output           q_so31_l,

	/* Shift output for bit 15 (SHL) */
	output           q_so15_l,
	/* Shift input  for bit 15 (SHR) */
	input            q_si15_l,

	/* Shift output for bit 7  (SHL) */
	output           q_so7_l,
	/* Shift input  for bit 7  (SHR) */
	input            q_si7_l,

	/* Shift output for bit 0  (SHR) */
	output           q_so0_l, 
	/* Shift input  for bit 0  (SHL) */
	input            q_si0_l,
	
	/* ----- Flag outputs ----- */
	
	/* Zero flag */
	output     [3:0] wmuxz_h,
	/* V? */
	output     [3:0] aluv_h
);
	
genvar i;
wire       _ext_data_l;

/* [ DPM03 EXT DATA L ] */
wire       ext_data_l;
/* [ ALU SIO ** L ] */
wire [8:0] a_sio_l;

/* [ Q SIO ** L ] */
wire [8:0] q_sio_l;
wire [8:0] _alp_a_shl_l;
wire [8:0] _alp_a_shr_l;
wire [8:0] _alp_q_shl_l;
wire [8:0] _alp_q_shr_l;
wire [8:0] _alk_a_so_l;
wire [8:0] _alk_q_so_l;

wire [3:0] _alp_ext_l;
wire [3:0] _alp_mbxe_l;
wire [3:0] _alp_zl_h;
wire [3:0] _alp_zh_h;

/* ALU Shifter */
assign _alp_a_shl_l[0] = 1'b1;
assign _alp_a_shr_l[8] = 1'b1;
assign _alk_a_so_l     = { a_si31_l, 7'b1111111, a_si0_l };
assign a_sio_l         = _alp_a_shl_l & _alp_a_shr_l & _alk_a_so_l; /* wire-AND */
assign a_so31_l        = a_sio_l[8];
assign a_so0_l         = a_sio_l[0];

/* Q Shifter connections */
assign _alp_q_shl_l[0] = 1'b1;
assign _alp_q_shr_l[8] = 1'b1;
assign _alk_q_so_l     = { q_si31_l, 3'b111, q_si15_l, 1'b1, q_si7_l, 1'b1, q_si0_l };
assign q_sio_l         = _alp_q_shl_l & _alp_q_shr_l & _alk_q_so_l; /* wire-AND */
assign q_so31_l        = q_sio_l[8];
assign q_so15_l        = q_sio_l[4];
assign q_so7_l         = q_sio_l[2];
assign q_so0_l         = q_sio_l[0];

/* [ E64 74S153 ] Sign extension data size mux */
assign _ext_data_l = (d_size_h[0]) ? mbus_l[15] : mbus_l[7]; 
assign ext_data_l  = _ext_data_l | ~rot_5_h;

/* Signals that don't share the same connection to all slices */
assign _alp_mbxe_l = {d_size_h[1], d_size_h[1], x_15_08_en_l, 1'b1};
assign _alp_ext_l  = {ext_data_l , ext_data_l , ext_data_l  , 1'b0}; 

/* Wire ANDs */
assign wmuxz_h      = _alp_zl_h & _alp_zh_h;

/* ALP Bitslices */

`define ALP_MAP(Ny) \
	.qdck_l    (qdck_l),                          \
	.lck_l     (lck_l),                           \
	.opc_h     (opc_h),                           \
	.shf_l     (shf_l),                           \
	.wbus_h_out(wbus_h_out  [(Ny)*4+3:(Ny)*4]),   \
	.rbus_l    (rbus_l      [(Ny)*4+3:(Ny)*4]),   \
	.mbus_l    (mbus_l      [(Ny)*4+3:(Ny)*4]),   \
	.sbus_h    (sbus_h      [(Ny)*4+6:(Ny)*4]),   \
	.g_l       (g_l         [(Ny)]),              \
	.p_l       (p_l         [(Ny)]),              \
	.cyin_l    (aluc_l      [(Ny)]),              \
	.mbxe_l    (_alp_mbxe_l [(Ny)/2]),            \
	.ext_l     (_alp_ext_l  [(Ny)/2]),            \
	\
	.a_so3_l   (_alp_a_shl_l[(Ny)+1]),            \
	.a_si3_l   (a_sio_l[(Ny)+1]),                 \
	.a_so0_l   (_alp_a_shr_l[(Ny)]),              \
	.a_si0_l   (a_sio_l[(Ny)]),                   \
	\
	.q_so3_l   (_alp_q_shl_l[(Ny)+1]),            \
	.q_si3_l   (q_sio_l[(Ny)+1]),                 \
	.q_so0_l   (_alp_q_shr_l[(Ny)]),              \
	.q_si0_l   (q_sio_l[(Ny)])             


generate
	for( i = 0; i < 8; i += 2 ) begin
	
		dc608_alp alp_l_slice(
			`ALP_MAP(i),
			.z_h    (_alp_zl_h[i / 2]));
		
		dc608_alp alp_h_slice(
			`ALP_MAP(i + 1),
			.z_h    (_alp_zh_h[i / 2]),
			.v_h    (aluv_h   [i / 2]));
	
	end
endgenerate
	
endmodule