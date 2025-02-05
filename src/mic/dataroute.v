module dataroute(
    input        b_clk_l,
    input        xb_select_h,
    input [1:0]  xb_pc_h,
    input        mmux_sel_s1_h,
    input        latched_msrc_2_h,
    input [1:0]  amux_sel_h,
    input [1:0]  dbus_sel_h,
    input [1:0]  dbus_rot_h,
    input [1:0]  clk_sel_h,
    input        mbus_ena_h,
    input        ena_cmi_l,
    input        snapshot_cmi_l,
    input        add_reg_ena_l,
    input        ena_smdr_l,
    input        clk_smdr_l,

    
    input  [31:0] wbus_h,
    input  [31:0] mad_h,

    input  [31:0] mbus_l,
    output [31:0] mbus_out_l,
    
    output [31:0] cache_out_h,
    input  [31:0] cache_h,

    output [23:0] pad_out_h,
    input  [23:0] pad_h,

    output [15:0] xbuf_out_h,
    input  [15:8] xbuf_h,

    output [31:0] cmi_data_out_h,
    input  [31:0] cmi_data_h );

    reg  [31:0] smdr_l;
    wire [31:0] _mdr_mbus_l;
    wire [31:0] _smdr_mbus_l;
    wire [31:0] mbus_in_l = mbus_l & _mdr_mbus_l & _smdr_mbus_l;
    assign mbus_out_l = _mdr_mbus_l & _smdr_mbus_l;

`define B32_SEL(bus, i)  { bus[i+24], bus[i+16], bus[i+8], bus[i] }
`define B24_SEL(bus, i)  { bus[i+16], bus[i+8], bus[i] }
`define B16_SEL(bus, i)  { bus[i+8], bus[i] }

`define MDR_INST( i, id ) \
    dc607_mdr MDR``i ( \
        .wbus_h(`B32_SEL( wbus_h, i )), \
        .ma_h  (`B32_SEL( mad_h, i )), \
        .id_h  (id), \
        .xbs_h (xb_select_h), \
        .pc_h  (xb_pc_h), \
        .ms_h  ({mmux_sel_s1_h, latched_msrc_2_h}), \
        .as_h  (amux_sel_h), \
        .ds_h  (dbus_sel_h), \
        .dr_h  (dbus_rot_h), \
        .cs_h  (clk_sel_h), \
        .mbus_ena_h(mbus_ena_h), \
        .ena_cmi_l(ena_cmi_l), \
        .snapshot_cmi_l(snapshot_cmi_l), \
        .are_l(add_reg_ena_l), \
        .b_clk_l(b_clk_l), \
        .mb_l(`B32_SEL(_mdr_mbus_l, i)), \
        .ca_out_h(`B32_SEL(cache_out_h, i)), \
        .ca_h(`B32_SEL(cache_h, i)), \
        .pa_out_h(`B24_SEL(pad_out_h, i)), \
        .pa_h(`B24_SEL(pad_h, i)), \
        .xb_out_h(`B16_SEL(xbuf_out_h, i)), \
        .xb_1_h(xbuf_h[8+i]), \
        .cmi_out_h(`B32_SEL(cmi_data_out_h, i)), \
        .cmi_h(`B32_SEL(cmi_data_h, i)) )

    `MDR_INST( 0, 1'b1 );
    `MDR_INST( 1, 1'b0 );
    `MDR_INST( 2, 1'b0 );
    `MDR_INST( 3, 1'b0 );
    `MDR_INST( 4, 1'b0 );
    `MDR_INST( 5, 1'b0 );
    `MDR_INST( 6, 1'b0 );
    `MDR_INST( 7, 1'b0 );

    always @ ( posedge clk_smdr_l )
        smdr_l = mbus_in_l;

    assign _smdr_mbus_l = ena_smdr_l ? 32'hFFFFFFFF : smdr_l;
endmodule