`define AOP_A_SUB_B 4'b0000
`define AOP_A_ADD_B 4'b0100
`define AOP_A_AND_B 4'b1000
`define AOP_A_OR_B  4'b1001
`define AOP_B_SUB_A 4'b1100
`define AOP_A_XOR_B 4'b1101

`define AOP_BCD     4'b0001
`define AOP_SR      4'b0010
`define AOP_SL      4'b0011

/* DQ field <49:48> */

/* D&Q REG CONT FOR MUX/(M.R1, M.Q1, M.S, XM.R, XM.Q, XM.S, D.R1, D.Q1, D.S, Z.S, R.Q, R.S) */
`define UC_DQ1_NOP         2'b00   // NOP
`define UC_DQ1_Q_WX        2'b01   // Q <- WMUX
`define UC_DQ1_D_WX        2'b10   // D <- WMUX
`define UC_DQ1_Q_D_WX      2'b11   // Q <- WMUX      D <- WMUX

/* D&Q REG CONT FOR MUX/(M.R2, M.Q2, D.Q2) */
`define UC_DQ2_SQL         2'b00   // SHF Q LEFT
`define UC_DQ2_SQR         2'b01   // SHF Q RIGHT
`define UC_DQ2_SQL_D_WX    2'b10   // SHF Q LEFT     D <- WMUX
`define UC_DQ2_SQR_D_WX    2'b11   // SHF Q RIGHT    D <- WMUX

/* D&Q REG CONT FOR MUX/D.R2 */
`define UC_DQ3_SQL_D_WX    2'b00   // SHF Q LEFT     D <- WMUX
`define UC_DQ3_SQR_D_WX    2'b01   // SHF Q RIGHT    D <- WMUX

/* ALU / ALUOD field <53:50> */

/* ALU FUNCTION CONTROL FOR MUX/(M.R1, M.R2, M.Q1, M,Q2    */
/* M.S, XM.R, XM.Q, ZM.S, D.R1, D.Q1, D.Q2, D.S, R.Q, R.S) */

`define UC_ALU_SHF_SL      2'b11
`define UC_ALU_SHF_SR      2'b10
`define UC_ALU_SHF_NONE    2'b0?

`define UC_ALU_SUB         4'b0000 // SUB WITH CARRY INPUT
`define UC_ALU_SUB_BCD     4'b0001 // BCD SUB WITH CARRY INPUT
`define UC_ALU_SUB_SR      4'b0010 // (SUB WITH CARRY INPUT) SHIFTED RIGHT
`define UC_ALU_SUB_SL      4'b0011 // (SUB WITH CARRY INPUT) SHIFTED LEFT
`define UC_ALU_SUB_BA      4'b1100 // SUB WITH CARRY INPUT

`define UC_ALU_ADD         4'b0100 // ADD WITH CARRY INPUT
`define UC_ALU_ADD_BCD     4'b0101 // BCD ADD WITH CARRY INPUT
`define UC_ALU_ADD_SR      4'b0110 // (ADD WITH CARRY INPUT) SHIFTED RIGHT
`define UC_ALU_ADD_SL      4'b0111 // (ADD WITH CARRY INPUT) SHIFTED LEFT

`define UC_ALU_AND         4'b1000 // A.AND.B
`define UC_ALU_OR          4'b1001 // A.OR.B
`define UC_ALU_AND_SR      4'b1010 // (A.AND.B) SHIFTED RIGHT
`define UC_ALU_AND_SL      4'b1011 // (A.AND.B) SHIFTED LEFT
`define UC_ALU_XOR         4'b1101 // A.XOR.B
`define UC_ALU_ANDNOT      4'b1110 // A.AND.(.NOT.B)
`define UC_ALU_NOTAND      4'b1111 // (.NOT.A).AND.B

/* ALU FUNCTION CONTROL FOR MUX/(D.R2, Z.S) */
`define UC_ALU_AND_OD      4'b1000 // A.AND.B                OUTPUT DISABLE
`define UC_ALU_OR_OD       4'b1001 // A.OR.B                 OUTPUT DISABLE
`define UC_ALU_AND_SR_OD   4'b1010 // (A.AND.B) SHFTD RIGHT  OUTPUT DISABLE
`define UC_ALU_AND_SL_OD   4'b1011 // (A.AND.B) SHFTD LEFT   OUTPUT DISABLE
`define UC_ALU_SUB_BA_OD   4'b1100 // SUB WITH CARRY         OUTPUT DISABLE
`define UC_ALU_XOR_OD      4'b1101 // A.XOR.B                OUTPUT DISABLE
`define UC_ALU_ANDNOT_OD   4'b1110 // A.AND.(.NOT.B)         OUTPUT DISABLE
`define UC_ALU_NOTAND_OD   4'b1111 // (.NOT.A).AND.B         OUTPUT DISABLE

