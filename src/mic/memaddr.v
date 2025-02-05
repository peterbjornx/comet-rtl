module memaddr(
    input        b_clk_l,
    input  [31:0] wbus_h,
    output [31:0] ma_h,
    input [1:0]  ma_select_h,
    input [1:0]  bsrc_sel_h,
    input [2:0]  asrc_sel_h,
    input        ena_pc_l,
    input        ena_pc_backup_l,
    input        ena_va_l,
    input        ena_va_save_l,
    input        latch_ma_l,
    input        force_ma_09_h,
    input        comp_mode_h,
    output       page_boundary_h,
    output [1:0] xb_pc_h,
    output       va_0_h );

    wire [3:0] aci_l;
    wire [3:0] cp_h;
    wire [3:0] cg_h;
    wire [4:0] ici_l;
    wire [3:0] pgb_h;
    wire [2:0] pc_h;

    assign aci_l[0] = 1'b1;
    assign ici_l[0] = 1'b1;
    assign xb_pc_h = pc_h[1:0];
    assign page_boundary_h = &pgb_h[1:0];

`define ADD_SHARED_CONN(i) \
    .b_clk_l(b_clk_l), \
    .aci_l(aci_l[i]), \
    .wbus_h(wbus_h[7+i*8:i*8]), \
    .ma_select_h(ma_select_h), \
    .bsrc_sel_h(bsrc_sel_h), \
    .asrc_sel_h(asrc_sel_h), \
    .ena_pc_l(ena_pc_l), \
    .ena_pc_backup_l(ena_pc_backup_l), \
    .ena_va_l(ena_va_l), \
    .ena_va_save_l(ena_va_save_l), \
    .latch_ma_l(latch_ma_l), \
    .ici_l(ici_l[i]), \
    .ico_l(ici_l[i+1]), \
    .pgb_h(pgb_h[i]), \
    .va_0_h(va_0_h), \
    .ma_h(ma_h[7+i*8:i*8]), \
    .cp_h(cp_h[i]), \
    .cg1_h(cg_h[i]), \
    .cg2_h()

    dc609_add ADD0 (
        `ADD_SHARED_CONN(0),
        .id_h(1'b0),
        .comp_h(1'b0),
        .pc_h(pc_h),
        .force_ma_h(1'b0) );

    dc609_add ADD1 (
        `ADD_SHARED_CONN(1),
        .id_h(1'b1),
        .comp_h(1'b0),
        .pc_h(),
        .force_ma_h(force_ma_09_h) );

    dc609_add ADD2 (
        `ADD_SHARED_CONN(2),
        .id_h(1'b1),
        .comp_h(comp_mode_h),
        .pc_h(),
        .force_ma_h(1'b0) );

    dc609_add ADD3 (
        `ADD_SHARED_CONN(3),
        .id_h(1'b1),
        .comp_h(comp_mode_h),
        .pc_h(),
        .force_ma_h(1'b0) );

    sn74s182 E164 (
        .nG({1'b0,cg_h[2:0]}),
        .nP({1'b0,cp_h[2:0]}),
        .Co(  aci_l[3:1] ),
        .C (1'b1),
        .nCP(),
        .nCG() );

endmodule