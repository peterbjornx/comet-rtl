module cachedp(
    input         b_clk_l,
    input         ena_cache_h,
    input         cache_grp0_wr_h,
    input         force_cache_pe_l,
    input  [ 3:0] ena_byte_l,
    input         ca_hit_h,
    input         ca_hit_inh_h,

    input         cache_valid_0_h,
    input  [23:0] pad_h,
    input  [31:0] cache_h,

    output [31:0] cache_out_h,

    output        ca_hit_out_h,
    output        ca_tag_par_err_h,
    output        ca_data_par_err_l );

    wire [31:0]  ca_h;
    wire [11:0]  ca_tag_h;
    wire [ 3:0]  ca_b_par_in_h;
    wire [ 3:0]  ca_b_par_out_h;
    wire         ca_tag_par_in_h;
    wire         ca_tag_par_out_h;
    wire         ca_valid_h;
    wire [3:0]   ca_b_perr_h;
    wire [3:0]   ca_b_par_l;
    wire [9:0]  index_h  = pad_h[11: 2];
    wire [11:0] in_tag_h = pad_h[23:12];
    wire         ena_cache_l = ~ena_cache_h;
    wire         ca_write_ena_l = ~( ~b_clk_l & cache_grp0_wr_h );

    ctagarray TAG (
        .A(index_h),
        .D({ca_tag_par_in_h , cache_valid_0_h, in_tag_h }),
        .Q({ca_tag_par_out_h, ca_valid_h     , ca_tag_h }),
        .nWE(ca_write_ena_l)
    );

    cachearray DATA (
        .A (index_h),
        .D (cache_h[31:0]),
        .Dp(ca_b_par_in_h),
        .Q (ca_h[31:0]),
        .Qp(ca_b_par_out_h),
        .ena_byte_l(ena_byte_l),
        .nWE(ca_write_ena_l)
    );

    assign cache_out_h = ena_cache_l ? 32'hFFFF_FFFF : ca_h;
    assign ca_hit_out_h = ca_valid_h & ( ca_tag_h == in_tag_h ) & ~ca_hit_inh_h;

    assign ca_tag_par_in_h =   ^{force_cache_pe_l, cache_valid_0_h, in_tag_h, 4'b0000 };
    assign ca_tag_par_err_h = ~^{ca_tag_par_out_h,      ca_valid_h, ca_tag_h, 4'b0000 };

    assign ca_b_par_in_h = ~ca_b_perr_h; //huh?
    assign ca_b_perr_h[3] = ^{ cache_h[31:24], ca_b_par_l[3] };
    assign ca_b_perr_h[2] = ^{ cache_h[23:16], ca_b_par_l[2] };
    assign ca_b_perr_h[1] = ^{ cache_h[15: 8], ca_b_par_l[1] };
    assign ca_b_perr_h[0] = ^{ cache_h[ 7: 0], ca_b_par_l[0] };

    assign ca_b_par_l =  force_cache_pe_l ? ~( ena_cache_l ? 4'b1111 : ca_b_par_out_h ) : 4'b1111;

    assign ca_data_par_err_l = ~|ca_b_perr_h;
    

endmodule