/* Mux field MUX/=<57:54> */

`define UC_MUX_M_R1              4'b0000 // A <- MBUS              B <- RBUS
`define UC_MUX_M_R2              4'b0001 // A <- MBUS              B <- RBUS
`define UC_MUX_M_Q1              4'b0010 // A <- MBUS              B <- Q REGISTER
`define UC_MUX_M_Q2              4'b0011 // A <- MBUS              B <- Q REGISTER
`define UC_MUX_M_S               4'b0100 // A <- MBUS              B <- SHIFTER
`define UC_MUX_XM_R              4'b0101 // A <- EXTENDED MBUS     B <- RBUS
`define UC_MUX_XM_Q              4'b0110 // A <- EXTENDED MBUS     B <- Q REGISTER
`define UC_MUX_XM_S              4'b0111 // A <- EXTENDED MBUS     B <- SHIFTER
`define UC_MUX_D_R1              4'b1000 // A <- D REGISTER        B <- RBUS
`define UC_MUX_D_R2              4'b1001 // A <- D REGISTER        B <- RBUS
`define UC_MUX_D_Q1              4'b1010 // A <- D REGISTER        B <- Q REGISTER
`define UC_MUX_D_Q2              4'b1011 // A <- D REGISTER        B <- Q REGISTER
`define UC_MUX_D_S               4'b1100 // A <- D REGISTER        B <- SHIFTER
`define UC_MUX_Z_S               4'b1101 // A <- 0                 B <- SHIFTER
`define UC_MUX_R_Q               4'b1110 // A <- RBUS              B <- Q REGISTER
`define UC_MUX_R_S               4'b1111 // A <- RBUS              B <- SHIFTER

