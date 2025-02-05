`include "chipmacros.vh"
`include "ucodedef.vh"

`define CMI_FUNC_RD       3'b000
`define CMI_FUNC_RD_LOCK  3'b001
`define CMI_FUNC_RD_LMOD  3'b010

`define CMI_FUNC_WR       3'b100
`define CMI_FUNC_WR_UNLK  3'b101
`define CMI_FUNC_WR_VEC   3'b110

module dc623_cmk(
    input b_clk_l,
    input d_clk_en_h,
    input m_clk_en_h,
    input bus_4_h,
    input cmi_cpu_priority_l,
    input dst_rmode_h,
    input hit_h,
    input wait_h,
    input phase_1_h,
    input mseq_init_l,
    input mmux_sel_s1_h,
    input [1:0] mad_h,
    input [3:0] lbus_h,
    input int_grant_h,
    input inhibit_cmi_h,
    input cache_int_l,
    input [1:0] dsize_h,
    input prefetch_l,

    input [27:25]  cmi_h,
    output [31:25] cmi_out_h,

    input dbbz_l,
    output dbbz_out_l,

    input hold_l,
    output hold_out_l,

    input [1:0] st_l,
    output [1:0] st_out_l,

    output add_reg_ena_l,
    output corr_data_int_l,
    output ena_cmi_l,
    output grant_stall_l,
    output snapshot_cmi_l,
    output reg [1:0] status_h,
    output status_valid_l,
    output write_vect_occ_l );

    wire mseq_init_h = ~mseq_init_l;
    wire b_clk_h = ~b_clk_l;
    wire final_cyc_dec_h;
    reg       latched_bus_4_h = 1'b0;
    wire[4:0] latched_bus_h = { latched_bus_4_h, lbus_h };
    reg [3:0] cmi_bm_base_h = 1'b0;
    reg [1:0] latched_dsize_h = 1'b0;
    reg [31:28]  cmi_31_28_d_h = 1'b0;
    wire [31:25] cmi_d_h;
    reg       add_reg_ena_h = 1'b0;
    reg       corr_data_int_h = 1'b0;
    wire lock_h;
    wire suppress_lock_h;
    reg ena_func_h = 1'b0;
    reg cmi_enable_h = 1'b0;
    wire set_ena_cmi_h;
    wire cmi_request_h;
    wire read_lock_inhibit_h;
    reg read_h = 1'b0;
    wire set_busy_h;
    reg latched_busy_h = 1'b0;
    wire inhibit_busy_h;
    wire read_lock_h;
    reg snapshot_cmi_h = 1'b0;
    reg write_vector_h = 1'b0;
    reg status_valid_h = 1'b0;
    wire timeout_clk_h;
    reg [7:0] timeout_counter_h = 8'h11;
    wire timeout_h;
    wire add_cyc_h;
    reg dbbz_del_h = 1'b0;
    reg lock_set_h = 1'b0;
    wire mem_req_h;
    reg bus_cyc_dec_h;
    wire replacement_h;
    reg add_ena_del_h = 1'b0;
    reg prefetch_del_h = 1'b0;
    wire enable_inval_h;
    wire reset_add_ena_h;
    reg inval_check_h = 1'b0;
    reg inval_write_h = 1'b0;
    reg wr_vect_latch_h = 1'b0;
    reg busy_h = 1'b0;
    reg cmi_in_prog_h = 1'b0;
    reg syn_int_done_h = 1'b0;
    reg cmi_ena_h = 1'b0;
    reg int_latch_h = 1'b0;
    reg prefetch_cycle_h = 1'b0;
	 
    assign add_reg_ena_l   = ~add_reg_ena_h;
    assign corr_data_int_l = ~corr_data_int_h;

    wire _lb4_j_h = m_clk_en_h &  bus_4_h;
    wire _lb4_k_h = m_clk_en_h & ~bus_4_h;
    `JKFF_P( b_clk_l, _lb4_j_h, _lb4_k_h, latched_bus_4_h )


    always @ ( latched_bus_h ) begin
        case( latched_bus_h )
            `UC_BUS_READ         : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_PHY     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_NT      : bus_cyc_dec_h <= 1'b1;
             5'h04               : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_SEC     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_LNG     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_MOD_LCK : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_MOD     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_READ_LNG_MOD : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE        : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_LNG    : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_UL     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_PHY    : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_SEC    : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_UL_SEC : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_NT     : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_NT_LNG : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_GRANT        : bus_cyc_dec_h <= 1'b1;
            `UC_BUS_WRITE_NOREG  : bus_cyc_dec_h <= ~dst_rmode_h;
            default: bus_cyc_dec_h <= 1'b0;
        endcase
    end


    wire _dsz_l_en_h = add_reg_ena_h & prefetch_l & &latched_bus_h[4:3];
    `LATCH_P( _dsz_l_en_h, dsize_h, latched_dsize_h )
    wire read_dec_h, write_dec_h;
	 
    /* Decode bus functions */
    assign write_dec_h = (
        latched_bus_h == `UC_BUS_WRITE    |
        latched_bus_h == `UC_BUS_WRITE_LNG |
        (latched_bus_h == `UC_BUS_WRITE_NOREG & ~dst_rmode_h) |
        latched_bus_h == `UC_BUS_WRITE_NT |
        latched_bus_h == `UC_BUS_WRITE_NT_LNG |
        latched_bus_h == `UC_BUS_WRITE_PHY |
        latched_bus_h == `UC_BUS_WRITE_SEC |
        latched_bus_h == `UC_BUS_WRITE_UL |
        latched_bus_h == `UC_BUS_WRITE_UL_SEC );

    assign read_dec_h = (
        latched_bus_h == `UC_BUS_READ |
        latched_bus_h == `UC_BUS_READ_SEC |
        latched_bus_h == `UC_BUS_READ_LNG |
        latched_bus_h == `UC_BUS_READ_PHY |
        latched_bus_h == `UC_BUS_READ_MOD |
        latched_bus_h == `UC_BUS_READ_MOD_LCK |
        latched_bus_h == `UC_BUS_READ_NT |
        latched_bus_h == `UC_BUS_READ_LNG_MOD );
	 
    assign read_lock_h = prefetch_l & ( latched_bus_h == `UC_BUS_READ_MOD_LCK );

    always @ ( latched_dsize_h or read_dec_h or write_dec_h ) begin 
        casez( { read_dec_h, write_dec_h, latched_dsize_h }) 
            4'b10_zz: cmi_bm_base_h <= 4'b1111;
            4'b01_00: cmi_bm_base_h <= 4'b0001;
            4'b01_01: cmi_bm_base_h <= 4'b0011;
            4'b01_1z: cmi_bm_base_h <= 4'b1111;
            default : cmi_bm_base_h <= 4'bxxxx;
        endcase
    end

    wire [3:0] cmi_31_28_rw_h = 4'b1111 << mad_h;
    wire [3:0] cmi_31_28_w2_h = (latched_dsize_h[1] & mad_h[1]) ? {1'b0, mad_h[0], 2'b11}: 4'b0001;

    always @ ( latched_bus_h ) begin
        casez( latched_bus_h )
            `UC_BUS_READ_PHY    : cmi_31_28_d_h <= 4'b1111;
            5'h04               : cmi_31_28_d_h <= 4'b1111;
            `UC_BUS_READ_SEC    : cmi_31_28_d_h <= 4'b1111;
            `UC_BUS_GRANT       : cmi_31_28_d_h <= 4'b1111;
            `UC_BUS_WRITE_NT_LNG: cmi_31_28_d_h <= 4'b1111;
            `UC_BUS_WRITE_PHY   : cmi_31_28_d_h <= 4'b1111;
            `UC_BUS_WRITE_LNG   : cmi_31_28_d_h <= 4'b1111;
            `UC_BUS_READ_LNG    : cmi_31_28_d_h <= 4'b1111;
            `UC_BUS_READ_LNG_MOD: cmi_31_28_d_h <= 4'b1111;
            `UC_BUS_READ        : cmi_31_28_d_h <= cmi_31_28_rw_h;
            `UC_BUS_READ_MOD    : cmi_31_28_d_h <= cmi_31_28_rw_h;
            `UC_BUS_READ_MOD_LCK: cmi_31_28_d_h <= cmi_31_28_rw_h;
            `UC_BUS_READ_NT     : cmi_31_28_d_h <= cmi_31_28_rw_h;
            `UC_BUS_WRITE       : cmi_31_28_d_h <= cmi_31_28_rw_h;
            `UC_BUS_WRITE_NT    : cmi_31_28_d_h <= cmi_31_28_rw_h;
            `UC_BUS_WRITE_UL    : cmi_31_28_d_h <= cmi_31_28_rw_h;
            `UC_BUS_WRITE_NOREG : cmi_31_28_d_h <= cmi_31_28_rw_h;
            `UC_BUS_WRITE_SEC   : cmi_31_28_d_h <= cmi_31_28_w2_h;
            `UC_BUS_WRITE_UL_SEC: cmi_31_28_d_h <= cmi_31_28_w2_h;
            default             : cmi_31_28_d_h <= 4'bxxxx;
        endcase
    end

    /* Encode function and byte enables for CMI */
    assign cmi_d_h[31:28] =  prefetch_cycle_h ? 4'b1111 : cmi_31_28_d_h;
    assign cmi_d_h[27]    = ~prefetch_cycle_h & write_dec_h;
    assign cmi_d_h[26]    = ~prefetch_cycle_h & (
        latched_bus_h == `UC_BUS_READ_MOD |
        latched_bus_h == `UC_BUS_READ_LNG_MOD |
        latched_bus_h == 5'h04);
    assign cmi_d_h[25]    = ~prefetch_cycle_h & lock_h;
    assign lock_h = (
         latched_bus_h == `UC_BUS_READ_MOD_LCK |
        (latched_bus_h == `UC_BUS_WRITE_UL & suppress_lock_h ) |
         latched_bus_h == `UC_BUS_WRITE_UL_SEC );

    assign cmi_out_h[31:28] = ena_func_h ? cmi_d_h[31:28] : 4'b1111;
    assign cmi_out_h[27:25] = ena_func_h ? cmi_d_h[27:25] : 3'b111;

    assign suppress_lock_h =  
		mad_h[1] & mad_h[0] & latched_dsize_h[0] |
        latched_dsize_h[1] & ( |mad_h );

    assign dbbz_out_l = ~ena_func_h;
    assign hold_out_l = ~(snapshot_cmi_h & ~inval_write_h);

    assign st_out_l        = write_vector_h ? 2'b00 : 2'b11;


    assign read_lock_inhibit_h = lock_set_h & latched_bus_h == `UC_BUS_READ_MOD_LCK;

    /*
	  * Whether the bus is ours to take: not HOLD, not BUSY (local or remote),
	  * not RESET, not being arbitrated away from us and not locked.
	  */
    assign cmi_request_h = hold_l & dbbz_l & ~cmi_ena_h & mseq_init_l &
         ~cmi_cpu_priority_l & ~read_lock_inhibit_h;

    /* Whether the current bus transaction is a read */
    wire _rd_d_h = ~prefetch_l | latched_bus_h == 5'h04 | read_dec_h;
    `LATCH_P( add_reg_ena_h, _rd_d_h, read_h )

	 /* Inhibit BUSY phase if:
	        ucode write cycle and operation is UC_BUS_GRANT, or
			  CMI disabled, or,
			  Cache hit on unlocked read */
    assign inhibit_busy_h =
			prefetch_l & ( latched_bus_h == `UC_BUS_GRANT | d_clk_en_h | m_clk_en_h ) | 
         inhibit_cmi_h | 
			read_h & ~read_lock_h & hit_h;

    /* The BUSY flop indicates we are waiting to start a bus transaction, and is set by ARE */
    wire _bs_j_h = ~inhibit_busy_h & add_reg_ena_h;         // Start BUSY H phase if ARE
    wire _bs_k_h = cmi_in_prog_h | mseq_init_h | timeout_h; // End   BUSY H if timeout, reset or CMI IN PROGRESS?
    `JKFF_P( b_clk_l, _bs_j_h, _bs_k_h, busy_h)

	 /* Latch version of BUSY H */
    wire _lb_d_h = busy_h ? ~_bs_k_h : _bs_j_h;
    `LATCH_N( b_clk_l, _lb_d_h, latched_busy_h )
	 
	 /* CMI ENA flop */
    wire _ce_j_h = cmi_request_h & set_busy_h;              // Set when SET BUSY and arbitration won
    wire _ce_k_h = read_h | dbbz_l | mseq_init_h;           // Cleared when READ, SLAVE ACK or RESET
    `JKFF_P( b_clk_l, _ce_j_h, _ce_k_h, cmi_ena_h )
	 
	 /* Latch version of CMI ENA H */
    wire _cmi_en_d_h = cmi_ena_h ? (~dbbz_l & ~read_h) : _ce_j_h;
    `LATCH_N( b_clk_l, _cmi_en_d_h, cmi_enable_h )

    assign set_busy_h    = cmi_ena_h & latched_busy_h;
    assign set_ena_cmi_h = cmi_request_h | cmi_enable_h;
    assign ena_cmi_l     = ~(set_ena_cmi_h & set_busy_h);
	 
	 /* CMI setup cycle flop, indicating this is the address/function code cycle */
    wire _ef_d_h  = set_busy_h & set_ena_cmi_h & dbbz_l;     // Set when SET BUSY, SET ENA CMI and bus idle (first cycle)
    `FF_P( b_clk_l, _ef_d_h , ena_func_h )

	 /* CMI cycle in progress flop. */
    wire _cip_j_h = set_busy_h & set_ena_cmi_h;            // Set by SET BUSY if 
    wire _cip_k_h = dbbz_l | mseq_init_h;                  // Cleared by deassertion of DBBZ (slave ack)
    `JKFF_P( b_clk_l, _cip_j_h, _cip_k_h, cmi_in_prog_h )
	 
	 /* transaction is busy and DBBZ assserted: final cycle of the CMI transaction */
    assign final_cyc_dec_h = cmi_in_prog_h & dbbz_l;
    
    wire _sv_d_h = (
		( inhibit_busy_h | add_reg_ena_l ) & ( add_reg_ena_h & reset_add_ena_h | final_cyc_dec_h | timeout_h )) | 
		mseq_init_h;

    `FF_P( b_clk_l, _sv_d_h, status_valid_h )
    assign status_valid_l = ~( b_clk_h & _sv_d_h | status_valid_h );
    
	 
	 

    assign grant_stall_l = ~( latched_bus_h == `UC_BUS_GRANT & 
        ((prefetch_l & busy_h & mseq_init_l) |
        (~phase_1_h & ~syn_int_done_h & ~write_vector_h & mseq_init_l )));
    
    assign snapshot_cmi_l = ~snapshot_cmi_h;
    assign write_vect_occ_l = ~write_vector_h;
    

    reg toggleflop_h;
    `FF_PRESET_P( b_clk_l, mseq_init_h, ~toggleflop_h, toggleflop_h )

    assign timeout_clk_h = ~b_clk_l & toggleflop_h;
    assign timeout_h = (~toggleflop_h) & &timeout_counter_h;
    wire timeout_en_h = (lock_set_h & busy_h) | (latched_bus_h == 5'h04);
    `FF_EN_P( timeout_clk_h, timeout_en_h, timeout_counter_h + 8'h01, timeout_counter_h )

	 /* High if this was an incoming address cycle (cache invalidation on DMA) */
    assign add_cyc_h = ~dbbz_l & ~dbbz_del_h & mseq_init_l;
	 
	 /* SNAPSHOT CMI flop is set when the incoming cycle was a (DMA) write */
    wire _sc_j_h = add_cyc_h & ~cmi_in_prog_h & cmi_h[27] & ~cmi_h[26];
    wire _sc_k_h = inval_write_h | mseq_init_h;
    `JKFF_P( b_clk_h, _sc_j_h, _sc_k_h, snapshot_cmi_h )

    wire _ls_j_h = add_cyc_h & ~cmi_in_prog_h & cmi_h[27:25] == `CMI_FUNC_RD_LOCK;
    wire _ls_k_h = add_cyc_h & cmi_h[27:25] == `CMI_FUNC_WR_UNLK | mseq_init_h | timeout_h;
    `JKFF_P( b_clk_h, _ls_j_h, _ls_k_h, lock_set_h)

    wire _st1_d_h = ~st_l[1] | ~final_cyc_dec_h;
    wire _st1_r_h = timeout_h | ~cache_int_l & ( status_valid_h | b_clk_l );
    `FF_PRESET_RESET_EN_P( b_clk_h, mseq_init_h, _st1_r_h, status_valid_l, _st1_d_h, status_h[1] )
	 
    wire _st0_d_h = ~st_l[0] | ~final_cyc_dec_h;
    `FF_RESET_EN_P( b_clk_h, mseq_init_h, status_valid_l, _st0_d_h, status_h[0] )


    assign mem_req_h = ( prefetch_del_h | 
        (bus_cyc_dec_h & prefetch_l & ~replacement_h)) &
        ~busy_h & ~cmi_in_prog_h;
    
    assign replacement_h = status_valid_h & ~add_ena_del_h & read_h;

    //XXX: stolen from CAK as it was missing from CMK
    `FF_PRESET_P( b_clk_l, prefetch_del_h, prefetch_del_h, prefetch_cycle_h  )
    
    wire _are_j_h = mem_req_h & ~inval_check_h;
    `JKFF_P( b_clk_l, _are_j_h, reset_add_ena_h, add_reg_ena_h )

    `FF_P( b_clk_l, add_reg_ena_h, add_ena_del_h )

    `FF_RESET_P( b_clk_l, prefetch_l, ~prefetch_l, prefetch_del_h )

    assign enable_inval_h = ~mmux_sel_s1_h & ( ~mem_req_h | add_reg_ena_h & reset_add_ena_h );
    assign reset_add_ena_h = prefetch_cycle_h | m_clk_en_h;

    wire _ivc_j_h = enable_inval_h & snapshot_cmi_h;
    wire _ivc_k_h = snapshot_cmi_l;
    `JKFF_P( b_clk_l, _ivc_j_h, _ivc_k_h, inval_check_h )

    wire _ivw_r_h = inval_check_h;
    `FF_RESET_P( b_clk_l, _ivw_r_h,  inval_check_h, inval_write_h )
    wire _wv_d_h = timeout_h | wr_vect_latch_h;
    `FF_P( b_clk_l, _wv_d_h, write_vector_h )

    wire _wvl_d_h = add_cyc_h & cmi_h[27] & cmi_h[26] & ~cmi_h[25];
    `LATCH_P( b_clk_l, _wvl_d_h, wr_vect_latch_h )

    wire _cdi_j_h = status_h[1] & ~status_h[0] & status_valid_h;
    `JKFF_P( b_clk_l, _cdi_j_h, m_clk_en_h, corr_data_int_h )

    wire _dbd_d_h = ~dbbz_l & mseq_init_l;

    `FF_P( b_clk_l, _dbd_d_h, dbbz_del_h )

    wire _sid_d_h = ~wait_h & ~int_grant_h & int_latch_h;
    `FF_P( b_clk_l, _sid_d_h, syn_int_done_h )

    always @ ( int_grant_h or phase_1_h ) begin
        if ( int_grant_h )
            int_latch_h <= 1'b1;
        else if ( phase_1_h )
            int_latch_h <= 1'b0;
    end



endmodule