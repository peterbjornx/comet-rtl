`include "chipmacros.vh"

module dc607_mdr(
    input [3:0] wbus_h,
    input [3:0] ma_h,
    input       id_h,
    input       xbs_h,
    input [1:0] pc_h,
    input [1:0] ms_h,
    input [1:0] as_h,
    input [1:0] ds_h,
    input [1:0] dr_h,
    input [1:0] cs_h,
    input       mbus_ena_h,
    input       ena_cmi_l,
    input       snapshot_cmi_l,
    input       are_l,
    input       b_clk_l,

    output [3:0] mb_l,
    
    output [3:0] ca_out_h,
    input  [3:0] ca_h,

    output [2:0] pa_out_h,
    input  [2:0] pa_h,

    output [1:0] xb_out_h,
    input        xb_1_h,

    output [3:0] cmi_out_h,
    input  [3:0] cmi_h );

    wire  [3:0] cbus_h;
    reg  [3:0] dbus_h;

    reg  [2:0] pamux_h;
    reg  [3:0] mmux_h;
    reg  [2:0] cmi_adr_h = 3'b0;
    reg  [3:0] mdr_h = 4'b0;
    reg  [3:0] wdr_h = 4'b0;
    reg  [3:0] dbus_rot_h;
    reg  [3:0] cmi_data_h = 4'b0;
    reg  [3:0] xb0_h = 4'b0;
    reg  [3:0] xb1_h = 4'b0;
    reg  [3:0] xb_data_h;

    wire cs_mdr_en_h = cs_h == 2'b01;
    wire cs_xb_en_h  = cs_h == 2'b10;
    wire cs_wdr_en_h = cs_h == 2'b11;
    wire xbs_xb0_en_h = ~xbs_h;
    wire xbs_xb1_en_h =  xbs_h;
	 wire are_h = ~are_l;
	 
	 `FF_EN_N( b_clk_l, are_h, pa_h, cmi_adr_h );

    //XXX: does this involve clock?
    `LATCH_N( snapshot_cmi_l, cmi_h, cmi_data_h )

    /* ZERO MDR */
    wire zero_mdr_h     = (ds_h == 2'b11) & (dr_h != 2'b00) & (cs_h == 2'b00);
    /* SOURCE WDR ONTO MBUS */
    wire src_wdr2m_h    = (ds_h == 2'b11) & (dr_h != 2'b00) & (cs_h == 2'b00);
    /* PA -> MBUS */
    wire pa_read_h      = (ms_h == 2'b11) & ~src_wdr2m_h;
    /* CACHE BUS DRIVER ENABLE */
    wire ca_drv_h       =  ds_h != 2'b00;
    /* READ, SECOND REFERENCE */
    wire read_2nd_ref_h =  dr_h != 2'b00 & cs_h == 2'b00 && ~src_wdr2m_h;
    /* XB DECODE BUS DRIVER ENABLE */
    wire xb_drv_h       = ~((ds_h == 2'b11) & (dr_h == 2'b00));
    
    /* WDR -> CBUS */
    wire cbus_wdr_h;

    reg cmi_ena_q_h = 1'b0;
    reg cbus_sel_h = 1'b0;
    `FF_P( b_clk_l,  ~ena_cmi_l, cmi_ena_q_h )
    `FF_P( b_clk_l, cmi_ena_q_h, cbus_sel_h )

    wire cmi_drv_h  = cmi_ena_q_h;
    wire cmi_drv3_h = cmi_ena_q_h & cbus_wdr_h;

    /* Output drivers */
    assign mb_l      = mbus_ena_h ? ~mmux_h : 4'b1111;
    assign ca_out_h  = ca_drv_h  ? cbus_h : 4'b1111;
    assign cmi_out_h[2:0] = cmi_drv_h  ? cbus_h    : 4'b111;
    assign cmi_out_h[3]   = cmi_drv3_h ? cbus_h[3] : 1'b1; 
    assign xb_out_h  = xb_drv_h  ? {1'b1, xb_data_h[0]} : xb_data_h[1:0];

    wire [2:0] pa_drv_h;
    wire force_cmi2d_h  = src_wdr2m_h | zero_mdr_h;


    wire en_pa_h       = (ds_h == 2'b00 | ~are_l ) & (as_h == 2'b00);
    assign pa_drv_h[0] =                    ~pa_read_h;
    assign pa_drv_h[1] = (en_pa_h | id_h) & ~pa_read_h;
    assign pa_drv_h[2] =  en_pa_h         & ~pa_read_h;

    wire wdr_force_en_h = ( |mdr_b_en_h | cs_xb_en_h ) & ds_h == 2'b01;

    assign pa_out_h = pamux_h | ~pa_drv_h;

    reg [3:0] mdr_b_en_h;


    always @ ( dr_h or read_2nd_ref_h or cs_mdr_en_h ) begin
        casez ( { read_2nd_ref_h, dr_h } )
            3'b101 : mdr_b_en_h <= 4'b1000;
            3'b110 : mdr_b_en_h <= 4'b1100;
            3'b111 : mdr_b_en_h <= 4'b1110;
            3'b0zz : mdr_b_en_h <= {4{cs_mdr_en_h | zero_mdr_h}};
            default: mdr_b_en_h <= 4'bxxxx;
        endcase
    end

    assign cbus_h = cbus_sel_h ? wdr_en_h : cmi_adr_h;

    /* XB register */
    `FF_EN_P( b_clk_l, xbs_xb0_en_h, dbus_h, xb0_h )
    `FF_EN_P( b_clk_l, xbs_xb1_en_h, dbus_h, xb1_h )

    /* MDR register */
    wire [3:0] mdr_d_h  = {4{~zero_mdr_h}} & dbus_rot_h;
    `FF_EN_P( b_clk_l, mdr_b_en_h[0], mdr_d_h[0], mdr_h[0] )
    `FF_EN_P( b_clk_l, mdr_b_en_h[1], mdr_d_h[1], mdr_h[1] )
    `FF_EN_P( b_clk_l, mdr_b_en_h[2], mdr_d_h[2], mdr_h[2] )
    `FF_EN_P( b_clk_l, mdr_b_en_h[3], mdr_d_h[3], mdr_h[3] )

    /* WDR MUX */
    wire [3:0] wdrmux_h = wdr_force_en_h ? dbus_h : dbus_rot_h;

    /* WDR register */
    wire wdr_en_h = wdr_force_en_h | cs_wdr_en_h;
    `FF_EN_P( b_clk_l, wdr_en_h, wdrmux_h, wdr_h )

    always @ (  force_cmi2d_h or ds_h or ca_h or cmi_data_h or wbus_h or xb_1_h ) begin
        casez( {force_cmi2d_h, ds_h} )
            3'b000  : dbus_h <= ca_h;
            3'b001  : dbus_h <= cmi_data_h;
            3'b010  : dbus_h <= wbus_h;
            3'b011  : dbus_h <= {3'b000, xb_1_h};
            3'b1zz  : dbus_h <= cmi_data_h;
            default: dbus_h <= 4'bxxxx;
        endcase
    end

    /* MBUS MUX */
    always @ (  ms_h or src_wdr2m_h or wdr_h or xb_data_h or mdr_h or ma_h or pa_h ) begin
        casez( { src_wdr2m_h, ms_h } )
            3'b000  : mmux_h <= mdr_h;
            3'b001  : mmux_h <= xb_data_h;
            3'b010  : mmux_h <= ma_h;
            3'b011  : mmux_h <= { 1'b0, pa_h }; //XXX: is this  0 or 1 ( logical 1, active low )
            3'b1zz  : mmux_h <= wdr_h;
            default : mmux_h <= 4'bxxxx;
        endcase
    end

    /* PA MUX */
    always @ (  as_h or en_pa_h or cmi_adr_h or cmi_data_h or ma_h or dbus_h ) begin
        casez( { en_pa_h, as_h } )
            3'b000  : pamux_h <= cmi_adr_h;
            3'b001  : pamux_h <= cmi_data_h [2:0];
            3'b010  : pamux_h <= ma_h  [2:0];
            3'b011  : pamux_h <= dbus_h[2:0];
            3'b1zz  : pamux_h <= ma_h  [2:0];
            default : pamux_h <= 3'bxxx;
        endcase
    end

    /* DBUS ROT Correct per TD and GA */
    always @ (  dr_h or dbus_h ) begin
        case( dr_h )
            2'b00   : dbus_rot_h <=   dbus_h;
            2'b01   : dbus_rot_h <= { dbus_h[  0], dbus_h[3:1] };
            2'b10   : dbus_rot_h <= { dbus_h[1:0], dbus_h[3:2] };
            2'b11   : dbus_rot_h <= { dbus_h[2:0], dbus_h[3  ] };
            default : dbus_rot_h <= 4'bxxxx;
        endcase
    end

    always @ ( xbs_h or pc_h or xb0_h or xb1_h ) begin
        case( { xbs_h, pc_h } )
            3'b000  : xb_data_h <= xb1_h;
            3'b001  : xb_data_h <= { xb0_h[  0], xb1_h[3:1] };
            3'b010  : xb_data_h <= { xb0_h[1:0], xb1_h[3:2] };
            3'b011  : xb_data_h <= { xb0_h[2:0], xb1_h[3  ] };
            3'b100  : xb_data_h <= xb0_h;
            3'b101  : xb_data_h <= { xb1_h[  0], xb0_h[3:1] };
            3'b110  : xb_data_h <= { xb1_h[1:0], xb0_h[3:2] };
            3'b111  : xb_data_h <= { xb1_h[2:0], xb0_h[3  ] };
            default : xb_data_h <= 4'bxxxx;
        endcase
    end



endmodule