/* ALPCTL Special functions <57:48> */
`define UC_ALPCTL_NOP            10'h364 // ALUOD/OR,MUX/Z.S,DQ1/NOP                  ;SETTING OF ALU FLAGS
`define UC_ALPCTL_WX_D_Q_Q_D     10'h2D7 // WMUX & D <- Q OLD      Q <- D OLD               D+Q+CI.BCD
`define UC_ALPCTL_WX_D_Q_Q_M     10'h0D7 // WMUX & D <- Q OLD      Q <- MBUS                M+Q+CI.BCD
`define UC_ALPCTL_WX_D_R_Q_D     10'h257 // WMUX & D <- RBUS       Q <- D OLD               D+R+CI.BCD
`define UC_ALPCTL_WX_D_R_Q_M     10'h057 // WMUX & D <- RBUS       Q <- MBUS                M+R+CI.BCD
`define UC_ALPCTL_WX_D_R_Q_XM    10'h157 // WMUX & D <- RBUS       Q <- S/Z MBUS           XM+R+CI.BCD
`define UC_ALPCTL_WX_D_S_Q_0     10'h357 // WMUX & D <- SUP ROT    Q <- 0                   0+S+ 0.BCD
`define UC_ALPCTL_WX_D_S_Q_R     10'h3D7 // WMUX & D <- SUP ROT    Q <- RBUS                R+S+ 0.BCD
`define UC_ALPCTL_WX_D_S_Q_XM    10'h1D7 // WMUX & D <- SUP ROT    Q <- S/Z MBUS           XM+S+ 0.BCD
`define UC_ALPCTL_WX_Q_Q_D       10'h2C7 // WMUX     <- Q OLD      Q <- D                   D-Q-CI.BCD
`define UC_ALPCTL_WX_Q_Q_M       10'h0C7 // WMUX     <- Q OLD      Q <- MBUS                M-Q-CI.BCD
`define UC_ALPCTL_WX_R_Q_D       10'h247 // WMUX     <- RBUS       Q <- D                   D-R-CI.BCD
`define UC_ALPCTL_WX_R_Q_M       10'h047 // WMUX     <- RBUS       Q <- MBUS                M-R-CI.BCD
`define UC_ALPCTL_WX_R_Q_XM      10'h147 // WMUX     <- RBUS       Q <- S/Z MBUS           XM-R-CI.BCD
`define UC_ALPCTL_WX_S_Q_0       10'h347 // WMUX     <- SUP ROT    Q <- O                   0-S- 0.BCD
`define UC_ALPCTL_WX_S_Q_R       10'h3C7 // WMUX     <- SUP ROT    Q <- RBUS                R-S- 0.BCD
`define UC_ALPCTL_WX_S_Q_XM      10'h1C7 // WMUX     <- SUP ROT    Q <- S/Z MBUS           XM-S- 0.BCD

`define UC_ALPCTL_WX_D_Q_S       10'h373 // WMUX & D & Q <- SUP ROT
`define UC_ALPCTL_WX_D_S         10'h372 // WMUX & D     <- SUP ROT
`define UC_ALPCTL_WX_Q_S         10'h371 // WMUX & Q     <- SUP ROT
`define UC_ALPCTL_WX_S           10'h370 // WMUX         <- SUP ROT
`define UC_ALPCTL_WX_D_Q__NOT_S  10'h363 // WMUX & D & Q <- .NOT.(SUP ROT)
`define UC_ALPCTL_WX_D__NOT_S    10'h362 // WMUX & D     <- .NOT.(SUP ROT)
`define UC_ALPCTL_WX_Q__NOT_S    10'h361 // WMUX & Q     <- .NOT.(SUP ROT)
`define UC_ALPCTL_WX__NOT_S      10'h360 // WMUX         <- .NOT.(SUP ROT)


`define UC_ALPCTL_WX_D_DSL_SQL   10'h24E // WMXU & D <- D SHF LEFT     Q <- SHF LEFT       (D-R-CI).SL
`define UC_ALPCTL_WX_D_DSL_SQR   10'h24F // WMXU & D <- D SHF LEFT     Q <- SHF RIGHT      (D-R-CI).SL
`define UC_ALPCTL_WX_D_DSR_SQL   10'h24A // WMXU & D <- D SHF RIGHT    Q <- SHF LEFT       (D-R-CI).SR
`define UC_ALPCTL_WX_D_DSR_SQR   10'h24B // WMXU & D <- D SHF RIGHT    Q <- SHF RIGHT      (D-R-CI).SR

`define UC_ALPCTL_WB_LOOPF       10'h378 // WB<31:3O> <- 0'LOOP FLAG
`define UC_ALPCTL_WB_LOOPF_Q_0   10'h379 // WB<31:3O> <- 0'LOOP FLAG   Q     <- 0
`define UC_ALPCTL_WB_LOOPF_D_0   10'h37A // WB<31:30> <- 0'LOOP FLAG   D     <- 0
`define UC_ALPCTL_WB_LOOPF_Q_D_0 10'h37B // WB<31:30> <- 0'LOOP FLAG   Q & D <- 0
`define UC_ALPCTL_WB_ALUF        10'h37C // WB<31:3O> <- ALUS0'ALKC
`define UC_ALPCTL_WB_ALUF_Q_S    10'h37D // WB<31:30> <- ALUS0'ALKC    Q     <- S
`define UC_ALPCTL_WB_ALUF_D_S    10'h37E // WB<31:30> <- ALUS0'ALKC    D     <- S
`define UC_ALPCTL_WB_ALUF_Q_D_S  10'h37F // WB<31:30> <- ALUS0'ALKC    Q &  D <- S

`define UC_ALPCTL_MULFASTP       10'h279 // MULTIPLY +RBUS BY Q (2 ITERATIONS PER CYCLE)
`define UC_ALPCTL_MULSLOWP       10'h27B // MULTIPLY +RBUS BY Q (1 ITERATION  PER CYCLE)
`define UC_ALPCTL_MULFASTN       10'h269 // MULTIPLY -RBUS BY Q (2 ITERATIONS PER CYCLE)
`define UC_ALPCTL_MULSLOWN       10'h26B // MULTIPLY -RBUS BY Q (1 ITERATION  PER CYCLE)
`define UC_ALPCTL_DIVFASTP       10'h26C // DIVIDE Q BY +RBUS (2 ITERATIONS PER CYCLE)
`define UC_ALPCTL_DIVSLOWP       10'h26E // DIVIDE Q BY +RBUS (1 ITERATION  PER CYCLE)
`define UC_ALPCTL_DIVFASTN       10'h27C // DIVIDE Q BY -RBUS (2 ITERATIONS PER CYCLE)
`define UC_ALPCTL_DIVSLOWN       10'h27E // DIVIDE Q BY -RBUS (1 ITERATION  PER CYCLE)
`define UC_ALPCTL_REM            10'h26A // UNSHIFT REMAINDER (RBUS MUST BE 0)
`define UC_ALPCTL_DIVDA          10'h27F // DIVIDE DOUBLE ADD
`define UC_ALPCTL_DIVDS          10'h26F // DIVIDE DOUBLE SUB

