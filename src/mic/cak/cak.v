`include "chipmacros.vh"
`include "ucodedef.vh"

module dc627_cak(
    input b_clk_l,
    input d_clk_en_h,
    input m_clk_en_h,
    input [1:0] d_size_h,
    input data_par_err_l,
    input dst_rmode_h,
    input io_address_l,
    input [4:0] bus_h,
    input [5:0] wctrl_h,
    input [1:0] mad_h,
    input mmux_sel_s1_h,
    input prefetch_l,
    input snapshot_cmi_l,
    input status_valid_l,
    input [1:0] tag_par_err_h,
    input [1:0] hit_h,
    output [1:0] hit_out_h,
    input [27:24] wbus_h,
    output [27:24] wbus_out_h,
    output       cache_int_l,
    output [1:0] cache_grp_wr_h,
    output [1:0] cache_valid_h,
    output [1:0] dbus_rot_h,
    output [3:0] ena_byte_l );

    reg       inval_check_h = 1'b0;
    wire      inval_check_l = ~inval_check_h;
    reg bus_cyc_dec_h;
    reg [1:0] par_err_h = 2'b0;
    reg       data_perr_h = 1'b0;
    reg       add_reg_ena_h = 1'b0;
    reg       add_ena_del_h = 1'b0;
    wire      size_latch_ena_h;
    reg [1:0] size_h = 2'b0;
    reg [1:0] latched_hit_h = 2'b0;
    reg [1:0] latched_ma_h = 2'b0;
    reg       prefetch_del_h = 1'b0;
    reg       prefetch_cyc_h = 1'b0;
    wire      prefetch_h = ~prefetch_l;
    wire      bus_grant_dec_h;
    wire      reset_add_ena_h;
    wire      ena_cache_err_h;
    wire      steer_tag_err_h;
    wire      steer_data_err_h;
    wire      ena_last_ref_h;
    wire      reset_tag_err_h;
    wire      reset_data_err_h;
    wire      tag_error_h;
    wire      data_error_h;
    wire      lost_error_h;
    wire      last_ref_hit_h;
    reg       read_h = 1'b0;
    reg       all_bytes_h = 1'b0;
    wire      ena_allocate_h;
    wire      ena_wbus_h;
    wire      cache_inval_h;
    wire      write_cache_h;
    reg       read_rot_dec_h = 1'b0;
    reg       latched_read_rot_h = 1'b0;
    reg       cyc_in_prog_h = 1'b0;
    reg       write_scnd_h = 1'b0;
    wire      mem_req_h;
    wire      replacement_h;
    wire      enable_inval_h;
    reg [1:0] inval_hit_h = 2'b0;
    reg [3:0] sc_add_h = 4'b0;
    reg       inval_write_h = 1'b0;
    wire      inval_write_l = ~inval_write_h;
    reg [3:0] cache_error_reg_h = 4'b0;
    reg [3:0] cache_ctl_h = 4'b0;
    reg       wr_cache_only_h = 1'b0;
    reg       status_val_h = 1'b0;
    reg       write_allocate_h = 1'b0;
    reg       replace_0_h = 1'b0;
    reg       phase1_h = 1'b0;
    reg       cache_int_h = 1'b0;
    
    wire [1:0] _hit_h = hit_h & hit_out_h;

    always @ ( bus_h ) begin
        case( bus_h )
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

    assign  bus_grant_dec_h = bus_h == `UC_BUS_GRANT;
    wire proc_init_h     = ~phase1_h & bus_h == `UC_BUS_PRINIT;
    wire write_if_not_rmode_h = ~dst_rmode_h & bus_h == `UC_BUS_WRITE_NOREG;


    `LATCH_P( add_reg_ena_h, tag_par_err_h, par_err_h )
    `LATCH_P( add_reg_ena_h, ~data_par_err_l, data_perr_h )
    `LATCH_P( add_reg_ena_h, _hit_h, latched_hit_h )
    `LATCH_P( add_reg_ena_h, mad_h, latched_ma_h )
    `LATCH_P( size_latch_ena_h, d_size_h, size_h )

    assign size_latch_ena_h = add_reg_ena_h & ~prefetch_del_h & 
        ( write_if_not_rmode_h | 
          bus_h == `UC_BUS_WRITE | bus_h == `UC_BUS_WRITE_LNG | bus_h == `UC_BUS_WRITE_UL );

    assign ena_cache_err_h = add_reg_ena_h & reset_add_ena_h & (
        prefetch_del_h | (d_clk_en_h & ~bus_grant_dec_h) );

    assign reset_add_ena_h = prefetch_cyc_h | m_clk_en_h;

    assign steer_tag_err_h = ena_cache_err_h & ( 
            tag_par_err_h[1] | 
            ( par_err_h[0] & hit_h[0] & read_h) |
            ( &latched_hit_h ));

    assign steer_data_err_h = ena_cache_err_h & data_perr_h & _hit_h[0] & read_h;

    assign ena_last_ref_h = ena_cache_err_h & ~prefetch_del_h;

    assign reset_tag_err_h = ~tag_error_h & b_clk_l;

    assign reset_data_err_h = ~data_error_h & b_clk_l;

    assign ena_wbus_h = ~phase1_h & sc_add_h[3:2] == 2'b01 & 
        wctrl_h == `UC_WCTRL_MEMSCR;

    assign cache_inval_h = wctrl_h == 6'h2D;
    
    assign write_cache_h = io_address_l & (
        (write_allocate_h & ena_allocate_h & ~inval_check_h) |
        (status_val_h & read_h & ~add_ena_del_h ) );
    
    wire _rd_d_h = prefetch_del_h | ~bus_h[3];
    `LATCH_P( add_reg_ena_h, _rd_d_h, read_h )

    assign ena_allocate_h = ( wr_cache_only_h | ~status_val_h ) & (
        ( &latched_hit_h | all_bytes_h | (size_h[1] & &latched_ma_h)));

    always @ ( add_reg_ena_h or bus_h or prefetch_h ) begin
        if ( add_reg_ena_h ) begin
            case ( bus_h )
                `UC_BUS_READ_PHY     : all_bytes_h <= 1'b1;
                `UC_BUS_WRITE_PHY    : all_bytes_h <= 1'b1;
                `UC_BUS_GRANT        : all_bytes_h <= 1'b1;
                `UC_BUS_READ_NT      : all_bytes_h <= 1'b1;
                `UC_BUS_READ_SEC     : all_bytes_h <= 1'b1;
                `UC_BUS_WRITE_LNG    : all_bytes_h <= 1'b1;
                `UC_BUS_WRITE_NT_LNG : all_bytes_h <= 1'b1;
                `UC_BUS_READ_LNG     : all_bytes_h <= 1'b1;
                `UC_BUS_READ_MOD     : all_bytes_h <= 1'b1;
                `UC_BUS_READ_LNG_MOD : all_bytes_h <= 1'b1;
                `UC_BUS_READ_MOD_LCK : all_bytes_h <= 1'b1;
                default: all_bytes_h <= prefetch_h;
            endcase
        end
    end
    always @ ( bus_h  ) begin
        case ( bus_h )
            `UC_BUS_READ:         read_rot_dec_h <= 1'b1;
            `UC_BUS_READ_MOD:     read_rot_dec_h <= 1'b1;
            `UC_BUS_READ_MOD_LCK: read_rot_dec_h <= 1'b1;
            `UC_BUS_READ_SEC:     read_rot_dec_h <= 1'b1;
            `UC_BUS_READ_NT:      read_rot_dec_h <= 1'b1;
            default:              read_rot_dec_h <= 1'b0;
        endcase
    end

    wire _d_clk_h = d_clk_en_h & ~b_clk_l;
    always @ ( posedge status_val_h or posedge _d_clk_h )
        if ( status_val_h )
            latched_read_rot_h <= 1'b0;
        else
            latched_read_rot_h <= read_rot_dec_h;

    wire _cip_reset_h = status_val_h | proc_init_h;
    always @ ( posedge add_reg_ena_h or posedge _cip_reset_h)
        if ( _cip_reset_h )
            cyc_in_prog_h <= 1'b0;
        else
            cyc_in_prog_h <= 1'b1;

    wire _wsh_h = bus_h == `UC_BUS_WRITE_SEC | bus_h == `UC_BUS_WRITE_UL_SEC;
    `LATCH_P( add_reg_ena_h, _wsh_h, write_scnd_h )

    assign mem_req_h = (prefetch_del_h | ( bus_cyc_dec_h & prefetch_l & ~replacement_h)) & 
        (add_reg_ena_h & ~cyc_in_prog_h);

    assign replacement_h = status_val_h & read_h & ~add_ena_del_h;
    assign enable_inval_h = ~mmux_sel_s1_h & (~mem_req_h | ( add_reg_ena_h & reset_add_ena_h ) );
    `LATCH_P( inval_write_l, _hit_h[0], inval_hit_h[0] )

    wire _scar_w_h = d_clk_en_h & wctrl_h == `UC_WCTRL_MEMSCAR_WB;
    `FF_EN_P( b_clk_l, _scar_w_h, wbus_h, sc_add_h ) // Was LATCH!

    wire _lost_error_h = (tag_error_h | data_error_h) & (steer_data_err_h | steer_tag_err_h);
    wire       _caer_w_h = d_clk_en_h & sc_add_h == 4'b0100 & wctrl_h == `UC_WCTRL_MEMSCR_WB;
    wire [3:0] _caer_d_h = _caer_w_h ? wbus_h : cache_error_reg_h & ~_caer_c_h | _caer_s_h;
    wire [3:0] _caer_s_h = {steer_tag_err_h, steer_data_err_h, _lost_error_h, ena_last_ref_h & _hit_h[0]};
    wire [3:0] _caer_c_h = {3'b0, ena_last_ref_h & ~_hit_h[0]};
    `FF_RESET_SZ_EN_P(4, b_clk_l, proc_init_h, 1'b1, _caer_d_h, cache_error_reg_h )
    assign tag_error_h = cache_error_reg_h[3];
    assign data_error_h = cache_error_reg_h[2];
    assign lost_error_h = cache_error_reg_h[1];
    assign last_ref_hit_h = cache_error_reg_h[0];

    wire _cgdr_w_h = d_clk_en_h & sc_add_h == 4'b0110 & wctrl_h == `UC_WCTRL_MEMSCR_WB;
    `FF_RESET_SZ_EN_P(4, b_clk_l, proc_init_h, _cgdr_w_h, wbus_h, cache_ctl_h )

    wire _wcor_w_h = d_clk_en_h & sc_add_h == 4'b1110 & wctrl_h == `UC_WCTRL_MEMSCR_WB;
    `FF_RESET_EN_P( b_clk_l, proc_init_h, _wcor_w_h, wbus_h[24], wr_cache_only_h )

    `FF_RESET_P ( b_clk_l, status_valid_l, ~status_valid_l, status_val_h )
    `FF_RESET_P ( b_clk_l, prefetch_l    , prefetch_h     , prefetch_del_h )
    `FF_PRESET_P( b_clk_l, prefetch_del_h, prefetch_del_h, prefetch_cyc_h  )
    
    wire _are_j_h = mem_req_h      & inval_check_l;
    wire _are_k_h = prefetch_cyc_h | m_clk_en_h; // TODO :  check
    `JKFF_P( b_clk_l, _are_j_h, _are_k_h, add_reg_ena_h )

    `FF_PRESET_P( b_clk_l, add_reg_ena_h, add_reg_ena_h, add_ena_del_h )

    wire _ic_j_h = ~snapshot_cmi_l & enable_inval_h;
    `JKFF_P( b_clk_l, _ic_j_h, snapshot_cmi_l, inval_check_h )

    `FF_RESET_P( b_clk_l, inval_check_l, inval_check_h, inval_write_h )

    wire _wa_j_h = ena_cache_err_h & ~read_h;
    wire _wa_k_h = inval_check_l   & ~ena_allocate_h; 
    `JKFF_P( b_clk_l, _wa_j_h, _wa_k_h, write_allocate_h )

    wire _ci_j_h = ena_cache_err_h & ( steer_tag_err_h | steer_data_err_h );
    `JKFF_RESET_P( b_clk_l, proc_init_h, _ci_j_h, m_clk_en_h, cache_int_h )

    wire _r0_d_h = cache_ctl_h[3] ? ~cache_ctl_h[2] : ~replace_0_h;
    `FF_PRESET_P( b_clk_l, proc_init_h, _r0_d_h, replace_0_h )

    `FF_P( b_clk_l, m_clk_en_h, phase1_h )

    assign hit_out_h = ~cache_ctl_h[1:0];

    reg [3:0] _wb_out_h;
    always @ (  sc_add_h or cache_ctl_h or cache_error_reg_h ) begin
        case( sc_add_h[1:0] )
            2'b00  : _wb_out_h <= cache_error_reg_h;
            2'b10  : _wb_out_h <= cache_ctl_h;
            default: _wb_out_h <= 4'b0000;
        endcase
    end

    assign wbus_out_h = ena_wbus_h ? _wb_out_h : 4'b1111;

    assign cache_int_l = ~cache_int_h;

    assign cache_grp_wr_h[1] = cache_inval_h | 
        ( inval_write_h & _hit_h[1]) |
        ( write_cache_h & ( latched_hit_h[1] | (replace_0_h & ~latched_hit_h[0])) );
    assign cache_grp_wr_h[0] = write_cache_h | 
        ( cache_inval_h & d_clk_en_h ) |
        ( inval_write_h & inval_hit_h[0] );

    assign cache_valid_h[1] = 
        ( ~cache_inval_h & inval_write_l ) & (
            (latched_hit_h[1] & ~latched_hit_h[0]) |
            (latched_hit_h[1] & ~replace_0_h) |
            (~latched_hit_h[0] & ~replace_0_h) ) ;

    assign cache_valid_h[0] = 
        ( ~cache_inval_h & inval_write_l ) & (
           ~par_err_h[0] | read_h | all_bytes_h | (
            size_h[1] & &(~latched_ma_h) )) ;
            
    wire ld_wdr_rot_h = wctrl_h == `UC_WCTRL_WDR_WB; //?

    assign dbus_rot_h[1] = 
        ( latched_ma_h[1] & ( latched_read_rot_h | read_rot_dec_h & d_clk_en_h ) ) |
        ( ( ld_wdr_rot_h & m_clk_en_h & ^mad_h) );

    assign dbus_rot_h[0] = 
        ( latched_ma_h[0] & ( latched_read_rot_h | read_rot_dec_h & d_clk_en_h ) ) |
        ( ( ld_wdr_rot_h & m_clk_en_h & mad_h[0]) ) |
        ( ( ~read_h | ~cyc_in_prog_h ) & (wctrl_h == 6'h26 || wctrl_h == 6'h27) ) ;
    
    assign ena_byte_l[3] = ~(
        all_bytes_h | ~write_allocate_h | 
        ~write_scnd_h & ( size_h[1] | &latched_ma_h | size_h[0] & latched_ma_h[1] ) );

    assign ena_byte_l[2] = ~(
        all_bytes_h | ~write_allocate_h | 
        ~write_scnd_h & ( 
            size_h[1] & ~latched_ma_h[1] |
            latched_ma_h == 2'b10  |
            latched_ma_h == 2'b01 & size_h[0] ) |
        write_scnd_h & 
            latched_ma_h == 2'b11 & size_h[1] );
    
    assign ena_byte_l[1] = ~(
        all_bytes_h | ~write_allocate_h | 
        ~write_scnd_h & latched_ma_h == 2'b10 & &size_h |
        write_scnd_h &  latched_ma_h[1] & size_h[1] );

    assign ena_byte_l[0] = ~(
        all_bytes_h | ~write_allocate_h | latched_ma_h == 2'b00 );
        
endmodule