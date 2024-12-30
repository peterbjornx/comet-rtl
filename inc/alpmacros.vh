/* One-hot selects for A multiplexer */
`define ALP_AMUX_NONE      4'b0000
`define ALP_AMUX_RBUS      4'b1000
`define ALP_AMUX_MBUS      4'b0100
`define ALP_AMUX_DREG      4'b0010
`define ALP_AMUX_PAD       4'b0001

/* One-hot selects for B multiplexer */
`define ALP_BMUX_NONE      3'b000
`define ALP_BMUX_RBUS      3'b100
`define ALP_BMUX_QREG      3'b010
`define ALP_BMUX_SMUX      3'b001

/* One-hot selects for Q multiplexer */
`define ALP_QMUX_NONE      4'b0000
`define ALP_QMUX_WMUX      4'b1000
`define ALP_QMUX_SHL       4'b0100
`define ALP_QMUX_SHR       4'b0010
`define ALP_QMUX_AMUX      4'b0001

/* One-hot selects for W multiplexer */
`define ALP_WMUX_NONE      5'b00000
`define ALP_WMUX_BCDA      5'b10000
`define ALP_WMUX_BMUX      5'b01000
`define ALP_WMUX_ASHL      5'b00100
`define ALP_WMUX_ASHR      5'b00010
`define ALP_WMUX_ALUQ      5'b00001