/* ALU CARRY INPUT CONTROL WHEN MUX DOES NOT SELECT S ROT AND P OR S LATCH IS NOT MODIFIED */
/* ALUCI/=<59:58> */
`define UC_ALUCI_ZERO             2'b00  // CI <- 0
`define UC_ALUCI_ALKC             2'b01  // CI <- ALK<C>
`define UC_ALUCI_ONE              2'b10  // CI <- 1
`define UC_ALUCI_PSLC             2'b11  // CI <- PSL<C>

/*ALUSHF/=<62:60> */
/* ALP SHIFT-IN CONTROL_WHEN MUX DOES NOT SELECT S ROT AND P OR S LATCH IS NOT MODIFIED */
/*                                       //  ALU      Q */
/* HARD DFFAULT                          //   0       0 */
`define UC_ALUSHF_ZERO            3'b000 //   0       0
`define UC_ALUSHF_ONE             3'b001 //   1       1
`define UC_ALUSHF_SHF             3'b010 //  (SHIFT ALU'Q)  (SEF TABLE 1)
`define UC_ALUSHF_ROT             3'b011 //  (ROT   ALU'Q)  (SEE TABLE 1)
`define UC_ALUSHF_ALU0_Q1         3'b100 //   0       1
`define UC_ALUSHF_ALU1_Q0         3'b101 //   1       0
`define UC_ALUSHF_WBUS30          3'b110 // WBUS<30> WBUS 30>
`define UC_ALUSHF_PSLC            3'b111 // PSL<C>   PSL<C>


/* SUPER ROTATOR CONTROL <63:58> */
`define UC_ROT_XZ_MR              6'h00 // EXTRACT & ZERO EXTEND_M'R, POS = PL, SIZE = SL  | SL.EQ.0        (PL<4:0>+SL).GT.32
`define UC_ROT_XZ_MM              6'h01 // EXTRACT & ZERO EXTEND M'M, POS = PL, SIZE = SL  | SL.EQ.0        (PL<4:0>+SL).GT.32
`define UC_ROT_XZ_RR              6'h02 // EXTRACT & ZERO EXTEND R'R, POS = PL, SIZE = SL  | SL.EQ.0        (PL<4:0>+SL).GT.32
`define UC_ROT_XZ_VPN             6'h0D // EXTRACT & ZERO EXTEND M'M, POS = 09, SIZE = 21  | DSIZE<1>       DSIZE<0>
`define UC_ROT_XZ_PTX             6'h0C // EXTRACT & ZERO EXTEND M'M, POS = 07, SIZE = 23  | DSIZE<1>       DSIZE<0>
`define UC_ROT_CLR1BM             6'h13 // CLR M<07:0>                                     | S<3:0>.NE.0    S<3:0>.NE.(11,13)
`define UC_ROT_CLR2BM             6'h12 // CLR M<15:0>                                     | S<3:0>.NE.0    S<3:0>.NE.(11,13)
`define UC_ROT_CLR3BM             6'h14 // CLR M<23:0>   

`define UC_ROT_RL_RM_P            6'h23 // ROT LEFT  R'M, NO. BITS = PLATCH<4:0>  (NOTE 1) | WX<31:16>.NE.0 WX<15:0>.NE.0
`define UC_ROT_RL_RM_PS           6'h20 // ROT LEFT  R'M, NO. BITS = (PL+SL)<4:0> (NOTE 1) | SL.EQ.0        UNDEFINED
`define UC_ROT_RL_RM_4            6'h08 // ROT LEFT  R'M, NO. BITS = 4                     | DSIZE<1>       DSIZE<0>
`define UC_ROT_RL_MM_P            6'h21 // ROT LEFT  M'M, NO. BITS = PLATCH                | SL.EQ.0        PL<5>
`define UC_ROT_RL_MM_PTE          6'h11 // ROT LEFT  M'M, NO. BITS = 9                     | S<3:0>.NE.0    S<3:0>.NE.(11,13)
`define UC_ROT_RL_RR_P            6'h22 // ROT LEFT  R'R, NO. BITS = PLATCH     

