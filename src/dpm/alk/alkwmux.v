/*********************************************************************
 * Project: COMET / DEC VAX-11/750
 * Board:   DPM (Datapath module of CPU)
 * Chip:    DC615 ALK ( ALU Control )
 * FUB:     alkwmux (ALK WBUS output multiplexer)
 * Purpose: Readout of ALK internal flags
 * 
 * Changes: DeMorgan conversions, merge of wire-ANDed gates, merge of
 *          _h/_l versions of control signals.
 *
 * Author:  Unknown DEC engineer ( Original design )
 * Author:  Peter Bosch ( Reverse engineered from chip micrographs )
 ********************************************************************/
 `include "chipmacros.vh"
 
module alkwmux(
	input          alpctl_wb_aluf_h,
	input          alpctl_wb_loopf_h,
	input          alpctl_wb_group_ld,
	input          alkc_flag_h,
	input          aluso_flag_h,
	input          loop_flag_h,
	output reg [31:30] wbus_out_h );

	wire [31:30] wmux_l;
	wire [31:30] wmux_h = ~wmux_l;
	
	assign wmux_l[30] = ~(alkc_flag_h  & alpctl_wb_aluf_h  ) &
						~(loop_flag_h  & alpctl_wb_loopf_h );
						
	assign wmux_l[31] = ~(aluso_flag_h & alpctl_wb_aluf_h  );
	wire wmux_oe_h = ~ alpctl_wb_group_ld;
	`TRISTATE_DRV( wmux_oe_h, 2, wbus_out_h, wmux_h )
	
endmodule