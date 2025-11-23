`include "chipmacros.vh"

module dc616_spa(
        input        m_clk_l,
        input        phase_h,
        input        d_clk_en_h,
        input [5:0]  rsrc_h,
        input [4:0]  msrc_h,
        input        lit_0_h,
        input        spwm_l,
        input        dst_rmode_h,
        input [1:0]  dsize_h,
        input [3:0]  ird_rnum_h,
        input        ird_ld_rnum_h,
        input        ifetch_h,
        input [3:0]  wbus_in_h,

        output [3:0] rspa_h,
        output [3:0] mspa_h,

        output       mcs_tmp_l,
        output       rcs_tmp_l,
        output       rcs_gpr_l,
        output       rcs_ipr_l,
        output       litr_l,
        output [3:0] wbus_out_h,

        output [1:0] spa_st_h );

        reg [3:0] rnum_h = 4'b0000;

        wire spw_mlong_h    = ~spwm_l;
        wire dec_rnum_ld_h  = msrc_h == 5'h1D;
        wire dec_read_rbs_h = msrc_h == 5'h1C;
        wire dec_push_add_h = msrc_h == 5'h15;
        wire dec_push_sub_h = msrc_h == 5'h14;
        wire dec_wbrnum_h   = msrc_h == 5'h16;
        wire dec_wbrbsp_h   = msrc_h == 5'h1D;
        wire dec_ldrbsp_h   = msrc_h == 5'h1E;
        wire dec_r_def_h    = (rsrc_h[5:2] == 4'b1101) & ~lit_0_h; 
        wire dec_r_zero_h   = (rsrc_h == 6'h36) & ~lit_0_h; 
        wire dec_r_zcrb_h   = (rsrc_h == 6'h37) & ~lit_0_h; 
        wire dec_lonlit_h   = (rsrc_h == 6'h35) & ~lit_0_h; 

        wire dec_zerorbsp_h = (dec_r_zcrb_h | ifetch_h) & ~lit_0_h;
        wire dec_push_h     = dec_push_add_h | dec_push_sub_h;
        wire dec_inc_rbsp_h = dec_push_h | dec_read_rbs_h;
        wire dec_rspec_h    = (rsrc_h[5:2] == 4'b1101) & ~lit_0_h;
        wire dec_rtmp_h     = (rsrc_h[5:4] == 2'h3) & (rsrc_h[1:0] == 2'h0) & ~dec_rspec_h & ~lit_0_h;
        wire dec_rdst_h     = (rsrc_h[5:4] == 2'h3) & (rsrc_h[1:0] == 2'h1) & ~dec_rspec_h & ~lit_0_h;
        wire dec_ripr_h     = (rsrc_h[5:4] == 2'h3) & (rsrc_h[1:0] == 2'h2) & ~dec_rspec_h & ~lit_0_h;
        wire dec_rgpr_h     = (rsrc_h[5:4] == 2'h3) & (rsrc_h[1:0] == 2'h3) & ~dec_rspec_h & ~lit_0_h;
        wire rbsp_z_h       = (rbsp_h == 3'h5) | dec_zerorbsp_h;

        wire [2:0] rbsp_next_h = rbsp_z_h ? 3'h0 : (rbsp_h + 3'h1);
        wire [2:0] rbsp_d_h = dec_ldrbsp_h ? wbus_in_h[2:0] : rbsp_next_h;
        wire       rbsp_e_h = d_clk_en_h & ( dec_ldrbsp_h | dec_inc_rbsp_h | dec_zerorbsp_h );
        reg [2:0] rbsp_h = 3'b000;
        `FF_EN_P( m_clk_l, rbsp_e_h, rbsp_d_h, rbsp_h )

        reg [6:0] rbs_mem_h [0:5];

        assign litr_l = ~dec_lonlit_h;
        assign wbus_out_h = 4'b1111;//TODO: foo
        wire rbs_wclk_h = ~m_clk_l;
        wire rbs_w_en_h = dec_push_h;
        wire [6:0] rbs_d_h = { dec_push_add_h, dsize_h, rnum_h };

        always @ ( posedge rbs_wclk_h ) begin
            if ( rbs_w_en_h )
                rbs_mem_h[ rbsp_h ] <= rbs_d_h;
        end


        reg [3:0] rnum_d_h;
        wire [6:0] rbs_q_h = rbs_mem_h[rbsp_h];
        wire [2:0] rnum_sel_h = {ird_ld_rnum_h, dec_rnum_ld_h, dec_read_rbs_h};
        always @ ( rnum_sel_h or rbs_q_h or ird_rnum_h or wbus_in_h ) begin
            casez (rnum_sel_h)
                3'b1zz:  rnum_d_h <= ird_rnum_h;
                3'b010:  rnum_d_h <= wbus_in_h;
                3'b001:  rnum_d_h <= rbs_q_h[3:0];
                default: rnum_d_h <= 4'bxxxx;
            endcase
        end
        wire rnum_e_h = d_clk_en_h & ( |rnum_sel_h );

        `FF_EN_P( rbs_wclk_h, rnum_e_h, rnum_d_h, rnum_h)

        reg [3:0] dec_rspa_h;
        wire      rw_rtmp_h;
        wire      dec_r_rmtmp_h;
        wire      rw_gpr_h;
        wire      rw_ipr_h;
        reg [3:0] dec_mspa_h;
        reg       rd_mtmp_h;
        wire      dec_m_rmtmp_h;

        wire is_write_h = phase_h;
        wire is_write_m_h;
        wire is_write_r_h;
        wire [3:0] wr_spa_h;

        always @ ( rsrc_h or rnum_h ) begin
            casez( rsrc_h )
                6'b00zzzz:  dec_rspa_h <= rsrc_h[3:0]; 
                6'b01zzzz:  dec_rspa_h <= rsrc_h[3:0]; 
                6'b10zzzz:  dec_rspa_h <= rsrc_h[3:0]; 
                6'b1100zz:  dec_rspa_h <= rnum_h;
                6'b110111:  dec_rspa_h <= 4'b0111;
                6'b1110zz:  dec_rspa_h <= rnum_h | 4'b0001;
                6'b1111zz:  dec_rspa_h <= rnum_h + 4'b0001;
                default  :  dec_rspa_h <= 4'h0;
            endcase
        end

        wire rdst_gate_h = dec_rdst_h & (dst_rmode_h | ~is_write_h);
        /* Address decodes for R scratchpad, including RNUM effects */
        assign rw_rtmp_h = ((rsrc_h[5:4] == 2'h0) | dec_rtmp_h) & ~lit_0_h;
        assign rw_gpr_h  = ((rsrc_h[5:4] == 2'h1) | dec_rgpr_h | rdst_gate_h) & ~lit_0_h;
        assign rw_ipr_h  = ((rsrc_h[5:4] == 2'h2) | dec_ripr_h) & ~lit_0_h;
        
        wire   wr_r_rtmp_h = rw_rtmp_h  | lit_0_h | dec_r_def_h;

        /* Is this an access to a dual port temp from RSRC */
        assign dec_r_rmtmp_h = (rw_rtmp_h & ~dec_rspa_h[3]) | lit_0_h | dec_r_def_h;

        always @ ( msrc_h or rnum_h ) begin
            casez( msrc_h )
                5'b0zzzz:  dec_mspa_h <= msrc_h[3:0]; 
                5'b10000:  dec_mspa_h <= rnum_h;
                5'b10001:  dec_mspa_h <= rnum_h + 1;
                default :  dec_mspa_h <= 4'h0;
            endcase
        end

        /* Is this an access to a dual port temp from MSRC */
        assign dec_m_rmtmp_h = ~dec_mspa_h[3];

		/* MSRC read CS decodes */   
        always @ ( msrc_h ) begin
            casez( msrc_h )
                5'b0zzzz:  rd_mtmp_h <= 1'b1; 
                5'h12   :  rd_mtmp_h <= 1'b0;
                5'h13   :  rd_mtmp_h <= 1'b0;
                5'b10111:  rd_mtmp_h <= 1'b0;
                5'b110zz:  rd_mtmp_h <= 1'b0;
                5'b11111:  rd_mtmp_h <= 1'b0;
                default :  rd_mtmp_h <= 1'b1; 
            endcase
        end

        assign is_write_m_h = is_write_h & spw_mlong_h;
        assign is_write_r_h = is_write_h & ~spw_mlong_h;

        /* Interchange write CS if SPW/MLONG */
        wire   wr_rtmp_h = spw_mlong_h ? dec_m_rmtmp_h : wr_r_rtmp_h;
        wire   wr_mtmp_h = spw_mlong_h ? 1'b1          : dec_r_rmtmp_h;
        assign wr_spa_h  = spw_mlong_h ? dec_mspa_h    : dec_rspa_h;

        /* Select write or read phase outputs */
        assign rspa_h    = is_write_h   ? wr_spa_h    : dec_rspa_h;
        assign mspa_h    = is_write_h   ? wr_spa_h    : dec_mspa_h;
        assign rcs_gpr_l = is_write_m_h ? 1'b1        : ~rw_gpr_h;
        assign rcs_ipr_l = is_write_m_h ? 1'b1        : ~rw_ipr_h;
        assign rcs_tmp_l = is_write_h   ?  ~wr_rtmp_h : ~rw_rtmp_h;
        assign mcs_tmp_l = is_write_h   ?  ~wr_mtmp_h : ~rd_mtmp_h;


endmodule