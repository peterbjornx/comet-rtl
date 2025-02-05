module tlb(
    input [23:0] pad_h,
    input [31:0] mad_h,
    input b_clk_l,
    input [1:0] tb_grp_wr_h,
    input pte_check_l,
    input tb_output_ena_l,
    input force_tb_pe_l,
    input [1:0] tb_hit_h,

    output       tb_data_perr_h,
    output [1:0] tb_tag_perr_h,
    output [23:0] pad_out_h,
    output       tb_val_h,
    output       tb_valid_h,
    output [3:0] ac_h,
    output [1:0] tb_hit_out_h,
    output       m_bit_h
);
    wire [2:0]  tb_data_perr__h;
    wire        t_tag_par_in_h;

    assign tb_val_h = ^tb_hit_h;
    wire [23:4] t1_tb_data_h; // merged ac, mbit in here
    wire  [2:0] t1_par_out_h;

    wire [23:4] t0_tb_data_h; // merged ac, mbit in here
    wire  [2:0] t0_par_out_h;
    wire  [2:0] tb_par_out_l;

    wire [14:0] in_tag_h = mad_h[30:16];
    wire  [7:0] index_h  = {mad_h[31], mad_h[15:9]};
    wire [23:4] tb_data_in_h = {pad_h[23:9],pad_h[7:3]};
    wire [23:4] _tb_out_mux = tb_hit_h[1] ?  t1_par_out_h : t0_tb_data_h;

    assign tb_par_out_l = tb_output_ena_l ? 3'b111 : ~(tb_hit_h[1] ? t1_par_out_h : t0_par_out_h);
    assign pad_out_h    = tb_output_ena_l ? 24'hFFFFFF : {_tb_out_mux[23:9], 9'h1FF }; 

    assign ac_h         = pte_check_l ? _tb_out_mux[8:4] : pad_h[7:4];
    assign tb_valid_h   = pte_check_l ? tb_val_h : pad_h[8:5];
    assign m_bit_h      = pte_check_l ? _tb_out_mux[4] : pad_h[3];

    assign t_tag_par_in_h = ~^{ force_tb_pe_l, pad_h[8], in_tag_h[14:9], ~^in_tag_h[8:0] };

    assign tb_data_perr__h[2] = ~^{ pad_h[23:18], tb_par_out_l[2] };
    assign tb_data_perr__h[1] = ~^{ pad_h[17:11], tb_par_out_l[1] };
    assign tb_data_perr__h[0] = ~^{ pad_h[10:9], ac_h, m_bit_h, tb_par_out_l[0], force_tb_pe_l };
    assign tb_data_perr_h     = |tb_data_perr__h;

    tlbgroup GRP1 (
        .b_clk_l(b_clk_l),
        .in_tag_h(in_tag_h),
        .in_valid_h( pad_h[8] ),
        .tag_par_in_h(t_tag_par_in_h),
        .index_h(index_h),
        .data_h(tb_data_in_h),
        .data_par_in_h(tb_data_perr__h),
        .write_h(tb_grp_wr_h[1]),
        .hit_h(tb_hit_out_h[1]),
        .tag_perr_h(tb_tag_perr_h[1]),
        .data_par_out_h(t1_par_out_h),
        .data_out_h(t1_tb_data_h) );

    tlbgroup GRP0 (
        .b_clk_l(b_clk_l),
        .in_tag_h(in_tag_h),
        .in_valid_h( pad_h[8] ),
        .tag_par_in_h(t_tag_par_in_h),
        .index_h(index_h),
        .data_h(tb_data_in_h),
        .data_par_in_h(tb_data_perr__h),
        .write_h(tb_grp_wr_h[0]),
        .hit_h(tb_hit_out_h[0]),
        .tag_perr_h(tb_tag_perr_h[0]),
        .data_par_out_h(t0_par_out_h),
        .data_out_h(t0_tb_data_h) );


endmodule