`define UC_ROT_RR_MR_P            6'h04 // ROT RIGHT M'R, NO. BITS = PLATCH<4:0>           | SL.EQ.0        (PL<4:0>+SL).GT.32
`define UC_ROT_RR_MR_PS           6'h24 // ROT_RIGHT M'R, NO. BITS = (PL+SL)<4:0>          | SL.EQ.0        (PL<4:0>+SL).GT.32
`define UC_ROT_RR_MR_4            6'h09 // ROT_RIGHT M'R, NO. BITS = 4                     | DSIZE<1>       DSIZE<0>
`define UC_ROT_RR_MR_S            6'h07 // ROT RIGHT M'R, NO. BITS = SLATCH<4:0>           |    0           PL<5>
`define UC_ROT_RR_MR_9            6'h0B // ROT RIGHT M'R, NO. BITS = 9                     | DSIZE<1>       DSIZE<0>
`define UC_ROT_RR_MM_P            6'h05 // ROT RIGHT M'M, NO. BITS = PLATCH                | SL.EQ.0        (PL<4:0>+SL).GT,32
`define UC_ROT_RR_MM_PS           6'h25 // ROT RIGHT M'M, NO. BITS = PLATCH+SLATCH         | SL,EQ.0        (PL<4:0>+SL),GT.32
`define UC_ROT_RR_MM_SIZ          6'h0E // ROT RIGHT M'M, NO. BITS = 8,16,24,0             | DSIZE<1>       DSIZE<0>
`define UC_ROT_RR_RR_P            6'h06 // ROT RIGHT R'R, NO. BITS = PLATCH                | SL.EQ.0        (PL<4:0>+SL),GT.32
`define UC_ROT_RR_RR_PS           6'h26 // ROT RIGHT R'R, NO. BITS = PLATCH+SLATCH         | SL.EQ.0        (PL<4:0>+SL).GT.32
`define UC_ROT_RR_RR_SIZ          6'h0A // ROT RIGHT R'R, NO. BITS = 8,16,24,0             | DSIZE<1>       DSIZE<0>
                                                
`define UC_ROT_ASL_R_P            6'h28 // ARITH SHF LEFT  R, NO. BITS = PLATCH (NOTE 2)   | PL<4:0>,EQ.0   PL<5>
`define UC_ROT_ASL_R_SIZ          6'h17 // ARITH SHF LEFT  R, NO. BITS = 0,1,2,3           | ASCII SIGN CHECK (SFF TABLE)
`define UC_ROT_ASL_R_7            6'h15 // ARITH SHF LEFT  R, NO. BITS = 7                 | ASCII SIGN CHECK (SEE TABLE)
`define UC_ROT_ASL_M_P            6'h29 // ARITH SHF LEFT  M, NO. BITS = PLATCH (NOTE 2)   | PL<4:0>.EQ.0   PL<5>
                                                
`define UC_ROT_ASR_M_P            6'h03 // ARITH SHF RIGHT M, NO. BITS = PLATCH            |     0          PL<5>
`define UC_ROT_ASR_M_NEG_P        6'h2A // ARITH SHF RIGHT M, NO. BITS = -PLATCH           | PL<4:0>.EQ.0   PL<5>
`define UC_ROT_ASR_M_3            6'h1D // ARITH SHF RIGHT M, NO. BITS = 3                 | ASCII SIGN_CHECK (SEE TABLE)
                                                
`define UC_ROT_GETNIB             6'h0F // GET LEAST SIGNIFICANT NIBBLE FR0M_MBUS          | DSIZE<1>       DSIZE<0>
`define UC_ROT_BCDSWP             6'h18 // BCD SWAP, MBUS                                  | S<3:0>.NE.0    S<3:0>.NE.(11,13)
`define UC_ROT_CVTPN              6'h1B // CONVERT PACKED TO NUMERIC, 4NIB TO 4BYTE, MBUS  | S<3:0>.NE.0    S<3:0>.NE.(11,13)
                                        // RBUS_MUST = 3XX33(HEX)                          |
`define UC_ROT_CVTNP              6'h1F // CONVERT_NUMERIC TO PACKED, 8BYTE TO 8NIB, M'P   | ASCII SIGN CHECK (SEE TABLE)
                                                                                  
