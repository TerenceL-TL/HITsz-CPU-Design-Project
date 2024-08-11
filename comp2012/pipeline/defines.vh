// Annotate this macro before synthesis
//`define RUN_TRACE

// NPC:
`define NPC_PC4   3'b000
`define NPC_BEQ   3'b001
`define NPC_BNE   3'b010
`define NPC_JAL   3'b011
`define NPC_BL    3'b100

// SEXT:
`define EXT_I5    3'b000
`define EXT_I12   3'b001
`define EXT_I12U  3'b010
`define EXT_I20   3'b011 
`define EXT_I16   3'b100
`define EXT_I26   3'b101

// LEXT
`define LEXT_8U   3'b000
`define LEXT_8    3'b001
`define LEXT_16U  3'b010
`define LEXT_16   3'b011 
`define LEXT_32   3'b100

// RF2_SEL
`define RFW_ALUC  2'b00
`define RFW_DRAM  2'b01
`define RFW_SEXT  2'b10
`define RFW_NPC   2'b11

// RFW_RSEL
`define RFWR_N  1'b0
`define RFWR_J  1'b1

// RF_WSEL
`define RF2_RK    1'b0
`define RF2_RD    1'b1

// ALU_SEL
`define ALUA_RD1  1'b0
`define ALUA_PC   1'b1
`define ALUB_RD2  1'b0
`define ALUB_SEXT 1'b1

// ALU_OP
`define ALU_ADD   4'b0000
`define ALU_OR    4'b0001
`define ALU_AND   4'b0010
`define ALU_SUB   4'b0110
`define ALU_XOR   4'b0101
`define ALU_SLL   4'b1000
`define ALU_SRL   4'b1010
`define ALU_SRA   4'b1011
`define ALU_SLT   4'b1100
`define ALU_SLTU  4'b1101

// RAM_WE
`define RAM_READ    1'b0
`define RAM_WRITE   1'b1

// Write back op
`define WB_BYTE  2'b00
`define WB_HEX   2'b01
`define WB_WORD  2'b10

// 外设I/O接口电路的端口地�?
`define PERI_ADDR_DIG   32'hFFFF_F000
`define PERI_ADDR_LED   32'hFFFF_F060
`define PERI_ADDR_SW    32'hFFFF_F070
`define PERI_ADDR_BTN   32'hFFFF_F078
