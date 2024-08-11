`timescale 1ns / 1ps

`include "defines.vh"

module controller(
    input wire [31:0] inst,

    output reg [2:0]  npc_op,

    output reg [1:0]  rf_wsel,
    output reg        rf_wrsel,   
    output reg        rf_we,
    output reg        rf2_sel,
    output reg [2:0]  sext_op,  

    output reg [2:0]  lext_op,

    output reg [3:0]  alu_op,
    output reg        alua_sel,
    output reg        alub_sel,
    output reg        ram_we,
    output reg [1:0]  wb_op
    );

    // Opcode and function extraction 
    wire [5:0] opcode = inst[31:26];
    wire       funct1 = inst[25];
    wire [2:0] funct3 = inst[24:22];
    wire [6:0] funct7 = inst[21:15];


    // ALU_OP
    always @(*) begin
        case (opcode)
            6'b000000: begin  // arthimatical op
                if (funct1 == 1'b0) begin
                    alu_op = (funct7 == 7'b0100000) ? `ALU_ADD :
                             (funct7 == 7'b0100010) ? `ALU_SUB :
                             (funct7 == 7'b0101001) ? `ALU_AND :
                             (funct7 == 7'b0101010) ? `ALU_OR  :
                             (funct7 == 7'b0101011) ? `ALU_XOR :
                             (funct7 == 7'b0101110) ? `ALU_SLL :
                             (funct7 == 7'b0101111) ? `ALU_SRL :
                             (funct7 == 7'b0110000) ? `ALU_SRA :
                             (funct7 == 7'b0100100) ? `ALU_SLT :
                             (funct7 == 7'b0100101) ? `ALU_SLTU:
                             (funct7 == 7'b0000001) ? `ALU_SLL :
                             (funct7 == 7'b0001001) ? `ALU_SRL :
                             (funct7 == 7'b0010001) ? `ALU_SRA :
                             4'b0000;

                end else begin
                    alu_op = (funct3 == 3'b010) ? `ALU_ADD : 
                             (funct3 == 3'b101) ? `ALU_AND : 
                             (funct3 == 3'b110) ? `ALU_OR  : 
                             (funct3 == 3'b111) ? `ALU_XOR : 
                             (funct3 == 3'b000) ? `ALU_SLT : 
                             (funct3 == 3'b001) ? `ALU_SLTU: 
                             4'b0000;
                end
            end
            6'b001010: alu_op = `ALU_ADD;
            6'b000111: alu_op = `ALU_ADD;
            6'b010110: alu_op = `ALU_SUB;
            6'b010111: alu_op = `ALU_SUB;
            6'b011000: alu_op = `ALU_SLT;
            6'b011010: alu_op = `ALU_SLTU;
            6'b011001: alu_op = `ALU_SLT;
            6'b011011: alu_op = `ALU_SLTU;
            6'b010011: alu_op = `ALU_ADD;
            default: alu_op = 4'b0000;
        endcase
    end

    // NPC_OP
    always @(*) begin
        case (opcode)
            6'b000000: npc_op = `NPC_PC4;
            6'b001010: npc_op = `NPC_PC4;
            6'b000101: npc_op = `NPC_PC4;
            6'b000111: npc_op = `NPC_PC4;  // Normal
            6'b010110: npc_op = `NPC_BEQ;  // beq
            6'b010111: npc_op = `NPC_BNE;  // bne
            6'b011000: npc_op = `NPC_BEQ;  // blt
            6'b011010: npc_op = `NPC_BEQ;  // bltu
            6'b011001: npc_op = `NPC_BNE;  // bge
            6'b011011: npc_op = `NPC_BNE;  // bgeu
            6'b010011: npc_op = `NPC_JAL;  // jirl
            6'b010100: npc_op = `NPC_BL;   // b
            6'b010101: npc_op = `NPC_BL;   // bl
            default: npc_op = 2'b00;
        endcase
    end

    // RF_WSEL
    always @(*) begin
        case (opcode)
            6'b000000: rf_wsel = `RFW_ALUC;
            6'b001010: rf_wsel = `RFW_DRAM;
            6'b000101: rf_wsel = `RFW_SEXT;
            6'b000111: rf_wsel = `RFW_ALUC;  // Normal
            6'b010011: rf_wsel = `RFW_NPC;   // jirl
            6'b010101: rf_wsel = `RFW_NPC;   // bl
            default: rf_wsel = 2'b00;
        endcase
    end

    // RF_WRSEL
    always @(*) begin
        case (opcode)
            6'b010101: rf_wrsel = `RFWR_J;   // bl
            default: rf_wrsel = `RFWR_N;
        endcase
    end

    // rf_we
    always @(*) begin
        case (opcode)
            6'b001010: rf_we = (funct3 == 3'b100) ? 1'b0 : 
                               (funct3 == 3'b101) ? 1'b0 :
                               (funct3 == 3'b110) ? 1'b0 : 1'b1;
            6'b010110: rf_we = 1'b0;  // beq
            6'b010111: rf_we = 1'b0;  // bne
            6'b011000: rf_we = 1'b0;  // blt
            6'b011010: rf_we = 1'b0;  // bltu
            6'b011001: rf_we = 1'b0;  // bge
            6'b011011: rf_we = 1'b0;  // bgeu
            6'b010100: rf_we = 1'b0;  // b
            default: rf_we = 1'b1;
        endcase
    end

    // rf2_sel
    always @(*) begin
        if (opcode == 6'b000000 & funct3 == 3'b000) rf2_sel = `RF2_RK;
        else rf2_sel = `RF2_RD; 
    end

    // sext_op
    always @(*) begin
        // Default value
        sext_op = `EXT_I12;
        case (opcode)
            6'b000000: begin 
                if (funct1 == 1'b0) sext_op = `EXT_I5;
                else sext_op = (funct3[2] == 1'b0) ?  `EXT_I12 : `EXT_I12U;
            end
            6'b001010: sext_op = `EXT_I12; // load and store
            6'b000101: sext_op = `EXT_I20; // LU21I instruction
            6'b000111: sext_op = `EXT_I20; // pcaddu12i instruction
            6'b010110: sext_op = `EXT_I16;  // beq
            6'b010111: sext_op = `EXT_I16;  // bne
            6'b011000: sext_op = `EXT_I16;  // blt
            6'b011010: sext_op = `EXT_I16;  // bltu
            6'b011001: sext_op = `EXT_I16;  // bge
            6'b011011: sext_op = `EXT_I16;  // bgeu
            6'b010011: sext_op = `EXT_I16;
            6'b010100: sext_op = `EXT_I26;
            6'b010101: sext_op = `EXT_I26; // Branch and Jump instructions
        endcase
    end

    always @(*) begin
        // Default value
        lext_op = `LEXT_32;
        case (opcode)
            6'b001010: begin // Load instructions
                case (funct3)
                    3'b000: lext_op = (funct1 == 1'b0) ? `LEXT_8 : `LEXT_8U;
                    3'b001: lext_op = (funct1 == 1'b0) ? `LEXT_16 : `LEXT_16U;
                    3'b010: lext_op = `LEXT_32;
                endcase
            end
        endcase
    end

    always @(*) begin
        // Default value
        alua_sel = `ALUA_RD1;
        case (opcode)
            6'b000111: alua_sel = `ALUA_PC; // pcaddu12i instruction
            default: alua_sel = `ALUA_RD1;
        endcase
    end

    always @(*) begin
        // Default value
        alub_sel = `ALUB_RD2;
        case (opcode)
            6'b000000: begin 
                if (funct1 == 1'b1) alub_sel = `ALUB_SEXT;
                else if (funct3 == 3'b001) alub_sel = `ALUB_SEXT;
                else alub_sel = `ALUB_RD2;
            end
            6'b001010: alub_sel = `ALUB_SEXT; // Load and Store instructions
            6'b000111: alub_sel = `ALUB_SEXT; // pcaddu12i instruction
            6'b010011: alub_sel = `ALUB_SEXT; // jirl
        endcase
    end
    
    always @(*) begin
        if (opcode == 6'b001010 & funct3[2] == 1'b1) ram_we = `RAM_WRITE;
        else ram_we = `RAM_READ;
    end

    always@(*) begin 
        case(funct3)
            3'b100: wb_op = `WB_BYTE;
            3'b101: wb_op = `WB_HEX;
            3'b110: wb_op = `WB_WORD;
        endcase
    end

endmodule
