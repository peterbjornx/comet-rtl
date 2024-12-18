`define LATCH_P(Clk,Data,Out) \
	always @ ( Clk or Data )  \
		if ( Clk )            \
			Out <= Data;      
			
`define LATCH_N(Clk,Data,Out) \
	always @ ( Clk or Data )  \
		if ( !Clk )           \
			Out <= Data;      

`define FF_EN_P(Clk, En, Data, Out) \
	always @ ( posedge Clk )        \
		if ( En )                   \
			Out <= Data;      

`define FF_EN_N(Clk, En, Data, Out) \
	always @ ( negedge Clk )        \
		if ( En )                   \
			Out <= Data;  

`define MUX2(Sel, Out, Ain, Bin) \
	always @ ( Ain or Bin or Sel ) begin \
		case ( Sel ) \
			1'b0: Out <= Ain; \
			1'b1: Out <= Bin; \
		endcase \
	end

`define NAND( a ) (~&(a))
`define INV( a )  (~(a))

/* Again, we avoid tri-state here and instead use logic HIGH as high-Z,
 * allowing for & to be used to combine them */
 
`define TRISTATE_DRV(Oe, Width, Out, Data) \
	always @ ( Data or Oe ) begin \
		case ( Oe ) \
			1'b0: Out <= { Width {1'b1} }; \
			1'b1: Out <= Data; \
		endcase \
	end
	

/* Again, we avoid tri-state here and instead use logic HIGH as high-Z,
 * allowing for & to be used to combine them */
`define OPENDRAIN_DRV(Oe, Width, Out, Data) \
	always @ ( Data or Oe ) begin \
		case ( Oe ) \
			1'b0: Out <= { Width {1'b1} }; \
			1'b1: Out <= Data; \
		endcase \
	end