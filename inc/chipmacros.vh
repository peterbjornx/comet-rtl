


`define RSFF( Preset, Reset, Out) \
	always @ ( Reset or Preset ) \
		begin \
			if( Reset == 1'b1 ) \
				Out <= 1'b0; \
			else if( Preset == 1'b1 ) \
				Out <= 1'b1; \
		end   

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

`define FF_P(Clk, Data, Out) \
	always @ ( posedge Clk )        \
		Out <= Data;      

`define FF_N(Clk, Data, Out) \
	always @ ( negedge Clk )        \
		Out <= Data;      

`define JKFF_P( Clk, J, K, Q ) \
	always @ ( posedge Clk ) \
		case ( { J, K } ) \
			2'b00 :  Q <=  Q; \
			2'b01 :  Q <=  0; \
			2'b10 :  Q <=  1; \
			2'b11 :  Q <= ~Q; \
		endcase

`define JKFF_N( Clk, J, K, Q ) \
	always @ ( negedge Clk ) \
		case ( { J, K } ) \
			2'b00 :  Q <=  Q; \
			2'b01 :  Q <=  0; \
			2'b10 :  Q <=  1; \
			2'b11 :  Q <= ~Q; \
		endcase

`define JKFF_RESET_P( Clk, Reset, J, K, Q ) \
	always @ ( posedge Reset or posedge Clk ) \
		casez ( { Reset, J, K } ) \
			3'b000 :  Q <=  Q; \
			3'b001 :  Q <=  0; \
			3'b010 :  Q <=  1; \
			3'b011 :  Q <= ~Q; \
			3'b1zz :  Q <=  0; \
		endcase

`define JKFF_RESET_N( Clk, Reset, J, K, Q ) \
	always @ ( posedge Reset or negedge Clk ) \
		casez ( { Reset, J, K } ) \
			3'b000 :  Q <=  Q; \
			3'b001 :  Q <=  0; \
			3'b010 :  Q <=  1; \
			3'b011 :  Q <= ~Q; \
			3'b1zz :  Q <=  0; \
		endcase

`define JKFF_PRESET_P( Clk, Preset, J, K, Q ) \
	always @ ( posedge Preset or posedge Clk ) \
		casez ( { Preset, J, K } ) \
			3'b000 :  Q <=  Q; \
			3'b001 :  Q <=  0; \
			3'b010 :  Q <=  1; \
			3'b011 :  Q <= ~Q; \
			3'b1zz :  Q <=  1; \
		endcase

`define FF_PRESET_P(Clk, Preset, Data, Out) \
	always @ ( posedge Clk or posedge Preset ) \
		begin \
		 if( Preset == 1'b1 ) \
		    Out <= 1'b1; \
		 else \
		    Out <= Data; \
		end    

`define FF_PRESET_N(Clk, Preset, Data, Out) \
	always @ ( negedge Clk or posedge Preset ) \
		begin \
			if( Preset == 1'b1 ) \
				Out <= 1'b1; \
			else \
				Out <= Data; \
		end    

`define FF_RESET_P(Clk, Reset, Data, Out) \
	always @ ( posedge Clk or posedge Reset ) \
		begin \
		 if( Reset == 1'b1 ) \
		    Out <= 1'b0; \
		 else \
		    Out <= Data; \
		end      

`define FF_RESET_N(Clk, Reset, Data, Out) \
	always @ ( posedge Clk or posedge Reset ) \
		begin \
			if( Reset == 1'b1 ) \
			Out <= 1'b0; \
			else \
			Out <= Data; \
		end      

`define FF_RESET_EN_P(Clk, Reset, En, Data, Out) \
	always @ ( posedge Clk or posedge Reset ) \
		begin \
		 if( Reset == 1'b1 ) \
		    Out <= 1'b0; \
		 else if (En) \
		    Out <= Data; \
		end   

`define FF_PRESET_RESET_EN_P(Clk, Preset, Reset, En, Data, Out) \
	always @ ( posedge Clk or posedge Reset or posedge Preset ) \
		begin \
			if( Reset == 1'b1 ) \
				Out <= 1'b0; \
			else if( Preset == 1'b1 ) \
				Out <= 1'b1; \
			else if (En) \
				Out <= Data; \
		end   

`define FF_RESET_SZ_EN_P(W, Clk, Reset, En, Data, Out) \
	always @ ( posedge Clk or posedge Reset ) \
		begin \
		 if( Reset == 1'b1 ) \
		    Out <= {W{1'b0}}; \
		 else if (En) \
		    Out <= Data; \
		end   
		
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
			default: Out <= { Width {1'bx} }; \
		endcase \
	end
	

/* Again, we avoid tri-state here and instead use logic HIGH as high-Z,
 * allowing for & to be used to combine them */
`define OPENDRAIN_DRV(Oe, Width, Out, Data) \
	always @ ( Data or Oe ) begin \
		case ( Oe ) \
			1'b0: Out <= { Width {1'b1} }; \
			1'b1: Out <= Data; \
			default: Out <= { Width {1'bx} }; \
		endcase \
	end