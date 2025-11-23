module dc622_ird(
    input  [15:0] xbuf_h,
    output [15:8] xbuf_out_h,
    input         psl_cm_h,
    input         mclk_l,
    input         ld_ir_l,
    input         ld_osr_l,
    input  [1:0]  ctl_h,
    input  [1:0]  sel_h,

    output [7:0]  ir_h,
    output [3:0]  cs_addr_l,
    output [3:0]  rnum_h,
    output [1:0]  isize_h,
    output        dst_rmode_h,
    output        reg_mode_h );

    assign cs_addr_l = 4'b1111;
	 assign ir_h = 8'h00;
	 assign isize_h = 2'b00;
	 assign dst_rmode_h = 1'b0;
	 assign reg_mode_h = 1'b0;
	 assign rnum_h = 4'b0000;

endmodule