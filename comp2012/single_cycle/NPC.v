`timescale 1ns / 1ps

`include "defines.vh"

module NPC(
    input wire [31:0] pc,       // Current inst_addr
    input wire [31:0] offset,   // offset of jumping
    input wire        br,       // 1 for jump, 0 for opposite 
    input wire [31:0] jal_npc,   // for jirl
    input wire [2:0]  npc_op,   // npc operation
    output reg [31:0] npc,      // Next inst_addr
    output reg [31:0] pc4       // pc + 4
    );

always @(*) begin
    case (npc_op)
        `NPC_PC4: npc = pc + 4;
        `NPC_BEQ: npc = (br == 1) ? (pc + offset) : (pc + 4);
        `NPC_BNE: npc = (br == 0) ? (pc + offset) : (pc + 4);
        `NPC_JAL: npc = jal_npc;
        `NPC_BL:  npc = pc + offset;
        default: npc = pc + 4;  // Default case to handle undefined npc_op values
    endcase
end

always @(*) begin
    pc4 = pc + 4;
end

endmodule

