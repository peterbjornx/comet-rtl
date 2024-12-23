module alpbcd(
		input  [3:1] aluq_h,
		input        add_h,
		output [3:1] bcda_h );
		
	wire sub_h = ~add_h;

	wire CELL_11_13_OUT =
		~&aluq_h[3:2];
		
	assign bcda_h[1] = 
		~aluq_h[1];
		
	assign bcda_h[2] =
		(~(add_h &  aluq_h[2] & ~aluq_h[1] )) &
		(~(add_h & ~aluq_h[2] &  aluq_h[1] )) &
		(~(sub_h &  aluq_h[2] &  aluq_h[1] )) &
		(~(sub_h & ~aluq_h[2] & ~aluq_h[1] ));
		
	assign bcda_h[3] =
		(~(        ~aluq_h[1]              )) &
		(~(add_h &  aluq_h[3]              )) &
		(~(sub_h & CELL_11_13_OUT          ));
		
endmodule