`define UC_ROT_PL_MSS             6'h27 // FIND MOST SIGNIFICANT_BIT SET MBUS,WBUS         | WX<31:16>.NE.0 WX<15:0>.NE.0
`define UC_ROT_GETEXP             6'h10 // EXTRACT & ZERO EXTEND M'M POS = 7, SIZE = 8     | S<3:0>.NE.0    S<3:0>.NE.(11,13)
`define UC_ROT_GETFPF             6'h19 // UNPACK FLOATING POINT FRACTI0N, M'R             | S<3:0>.NE.0    S<3:0>.NE.(11,13)
`define UC_ROT_FPLIT              6'h1E // EXPAND FLOATING POINT LITERAL, MBUS             | ASCII SIGN CHECK (SEE TABLE)
`define UC_ROT_FPACK              6'h1A // S ROT<31:16,15,14:7,6:0> <-                     | S<3:0>.NE.0    S<3:0>.NE.(11,13)
                                        //  MB<24:9>,0,RB<7:0>,MB<31:25>                   |
`define UC_ROT_PL                 6'h2C // SUP ROT <- PLATCH                               | WBUS RANGE CHECK (SEE TABLE)
`define UC_ROT_SL                 6'h2E // SUP ROT <- SLATCH                               | WBUS RANGE CHECK (SEE TABLE)
`define UC_ROT_SL_PL_WB           6'h2F // S_ROT <- SLATCH . PLATCH  <- WB<5:0>            | WBUS RANGE CHECK (SEE TABLE)
`define UC_ROT_OLIT0_PL43_WB      6'h3F // S_ROT <- OLIT0 . PL<4:3> <- WB<1:0>             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_OLIT0_PL_LIT       6'h3B // S_ROT <- OLIT0 . PLATCH  <- SHORT LITERAL       | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_PL_SL_WB           6'h2D // S ROT <- PLATCH . SLATCH  <- WB<5:0>            | WBUS RANGE CHECK (SEE TABLE)
`define UC_ROT_OLIT0_SL_LIT       6'h3D // S_POT <- OLIT0 . SLATCH  <- SHORT LITERAL       | ABS VAL CHECK (SEE TABLE)
                                                
`define UC_ROT_ZERO               6'h16 // CONSTANT 0                                      | ASCII SIGN CHECK (SEE TABLE)
`define UC_ROT_MINUS1             6'h39 // CONSTANT -1                                     | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_CONX_SIZ           6'h1C // CONSTANT 1,2,4,8 DEPENDING ON SIZE(-(R)+)       | ASCII SIGN CHECK (SEE TABLE)
`define UC_ROT_ZLIT0              6'h30 // 0 EXTEND LITERAL & ROT LEFT 00 BITS             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_ZLIT4              6'h37 // 0 EXTEND LITERAL & ROT LEFT 04 BITS             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_ZLIT8              6'h36 // 0 EXTEND LITERAL & ROT LEFT 08 BITS             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_ZLIT12             6'h35 // 0 EXTEND LITERAL & ROT LEFT 12 BITS             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_ZLIT16             6'h34 // 0 EXTEND LITERAL & ROT LEFT 16 BITS             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_ZLIT20             6'h33 // 0 EXTEND LITERAL & ROT LEFT 20 BITS             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_ZLIT24             6'h32 // 0 EXTEND LITERAL & ROT LEFT 24 BITS             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_ZLIT28             6'h31 // 0 EXTEND LITERAL & ROT LEFT 28 BITS             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_ZLITPL             6'h2B // 0 EXTEND LITERAL & ROT LEFT PL BITS             | PL<4:0>.EQ.0    0
`define UC_ROT_OLIT0              6'h38 // 1 EXTEND LITERAL & ROT LEFT 00 BITS             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_OLIT8              6'h3E // 1 EXTEND LITERAL & ROT LEFT 08 BITS             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_OLIT16             6'h3C // 1 EXTEND LITERAL & ROT LEFT 16 BITS             | ABS VAL CHECK (SEE TABLE)
`define UC_ROT_OLIT24             6'h3A // 1 EXTEND LITERAL & ROT LEFT 24 BITS             | ABS VAL CHECK (SEE TABLE)
