`timescale 1ns / 1ps

`include "defines.vh"

module NPC(
    input wire [31:0] wb_pc,    // Current inst_addr
    input wire [31:0] offset,   // offset of jumping
    input wire        br,       // 1 for jump, 0 for opposite 
    input wire [31:0] jal_npc,  // for jirl
    input wire [2:0]  npc_op,   // npc operation
    output reg [31:0] npc,      // Next inst_addr
    output reg        jump_en   // sign to jump
    );

always @(*) begin
    case (npc_op)
        `NPC_PC4: npc = wb_pc + 4;
        `NPC_BEQ: npc = (br == 1) ? (wb_pc + offset) : (wb_pc + 4);
        `NPC_BNE: npc = (br == 0) ? (wb_pc + offset) : (wb_pc + 4);
        `NPC_JAL: npc = jal_npc;
        `NPC_BL:  npc = wb_pc + offset;
        default: npc = wb_pc + 4;  // Default case to handle undefined npc_op values
    endcase
end

always @(*) begin
    case (npc_op)
        `NPC_PC4: jump_en = 1'b0;
        `NPC_BEQ: jump_en = (br == 1);
        `NPC_BNE: jump_en = (br == 0); 
        `NPC_JAL: jump_en = 1'b1;
        `NPC_BL:  jump_en = 1'b1;
        default: jump_en = 1'b0;  // Default case to handle undefined npc_op values
    endcase
end



endmodule

