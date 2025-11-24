module tlbgroup(
    input        b_clk_l,
    input        in_valid_h,
    input [14:0] in_tag_h,
    input        tag_par_in_h,
    input [ 7:0] index_h,
    input [23:4] data_h,
    input  [2:0] data_par_in_h,
    input        write_h,

    output        hit_h,
    output        tag_perr_h,
    output  [2:0] data_par_out_h,
    output [23:4] data_out_h // merged ac, mbit in here
    );
    wire        valid_h;
    wire [14:0] tag_h;
    wire        tag_par_out_l;
    
    wire        t_write_ena_l = ~(write_h & ~b_clk_l);
    assign hit_h = valid_h & ( tag_h == in_tag_h );

    ttagarray TAG (
        .A( index_h ),
        .D( {in_valid_h, in_tag_h} ),
        .Dp( tag_par_in_h ),
        .Q( { valid_h, tag_h } ),
        .nQp( tag_par_out_l ),
        .nWE( t_write_ena_l )
    );

    tlbarray TLB (
        .A( index_h ),
        .D( data_h ),
        .Dp( data_par_in_h ),
        .Q( data_out_h ),
        .Qp( data_par_out_h ),
        .nWE( t_write_ena_l)
    );

    assign tag_perr_h = ~^{ tag_par_out_l, valid_h, tag_h[14:9], ~^tag_h[8:0] }; 

endmodule