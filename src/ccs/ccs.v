`include "chipmacros.vh"
module ccs(
    input [13:0] cs_addr_h,
    output [13:0] cs_addr_out_h,
    input        m_clk_l,
    input        dis_hi_next_h,
    output reg [13:6] next_h,
    output        cs_hnext_par_h,
    output        hnext_par_h,

    
    output [13:0] cs_next_h,
    output        cs_jsr_h,
    output        cs_clkx_h,
    output [3:0]  cs_fpa_h,
    output [4:0]  cs_bus_h,
    output [5:0]  cs_wctrl_h,
    output [1:0]  cs_cc_h,
    output        cs_istrm_h,
    output [5:0]  cs_rsrc_h,
    output [1:0]  cs_dtype_h,
    output [5:0]  cs_but_h,
    output [9:0]  cs_alpctl_h,
    output [5:0]  cs_rot_h,
    output [4:0]  cs_msrc_h,
    output [1:0]  cs_spw_h,
    output [4:0]  cs_miscctl_h,
    output [1:0]  cs_lit_h,
    output [1:0]  cs_par_h
);

    `FF_P( m_clk_l, cs_next_h[13:6], next_h )

    wire hi_next_gate_l;
    wire hi_next_ff_d_h = ~&cs_addr_h[12:11];
    reg  hi_next_ff_q5;
    wire hi_next_ff_nq6 = ~hi_next_ff_q5;

    `FF_P( m_clk_l, hi_next_ff_d_h, hi_next_ff_q5 )

    assign cs_addr_out_h = _cs_hnext_addr_h;

    assign hi_next_gate_l = ~( ~hi_next_ff_nq6 & ~dis_hi_next_h );

    assign hnext_par_h = ^(~next_h);

    assign cs_hnext_par_h = ~( hnext_par_h & hi_next_ff_q5 );

    wire [13:0] _cs_hnext_addr_h = hi_next_gate_l ? 14'h3FFF : {next_h, 6'h3F};
    wire [13:0] cs_addr_rom_h = cs_addr_h & _cs_hnext_addr_h;

    reg [79:0] stor [0:8191];
    wire [79:0] cs_q_h;
    assign cs_q_h = cs_addr_rom_h[13] ? 80'hFFFFFFFFFF : stor[cs_addr_rom_h[12:0]];
    
    initial $readmemh( "rom/ucode.hex", stor );

    assign cs_next_h    = cs_q_h[13:0];
    assign cs_jsr_h     = cs_q_h[14];
    assign cs_clkx_h    = cs_q_h[15];
    assign cs_fpa_h     = cs_q_h[19:16];
    assign cs_bus_h     = cs_q_h[24:20];
    assign cs_wctrl_h   = cs_q_h[30:25];
    assign cs_cc_h      = cs_q_h[32:31];
    assign cs_istrm_h   = cs_q_h[33];
    assign cs_rsrc_h    = cs_q_h[39:34];
    assign cs_dtype_h   = cs_q_h[41:40];
    assign cs_but_h     = cs_q_h[47:42];
    assign cs_alpctl_h  = cs_q_h[57:48];
    assign cs_rot_h     = cs_q_h[63:58];
    assign cs_msrc_h    = cs_q_h[68:64];
    assign cs_spw_h     = cs_q_h[70:69];
    assign cs_miscctl_h = cs_q_h[75:71];
    assign cs_lit_h     = cs_q_h[77:76];
    assign cs_par_h     = cs_q_h[79:78];

endmodule