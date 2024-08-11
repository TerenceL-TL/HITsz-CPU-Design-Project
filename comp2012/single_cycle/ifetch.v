`timescale 1ns / 1ps

`include "defines.vh"

module ifetch(
    input wire clk,
    input wire rst,
    input wire [31:0] offset,
    input wire [31:0]  jal_npc,   // for jirl
    input wire br,
    input wire [2:0] npc_op,
    output wire [31:0] pc4,
`ifdef RUN_TRACE
    output wire [15:0]  inst_addr
`else
    output wire [13:0]  inst_addr // Output instruction address slice for IROM
`endif
);

    // NPC inputs and outputs
    wire [31:0] pc;              // Current instruction address
    wire [31:0] NPC_npc;         // Next instruction address

    // Instantiate NPC module
    NPC npc_inst (
        .pc(pc),
        .offset(offset),
        .jal_npc(jal_npc),
        .br(br),
        .npc_op(npc_op),
        .npc(NPC_npc),
        .pc4(pc4)
    );

    PC pc_inst (
        .clk(clk),
        .rst(rst),
        .din(NPC_npc),
        .pc(pc)
    );

`ifdef RUN_TRACE
    assign inst_addr = pc[17:2];
`else
    assign inst_addr = pc[15:2];
`endif 

endmodule
