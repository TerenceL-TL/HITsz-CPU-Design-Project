`timescale 1ns / 1ps

`include "defines.vh"

module ifetch(
    input wire clk,
    input wire rst,
    input wire [31:0] offset,
    input wire [31:0] jal_npc,   // for jirl
    input wire [31:0] wb_pc,   
    input wire br,
    input wire [2:0] npc_op,
    output wire [31:0] pc4,
    output wire [31:0] pc,       // Current instruction address
    output wire        jump_en,
`ifdef RUN_TRACE
    output wire [15:0]  inst_addr
`else
    output wire [13:0]  inst_addr // Output instruction address slice for IROM
`endif
);

    // NPC inputs and outputs
    wire [31:0] NPC_npc;         // Next instruction address
    wire [31:0] npc;         // Next instruction address

    // Instantiate NPC module
    NPC npc_inst (
        .wb_pc(wb_pc),
        .offset(offset),
        .jal_npc(jal_npc),
        .br(br),
        .npc_op(npc_op),
        .npc(NPC_npc),
        .jump_en(jump_en)
    );

    PC pc_inst (
        .clk(clk),
        .rst(rst),
        .din(npc),
        .pc(pc)
    );

    assign pc4 = pc + 4;

    assign npc = jump_en ? NPC_npc : pc4;

`ifdef RUN_TRACE
    assign inst_addr = pc[17:2];
`else
    assign inst_addr = pc[15:2];
`endif 

endmodule
