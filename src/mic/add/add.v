`include "chipmacros.vh"

module dc609_add(
    	input b_clk_l,

        input        aci_l,
        input [7:0]  wbus_h,

        input [1:0]  ma_select_h,
        input [1:0]  bsrc_sel_h,
        input [2:0]  asrc_sel_h,
        input        ena_pc_l,
        input        ena_pc_backup_l,
        input        ena_va_l,
        input        ena_va_save_l,
        input        latch_ma_l,
        input        force_ma_h,
        input        comp_h,
        input        id_h,

        input        ici_l,
        output       ico_l,

        output       pgb_h,
        output [2:0] pc_h,
        output       va_0_h,
        output [7:0] ma_h,

        output       cp_h,
        output       cg1_h,
        output       cg2_h
    );

    wire [8:0] adder_q_h;
    wire [7:0] inc_q_h;

    reg [7:0] va_h = 8'b0;
    reg [7:0] pc_q_h = 8'b0;
    reg [7:0] va_save_h = 8'b0;
    reg [7:0] pc_backup_h = 8'b0;
    reg [7:0] ma_latch_h = 8'b0;

    reg [7:0] mmux_h;
    reg [7:0] amux_h;
    reg [7:0] bmux_h;

    reg lma_reg_h = 1'b0;
    `FF_P( b_clk_l, latch_ma_l, lma_reg_h )
    wire lma_h = lma_reg_h & ~b_clk_l;

    wire vas_clk_h = ~b_clk_l & ~ena_va_save_l;
    `LATCH_P( vas_clk_h,                   adder_q_h[7:0], va_save_h   )
    `FF_EN_P( b_clk_l  , ~ena_va_l       , adder_q_h[7:0], va_h        )
    `FF_EN_P( b_clk_l  , ~ena_pc_l       , va_save_h     , pc_q_h      )
    `FF_EN_P( b_clk_l  , ~ena_pc_backup_l, va_save_h     , pc_backup_h )

    always @( asrc_sel_h or wbus_h ) begin
        casez( asrc_sel_h )
            3'b000 : amux_h <= 4'h0 & {4{~id_h}};
            3'b001 : amux_h <= 4'h1 & {4{~id_h}};
            3'b010 : amux_h <= 4'h2 & {4{~id_h}};
            3'b011 : amux_h <= 4'h4 & {4{~id_h}};
            3'b1zz : amux_h <= wbus_h;
            default: amux_h <= 8'bxxxxxxxx;
        endcase
    end

    always @( bsrc_sel_h or pc_q_h or va_save_h or va_h ) begin
        case( bsrc_sel_h )
            2'b00  : bmux_h <= 4'h0;
            2'b01  : bmux_h <= pc_q_h;
            2'b10  : bmux_h <= va_save_h;
            2'b11  : bmux_h <= va_h;
            default: bmux_h <= 8'bxxxxxxxx;
        endcase
    end

    always @( comp_h or ma_select_h or inc_q_h or pc_q_h or pc_backup_h or va_h ) begin
        casez( { comp_h, ma_select_h } )
            3'b000 : mmux_h <= inc_q_h;
            3'b001 : mmux_h <= pc_backup_h;
            3'b010 : mmux_h <= pc_q_h;
            3'b011 : mmux_h <= va_h;
            3'b1zz : mmux_h <= 8'h00;
            default: mmux_h <= 8'bxxxxxxxx;
        endcase
    end

    /* Incrementer */
    assign inc_q_h = pc_q_h + {3'b000, ~ici_l} + {1'b0, ~id_h, 2'b0};
    assign ico_l = id_h ? (&pc_q_h & ~ici_l) : &pc_q_h[7:2];

    assign pgb_h = id_h ? va_h[0] : &va_h[7:3];
    assign va_0_h = va_h[0];
    assign pc_h   = pc_q_h[2:0];


    assign adder_q_h = {1'b0, amux_h} + {1'b0, bmux_h} + {8'h00, ~aci_l};
    assign cp_h  = |(amux_h & bmux_h);
    assign cg1_h = adder_q_h[8] | &adder_q_h[7:0]; 
    assign cg2_h = adder_q_h[8] | &adder_q_h[7:0]; 

    `LATCH_P( lma_h, mmux_h, ma_latch_h )

    assign ma_h = ma_latch_h | {6'h00, force_ma_h, 1'b0};

endmodule