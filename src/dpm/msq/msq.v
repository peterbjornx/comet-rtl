`include "ucodedef.vh"
`include "chipmacros.vh"

module dc621_msq(
    input        bclk_l,
    input        mclk_l,
    input [5:0]  next_h,
    input [5:0]  ustk_h,
    input        jsr_h,
    input        micro_addr_inh_l,
    input        but_cc_a_h,
    input [2:0]  but_h,
    input        do_service_l,
    input        uvector_h,
    input [2:1]  irdctr_h,
    input [1:0]  lit_h,
    input        init_l,
    input        rom_os_inh_h,
    output       zero_hi_next_l,
    output       dis_hi_next_h,
    output       ustk_out_en_l,
    output       en_ird_rom_h,
    output       ld_osr_l,
    output       fpa_wait_l,
    output [3:0] ustk_addr_h,
    output [5:0] cs_addr_l
);

    wire init_h = ~init_l;

    /* FPA WAIT */
    assign fpa_wait_l = ~(lit_h == 2'b10);

    /* BUT decode */
    wire [5:0] _but_h = {{3{~but_cc_a_h}}, but_h};

    wire but_ird1_h     = _but_h == `UC_BUT_IRD1;
    wire but_ird1tst_h  = _but_h == `UC_BUT_IRD1TST;
    wire but_irdx_h     = _but_h == `UC_BUT_IRDX;
    wire but_ret_h      = _but_h == `UC_BUT_RETURN;
    wire but_ret_dinh_h = _but_h == `UC_BUT_RET_DINH;
    wire but_lod_inc_h  = _but_h == `UC_BUT_LOD_INC_BRA;
    wire but_lod_h      = _but_h == `UC_BUT_LOD_BRA;

    /* IRDX return logic */
    wire irdcnt_01_h = ~|irdctr_h[2:1];
    wire dec_irdx_h  = but_irdx_h & irdcnt_01_h;
    wire dec_ret_h   = but_ret_h  | but_ret_dinh_h | (but_irdx_h & ~irdcnt_01_h);
    wire dec_ird1_h  = but_ird1_h | but_ird1tst_h;
    wire dec_ird_h   = dec_irdx_h | dec_ird1_h;
    wire dec_lod_h   = but_lod_h  | but_lod_inc_h;

    /* Addressing mode logic */
    wire am_ext_h    = ~micro_addr_inh_l;
    wire am_init_h   = init_h & ~am_ext_h;
    wire am_uvec_h   = (uvector_h | ~do_service_l) & ~(am_init_h | am_ext_h);
    wire am_ret_h    = dec_ret_h & ~(am_init_h | am_ext_h | am_uvec_h);
    wire am_ird_h    = dec_ird_h & ~(am_init_h | am_ext_h | am_uvec_h);
    wire am_def_h    = ~(am_ext_h | am_init_h | am_uvec_h | am_ret_h | am_ird_h );
    
    /* Microvector */
    reg [5:0] um_svc_h;
    wire [1:0] svc_sel_h = { uvector_h, ~do_service_l };
    always @ (  svc_sel_h ) begin
        case (svc_sel_h)
            2'b10  : um_svc_h <= 6'b10000;
            2'b01  : um_svc_h <= 6'b01000;
            2'b11  : um_svc_h <= 6'b11100;
            default: um_svc_h <= 6'b00000;
        endcase
    end

    /* Micro addr */
    wire [5:0] um_add_h = next_h + ustk_h;
    reg  [5:0] umux_h;
    wire [4:0] umux_sel_h = {am_ext_h,am_init_h,am_uvec_h,am_ret_h,am_ird_h};

    always @ ( um_svc_h or next_h or
               um_add_h or umux_sel_h) begin
        casez (umux_sel_h)
           5'b00001 : umux_h <= 6'h00;
           5'b0001z : umux_h <= um_add_h;
           5'b001zz : umux_h <= um_svc_h;
           5'b01zzz : umux_h <= 6'h00;
           5'b1zzzz : umux_h <= 6'h00;
           default  : umux_h <= next_h;
        endcase
     end

     assign cs_addr_l = ~umux_h;

     wire _jsr_h = jsr_h | am_uvec_h;

     reg [3:0] ustkptr_h;

     reg ph1_ff;
     reg ph2_ff;
     /*wire bclk_h = ~bclk_l;
     `FF_PRESET_P(bclk_h, ~mclk_l,   1'b0, ph1_ff )
     `FF_P       (bclk_h,          ph1_ff, ph2_ff )*/
     wire inc_ustkp_h = _jsr_h   ;
     wire dec_ustkp_h = dec_ret_h & ~inc_ustkp_h;
	  reg [3:0] ustkptr_d_h;
	  always @ ( inc_ustkp_h or dec_ustkp_h or ustkptr_h ) begin
		case({inc_ustkp_h,dec_ustkp_h})
			2'b10     : ustkptr_d_h <= ustkptr_h + 4'b1;
			2'b01     : ustkptr_d_h <= ustkptr_h - 4'b1;
			default   : ustkptr_d_h <= ustkptr_h;
		endcase
	  end
	  
     always @ ( posedge mclk_l ) begin
        if ( init_h )
            ustkptr_h <= 1'b0;
		  else
            ustkptr_h <= ustkptr_d_h;
     end

     assign ustk_addr_h    = ustkptr_d_h;    
     assign ustk_out_en_l  = ~am_ret_h;
     assign zero_hi_next_l = ~(am_uvec_h | am_init_h);
     assign dis_hi_next_h  = ~am_def_h;
     assign en_ird_rom_h   = am_ird_h;
     assign ld_osr_l       = ~(dec_lod_h | but_ird1tst_h | 
                             ( rom_os_inh_h & ( dec_ird_h ) ));

endmodule